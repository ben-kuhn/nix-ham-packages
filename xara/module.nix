# NixOS module for xara, a VARA-compatible HF/FM software modem.
#
# Any number of independent modems can run on one host.  Each
# `services.xara.instances.<name>` is a typed, declarative description of one
# xara process and becomes a `xara-<name>` systemd unit.  Instances run as
# system services by default, or as a systemd --user service when `user` is
# set (needed when audio comes from that user's PipeWire session).
{ config, lib, pkgs, ... }:

let
  cfg = config.services.xara;

  mkArgs = icfg:
    let
      ui = icfg.ui;
    in
    [ "${cfg.package}/bin/xara" ]
    ++ [
      "--call" icfg.call
      "--audio" icfg.audio
      "--capture" icfg.capture
      "--playback" icfg.playback
      "--addr" icfg.addr
      "--port" (toString icfg.port)
    ]
    ++ lib.optionals (icfg.hf != null) [ "--hf" (toString icfg.hf) ]
    ++ lib.optionals (icfg.fm != null) [ "--fm" icfg.fm ]
    ++ lib.optionals icfg.radio [ "--radio" ]
    ++ lib.optionals (icfg.ptt != null) [ "--ptt" icfg.ptt ]
    ++ lib.optionals (icfg.pttLeadMs != null) [ "--ptt-lead-ms" (toString icfg.pttLeadMs) ]
    ++ lib.optionals (icfg.pttTailMs != null) [ "--ptt-tail-ms" (toString icfg.pttTailMs) ]
    ++ lib.optionals (icfg.pttMaxS != null) [ "--ptt-max-s" (toString icfg.pttMaxS) ]
    ++ lib.optionals (icfg.driveDb != null) [ "--drive-db" (toString icfg.driveDb) ]
    ++ (if icfg.kissPort == null then [ "--kiss-port" "off" ] else [ "--kiss-port" (toString icfg.kissPort) ])
    ++ lib.optionals (icfg.persistence != null) [ "--persistence" (toString icfg.persistence) ]
    ++ lib.optionals (icfg.digi != null) [ "--digi" icfg.digi ]
    ++ lib.optionals icfg.registered [ "--registered" ]
    ++ lib.optionals (icfg.offerLevel != null) [ "--offer-level" (toString icfg.offerLevel) ]
    ++ lib.optionals (icfg.stateDir != null) [ "--state-dir" icfg.stateDir ]
    ++ lib.optionals (icfg.record != null) [ "--record" icfg.record ]
    ++ lib.optionals (ui.port != null) [ "--ui-port" (toString ui.port) ]
    ++ lib.optionals (ui.addr != null) [ "--ui-addr" ui.addr ]
    ++ lib.concatMap (h: [ "--ui-host" h ]) ui.hosts
    ++ lib.optionals ui.control [ "--ui-control" ]
    ++ lib.optionals (ui.token != null) [ "--ui-token" ui.token ]
    ++ icfg.extraArgs;

  hasSystemInstances = lib.any (i: i.enable && i.user == null) (lib.attrValues cfg.instances);

  mkService = name: icfg: isUser:
    let
      preStart = lib.optionalString (icfg.preStart != "") (
        pkgs.writeShellScript "xara-${name}-pre" icfg.preStart
      );
      postStart = lib.optionalString (icfg.postStart != "") (
        pkgs.writeShellScript "xara-${name}-post" icfg.postStart
      );
      wantedBy =
        if !icfg.autoStart then [ ]
        else if icfg.wantedBy != [ ] then icfg.wantedBy
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
        ExecStart = lib.escapeShellArgs (mkArgs icfg);
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

  enabledInstances = lib.filterAttrs (_: i: i.enable) cfg.instances;
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
            description = "Whether to define this xara instance.";
          };

          autoStart = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether systemd should start this instance automatically.  Set
              to false when the unit should exist but be started manually (for
              example, during A/B testing).
            '';
          };

          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "alice";
            description = ''
              Run this instance as a systemd --user service in this user's
              instance instead of as a system service.  Use this when the
              modem needs that user's PipeWire/PulseAudio session.

              The generated unit is scoped with `ConditionUser`, so it does
              not run in other users' sessions.
            '';
          };

          description = lib.mkOption {
            type = lib.types.str;
            default = "xara modem (${name})";
            description = "systemd unit description.";
          };

          call = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Callsign (`--call`).";
          };

          hf = lib.mkOption {
            type = lib.types.nullOr (lib.types.enum [ 500 2300 2750 ]);
            default = null;
            description = "HF bandwidth (`--hf`).  Mutually exclusive with fm.";
          };

          fm = lib.mkOption {
            type = lib.types.nullOr (lib.types.enum [ "narrow" "wide" ]);
            default = null;
            description = "FM bandwidth (`--fm`).  Mutually exclusive with hf.";
          };

          audio = lib.mkOption {
            type = lib.types.enum [ "pulse" "alsa" ];
            default = "pulse";
            description = "Audio backend (`--audio`).";
          };

          capture = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Capture device (`--capture`).";
          };

          playback = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Playback device (`--playback`).";
          };

          radio = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable radio mode / TX drive (`--radio`).";
          };

          ptt = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "rigctld:127.0.0.1:4532";
            description = ''
              PTT method (`--ptt`): `vox`, `rigctld[:HOST:PORT]`,
              `cm108:/dev/hidrawN[:GPIO]`, `rts:DEV`, or `dtr:DEV`.
            '';
          };

          pttLeadMs = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "PTT lead time in ms (`--ptt-lead-ms`, 0..1000).";
          };

          pttTailMs = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "PTT tail time in ms (`--ptt-tail-ms`, 0..1000).";
          };

          pttMaxS = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Maximum keyed time in seconds (`--ptt-max-s`, 1..120).";
          };

          driveDb = lib.mkOption {
            type = lib.types.nullOr (lib.types.either lib.types.int lib.types.float);
            default = null;
            description = "TX drive level in dB, <= 0 (`--drive-db`).";
          };

          addr = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "KISS/command bind address (`--addr`).";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 8300;
            description = "Command port (`--port`).  The data port is port + 1.";
          };

          kissPort = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = 8100;
            description = "KISS TCP port (`--kiss-port`).  Null disables KISS.";
          };

          persistence = lib.mkOption {
            type = lib.types.nullOr lib.types.float;
            default = null;
            description = "KISS p-persistence, 0..1 (`--persistence`).";
          };

          digi = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "FM digipeater callsign (`--digi`, requires fm).";
          };

          registered = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable registered speeds (`--registered`).";
          };

          offerLevel = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Preferred data level (`--offer-level`, requires registered).";
          };

          ui = {
            port = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Web UI port (`--ui-port`); null disables the UI.";
            };
            addr = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Web UI bind address (`--ui-addr`).";
            };
            hosts = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Accepted HTTP Host names (`--ui-host`, repeatable).";
            };
            control = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Allow remote PTT control (`--ui-control`).";
            };
            token = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Web UI token (`--ui-token`).  Note: the value is written to the
                world-readable Nix store; prefer an environment file for
                secrets if this matters.
              '';
            };
          };

          stateDir = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Value passed as `--state-dir` (web UI settings/token).  When
              null, a systemd `StateDirectory` named `xara/<instance>` is used
              instead.
            '';
          };

          record = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Record RX/TX/PTT to this path (`--record`).";
          };

          extraArgs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Extra command-line arguments appended to ExecStart.";
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
              for user instances; ignored when autoStart is false.
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

  config = {
    assertions = lib.flatten (lib.mapAttrsToList (name: i: [
      {
        assertion = (i.hf != null) != (i.fm != null);
        message = "services.xara.instances.${name}: set exactly one of `hf` or `fm`.";
      }
      {
        assertion = i.digi == null || i.fm != null;
        message = "services.xara.instances.${name}: `digi` requires `fm`.";
      }
      {
        assertion = i.call != "";
        message = "services.xara.instances.${name}: `call` is required.";
      }
      {
        assertion = i.capture != "" && i.playback != "";
        message = "services.xara.instances.${name}: `capture` and `playback` are required.";
      }
      {
        assertion = i.radio || i.ptt == null;
        message = "services.xara.instances.${name}: `ptt` requires `radio = true`.";
      }
      {
        assertion = !i.radio || i.ptt != null;
        message = "services.xara.instances.${name}: `radio = true` requires `ptt` (use \"vox\" for none).";
      }
      {
        assertion = i.offerLevel == null || i.registered;
        message = "services.xara.instances.${name}: `offerLevel` requires `registered = true`.";
      }
      {
        assertion = i.ui.port != null || (!i.ui.control && i.ui.token == null && i.ui.hosts == [ ]);
        message = "services.xara.instances.${name}: `ui.control`, `ui.token` and `ui.hosts` require `ui.port`.";
      }
      {
        assertion = i.ui.token == null || i.ui.control;
        message = "services.xara.instances.${name}: `ui.token` requires `ui.control = true`.";
      }
      {
        assertion = i.driveDb == null || i.driveDb <= 0;
        message = "services.xara.instances.${name}: `driveDb` must be <= 0.";
      }
      {
        assertion = i.port < 65535;
        message = "services.xara.instances.${name}: `port` must be below 65535 (data port is port + 1).";
      }
      {
        assertion = i.pttLeadMs == null || (i.pttLeadMs >= 0 && i.pttLeadMs <= 1000);
        message = "services.xara.instances.${name}: `pttLeadMs` must be 0..1000.";
      }
      {
        assertion = i.pttTailMs == null || (i.pttTailMs >= 0 && i.pttTailMs <= 1000);
        message = "services.xara.instances.${name}: `pttTailMs` must be 0..1000.";
      }
      {
        assertion = i.pttMaxS == null || (i.pttMaxS >= 1 && i.pttMaxS <= 120);
        message = "services.xara.instances.${name}: `pttMaxS` must be 1..120.";
      }
      {
        assertion = i.persistence == null || (i.persistence >= 0.0 && i.persistence <= 1.0);
        message = "services.xara.instances.${name}: `persistence` must be 0..1.";
      }
    ]) (lib.filterAttrs (_: i: i.enable) cfg.instances));
  } // lib.mkIf cfg.enable {
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
