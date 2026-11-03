{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.packet-browser-client;

  iniFormat = pkgs.formats.ini { };

  mkVaraEndpoint =
    { defaultCmdPort, defaultDataPort, bandwidthValues, defaultBandwidth }:
    types.submodule {
      options = {
        cmdHost = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "VARA command-channel host.";
        };

        cmdPort = mkOption {
          type = types.port;
          default = defaultCmdPort;
          description = "VARA command-channel TCP port.";
        };

        dataHost = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "VARA data-channel host.";
        };

        dataPort = mkOption {
          type = types.port;
          default = defaultDataPort;
          description = "VARA data-channel TCP port.";
        };

        bandwidth = mkOption {
          type = types.enum bandwidthValues;
          default = defaultBandwidth;
          description = "VARA bandwidth mode.";
        };
      };
    };

  configFile = iniFormat.generate "packet-browser-client.ini" {
    server = {
      agwpe_host = cfg.agwpeHost;
      agwpe_port = cfg.agwpePort;
    };

    session = {
      my_callsign = cfg.myCallsign;
      target_callsign = cfg.targetCallsign;
      bpq_command = cfg.bpqCommand;
      skip_bpq_app = cfg.skipBpqApp;
    };

    cache = {
      enabled = cfg.cache.enable;
      max_bytes = cfg.cache.maxBytes;
      max_ttl_seconds = cfg.cache.maxTtlSeconds;
      dir = cfg.cache.dir;
    };

    connection = {
      response_timeout_secs = cfg.connection.responseTimeoutSecs;
      auto_reconnect = cfg.connection.autoReconnect;
    };

    transport = {
      default = cfg.transport;
    };

    vara_hf = {
      cmd_host = cfg.varaHf.cmdHost;
      cmd_port = cfg.varaHf.cmdPort;
      data_host = cfg.varaHf.dataHost;
      data_port = cfg.varaHf.dataPort;
      bandwidth = cfg.varaHf.bandwidth;
    };

    vara_fm = {
      cmd_host = cfg.varaFm.cmdHost;
      cmd_port = cfg.varaFm.cmdPort;
      data_host = cfg.varaFm.dataHost;
      data_port = cfg.varaFm.dataPort;
      bandwidth = cfg.varaFm.bandwidth;
    };
  };

  execArgs = [
    "${cfg.package}/bin/packet-browser-client"
    "--config"
    (toString configFile)
    "--listen-addr"
    cfg.listenAddr
  ]
  ++ optionals (cfg.allowedHosts != [ ]) [ "--allowed-hosts" (concatStringsSep "," cfg.allowedHosts) ]
  ++ optionals cfg.dontLaunchBrowser [ "--dont-launch-browser" ]
  ++ cfg.extraArgs;
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
      default = "127.0.0.1:8088";
      description = "Address and port for the web proxy to listen on.";
    };

    allowedHosts = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra hostnames accepted in the HTTP Host header, for example mDNS
        names when listening on a LAN interface. Loopback and LAN IP literals
        are accepted automatically based on <option>listenAddr</option>.
      '';
      example = [ "packet.local" ];
    };

    dontLaunchBrowser = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Do not open a local browser when the service starts. The default is
        true for the system service; set it to false when running the client
        interactively.
      '';
    };

    agwpeHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "AGWPE TNC server hostname or IP address (AX.25 transport).";
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
      description = "BPQ APPLICATION command to send after the AX.25 connection.";
    };

    skipBpqApp = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Skip sending the BPQ APPLICATION command. Useful when connecting
        directly to a node SSID that already runs the browser application.
      '';
    };

    transport = mkOption {
      type = types.enum [ "ax25" "vara_fm" "vara_hf" ];
      default = "ax25";
      description = ''
        Default transport for startup auto-connect and the Connect page:
        <literal>ax25</literal> (AGWPE), <literal>vara_fm</literal>, or
        <literal>vara_hf</literal> (VARA HF or Mercury).
      '';
    };

    varaHf = mkOption {
      type = mkVaraEndpoint {
        defaultCmdPort = 8300;
        defaultDataPort = 8301;
        bandwidthValues = [ "bw250" "bw500" "bw2300" "bw2750" ];
        defaultBandwidth = "bw500";
      };
      default = { };
      description = "VARA HF / Mercury endpoint.";
    };

    varaFm = mkOption {
      type = mkVaraEndpoint {
        defaultCmdPort = 8400;
        defaultDataPort = 8401;
        bandwidthValues = [ "vnarrow" "vwide" ];
        defaultBandwidth = "vwide";
      };
      default = { };
      description = "VARA FM endpoint.";
    };

    cache = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the client-side page cache.";
      };

      maxBytes = mkOption {
        type = types.int;
        default = 209715200;
        description = "Maximum page-cache size in bytes (default 200 MiB).";
      };

      maxTtlSeconds = mkOption {
        type = types.int;
        default = 86400;
        description = "Maximum cache entry lifetime in seconds.";
      };

      dir = mkOption {
        type = types.str;
        default = "/var/cache/packet-browser";
        description = "Cache directory.";
      };
    };

    connection = {
      responseTimeoutSecs = mkOption {
        type = types.int;
        default = 30;
        description = "Timeout in seconds for a response from the server.";
      };

      autoReconnect = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically reconnect the modem after a transport loss.";
      };
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
        ExecStart = escapeShellArgs execArgs;
        Restart = "on-failure";
        RestartSec = 5;

        CacheDirectory = "packet-browser";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
