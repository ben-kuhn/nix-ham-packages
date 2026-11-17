{ config, lib, pkgs, ... }:

let
  cfg = config.services.open-rmslist;
in {
  options.services.open-rmslist = {

    enable = lib.mkEnableOption "open-rmslist, a self-hosted Winlink RMS gateway map";

    package = lib.mkPackageOption pkgs "open-rmslist" { };

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
      default = [ "PUBLIC" "EMCOMM" "MERCURY" "VARDEFM" ];
      description = ''
        Winlink service codes to fetch. The API has no wildcard, so this lists
        the codes to request explicitly; the web UI offers a dropdown of the
        codes actually present in the returned data.
      '';
    };

    refreshInterval = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "Gateway list refresh interval (Go duration, e.g. 1h).";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/open-rmslist";
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
    systemd.services.open-rmslist = let
      # Prefer explicit overrides; otherwise derive from the voacapl package.
      exe = if cfg.voacapExecutable != null then cfg.voacapExecutable
        else if cfg.voacapl != null then "${cfg.voacapl}/bin/voacapl" else null;
      datadir = if cfg.voacapDataDir != null then cfg.voacapDataDir
        else if cfg.voacapl != null then "${cfg.voacapl}/share/voacapl/itshfbc" else null;
      args = [
        "-listen" "${cfg.listenAddress}:${toString cfg.port}"
        "-cache-dir" cfg.cacheDir
        "-service-codes" (lib.concatStringsSep "," cfg.serviceCodes)
        "-refresh" cfg.refreshInterval
      ] ++ lib.optionals (exe != null) [ "-voacap-executable" exe ]
        ++ lib.optionals (datadir != null) [ "-voacap-data-dir" datadir ]
        ++ lib.optionals (cfg.voacapUrl != null) [ "-voacap-url" cfg.voacapUrl ];
    in {
      description = "open-rmslist Winlink gateway map";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "open-rmslist";
        ExecStart = "${cfg.package}/bin/open-rmslist ${lib.concatStringsSep " " (map lib.escapeShellArg args)}";
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
