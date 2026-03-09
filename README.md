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

## Installation

### 1. Clone the repository

```bash
git clone <repository-url> /etc/nixos/nix-ham-packages
```

### 2. Add to your NixOS configuration

Edit `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import /etc/nixos/nix-ham-packages)
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

### 3. Rebuild

```bash
sudo nixos-rebuild switch
```

---

## User-Level Installation (Nix Package Manager)

For non-NixOS systems using the Nix package manager:

### 1. Create user overlays directory

```bash
mkdir -p ~/.config/nixpkgs/overlays
```

### 2. Symlink the overlay

```bash
ln -s /path/to/nix-ham-packages/default.nix ~/.config/nixpkgs/overlays/ham-radio.nix
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

{
  nixpkgs.overlays = [
    (import /etc/nixos/nix-ham-packages)
  ];

  imports = [
    /etc/nixos/nix-ham-packages/linbpq/module.nix
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

Create the configuration file before starting:

```bash
sudo mkdir -p /var/lib/linbpq/logs
sudo nano /var/lib/linbpq/bpq32.cfg
sudo chown -R bpq:bpq /var/lib/linbpq
```

See [linbpq/README.md](linbpq/README.md) for full documentation.

---

## Package Documentation

- [LinBPQ](linbpq/README.md) - Full BPQ node setup and configuration
- [ldsped](ldsped/INSTALL-NIXOS.md) - AGW Packet Engine setup
- [paracon](paracon/INSTALL.md) - Packet radio terminal
- [qtsoundmodem](qtsoundmodem/INSTALL.md) - Sound modem setup
- [qttermtcp](qttermtcp/INSTALL.md) - Terminal client

## Resources

- [NixOS Manual - Overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays)
- [LinBPQ Documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [AX.25 for Linux](https://www.linux-ax25.org/)
