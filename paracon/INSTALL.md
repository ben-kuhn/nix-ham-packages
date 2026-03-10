# Installing Paracon on NixOS

Paracon is a packet radio terminal application.

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

```bash
paracon
```

## Documentation

- [Paracon GitHub Repository](https://github.com/mfncooper/paracon)
