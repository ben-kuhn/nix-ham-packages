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
sudo cp "$(dirname "$(readlink -f "$(which ldsped)")")/../share/doc/ldsped/ldsped.conf.example" /etc/ax25/ldsped.conf
sudo nano /etc/ax25/ldsped.conf
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
