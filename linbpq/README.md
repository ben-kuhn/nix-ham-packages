# LinBPQ NixOS Package

LinBPQ is a Linux implementation of the BPQ packet radio networking system.

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

Create the configuration file:

```bash
sudo nano /etc/linbpq/bpq32.cfg
sudo chown -R bpq:bpq /etc/linbpq /var/lib/linbpq
sudo systemctl start linbpq
```

For configuration syntax, see the [LinBPQ documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm).

## Module Options

```nix
services.linbpq = {
  enable = true;
  user = "bpq";
  group = "bpq";

  configDir = "/etc/linbpq";       # bpq32.cfg location
  dataDir = "/var/lib/linbpq";     # User data (mail, BBS, state)
  logDir = "/var/log/linbpq";      # Log files

  openFirewall = false;
  firewallPorts = [ 8010 8011 8080 ];
  firewallUDPPorts = [ ];
};
```

## Default Ports

| Port | Description |
|------|-------------|
| 8010 | Telnet (TCPPORT) |
| 8011 | FBB/QtTermTCP (FBBPORT) |
| 8080 | Web interface (HTTPPORT) |

## Service Management

```bash
sudo systemctl start linbpq
sudo systemctl stop linbpq
sudo systemctl status linbpq
journalctl -u linbpq -f
```

## Documentation

- [LinBPQ Installation Guide](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [G8BPQ GitHub Repository](https://github.com/g8bpq/linbpq)
