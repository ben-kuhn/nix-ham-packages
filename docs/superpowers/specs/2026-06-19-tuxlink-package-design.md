---
name: tuxlink-package-design
description: Nix package for Tuxlink (native Linux Winlink client, Tauri 2.x / Rust + React) at v0.67.0, added to the nix-ham-packages overlay.
---

# Tuxlink package — design

## Goal

Add Tuxlink v0.67.0 to the `nix-ham-packages` overlay as a from-source Nix
package. Upstream: <https://github.com/cameronzucker/tuxlink>.

Tuxlink is a Tauri 2.x desktop application — Rust backend + React 19 /
TypeScript frontend rendered through WebKitGTK 4.1 — providing a native Linux
Winlink-compatible amateur-radio email client.

## Scope

In:

- Single package `tuxlink` built from source at tag `v0.67.0`.
- Main binary `tuxlink` and helper binary `tuxlink-gps-fix`.
- Desktop entry, icons, polkit policy.
- Wired into `default.nix`; row added to `README.md` package table.
- Target platform `x86_64-linux`.

Out:

- NixOS module (Tuxlink is a user-launched GUI app).
- AppImage/.deb/.rpm bundling (replaced by Nix install phase).
- Auto-updater (irrelevant under Nix).
- ARM64 (may work, not claimed).

## Architecture

One derivation with two build phases:

1. **Frontend phase.** pnpm dependencies fetched deterministically via
   `pnpm.fetchDeps` (nixpkgs helper). `pnpm build` runs `tsc && vite build`
   and produces static assets in `dist/`.
2. **Cargo phase.** `rustPlatform.cargoSetupHook` vendors the Cargo deps
   from `src-tauri/Cargo.lock`. `cargo build --release --bins` inside
   `src-tauri/` produces `tuxlink` and `tuxlink-gps-fix`. Tauri's `build.rs`
   embeds the prebuilt `dist/` at compile time via the `frontendDist:
   "../dist"` setting in `tauri.conf.json`.

We deliberately do **not** invoke `cargo tauri build`. The Tauri bundler runs
network/system operations (AppImage/deb/rpm packaging, icon synthesis) that
fail in the Nix sandbox. Calling `cargo build` directly is sufficient because
`tauri-build` embeds the dist at compile time.

## Install layout

| Path | Source |
|------|--------|
| `$out/bin/tuxlink` | `src-tauri/target/release/tuxlink` |
| `$out/libexec/tuxlink-gps-fix` | `src-tauri/target/release/tuxlink-gps-fix` |
| `$out/share/applications/tuxlink.desktop` | `scripts/tuxlink.desktop` (patched `Exec=`) |
| `$out/share/icons/hicolor/32x32/apps/tuxlink.png` | `src-tauri/icons/32x32.png` |
| `$out/share/icons/hicolor/128x128/apps/tuxlink.png` | `src-tauri/icons/128x128.png` |
| `$out/share/polkit-1/actions/com.tuxlink.app.policy` | `src-tauri/packaging/com.tuxlink.app.policy` |

`wrapGAppsHook4` wraps the binary to expose GIO modules, GSettings schemas,
and pixbuf loaders at runtime — the standard nixpkgs pattern for WebKitGTK
applications.

## Dependencies

`nativeBuildInputs`:

- `pkg-config`
- `wrapGAppsHook4`
- `pnpm_9`
- `nodejs`
- `cargo`, `rustc`
- `rustPlatform.cargoSetupHook`
- `rustPlatform.bindgenHook` (libheif-sys uses bindgen)

`buildInputs`:

- `webkitgtk_4_1`
- `glib-networking`
- `gtk3`
- `libsecret`
- `libax25`
- `libheif`, `libde265`, `libwebp`
- `openssl`
- `libsoup_3`
- `libayatana-appindicator`
- `librsvg`
- `libxdo`
- `dbus`
- `alsa-lib`

Two hashes that settle empirically on the first build:

- `pnpmDeps` hash (from `pnpm.fetchDeps`)
- `cargoHash` (from the vendored Rust deps in `src-tauri/`)

Standard flow: start with `lib.fakeHash`, take the correct value from the
mismatch error, rebuild.

## Overlay wiring

In `default.nix`:

```nix
tuxlink = prev.callPackage ./tuxlink { };
```

In `README.md`, add a row to the package table:

```
| `tuxlink` | Native Linux Winlink client (Rust + Tauri). Alpha. |
```

## Known risks

1. **libheif version pin.** Tuxlink pins `libheif-rs = "=1.0.2"`, which uses
   `libheif-sys ^2.1` and expects libheif 1.17.x (Ubuntu 24.04 vintage).
   Nixpkgs may ship a newer libheif. If libheif-sys fails to build, options:
   (a) override `libheif` to a 1.17.x version in the build inputs, or
   (b) patch the Cargo.toml pin upward to a `libheif-rs` that accepts the
   nixpkgs libheif. Start with whatever nixpkgs has; iterate on failure.
2. **Tauri sandbox quirks.** `tauri-build` may attempt to fetch tooling or
   synthesize icons. If that surfaces, set offline env vars
   (`TAURI_SKIP_DEVSERVER_CHECK=1` etc.) and patch out fetches.
3. **Alpha software.** v0.67.0 is alpha per upstream README. The README
   table row should mark it as such.

## Testing

- `nix-build -A tuxlink` succeeds.
- Resulting binary launches and renders the main window. We do not test radio
  functionality.

## Meta

- License: GPL-3.0-or-later.
- Homepage: <https://github.com/cameronzucker/tuxlink>.
- Platforms: `x86_64-linux`.
- Main program: `tuxlink`.
