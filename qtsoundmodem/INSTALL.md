# Installing QtSoundModem on NixOS

## About QtSoundModem

QtSoundModem is a multi-platform sound modem for packet radio, based on UZ7HO's Sound Modem. It uses your computer's sound interface to send and receive AX.25 packet radio data.

**Key Features:**
- Supports baud rates from 300 to 4800
- Modern protocol extensions: FX.25 and IL2P
- Multiple modems with different KISS interfaces (up to 4 ports)
- Compatible with various sound systems (ALSA, PulseAudio)

**Note:** QtSoundModem only handles modulation/demodulation. You'll need a packet terminal like QtTermTCP or LinBPQ to interact with other packet stations.

## Recommended: Using the Overlay

Use the nix-ham-packages overlay for the cleanest installation:

```nix
{ config, pkgs, ... }:

{
  # Import the overlay (adjust path to your clone location)
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  # Add qtsoundmodem to your system packages
  environment.systemPackages = with pkgs; [
    qtsoundmodem
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
- Run `QtSoundModem` from the command line
- Find "QtSoundModem" in your application menu under Network/HamRadio

## Using with QtTermTCP or LinBPQ

For a complete packet radio setup, you'll likely want both QtSoundModem (for modem functionality) and a terminal application:

```nix
nixpkgs.overlays = [
  (import /path/to/nix-ham-packages)
];

environment.systemPackages = with pkgs; [
  qtsoundmodem
  qttermtcp
  # Or use linbpq for a full node setup
];
```

## Documentation

- Homepage: https://github.com/g8bpq/QtSoundModem
- Hibby's Guide: https://guide.hibbian.org/modems/qtsm/
- OARC Wiki: https://wiki.oarc.uk/packet:qtsoundmodem
