{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.packet-browser-client;

  iniFormat = pkgs.formats.ini { };
  configFile = iniFormat.generate "packet-browser-client.ini" {
    server = {
      agwpe_host = cfg.agwpeHost;
      agwpe_port = cfg.agwpePort;
    };
    session = {
      my_callsign = cfg.myCallsign;
      target_callsign = cfg.targetCallsign;
      bpq_command = cfg.bpqCommand;
    };
  };
in
{
  options.services.packet-browser-client = {
    enable = mkEnableOption "Packet Browser Client - web browser over AX.25 packet radio";

    package = mkOption {
      type = types.package;
      default = pkgs.packet-browser-client;
      defaultText = literalExpression "pkgs.packet-browser-client";
      description = "The packet-browser-client package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "packet-browser";
      description = "User account under which the client runs.";
    };

    group = mkOption {
      type = types.str;
      default = "packet-browser";
      description = "Group under which the client runs.";
    };

    listenAddr = mkOption {
      type = types.str;
      default = "127.0.0.1:8080";
      description = "Address and port for the web proxy to listen on.";
    };

    agwpeHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "AGWPE TNC server hostname or IP address.";
    };

    agwpePort = mkOption {
      type = types.port;
      default = 8000;
      description = "AGWPE TNC server port.";
    };

    myCallsign = mkOption {
      type = types.str;
      description = "Your amateur radio callsign.";
      example = "N0CALL";
    };

    targetCallsign = mkOption {
      type = types.str;
      default = "";
      description = "Target BPQ node callsign to connect to.";
      example = "NODE1";
    };

    bpqCommand = mkOption {
      type = types.str;
      default = "WEB";
      description = "BPQ APPLICATION command to send after AX.25 connection.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "-vv" ];
      description = "Extra command-line arguments to pass to packet-browser-client.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Packet Browser Client daemon user";
    };

    users.groups.${cfg.group} = { };

    systemd.services.packet-browser-client = {
      description = "Packet Browser Client - web browser over AX.25 packet radio";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/packet-browser-client --config ${configFile} --listen-addr ${cfg.listenAddr} ${concatStringsSep " " cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
