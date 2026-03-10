# LinBPQ NixOS Package

LinBPQ is a Linux implementation of the BPQ packet radio networking system, providing a full-featured packet radio BBS, network node, and gateway.

## Installation

Add to your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

let
  ham-packages = builtins.fetchGit {
    url = "https://github.com/ben-kuhn/nix-ham-packages";
    ref = "main";
  };
in
{
  nixpkgs.overlays = [
    (import ham-packages)
  ];

  imports = [
    "${ham-packages}/linbpq/module.nix"
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Initial Setup

1. Create the configuration file:

```bash
sudo nano /etc/linbpq/bpq32.cfg
```

2. Set ownership and start the service:

```bash
sudo chown -R bpq:bpq /etc/linbpq
sudo systemctl start linbpq
```

For configuration file syntax and options, see the [official LinBPQ documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm).

## Module Options

```nix
services.linbpq = {
  enable = true;

  # User and group (created automatically)
  user = "bpq";
  group = "bpq";

  # Directory paths
  configDir = "/etc/linbpq";         # Configuration files (bpq32.cfg)
  dataDir = "/var/lib/linbpq";       # Runtime data
  logDir = "/var/log/linbpq";        # Log files

  # Firewall
  openFirewall = false;
  firewallPorts = [ 8010 8011 8080 ];  # TCP ports
  firewallUDPPorts = [ ];              # UDP ports
};
```

## Default Ports

| Port | Description |
|------|-------------|
| 8010 | Telnet access (TCPPORT) |
| 8011 | FBB/QtTermTCP (FBBPORT) |
| 8080 | Web interface (HTTPPORT) |

## Service Management

```bash
sudo systemctl start linbpq
sudo systemctl stop linbpq
sudo systemctl restart linbpq
sudo systemctl status linbpq

# View logs
journalctl -u linbpq -f
```

## Manual Execution

For testing outside of systemd:

```bash
linbpq -c /etc/linbpq -d /var/lib/linbpq -l /var/log/linbpq
```

## Documentation

- [LinBPQ Installation Guide](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [Telnet Server Configuration](https://www.cantab.net/users/john.wiseman/Documents/TelnetServer.htm)
- [G8BPQ GitHub Repository](https://github.com/g8bpq/linbpq)
