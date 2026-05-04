# NixOS Amateur Radio Packages Overlay

This repository contains NixOS packages for amateur radio software.

## Included Packages

| Package | Description |
|---------|-------------|
| `linbpq` | Linux BPQ Packet Radio Node (includes NixOS module for service) |
| `ldsped` | Open-source AGW Packet Engine replacement for AX.25 packet radio |
| `mercury-modem` | Mercury Modem for HF digital communications |
| `paracon` | Paracon packet radio terminal |
| `qtsoundmodem` | Qt-based sound modem for packet radio |
| `qttermtcp` | Qt Terminal TCP client for BPQ packet nodes |
| `tncd` | AGWPE-to-KISS Translation Bridge (includes NixOS module for service) |

## Installation

### 1. Add to your NixOS configuration

Edit `/etc/nixos/configuration.nix`:

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

  environment.systemPackages = with pkgs; [
    linbpq
    ldsped
    mercury-modem
    paracon
    qtsoundmodem
    qttermtcp
  ];
}
```

### 2. Rebuild

```bash
sudo nixos-rebuild switch
```

---

## User-Level Installation (Nix Package Manager)

For non-NixOS systems using the Nix package manager:

### 1. Clone the repository

```bash
git clone https://github.com/ben-kuhn/nix-ham-packages ~/.config/nixpkgs/overlays/nix-ham-packages
```

### 2. Create overlay symlink

```bash
ln -s ~/.config/nixpkgs/overlays/nix-ham-packages/default.nix ~/.config/nixpkgs/overlays/ham-radio.nix
```

### 3. Install packages

```bash
nix-env -iA nixpkgs.qtsoundmodem
nix-env -iA nixpkgs.qttermtcp
nix-env -iA nixpkgs.paracon
nix-env -iA nixpkgs.ldsped
nix-env -iA nixpkgs.mercury-modem
```

---

## LinBPQ Service

LinBPQ includes a NixOS module for running as a systemd service:

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

Create the configuration file before starting:

```bash
sudo nano /etc/linbpq/bpq32.cfg
sudo chown -R bpq:bpq /etc/linbpq /var/lib/linbpq
sudo systemctl start linbpq
```

See [linbpq/README.md](linbpq/README.md) for module options.

---

## tncd Service

tncd includes a NixOS module for running as a systemd service:

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
    "${ham-packages}/tncd/module.nix"
  ];

  services.tncd = {
    enable = true;
    settings = {
      server = {
        listen_host = "0.0.0.0";
        listen_port = 8000;
        callsign = "N0CALL";
      };
      client = {
        type = "serial";
        device = "/dev/ttyUSB0";
        serial_baudrate = 9600;
        ota_baudrate = 1200;
      };
    };
  };
}
```

For Bluetooth TNC support, set `services.tncd.bluetooth.enable = true` and add a
`bluetooth` section to `settings`. See [tncd documentation](https://github.com/ben-kuhn/tncd/blob/main/nix/README.md)
for full module options.

---

## Package Documentation

- [LinBPQ](linbpq/README.md) - Full BPQ node setup and configuration
- [ldsped](ldsped/INSTALL-NIXOS.md) - AGW Packet Engine setup
- [paracon](paracon/INSTALL.md) - Packet radio terminal
- [qtsoundmodem](qtsoundmodem/INSTALL.md) - Sound modem setup
- [qttermtcp](qttermtcp/INSTALL.md) - Terminal client
- [tncd](https://github.com/ben-kuhn/tncd) - AGWPE-to-KISS bridge

## Resources

- [NixOS Manual - Overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays)
- [LinBPQ Documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
