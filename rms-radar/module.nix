{ config, lib, pkgs, ... }:

let
  cfg = config.services.rms-radar;
in {
  options.services.rms-radar = {

    enable = lib.mkEnableOption "RMS Radar, a self-hosted Winlink RMS gateway map";

    package = lib.mkPackageOption pkgs "rms-radar" { };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address to bind. Use "0.0.0.0" to serve other machines on the network.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8079;
      description = "HTTP port to listen on.";
    };

    serviceCodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "PUBLIC" "EMCOMM" "MERCURY" "VARDEFM" "MODEM73" "DATA2G" "IONHF" ];
      description = ''
        Winlink service codes to fetch. The API has no wildcard and does not
        publish private group codes, so this lists the known public/community
        codes explicitly; the web UI offers a dropdown of the codes actually
        present in the returned data. Add a private group code here or through
        the desktop/admin API if you are entitled to it.
      '';
    };

    adminToken = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional admin token. When set, service-code changes require the
        X-RMS-Radar-Admin header (the web dialog can store it for the tab).
        Leave null to disable service-code editing on the server.
      '';
    };

    refreshInterval = lib.mkOption {
      type = lib.types.str;
      default = "24h";
      description = "Gateway list refresh interval (Go duration, e.g. 24h). The UI Refresh button forces an update.";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/rms-radar";
      description = "Directory for the cached gateway list and propagation data.";
    };

    voacapl = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? voacapl then pkgs.voacapl else null;
      defaultText = lib.literalExpression "pkgs.voacapl";
      description = "voacapl package providing the VOACAP engine and its ITSHFBC data.";
    };

    voacapUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional remote VOACAP API base URL (enables forecasts).";
    };

    voacapExecutable = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a local voacapl/voacapw binary (enables forecasts).";
    };

    voacapDataDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ITSHFBC data directory for the local VOACAP binary.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the configured TCP port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rms-radar = let
      # Prefer explicit overrides; otherwise derive from the voacapl package.
      exe = if cfg.voacapExecutable != null then cfg.voacapExecutable
        else if cfg.voacapl != null then "${cfg.voacapl}/bin/voacapl" else null;
      datadir = if cfg.voacapDataDir != null then cfg.voacapDataDir
        else if cfg.voacapl != null then "${cfg.voacapl}/share/voacapl/itshfbc" else null;
      args = [
        "-d"
        "-listen" "${cfg.listenAddress}:${toString cfg.port}"
        "-cache-dir" cfg.cacheDir
        "-service-codes" (lib.concatStringsSep "," cfg.serviceCodes)
        "-refresh" cfg.refreshInterval
      ] ++ lib.optionals (exe != null) [ "-voacap-executable" exe ]
        ++ lib.optionals (datadir != null) [ "-voacap-data-dir" datadir ]
        ++ lib.optionals (cfg.voacapUrl != null) [ "-voacap-url" cfg.voacapUrl ];
    in {
      description = "RMS Radar Winlink gateway map";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = lib.optionalAttrs (cfg.adminToken != null) {
        RMSRADAR_ADMIN_TOKEN = cfg.adminToken;
      };
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "rms-radar";
        ExecStart = "${cfg.package}/bin/rms-radar ${lib.concatStringsSep " " (map lib.escapeShellArg args)}";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        CapabilityBoundingSet = "";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
