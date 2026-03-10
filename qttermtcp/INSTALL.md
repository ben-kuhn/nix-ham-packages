# Installing QtTermTCP on NixOS

QtTermTCP is a GUI terminal for connecting to BPQ packet nodes.

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

## Running

```bash
QtTermTCP
```

Or find "QtTermTCP" in your application menu.

## Documentation

- [QtTermTCP GitHub Repository](https://github.com/g8bpq/QtTermTCP)
