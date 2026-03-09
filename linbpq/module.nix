{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.linbpq;
  linbpq = pkgs.linbpq;
in
{
  options.services.linbpq = {
    enable = mkEnableOption "LinBPQ packet radio node";

    package = mkOption {
      type = types.package;
      default = pkgs.linbpq;
      defaultText = literalExpression "pkgs.linbpq";
      description = "The LinBPQ package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "bpq";
      description = "User account under which LinBPQ runs.";
    };

    group = mkOption {
      type = types.str;
      default = "bpq";
      description = "Group under which LinBPQ runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/linbpq";
      description = ''
        Directory for LinBPQ working files (data, config, and state).
        This is where bpq32.cfg and other runtime files are stored.
      '';
    };

    logDir = mkOption {
      type = types.path;
      default = "/var/lib/linbpq/logs";
      description = "Directory for LinBPQ log files.";
    };

    configDir = mkOption {
      type = types.path;
      default = "/var/lib/linbpq";
      description = "Directory containing LinBPQ configuration files.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to automatically open firewall ports for LinBPQ.
        Note: You may need to manually configure ports based on your bpq32.cfg.
      '';
    };

    firewallPorts = mkOption {
      type = types.listOf types.port;
      default = [ 8010 8011 8080 ];
      description = ''
        List of TCP ports to open in the firewall.
        Default includes common BPQ ports:
        - 8010: TCPPORT (Telnet access)
        - 8011: FBBPORT (FBB forwarding / QtTermTCP)
        - 8080: HTTPPORT (Web management interface)
      '';
    };

    firewallUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of UDP ports to open in the firewall.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "daemon" ];
      description = "Extra command-line arguments to pass to linbpq.";
    };
  };

  config = mkIf cfg.enable {
    # Create the bpq user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "LinBPQ daemon user";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    # Create required directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.logDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/HTML 0750 ${cfg.user} ${cfg.group} -"
    ];

    # systemd service
    systemd.services.linbpq = {
      description = "LinBPQ Packet Radio Node";
      after = [ "network.target" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/linbpq -d ${cfg.dataDir} -c ${cfg.configDir} -l ${cfg.logDir} ${concatStringsSep " " cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 10;

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          cfg.dataDir
          cfg.logDir
          cfg.configDir
        ];

        # Network capabilities for binding to privileged ports if needed
        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
        ];
      };

      # Ensure config exists before starting
      preStart = ''
        if [ ! -f ${cfg.configDir}/bpq32.cfg ]; then
          echo "ERROR: ${cfg.configDir}/bpq32.cfg not found!"
          echo "Please create a configuration file before starting LinBPQ."
          echo "Documentation: https://www.cantab.net/users/john.wiseman/Documents/LinBPQ.html"
          exit 1
        fi
      '';
    };

    # Firewall configuration
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = cfg.firewallPorts;
      allowedUDPPorts = cfg.firewallUDPPorts;
    };
  };
}
