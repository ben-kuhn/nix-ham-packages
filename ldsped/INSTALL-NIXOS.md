# Installing ldsped on NixOS

ldsped is an open-source replacement for AGWPE (AGW Packet Engine).

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
    ldsped
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Configuration

Copy the example configuration:

```bash
sudo mkdir -p /etc/ax25
sudo cp $(nix eval --raw nixpkgs#ldsped.outPath 2>/dev/null || echo /nix/store/*-ldsped-*/)/etc/ax25/ldsped.conf.example /etc/ax25/ldsped.conf
sudo nano /etc/ax25/ldsped.conf
```

Or find it manually:

```bash
find /nix/store -name "ldsped.conf.example" 2>/dev/null | head -1
```

## Running

ldsped requires root privileges:

```bash
sudo ldsped
```

## Systemd Service (Optional)

Add to your configuration.nix:

```nix
systemd.services.ldsped = {
  description = "LDSPED - AGW Packet Engine replacement";
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.ldsped}/bin/ldsped";
    Restart = "on-failure";
  };
};
```

## Documentation

- [ldsped GitHub Repository](https://github.com/ampledata/ldsped)
