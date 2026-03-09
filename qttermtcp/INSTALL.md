# Installing QtTermTCP on NixOS

## About QtTermTCP

QtTermTCP is a GUI terminal for connecting to BPQ packet nodes. It supports FBB mode, AGWPE, KISS, and VARA modems.

## Recommended: Using the Overlay

Use the nix-ham-packages overlay for the cleanest installation:

```nix
{ config, pkgs, ... }:

{
  # Import the overlay (adjust path to your clone location)
  nixpkgs.overlays = [
    (import /path/to/nix-ham-packages)
  ];

  # Add qttermtcp to your system packages
  environment.systemPackages = with pkgs; [
    qttermtcp
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
- Run `QtTermTCP` from the command line
- Find "QtTermTCP" in your application menu under Network/HamRadio

## Using with QtSoundModem or LinBPQ

For a complete packet radio setup:

```nix
nixpkgs.overlays = [
  (import /path/to/nix-ham-packages)
];

environment.systemPackages = with pkgs; [
  qtsoundmodem
  qttermtcp
];
```

To connect to a LinBPQ node, use the FBBPORT (default 8011) in QtTermTCP's connection settings.

## Documentation

- Homepage: https://github.com/g8bpq/QtTermTCP
