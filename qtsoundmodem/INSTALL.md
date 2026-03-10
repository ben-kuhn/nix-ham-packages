# Installing QtSoundModem on NixOS

QtSoundModem is a sound modem for packet radio.

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

## Documentation

- [QtSoundModem GitHub Repository](https://github.com/g8bpq/QtSoundModem)
- [OARC Wiki](https://wiki.oarc.uk/packet:qtsoundmodem)
