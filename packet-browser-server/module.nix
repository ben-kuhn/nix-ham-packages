{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.packet-browser-server;

  logDir = "/var/log/packet-browser";

  # Firefox is launched directly by geckodriver, which rejects wrapper
  # scripts. Use the unwrapped binary and supply the NSS/p11-kit libraries it
  # dlopens at runtime (libnssckbi.so and the p11-kit trust module).
  firefoxLibraryPath = makeLibraryPath [ cfg.firefoxPackage pkgs.nss pkgs.p11-kit ];

  # Wrapper script that sets the runtime environment for the server. The
  # server expects FIREFOX_PATH and GECKODRIVER_PATH; the old CHROMIUM_PATH
  # variable was removed upstream when packet-browser switched to Firefox.
  wrapperScript = pkgs.writeShellScriptBin "packet-browser-server-wrapper" ''
    export LISTEN_PORT="${toString cfg.listenPort}"
    export PORTAL_URL="${cfg.portalUrl}"
    export IDLE_TIMEOUT_MINUTES="${toString cfg.idleTimeoutMinutes}"
    export BROTLI_QUALITY="${toString cfg.brotliQuality}"
    export BLOCKED_RANGES="${concatStringsSep "," cfg.blockedRanges}"
    export BLOCKLIST_ENABLED="${boolToString cfg.blocklistEnabled}"
    export BLOCKLIST_REFRESH_HOURS="${toString cfg.blocklistRefreshHours}"
    export BLOCKLIST_URLS="${concatStringsSep "," cfg.blocklistUrls}"
    export ALLOWED_CALLSIGNS="${concatStringsSep "," cfg.allowedCallsigns}"
    export ORIGIN_CC_HEAD_TIMEOUT_MS="${toString cfg.originCcHeadTimeoutMs}"
    export DEFAULT_MAX_AGE_SECONDS="${toString cfg.defaultMaxAgeSeconds}"
    export MAX_MAX_AGE_SECONDS="${toString cfg.maxMaxAgeSeconds}"

    export FIREFOX_PATH="${cfg.firefoxPackage}/bin/firefox"
    export GECKODRIVER_PATH="${cfg.geckodriverPackage}/bin/geckodriver"
    export LD_LIBRARY_PATH="${firefoxLibraryPath}"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

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

    firefoxPackage = mkOption {
      type = types.package;
      default = pkgs.firefox-esr-unwrapped;
      defaultText = literalExpression "pkgs.firefox-esr-unwrapped";
      description = ''
        Firefox package used for headless page rendering. Use the unwrapped
        build: geckodriver passes the path directly to the browser and rejects
        wrapper scripts that are not ELF executables.
      '';
    };

    geckodriverPackage = mkOption {
      type = types.package;
      default = pkgs.geckodriver;
      defaultText = literalExpression "pkgs.geckodriver";
      description = "geckodriver package used to control headless Firefox.";
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
      default = [
        "0.0.0.0/8"
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "169.254.0.0/16"
      ];
      description = "CIDR ranges blocked for SSRF prevention.";
    };

    blocklistEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the in-process hosts-based blocklist.";
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

    allowedCallsigns = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Callsigns that bypass the strict ITU-shape validation. Intended for
        off-air testing, where LinBPQ may inject synthetic callsigns such as
        DEMOUSR or W1TEST. Matching is case-insensitive and ignores an SSID
        suffix.
      '';
      example = [ "DEMOUSR" "W1TEST" ];
    };

    originCcHeadTimeoutMs = mkOption {
      type = types.int;
      default = 3000;
      description = "Timeout in milliseconds for the upstream Cache-Control HEAD probe.";
    };

    defaultMaxAgeSeconds = mkOption {
      type = types.int;
      default = 3600;
      description = "Default cache max-age in seconds when the origin gives no directive.";
    };

    maxMaxAgeSeconds = mkOption {
      type = types.int;
      default = 2592000;
      description = "Upper bound in seconds for origin-provided cache max-age values.";
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
      "d ${logDir} 0750 ${cfg.user} ${cfg.group} -"
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

        ReadWritePaths = [ logDir ];

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
