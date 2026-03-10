{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.linbpq;
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

    configDir = mkOption {
      type = types.path;
      default = "/etc/linbpq";
      description = "Directory containing bpq32.cfg.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/linbpq";
      description = ''
        Directory for LinBPQ state data including user mail, BBS data,
        and web-generated configuration.
      '';
    };

    logDir = mkOption {
      type = types.path;
      default = "/var/log/linbpq";
      description = "Directory for LinBPQ log files.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically open firewall ports for LinBPQ.";
    };

    firewallPorts = mkOption {
      type = types.listOf types.port;
      default = [ 8010 8011 8080 ];
      description = ''
        TCP ports to open in the firewall:
        - 8010: Telnet (TCPPORT)
        - 8011: FBB/QtTermTCP (FBBPORT)
        - 8080: Web interface (HTTPPORT)
      '';
    };

    firewallUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "UDP ports to open in the firewall.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "daemon" ];
      description = "Extra command-line arguments to pass to linbpq.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "LinBPQ daemon user";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/HTML 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.logDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

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
        ExecStart = "${cfg.package}/bin/linbpq -c ${cfg.configDir} -d ${cfg.dataDir} -l ${cfg.logDir} ${concatStringsSep " " cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 10;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          cfg.configDir
          cfg.dataDir
          cfg.logDir
        ];

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

      preStart = ''
        if [ ! -f ${cfg.configDir}/bpq32.cfg ]; then
          echo "ERROR: ${cfg.configDir}/bpq32.cfg not found!"
          echo "Create configuration file before starting LinBPQ."
          exit 1
        fi
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = cfg.firewallPorts;
      allowedUDPPorts = cfg.firewallUDPPorts;
    };
  };
}
