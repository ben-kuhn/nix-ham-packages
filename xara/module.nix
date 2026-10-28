# NixOS module for xara, a VARA-compatible HF/FM software modem.
#
# A single host can run any number of independent xara instances (for example
# one per radio/band), each with its own config, TCP ports and audio devices.
# Instances run as system services by default, or as a systemd --user service
# when `user` is set (needed when audio comes from that user's PipeWire session).
{ config, lib, pkgs, ... }:

let
  cfg = config.services.xara;

  settingsType = lib.types.attrsOf (lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
  ]);

  # xara's config format is `key = value`, one per line, where keys are the
  # CLI flags without the leading `--`.  Switches accept yes/true/on.
  renderValue = v:
    if lib.isBool v then (if v then "yes" else "no")
    else toString v;

  renderSettings = settings:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${renderValue v}") settings)
    + "\n";

  mkConfigFile = name: icfg:
    if icfg.configFile != null then icfg.configFile
    else pkgs.writeText "xara-${name}.conf" (renderSettings icfg.settings);

  hasSystemInstances = lib.any (i: i.enable && i.user == null) (lib.attrValues cfg.instances);

  mkService = name: icfg: isUser:
    let
      configFile = mkConfigFile name icfg;
      preStart = lib.optionalString (icfg.preStart != "") (
        pkgs.writeShellScript "xara-${name}-pre" icfg.preStart
      );
      postStart = lib.optionalString (icfg.postStart != "") (
        pkgs.writeShellScript "xara-${name}-post" icfg.postStart
      );
      wantedBy =
        if icfg.wantedBy != [ ] then icfg.wantedBy
        else if isUser then [ "default.target" ]
        else [ "multi-user.target" ];
      after =
        if icfg.after != [ ] then icfg.after
        else if isUser then [ "pipewire.service" "wireplumber.service" ]
        else [ "network.target" "sound.target" ];
    in
    {
      description = icfg.description;
      inherit wantedBy after;
      wants = icfg.wants;
      bindsTo = icfg.bindsTo;
      partOf = icfg.partOf;
      path = icfg.path;
      environment = icfg.environment;
      unitConfig = lib.optionalAttrs isUser {
        ConditionUser = icfg.user;
      } // icfg.unitConfig;
      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [ "${cfg.package}/bin/xara" "--config" (lib.escapeShellArg "${configFile}") ]
          ++ lib.optionals (icfg.stateDir != null) [ "--state-dir" (lib.escapeShellArg icfg.stateDir) ]
          ++ map lib.escapeShellArg icfg.extraArgs
        );
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
      } // lib.optionalAttrs (preStart != "") {
        ExecStartPre = preStart;
      } // lib.optionalAttrs (postStart != "") {
        ExecStartPost = postStart;
      } // lib.optionalAttrs (icfg.stateDir == null) {
        StateDirectory = "xara/${name}";
      } // lib.optionalAttrs (!isUser) {
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = [ "audio" "dialout" "plugdev" ];
        ProtectSystem = "strict";
        ProtectHome = true;
      } // icfg.serviceConfig;
    };
in
{
  options.services.xara = {
    enable = lib.mkEnableOption "xara software modem services";

    package = lib.mkPackageOption pkgs "xara" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = "xara";
      description = ''
        User account under which system (non-`user`) instances run.  When left
        at the default, the module creates this user and the matching group.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "xara";
      description = "Group under which system (non-`user`) instances run.";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to run this xara instance.";
          };

          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "alice";
            description = ''
              Run this instance as a systemd --user service in this user's
              instance instead of as a system service.  Use this when the
              modem needs that user's PipeWire/PulseAudio session (the usual
              case for a desktop or kiosk host).

              The generated unit is scoped with `ConditionUser`, so it does
              not run in other users' sessions.
            '';
          };

          description = lib.mkOption {
            type = lib.types.str;
            default = "xara modem (${name})";
            description = "systemd unit description.";
          };

          settings = lib.mkOption {
            type = settingsType;
            default = { };
            example = {
              call = "N0CALL";
              fm = "narrow";
              audio = "pulse";
              capture = "alsa_input.usb-...";
              playback = "alsa_output.usb-...";
              radio = true;
              ptt = "rigctld:127.0.0.1:4532";
              port = 8300;
            };
            description = ''
              xara configuration, rendered as a `key = value` config file and
              passed with `--config`.  Keys are xara's long option names without
              the leading `--` (for example `kiss-port`, `ptt-lead-ms`).
              Boolean values render as `yes`/`no`.
            '';
          };

          configFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Use this config file instead of rendering <option>settings</option>.
            '';
          };

          stateDir = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "/var/lib/xara/fm";
            description = ''
              Value passed as `--state-dir` (web UI settings/token).  When
              null, a systemd `StateDirectory` named `xara/<instance>` is used
              instead (for user units this lands under `$XDG_STATE_HOME`).
            '';
          };

          extraArgs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Extra command-line arguments passed after `--config`.";
          };

          environment = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            example = {
              "PULSE_PROP_application.name" = "xara-fm";
            };
            description = "Environment variables for the instance.";
          };

          preStart = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              Shell snippet run as `ExecStartPre` before xara starts (for
              example, to wait for and set sound-card volumes).
            '';
          };

          postStart = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              Shell snippet run as `ExecStartPost` after xara starts (for
              example, to pin the modem's PulseAudio stream to a device).
            '';
          };

          wantedBy = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              systemd target(s) that should start this instance.  Defaults to
              `multi-user.target` for system instances and `default.target`
              for user instances.
            '';
          };

          after = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              systemd `After=` ordering.  Defaults to `network.target` and
              `sound.target` for system instances, or `pipewire.service` and
              `wireplumber.service` for user instances.
            '';
          };

          wants = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "systemd `Wants=` dependencies.";
          };

          bindsTo = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "systemd `BindsTo=` dependencies.";
          };

          partOf = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "systemd `PartOf=` dependencies.";
          };

          path = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [ coreutils gnugrep pulseaudio jq ];
            description = ''
              Packages made available on the instance's `PATH` (used by
              <option>preStart</option>/<option>postStart</option> snippets).
            '';
          };

          serviceConfig = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "Extra systemd `Service=` settings for this instance.";
          };

          unitConfig = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "Extra systemd `Unit=` settings for this instance.";
          };
        };
      }));
      default = { };
      description = ''
        Independent xara modem instances.  Each becomes a `xara-<name>` unit.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    # The package ships udev rules for CM108/CM119/AIOC HID PTT.
    services.udev.packages = [ cfg.package ];

    users.users = lib.mkIf (hasSystemInstances && cfg.user == "xara" && cfg.group == "xara") {
      xara = {
        isSystemUser = true;
        group = "xara";
        extraGroups = [ "audio" "dialout" "plugdev" ];
        description = "xara modem service user";
      };
    };

    users.groups = lib.mkIf (hasSystemInstances && cfg.group == "xara") {
      xara = { };
    };

    systemd.services = lib.mapAttrs' (
      name: icfg:
      lib.nameValuePair "xara-${name}" (mkService name icfg false)
    ) (lib.filterAttrs (_: i: i.enable && i.user == null) cfg.instances);

    systemd.user.services = lib.mapAttrs' (
      name: icfg:
      lib.nameValuePair "xara-${name}" (mkService name icfg true)
    ) (lib.filterAttrs (_: i: i.enable && i.user != null) cfg.instances);
  };
}
