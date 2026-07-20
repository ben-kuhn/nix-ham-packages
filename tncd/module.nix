{ config, lib, pkgs, ... }:

let
  cfg = config.services.tncd;
  iniFormat = pkgs.formats.ini {};
  configFile = if cfg.configFile != null
    then cfg.configFile
    else iniFormat.generate "tncd.ini" cfg.settings;
  # The Go tncd binary has native D-Bus Bluetooth SPP built in — no rebuild
  # variant needed (unlike the 1.x Python package's bluetoothSupport override).
  finalPackage = cfg.package;
in {
  options.services.tncd = {

    enable = lib.mkEnableOption "AGWPE-to-KISS bridge";

    package = lib.mkPackageOption pkgs "tncd" {};

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to an existing tncd.ini file.  When set, <option>settings</option>
        is ignored and this file is passed directly to the bridge.
      '';
    };

    settings = lib.mkOption {
      type = iniFormat.type;
      description = ''
        tncd configuration written as a Nix attribute set.  Generates
        <filename>/etc/tncd.ini</filename> automatically.  Ignored when
        <option>configFile</option> is set.
      '';
      default = {};
      example = lib.literalExpression ''
        {
          server = {
            listen_host = "0.0.0.0";
            listen_port = 8000;
            callsign = "N0CALL";
          };
          "client.0" = {
            type = "serial";
            device = "/dev/ttyUSB0";
            serial_baudrate = 9600;
            ota_baudrate = 1200;    # over-the-air baud rate (for T1/T2 timers)
            # Optional serial port settings
            # parity = "N";      # N=none O=odd E=even M=mark S=space
            # stopbits = 1;      # 1, 1.5, or 2
            # rtscts = false;    # RTS/CTS hardware flow control
            # init_string = "INT KISS\r";  # command to enter KISS mode
            # init_delay = 1.0;            # seconds to wait after init_string
          };
        }
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "tncd";
      description = "User account under which tncd runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "tncd";
      description = "Group under which tncd runs.";
    };

    bluetooth = {
      enable = lib.mkEnableOption "Bluetooth SPP support (adds the user to the bluetooth group and orders tncd after bluetooth.service; the Go binary's D-Bus SPP support is always built in)";
    };

  };

  config = lib.mkIf cfg.enable {

    users.users = lib.mkIf (cfg.user == "tncd") {
      tncd = {
        isSystemUser = true;
        group = cfg.group;
        # dialout allows access to serial/rfcomm devices without root.
        extraGroups = [ "dialout" ]
          ++ lib.optionals cfg.bluetooth.enable [ "bluetooth" ];
        description = "tncd service user";
      };
    };

    users.groups = lib.mkIf (cfg.group == "tncd") {
      tncd = {};
    };

    systemd.services.tncd = {
      description = "AGWPE-to-KISS Translation Bridge";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]
        ++ lib.optionals cfg.bluetooth.enable [ "bluetooth.service" ];
      wants = lib.optionals cfg.bluetooth.enable [ "bluetooth.service" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${finalPackage}/bin/tncd -c ${configFile}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

  };
}
