# LinBPQ NixOS Package

LinBPQ is a Linux implementation of the BPQ packet radio networking system, providing a full-featured packet radio BBS, network node, and gateway.

## Features

- Packet radio BBS with full mail and bulletin support
- Network node with NETROM and other routing protocols
- Support for multiple TNCs and modems (VARA, ARDOP, SoundModem, etc.)
- Web-based management interface
- MQTT integration
- APRS support
- Chat server

## Quick Start

### 1. Add the overlay and module to your NixOS configuration

Edit `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  imports = [
    /path/to/nix-ham-packages/linbpq/module.nix
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

### 2. Create the configuration file

```bash
sudo mkdir -p /var/lib/linbpq/logs
sudo nano /var/lib/linbpq/bpq32.cfg
```

Add a minimal configuration (replace `N0CALL` with your callsign):

```
; LinBPQ Minimal Configuration
SIMPLE
NODECALL=N0CALL
NODEALIAS=MYNODE
LOCATOR=AB12cd

; Telnet port with web interface
PORT
PORTNUM=1
ID=Telnet
DRIVER=Telnet
CONFIG
TCPPORT=8010
FBBPORT=8011
HTTPPORT=8080
ENDPORT
```

### 3. Set permissions and rebuild

```bash
sudo chown -R bpq:bpq /var/lib/linbpq
sudo nixos-rebuild switch
```

### 4. Access LinBPQ

- **Web interface**: http://localhost:8080
- **Telnet**: `telnet localhost 8010`
- **FBB/QtTermTCP**: Connect to port 8011

---

## Installation Methods

### Method 1: NixOS Module (Recommended)

The NixOS module handles user creation, directory setup, systemd service, and firewall configuration automatically.

```nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  imports = [
    /path/to/nix-ham-packages/linbpq/module.nix
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

### Method 2: Manual Installation

Build and install the package without the module:

```bash
# Build the package
nix-build /path/to/nix-ham-packages -A linbpq

# Or install to user profile
nix-env -f /path/to/nix-ham-packages -iA linbpq
```

---

## Running LinBPQ

### With systemd (NixOS Module)

```bash
# Start the service
sudo systemctl start linbpq

# Stop the service
sudo systemctl stop linbpq

# Restart the service
sudo systemctl restart linbpq

# Enable at boot (automatic with module)
sudo systemctl enable linbpq

# View live logs
journalctl -u linbpq -f

# View recent logs
journalctl -u linbpq -n 100 --no-pager

# Check service status
sudo systemctl status linbpq
```

### Manual Execution

For testing or debugging, run LinBPQ directly:

```bash
# Basic execution
linbpq -d /var/lib/linbpq -c /var/lib/linbpq -l /var/lib/linbpq/logs

# Run in background (daemon mode)
linbpq -d /var/lib/linbpq -c /var/lib/linbpq -l /var/lib/linbpq/logs daemon

# With root privileges (required for some network features)
sudo linbpq -d /var/lib/linbpq -c /var/lib/linbpq -l /var/lib/linbpq/logs
```

### Command Line Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-d` | `--datadir` | Data/working directory (where runtime files are stored) |
| `-c` | `--configdir` | Configuration directory (where bpq32.cfg is located) |
| `-l` | `--logdir` | Log file directory |
| `-h` | `--help` | Show help message |
| `-v` | | Show version information |

---

## NixOS Module Options

```nix
services.linbpq = {
  # Enable the LinBPQ service
  enable = true;

  # Package to use (default: pkgs.linbpq)
  package = pkgs.linbpq;

  # User and group (created automatically)
  user = "bpq";
  group = "bpq";

  # Directory paths
  dataDir = "/var/lib/linbpq";       # Working directory
  configDir = "/var/lib/linbpq";     # Config file location
  logDir = "/var/lib/linbpq/logs";   # Log files

  # Firewall settings
  openFirewall = false;              # Auto-open ports
  firewallPorts = [ 8010 8011 8080 ];  # TCP ports to open
  firewallUDPPorts = [ ];            # UDP ports to open

  # Extra command-line arguments
  extraArgs = [ ];
};
```

### Example: Custom Directories

```nix
services.linbpq = {
  enable = true;
  dataDir = "/var/lib/linbpq";
  configDir = "/etc/linbpq";
  logDir = "/var/log/linbpq";
  openFirewall = true;
  firewallPorts = [ 8010 8011 8080 8015 ];  # Include APRS port
};
```

---

## Configuration

### Directory Structure

```
/var/lib/linbpq/
├── bpq32.cfg          # Main configuration file (required)
├── logs/              # Log files
│   ├── BPQDebug.log
│   └── ...
├── HTML/              # Web interface files (optional)
└── *.txt              # Various data files (created at runtime)
```

### Common Ports

LinBPQ uses ports above 1024 by default since it runs as a non-root user.

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 8010 | TCP | TCPPORT | Telnet access to node |
| 8011 | TCP | FBBPORT | FBB forwarding / QtTermTCP |
| 8080 | TCP | HTTPPORT | Web management interface |
| 8015 | TCP | APRS-IS | APRS Internet Service (optional) |

These ports are configured in the Telnet port section of `bpq32.cfg`.

### Minimal bpq32.cfg

```
; LinBPQ Configuration
; Documentation: https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm

SIMPLE
NODECALL=N0CALL          ; Your callsign
NODEALIAS=MYNODE         ; Node alias (up to 6 chars)
LOCATOR=AB12cd           ; Maidenhead grid locator

; Telnet port - required for web management
PORT
PORTNUM=1
ID=Telnet
DRIVER=Telnet
CONFIG
TCPPORT=8010             ; Telnet connections
FBBPORT=8011             ; FBB/QtTermTCP connections
HTTPPORT=8080            ; Web interface
LOGINPROMPT=Callsign:
PASSWORDPROMPT=Password:
MAXSESSIONS=10
ENDPORT
```

### Full Example with KISS TNC

```
; LinBPQ Configuration with KISS TNC

SIMPLE
NODECALL=N0CALL
NODEALIAS=MYNODE
LOCATOR=AB12cd

; Telnet port with web interface
PORT
PORTNUM=1
ID=Telnet
DRIVER=Telnet
CONFIG
TCPPORT=8010
FBBPORT=8011
HTTPPORT=8080
LOGINPROMPT=Callsign:
PASSWORDPROMPT=Password:
MAXSESSIONS=10
ENDPORT

; KISS TNC on serial port
PORT
PORTNUM=2
ID=KISS TNC
TYPE=ASYNC
PROTOCOL=KISS
FULLDUP=0
FRACK=5000
RESPTIME=1000
RETRIES=5
MAXFRAME=4
PACLEN=128
TXDELAY=300
SLOTTIME=100
PERSIST=64
COMPORT=/dev/ttyUSB0
SPEED=9600
ENDPORT
```

### Example with QtSoundModem (AGWPE)

```
; LinBPQ with QtSoundModem via AGWPE protocol

SIMPLE
NODECALL=N0CALL
NODEALIAS=MYNODE
LOCATOR=AB12cd

; Telnet with web interface
PORT
PORTNUM=1
ID=Telnet
DRIVER=Telnet
CONFIG
TCPPORT=8010
FBBPORT=8011
HTTPPORT=8080
ENDPORT

; AGWPE connection to QtSoundModem
PORT
PORTNUM=2
ID=SoundModem
DRIVER=AGWPE
CONFIG
AGWPORT=8000           ; QtSoundModem AGWPE port
AGWHOST=127.0.0.1
AGWPACKET=1
ENDPORT
```

---

## Troubleshooting

### Service fails to start

```bash
# Check if config exists
ls -la /var/lib/linbpq/bpq32.cfg

# View service logs
journalctl -u linbpq -n 50 --no-pager

# Check for syntax errors - run manually
sudo -u bpq linbpq -d /var/lib/linbpq -c /var/lib/linbpq -l /var/lib/linbpq/logs
```

### Permission denied errors

```bash
# Fix ownership
sudo chown -R bpq:bpq /var/lib/linbpq

# Fix permissions
sudo chmod 750 /var/lib/linbpq
sudo chmod 640 /var/lib/linbpq/bpq32.cfg
```

### Cannot bind to port

LinBPQ needs network capabilities for privileged ports (< 1024). The NixOS module sets these automatically. For manual runs:

```bash
# Run as root
sudo linbpq -d /var/lib/linbpq -c /var/lib/linbpq -l /var/lib/linbpq/logs

# Or use ports > 1024 in your configuration (recommended)
```

### Web interface not accessible

1. Check the service is running: `systemctl status linbpq`
2. Verify HTTPPORT is set in bpq32.cfg within a Telnet PORT section
3. Check firewall: `sudo iptables -L -n | grep 8080`
4. Ensure `openFirewall = true` in NixOS config

### TNC not connecting

1. Check serial port permissions: `ls -la /dev/ttyUSB0`
2. Add user to dialout group or configure udev rules
3. Verify baud rate matches TNC settings

```nix
# In configuration.nix - add bpq user to dialout group
users.users.bpq.extraGroups = [ "dialout" ];
```

### View debug information

Enable verbose logging in bpq32.cfg:

```
; Add to bpq32.cfg
LOGDIR=/var/lib/linbpq/logs
```

---

## Connecting to LinBPQ

### Via Telnet

```bash
telnet localhost 8010
```

### Via Web Browser

Navigate to http://localhost:8080 (or your configured HTTPPORT).

### Via QtTermTCP

Connect to `localhost:8011` using FBB mode.

### Via Packet Radio

Connect to your node's callsign via RF using a TNC or software modem.

---

## Integration with Other Packages

### With QtSoundModem

```nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  imports = [
    /path/to/nix-ham-packages/linbpq/module.nix
  ];

  environment.systemPackages = with pkgs; [
    qtsoundmodem
    qttermtcp
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

Run QtSoundModem first, then configure LinBPQ to connect via AGWPE.

---

## Backup and Restore

### Backup

```bash
# Backup configuration and data
sudo tar -czvf linbpq-backup.tar.gz /var/lib/linbpq
```

### Restore

```bash
# Restore from backup
sudo tar -xzvf linbpq-backup.tar.gz -C /
sudo chown -R bpq:bpq /var/lib/linbpq
sudo systemctl restart linbpq
```

---

## Documentation

- [LinBPQ Installation Guide](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [Telnet Server Configuration](https://www.cantab.net/users/john.wiseman/Documents/TelnetServer.htm)
- [G8BPQ GitHub Repository](https://github.com/g8bpq/linbpq)
- [LinBPQ Mailing List](https://groups.google.com/g/linbpq)

## License

LinBPQ is released under the GPL-3.0+ license.
