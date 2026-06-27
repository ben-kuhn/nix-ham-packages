{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.packet-browser-server;

  # Wrapper script that sets CHROMIUM_PATH and other runtime env
  wrapperScript = pkgs.writeShellScriptBin "packet-browser-server-wrapper" ''
    export CHROMIUM_PATH="${cfg.chromiumPackage}/bin/chromium"
    export LISTEN_PORT="${toString cfg.listenPort}"
    export PORTAL_URL="${cfg.portalUrl}"
    export IDLE_TIMEOUT_MINUTES="${toString cfg.idleTimeoutMinutes}"
    export BROTLI_QUALITY="${toString cfg.brotliQuality}"
    export BLOCKED_RANGES="${concatStringsSep "," cfg.blockedRanges}"
    export BLOCKLIST_ENABLED="${boolToString cfg.blocklistEnabled}"
    export BLOCKLIST_REFRESH_HOURS="${toString cfg.blocklistRefreshHours}"
    ${optionalString (cfg.blocklistUrls != []) ''export BLOCKLIST_URLS="${concatStringsSep "," cfg.blocklistUrls}"''}
    export LOG_ROTATE_ENABLED="${boolToString cfg.logRotateEnabled}"
    export LOG_RETAIN_DAYS="${toString cfg.logRetainDays}"
    ${optionalString cfg.syslogEnabled ''
      export SYSLOG_ENABLED=true
      export SYSLOG_HOST="${cfg.syslogHost}"
      export SYSLOG_PORT="${toString cfg.syslogPort}"
    ''}
    exec ${cfg.package}/bin/packet-browser-server
  '';
in
{
  options.services.packet-browser-server = {
    enable = mkEnableOption "Packet Browser Server - web page fetcher for AX.25 packet radio";

    package = mkOption {
      type = types.package;
      default = pkgs.packet-browser-server;
      defaultText = literalExpression "pkgs.packet-browser-server";
      description = "The packet-browser-server package to use.";
    };

    chromiumPackage = mkOption {
      type = types.package;
      default = pkgs.chromium;
      defaultText = literalExpression "pkgs.chromium";
      description = "Chromium package to use for headless page rendering.";
    };

    user = mkOption {
      type = types.str;
      default = "packet-browser";
      description = "User account under which the server runs.";
    };

    group = mkOption {
      type = types.str;
      default = "packet-browser";
      description = "Group under which the server runs.";
    };

    listenPort = mkOption {
      type = types.port;
      default = 63004;
      description = "TCP port the server listens on for BPQ connections.";
    };

    portalUrl = mkOption {
      type = types.str;
      default = "https://www.zeroretries.radio";
      description = "Default home page URL shown on connect.";
    };

    idleTimeoutMinutes = mkOption {
      type = types.int;
      default = 10;
      description = "Session timeout in minutes for idle connections.";
    };

    brotliQuality = mkOption {
      type = types.int;
      default = 11;
      description = "Brotli compression level (0-11).";
    };

    blockedRanges = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "169.254.0.0/16" ];
      description = "CIDR ranges blocked for SSRF prevention.";
    };

    blocklistEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hosts-based blocklist.";
    };

    blocklistUrls = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "URLs of hosts-format blocklists to fetch.";
      example = [ "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/ultimate.txt" ];
    };

    blocklistRefreshHours = mkOption {
      type = types.int;
      default = 24;
      description = "How often to refresh blocklists from URLs (hours).";
    };

    logRotateEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic log rotation.";
    };

    logRetainDays = mkOption {
      type = types.int;
      default = 30;
      description = "Number of days to retain rotated logs.";
    };

    syslogEnabled = mkOption {
      type = types.bool;
      default = false;
      description = "Forward logs to external syslog server.";
    };

    syslogHost = mkOption {
      type = types.str;
      default = "";
      description = "Syslog server hostname or IP.";
    };

    syslogPort = mkOption {
      type = types.port;
      default = 514;
      description = "Syslog server port.";
    };

    logDir = mkOption {
      type = types.path;
      default = "/var/log/packet-browser";
      description = "Directory for log files.";
    };

    hostsFile = mkOption {
      type = types.path;
      default = "/etc/packet-browser/hosts";
      description = "Hosts file for blocklist management.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically open the listen port in the firewall.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Packet Browser Server daemon user";
    };

    users.groups.${cfg.group} = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.logDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${dirOf cfg.hostsFile} 0750 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.packet-browser-server = {
      description = "Packet Browser Server - web page fetcher for AX.25 packet radio";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${wrapperScript}/bin/packet-browser-server-wrapper";
        Restart = "on-failure";
        RestartSec = 5;

        ReadWritePaths = [ cfg.logDir (dirOf cfg.hostsFile) ];

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };
  };
}
