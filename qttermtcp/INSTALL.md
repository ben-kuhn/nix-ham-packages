# Installing QtTermTCP on NixOS

## About QtTermTCP

QtTermTCP is a GUI terminal for connecting to BPQ packet nodes. It supports FBB mode, AGWPE, KISS, and VARA modems.

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
    qttermtcp
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Verifying Installation

After rebuilding:
- Run `QtTermTCP` from the command line
- Find "QtTermTCP" in your application menu under Network/HamRadio

## Using with QtSoundModem or LinBPQ

For a complete packet radio setup:

```nix
environment.systemPackages = with pkgs; [
  qtsoundmodem
  qttermtcp
];
```

To connect to a LinBPQ node, use the FBBPORT (default 8011) in QtTermTCP's connection settings.

## Documentation

- Homepage: https://github.com/g8bpq/QtTermTCP
