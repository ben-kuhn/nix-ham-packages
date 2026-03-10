# Installing QtSoundModem on NixOS

## About QtSoundModem

QtSoundModem is a multi-platform sound modem for packet radio, based on UZ7HO's Sound Modem. It uses your computer's sound interface to send and receive AX.25 packet radio data.

**Key Features:**
- Supports baud rates from 300 to 9600
- Modern protocol extensions: FX.25 and IL2P
- Multiple modems with different KISS interfaces (up to 4 ports)
- Compatible with various sound systems (ALSA, PulseAudio)

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
    qtsoundmodem
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Verifying Installation

After rebuilding:
- Run `QtSoundModem` from the command line
- Find "QtSoundModem" in your application menu under Network/HamRadio

## Documentation

- Homepage: https://github.com/g8bpq/QtSoundModem
- Hibby's Guide: https://guide.hibbian.org/modems/qtsm/
- OARC Wiki: https://wiki.oarc.uk/packet:qtsoundmodem
