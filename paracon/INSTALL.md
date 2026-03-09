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

## Recommended: Using the Overlay

Use the nix-ham-packages overlay for the cleanest installation:

```nix
{ config, pkgs, ... }:

{
  # Import the overlay (adjust path to your clone location)
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  # Add paracon to your system packages
  environment.systemPackages = with pkgs; [
    paracon
  ];
}
```

## Apply the Configuration

After editing `/etc/nixos/configuration.nix`, run:

```bash
sudo nixos-rebuild switch
```

## Verifying Installation

After rebuilding, you should be able to:
- Run `paracon` from the command line

## Complete Packet Radio Setup

For a full packet radio station, you'll likely want:
- **QtSoundModem** or **Direwolf** - Sound modem for radio modulation/demodulation
- **Paracon** or **QtTermTCP** - Terminal for packet communications

You can install multiple packages using the overlay:

```nix
nixpkgs.overlays = [
  (import /path/to/nix-ham-packages)
];

environment.systemPackages = with pkgs; [
  paracon
  qtsoundmodem
  qttermtcp
];
```

## Dependencies Included

This package automatically includes:
- **urwid** - Terminal UI library
- **pyham_ax25** - AX.25 packet handling library
- **pyham_pe** - AGWPE protocol client library

All dependencies are bundled and will be installed automatically.

## Documentation

- Homepage: https://github.com/mfncooper/paracon
- Author: Martin F N Cooper (mfncooper)
- License: MIT License
