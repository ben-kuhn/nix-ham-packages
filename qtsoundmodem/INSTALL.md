# Installing QtSoundModem on NixOS

QtSoundModem is a Qt sound-card modem for packet radio. It is a multi-platform
port of UZ7HO's Sound Modem and supports multiple modems, baud rates from 300
to 4800, FX.25 and IL2P.

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

## Running

```bash
QtSoundModem
```

Or find "QtSoundModem" in your application menu.

In the GUI:

1. Select the sound-card capture and playback devices.
2. Configure one or more modems (baud rate, mode, KISS port).
3. Point your packet software (for example LinBPQ, Paracon or tncd) at the
   KISS TCP port you configured.

QtSoundModem needs access to your sound devices; on NixOS the desktop user is
normally in the `audio` group already.

## Documentation

- [QtSoundModem GitHub Repository](https://github.com/g8bpq/QtSoundModem)
- [OARC Wiki](https://wiki.oarc.uk/packet:qtsoundmodem)
- [QtSoundModem documentation](https://www.cantab.net/users/john.wiseman/Documents/QtSoundModem.html)
