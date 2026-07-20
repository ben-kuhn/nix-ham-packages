# NixOS Amateur Radio Packages Overlay

This repository contains NixOS packages for amateur radio software.

## Included Packages

| Package | Description |
|---------|-------------|
| `cwdaemon` | Morse code (CW) keying daemon (UDP-controlled, used by Not1MM) |
| `linbpq` | Linux BPQ Packet Radio Node (includes NixOS module for service) |
| `ldsped` | Open-source AGW Packet Engine replacement for AX.25 packet radio |
| `mercury-modem` | Mercury Modem for HF digital communications |
| `not1mm` | Amateur radio contest logger (PyQt6) — talks to rigctld and cwdaemon |
| `paracon` | Paracon packet radio terminal |
| `packet-browser-server` | Web page fetcher for AX.25 packet radio (includes NixOS module) |
| `packet-browser-client` | AGWPE client with web proxy interface (includes NixOS module) |
| `qtsoundmodem` | Qt-based sound modem for packet radio |
| `qttermtcp` | Qt Terminal TCP client for BPQ packet nodes |
| `tncd` | AGWPE-to-KISS Translation Bridge (includes NixOS module for service) |
| `tuxlink` | Native Linux Winlink client (Rust + Tauri). Alpha. |

## Installation

### NixOS (Recommended)

Add the overlay to your `/etc/nixos/configuration.nix`:

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
    cwdaemon
    linbpq
    ldsped
    mercury-modem
    not1mm
    paracon
    packet-browser-server
    packet-browser-client
    qtsoundmodem
    qttermtcp
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

The packages are now available system-wide. No additional installation steps needed.

**Alternative: User-level installation**

If you prefer to install packages into your user profile instead of system-wide, add only the overlay to configuration.nix (omit `environment.systemPackages`), rebuild, then:

```bash
nix-env -iA nixos.packet-browser-client
nix-env -iA nixos.packet-browser-server
```

### Non-NixOS (Nix Package Manager)

For systems using the Nix package manager (not NixOS):

```bash
# Clone the overlay
git clone https://github.com/ben-kuhn/nix-ham-packages ~/.config/nixpkgs/overlays/nix-ham-packages

# Create symlink
ln -s ~/.config/nixpkgs/overlays/nix-ham-packages/default.nix ~/.config/nixpkgs/overlays/ham-radio.nix

# Install packages
nix-env -iA nixpkgs.packet-browser-client
nix-env -iA nixpkgs.packet-browser-server
nix-env -iA nixpkgs.qtsoundmodem
nix-env -iA nixpkgs.qttermtcp
nix-env -iA nixpkgs.paracon
nix-env -iA nixpkgs.ldsped
nix-env -iA nixpkgs.mercury-modem
nix-env -iA nixpkgs.not1mm
nix-env -iA nixpkgs.cwdaemon
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

## Packet Browser Service

Packet Browser is a client/server system for browsing web pages over AX.25 packet radio. The server fetches and sanitizes web pages using headless Chromium, while the client connects via AGWPE and provides a web proxy interface.

### Server Configuration

The server runs behind a BPQ node and handles web page fetching:

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
    "${ham-packages}/packet-browser-server/module.nix"
  ];

  services.packet-browser-server = {
    enable = true;
    listenPort = 63004;
    portalUrl = "https://www.zeroretries.radio";
    idleTimeoutMinutes = 10;
    brotliQuality = 11;
    blocklistEnabled = true;
    blocklistUrls = [
      "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/ultimate.txt"
    ];
    openFirewall = true;
  };
}
```

The server requires Chromium at runtime. The module automatically sets `CHROMIUM_PATH` to the Nix-packaged Chromium.

### Client Configuration

The client runs on your local machine and connects to AGWPE:

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
    "${ham-packages}/packet-browser-client/module.nix"
  ];

  services.packet-browser-client = {
    enable = true;
    myCallsign = "N0CALL";
    targetCallsign = "NODE1";
    agwpeHost = "127.0.0.1";
    agwpePort = 8000;
    bpqCommand = "WEB";
    listenAddr = "127.0.0.1:8080";
  };
}
```

After enabling the client service, open your browser to `http://localhost:8080` to access the web interface.

See [packet-browser documentation](https://github.com/ben-kuhn/docker-packet-browser) for full details on the client/server architecture and BPQ integration.

---

## Not1MM external daemons

Not1MM connects to two external daemons over the network:

- `rigctld` (radio control) — provided by `hamlib` in upstream nixpkgs. Install
  with `environment.systemPackages = [ pkgs.hamlib ];` and start `rigctld`
  yourself (e.g. via a systemd user service or a shell).
- `cwdaemon` (CW keying) — provided by this overlay (`pkgs.cwdaemon`). Start
  it manually with the appropriate keyer device.

Configure Not1MM to point at the host/port of each running daemon.

---

## Package Documentation

- [LinBPQ](linbpq/README.md) - Full BPQ node setup and configuration
- [ldsped](ldsped/INSTALL-NIXOS.md) - AGW Packet Engine setup
- [paracon](paracon/INSTALL.md) - Packet radio terminal
- [packet-browser](https://github.com/ben-kuhn/docker-packet-browser) - Web browser over AX.25 (client/server)
- [qtsoundmodem](qtsoundmodem/INSTALL.md) - Sound modem setup
- [qttermtcp](qttermtcp/INSTALL.md) - Terminal client
- [tncd](https://github.com/ben-kuhn/tncd) - AGWPE-to-KISS bridge

## Resources

- [NixOS Manual - Overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays)
- [LinBPQ Documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
