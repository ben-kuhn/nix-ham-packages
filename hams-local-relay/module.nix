{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hams-local-relay;

  # The relay is designed to run as a per-user daemon: it needs access to
  # the user's audio devices, serial ports (dialout), and home directory
  # for its secrets and settings.  Upstream ships it as a systemd --user
  # service, so this module does the same.
  unitName = "hams-local-relay";

  execStart = lib.concatStringsSep " " (
    [ "${cfg.package}/bin/${unitName}" ] ++ map lib.escapeShellArg cfg.extraArgs
  );
in
{
  options.services.hams-local-relay = {
    enable = lib.mkEnableOption "the hams.com Local Hardware Relay user service";

    package = lib.mkPackageOption pkgs "hams-local-relay" { };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "alice";
      description = ''
        Only start the relay in this user's systemd user instance.

        The relay is a per-user daemon; on a machine with more than one
        interactive user, set this so only one relay instance runs (and
        only one process tries to bind the local HTTPS port).
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--force-ptt-off" ];
      description = "Extra command-line arguments passed to the relay.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        CLUBLOG_API_KEY = "your-key";
      };
      description = ''
        Environment variables for the relay service.  Prefer an
        <option>environmentFile</option> for secrets, since values set here
        are stored in the world-readable Nix store.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/hams-local-relay.env";
      description = ''
        Optional environment file (systemd `EnvironmentFile=`) for secrets
        such as <envar>CLUBLOG_API_KEY</envar>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.${unitName} = {
      description = "Hams.com Local Hardware Relay";
      wantedBy = [ "default.target" ];

      path = with pkgs; [
        # The relay shells out to amixer for sound-card mixer takeover and
        # pactl to ask PipeWire/PulseAudio for the default device.  Without
        # these on PATH it cannot open the radio's audio device.
        alsa-utils
        bash
        coreutils
        pulseaudio
      ];

      environment = cfg.environment;

      unitConfig = lib.optionalAttrs (cfg.user != null) {
        ConditionUser = cfg.user;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = execStart;
        WorkingDirectory = "%h";
        Restart = "on-failure";
        RestartSec = 5;

        # Make sure the directory the relay writes its settings and secrets
        # to exists before it starts.
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/hams_local_relay";

        # After any stop, force PTT off on every radio this service had open.
        # A crash or SIGKILL bypasses the daemon's own shutdown code, and
        # some rigs have no transmit time-out.
        ExecStopPost = "${cfg.package}/bin/${unitName} --force-ptt-off";

        # Hardening adapted from the upstream systemd --user unit.  The
        # relay needs home-directory write access (settings, secrets, LoTW
        # credentials) and access to /dev/tty* and /dev/snd, so ProtectHome
        # and PrivateDevices are deliberately not enabled.
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        UMask = "0077";
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };
  };
}
