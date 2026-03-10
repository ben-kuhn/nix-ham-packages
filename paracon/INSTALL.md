# Installing Paracon on NixOS

## About Paracon

Paracon is a packet radio terminal application that runs in a terminal window. It provides a straightforward interface for ham radio packet communications.

**Key Features:**
- Multiple simultaneous AX.25 connected-mode sessions
- Unproto (datagram) mode for keyboard-to-keyboard chat
- Cross-platform text-based console interface
- AGWPE protocol compatibility with servers like Direwolf and ldsped
- Requires Python 3.9 or later

**Note:** Paracon is a terminal application, not a modem. You'll need a packet modem like QtSoundModem or Direwolf to handle the actual radio modulation/demodulation.

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

## Verifying Installation

After rebuilding, run `paracon` from the command line.

## Dependencies Included

This package automatically includes:
- **urwid** - Terminal UI library
- **pyham_ax25** - AX.25 packet handling library
- **pyham_pe** - AGWPE protocol client library

## Documentation

- Homepage: https://github.com/mfncooper/paracon
- License: MIT License
