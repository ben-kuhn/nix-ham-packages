# Installing QtTermTCP on NixOS

QtTermTCP is a Qt terminal client for BPQ packet nodes. It supports BPQ's
FBB mode as well as AGWPE, KISS and VARA modems.

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

Use the connection dialog to choose a transport:

- **BPQ/FBB** — connect to a BPQ node's FBB port (8011 by default).
- **AGWPE** — connect to an AGWPE server such as Direwolf or tncd.
- **KISS** — connect directly to a KISS TCP port.
- **VARA** — connect to a VARA-compatible modem such as xara.

## Documentation

- [QtTermTCP GitHub Repository](https://github.com/g8bpq/QtTermTCP)
- [QtTermTCP documentation](https://www.cantab.net/users/john.wiseman/Documents/QtTermTCP.html)
