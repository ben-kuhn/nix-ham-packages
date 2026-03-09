# Installing ldsped on NixOS (Non-Flakes)

This guide explains how to install the `ldsped` package on a NixOS system without using flakes.

## Prerequisites

- A working NixOS installation
- Root access (sudo) to modify system configuration
- The `ldsped-package` directory containing `default.nix`

## Installation Methods

### Method 1: Add to System Configuration (Recommended)

This method installs ldsped system-wide and makes it available to all users.

#### Step 1: Copy the package to a permanent location

```bash
sudo mkdir -p /etc/nixos/packages
sudo cp /path/to/ldsped-package/default.nix /etc/nixos/packages/ldsped.nix
```

#### Step 2: Edit your NixOS configuration

Open `/etc/nixos/configuration.nix` and add the following:

```nix
{ config, pkgs, lib, ... }:

let
  ldsped = pkgs.callPackage ./packages/ldsped.nix { };
in
{
  # ... your existing configuration ...

  environment.systemPackages = with pkgs; [
    # ... your other packages ...
    ldsped
  ];
}
```

#### Step 3: Rebuild the system

```bash
sudo nixos-rebuild switch
```

---

### Method 2: Using a Local Overlay

Overlays allow you to extend or modify the nixpkgs package set.

#### Step 1: Create the overlay directory

```bash
sudo mkdir -p /etc/nixos/overlays
sudo cp /path/to/ldsped-package/default.nix /etc/nixos/overlays/ldsped.nix
```

#### Step 2: Create the overlay file

Create `/etc/nixos/overlays/default.nix`:

```nix
self: super: {
  ldsped = super.callPackage ./ldsped.nix { };
}
```

#### Step 3: Configure NixOS to use the overlay

Edit `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (import ./overlays)
  ];

  environment.systemPackages = with pkgs; [
    ldsped
  ];
}
```

#### Step 4: Rebuild the system

```bash
sudo nixos-rebuild switch
```

---

### Method 3: User-Level Installation with nix-env

This method installs ldsped only for the current user.

#### Step 1: Build and install directly

```bash
cd /path/to/ldsped-package
nix-env -f default.nix -i
```

Or install without changing directory:

```bash
nix-env -f /path/to/ldsped-package/default.nix -i
```

---

### Method 4: Add to ~/.config/nixpkgs/overlays

For user-specific overlays that don't require root:

#### Step 1: Create the user overlay directory

```bash
mkdir -p ~/.config/nixpkgs/overlays
cp /path/to/ldsped-package/default.nix ~/.config/nixpkgs/overlays/ldsped.nix
```

#### Step 2: Create the overlay

Create `~/.config/nixpkgs/overlays/ldsped-overlay.nix`:

```nix
self: super: {
  ldsped = super.callPackage ./ldsped.nix { };
}
```

#### Step 3: Install using nix-env

```bash
nix-env -iA nixos.ldsped
```

---

## Hash Updates

The package includes a pre-computed SHA256 hash for the source. However, since the package tracks the `master` branch, you may need to update the hash if the upstream repository changes.

If the build fails with a hash mismatch:

```
error: hash mismatch in fixed-output derivation '/nix/store/...':
         specified: sha256-abc...
            got:    sha256-xyz...
```

Copy the hash from the "got:" line and update `default.nix`:

```nix
src = fetchFromGitHub {
  owner = "ampledata";
  repo = "ldsped";
  rev = "master";
  sha256 = "sha256-xyz...";  # Use the hash from "got:"
};
```

Alternatively, use `nix-prefetch-url` to get the current hash:

```bash
nix-prefetch-url --unpack https://github.com/ampledata/ldsped/archive/refs/heads/master.tar.gz
```

---

## Post-Installation Configuration

### Configuration File

After installation, copy the example configuration file:

```bash
sudo mkdir -p /etc/ax25
sudo cp $(nix-build /path/to/ldsped-package)/etc/ax25/ldsped.conf.example /etc/ax25/ldsped.conf
```

Or if you've installed it system-wide, find the package path and copy:

```bash
sudo cp $(dirname $(which ldsped))/../etc/ax25/ldsped.conf.example /etc/ax25/ldsped.conf
```

Edit `/etc/ax25/ldsped.conf` to match your setup.

### Running ldsped

ldsped requires root privileges because it connects to system sockets:

```bash
sudo ldsped
```

### Creating a systemd Service (Optional)

Add to your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

let
  ldsped = pkgs.callPackage ./packages/ldsped.nix { };
in
{
  environment.systemPackages = [ ldsped ];

  # Create the service
  systemd.services.ldsped = {
    description = "LDSPED - AGW Packet Engine replacement";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${ldsped}/bin/ldsped";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Ensure the config directory exists
  environment.etc."ax25/ldsped.conf".source =
    "${ldsped}/etc/ax25/ldsped.conf.example";
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
sudo systemctl enable ldsped
sudo systemctl start ldsped
```

---

## Included Programs

The package includes:

- **ldsped**: The main AGW Packet Engine replacement daemon
- **latlon**: Latitude/longitude utility for position calculations

Both programs are installed to `$out/bin/`.

---

## Dependencies

The package depends on:

- **libax25**: AX.25 library for amateur packet radio
- **linuxHeaders**: Linux kernel headers for AX.25/ROSE protocol definitions

These dependencies are automatically handled by Nix when building the package.

---

## Troubleshooting

### Build fails with missing ax25 headers

Ensure `libax25` is available in nixpkgs:

```bash
nix-env -qaP libax25
```

If not found, you may need to update your nixpkgs channel:

```bash
sudo nix-channel --update
```

### Permission denied errors

ldsped must run as root. Use `sudo` or configure the systemd service as shown above.

### Configuration file not found

Make sure to copy the example configuration file to `/etc/ax25/ldsped.conf` and edit it for your setup.

---

## Updating the Package

To update to a newer version:

1. Update the `version` in `default.nix` if applicable
2. Change `rev` to the new commit/tag
3. Set `sha256 = lib.fakeSha256;` to force hash recalculation
4. Rebuild to get the new hash
5. Update `sha256` with the correct value
6. Rebuild again

---

## Uninstalling

### System-wide installation

Remove `ldsped` from `environment.systemPackages` in `/etc/nixos/configuration.nix` and run:

```bash
sudo nixos-rebuild switch
```

### User installation

```bash
nix-env -e ldsped
```

---

## Additional Resources

- [ldsped GitHub Repository](https://github.com/ampledata/ldsped)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [AX.25 for Linux](https://www.linux-ax25.org/)
