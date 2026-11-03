# LinBPQ NixOS Package

LinBPQ is a Linux implementation of the BPQ packet radio networking system:
a BBS, network node and gateway supporting AX.25, VARA, ARDOP and related
modes.

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

The module creates `/etc/linbpq`, `/var/lib/linbpq` and `/var/log/linbpq`
with the configured ownership. It does **not** generate a `bpq32.cfg`; the
service refuses to start until one exists.

```bash
sudoedit /etc/linbpq/bpq32.cfg
sudo systemctl start linbpq
```

For configuration syntax, see the
[LinBPQ documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm).
Example configuration files are installed under
`share/linbpq/examples` in the package output.

## Module Options

```nix
services.linbpq = {
  enable = true;

  package = pkgs.linbpq;       # package to run
  user = "bpq";                # service account
  group = "bpq";               # service group

  configDir = "/etc/linbpq";       # bpq32.cfg location
  dataDir = "/var/lib/linbpq";     # user data (mail, BBS, state)
  logDir = "/var/log/linbpq";      # log files

  openFirewall = false;
  firewallPorts = [ 8010 8011 8080 ];
  firewallUDPPorts = [ ];

  extraArgs = [ ];             # extra arguments appended to the linbpq command
};
```

All three directories are created by systemd-tmpfiles and are writable by
the service account. The module runs LinBPQ with `CAP_NET_BIND_SERVICE`,
`CAP_NET_RAW` and `CAP_NET_ADMIN` so it can bind low ports and use raw
sockets without running as root.

## Default Ports

When `openFirewall` is enabled, the module's `firewallPorts` default opens
these TCP ports:

| Port | Description |
|------|-------------|
| 8010 | Telnet (TCPPORT) |
| 8011 | FBB/QtTermTCP (FBBPORT) |
| 8080 | Web interface (HTTPPORT) |

These are firewall defaults only: the ports LinBPQ actually listens on are
defined in `bpq32.cfg`. Make the two match, or set `firewallPorts` to the
ports you configure. With the default `openFirewall = false`, nothing is
opened automatically.

## Service Management

```bash
sudo systemctl start linbpq
sudo systemctl stop linbpq
sudo systemctl restart linbpq
sudo systemctl status linbpq
journalctl -u linbpq -f
```

## Documentation

- [LinBPQ Installation Guide](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [G8BPQ GitHub Repository](https://github.com/g8bpq/linbpq)
