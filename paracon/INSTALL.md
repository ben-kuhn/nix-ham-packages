# Installing Paracon on NixOS

Paracon is a text-mode packet radio terminal. It supports multiple
simultaneous AX.25 connected-mode sessions, unproto (UI/datagram) chat, and
talks to any AGWPE-compatible server.

## Requirements

Paracon is only a client: you also need an AGWPE server, such as:

- [Direwolf](https://github.com/wb2osz/direwolf) (sound-card TNC)
- `tncd` from this overlay (KISS/serial/TCP/Bluetooth TNC bridge)
- LinBPQ 6.0.24.73 or later

The `pyham-ax25` and `pyham-pe` libraries it needs are packaged in this
overlay and pulled in automatically.

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

  environment.systemPackages = with pkgs; [
    paracon
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Running

Paracon writes its configuration and log files to the **current directory**,
so start it somewhere writable:

```bash
mkdir -p ~/.local/share/paracon
cd ~/.local/share/paracon
paracon
```

On first start, use the configuration screen to point Paracon at your AGWPE
server's host and port (Direwolf defaults to port 8000). The interface is
keyboard-driven; the status bar and built-in help screen list the key
bindings.

## Documentation

- [Paracon User Guide](https://paracon.readthedocs.io/en/latest/)
- [Paracon GitHub Repository](https://github.com/mfncooper/paracon)
