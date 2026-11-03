# NixOS Amateur Radio Packages Overlay

This repository contains Nix packages and NixOS modules for amateur radio
software. It is a plain nixpkgs overlay: import it and the packages below are
available as `pkgs.<name>`.

## Included Packages

| Package | Description |
|---------|-------------|
| `bpq-monitor` | Web UI for watching BPQ node modem traffic and status |
| `cwdaemon` | Morse code (CW) keying daemon (UDP-controlled, used by Not1MM) |
| `hams-local-relay` | Hams.com Local Hardware Relay (proprietary, pre-built; requires `allowUnfree`) |
| `linbpq` | Linux BPQ Packet Radio Node (includes a NixOS module) |
| `mercury-modem` | Mercury software-defined HF modem |
| `modem73` | High-speed software modem (KISS TNC) for HF/VHF/UHF 2400 Hz radios |
| `not1mm` | Amateur radio contest logger (PyQt6) — talks to rigctld and cwdaemon |
| `paracon` | Packet radio terminal (AGWPE client) |
| `packet-browser-client` | AX.25/AGWPE and VARA client with a local web proxy (includes a NixOS module) |
| `packet-browser-server` | Web page fetcher using headless Firefox (includes a NixOS module) |
| `pat` | Cross-platform Winlink client, updated to 1.0.0 (nixpkgs still ships 0.19.1) |
| `pyham-ax25` | Python AX.25 packet encoding/decoding library |
| `pyham-pe` | Python AGWPE client library |
| `qtsoundmodem` | Qt-based sound modem for packet radio |
| `qttermtcp` | Qt terminal client for BPQ (FBB, AGWPE, KISS and VARA) |
| `tncd` | AGWPE-to-KISS translation bridge (2.0 Go rewrite, beta; includes a NixOS module) |
| `tuxlink` | Linux-native Winlink client (Rust + Tauri; alpha, tracks upstream pre-releases) |
| `xara` | VARA-compatible HF/FM software modem (registered speeds enabled; includes `xara-monitor` and a NixOS module) |

`tuxlink` is currently `x86_64-linux` only. The other packages support the
platforms listed in their `meta.platforms`.

## Installation

### NixOS (Recommended)

Add the overlay and packages to `/etc/nixos/configuration.nix`:

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

  nixpkgs.config.allowUnfree = true; # for hams-local-relay

  environment.systemPackages = with pkgs; [
    bpq-monitor
    cwdaemon
    hams-local-relay
    linbpq
    mercury-modem
    modem73
    not1mm
    paracon
    packet-browser-client
    packet-browser-server
    pat
    qtsoundmodem
    qttermtcp
    tncd
    tuxlink
    xara
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

The packages are now available system-wide. No additional installation steps
are needed unless a section below says otherwise (for example, `modem73` udev
rules or a service module).

**Alternative: User-level installation**

If you prefer to install packages into your user profile instead of
system-wide, add only the overlay to `configuration.nix` (omit
`environment.systemPackages`), rebuild, then:

```bash
nix-env -iA nixos.packet-browser-client
nix-env -iA nixos.packet-browser-server
nix-env -iA nixos.pat
```

### Non-NixOS (Nix Package Manager)

For systems using the standalone Nix package manager:

```bash
# Clone the overlay
git clone https://github.com/ben-kuhn/nix-ham-packages \
  ~/.config/nixpkgs/overlays/nix-ham-packages

# Create the overlay symlink
ln -s ~/.config/nixpkgs/overlays/nix-ham-packages/default.nix \
  ~/.config/nixpkgs/overlays/ham-radio.nix

# Install packages
nix-env -iA nixpkgs.bpq-monitor
nix-env -iA nixpkgs.cwdaemon
nix-env -iA nixpkgs.linbpq
nix-env -iA nixpkgs.mercury-modem
nix-env -iA nixpkgs.modem73
nix-env -iA nixpkgs.not1mm
nix-env -iA nixpkgs.paracon
nix-env -iA nixpkgs.packet-browser-client
nix-env -iA nixpkgs.packet-browser-server
nix-env -iA nixpkgs.pat
nix-env -iA nixpkgs.qtsoundmodem
nix-env -iA nixpkgs.qttermtcp
nix-env -iA nixpkgs.tncd
nix-env -iA nixpkgs.tuxlink
nix-env -iA nixpkgs.xara
```

`hams-local-relay` is unfree and must be enabled explicitly, and `tuxlink`
currently only builds on `x86_64-linux`:

```nix
# ~/.config/nixpkgs/config.nix
{
  allowUnfree = true;
}
```

```bash
nix-env -iA nixpkgs.hams-local-relay
```

The NixOS modules in this repository are NixOS-only and cannot be used with
the standalone package manager; the packages themselves work anywhere nixpkgs
does.

## NixOS Modules

| Module | Options |
|--------|---------|
| `hams-local-relay/module.nix` | `services.hams-local-relay` |
| `linbpq/module.nix` | `services.linbpq` |
| `packet-browser-client/module.nix` | `services.packet-browser-client` |
| `packet-browser-server/module.nix` | `services.packet-browser-server` |
| `tncd/module.nix` | `services.tncd` |
| `xara/module.nix` | `services.xara` |

Import a module with its path inside the overlay checkout:

```nix
imports = [ "${ham-packages}/linbpq/module.nix" ];
```

---

## Hams.com Local Relay

`hams-local-relay` is hams.com's per-user daemon that connects a local radio
(via Hamlib) and sound device to the hams.com Web Shack. It provides FT8,
WSPR, PSK31, RTTY, FreeDV/RADE, satellite tracking, LoTW uploads, and CAT
sharing on `127.0.0.1:4533` / `127.0.0.1:4534`.

For Logbook of the World uploads, also install `pkgs.tqsl` system-wide. The
relay shells out to the system `tqsl` rather than bundling it.

The relay is **proprietary software** distributed by hams.com as a pre-built
binary. This overlay repackages the official `.deb`; the source is available
from hams.com after registration, but is not open source. Because the package
is marked unfree, enable unfree packages in your configuration:

```nix
nixpkgs.config.allowUnfree = true;
```

Updates are handled through the overlay. The relay's built-in self-updater
cannot replace a binary in the immutable Nix store, so upgrade by bumping the
package version rather than using the relay's update button.

### NixOS user service

The relay runs inside your systemd user session so it can use your audio
devices and serial ports:

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

  nixpkgs.config.allowUnfree = true;

  imports = [
    "${ham-packages}/hams-local-relay/module.nix"
  ];

  services.hams-local-relay = {
    enable = true;
    # On a multi-user machine, restrict the service to one user.
    user = "alice";
    # Secrets should go in an environment file, not in the Nix store.
    environmentFile = "/run/secrets/hams-local-relay.env";
  };

  # The relay needs your sound card and radio's serial port.
  users.users.alice.extraGroups = [ "audio" "dialout" ];
}
```

Then open <https://localhost:7388> and accept the relay's self-signed
certificate the first time. Use `systemctl --user status hams-local-relay`
to check the service. To keep it running when the user is not logged in, also
set `users.users.alice.linger = true` (or run `loginctl enable-linger alice`).

Module options:

| Option | Default | Description |
|--------|---------|-------------|
| `enable` | `false` | Enable the user service |
| `package` | `pkgs.hams-local-relay` | Package to use |
| `user` | `null` | Only run the service in this user's systemd instance |
| `extraArgs` | `[ ]` | Extra arguments, e.g. `[ "--force-ptt-off" ]` |
| `environment` | `{ }` | Environment variables (visible in the Nix store) |
| `environmentFile` | `null` | Secrets file loaded with systemd `EnvironmentFile=` |

Without the module, install `pkgs.hams-local-relay` and start
`hams-local-relay` manually; it stores its data in
`~/.local/share/hams_local_relay`.

The package also ships the upstream DKMS sources for the `ch341` USB serial
driver under `share/hams-local-relay/dkms`, for kernels that do not include
it. NixOS kernels normally already provide `ch341`.

---

## LinBPQ Service

LinBPQ includes a NixOS module for running it as a systemd service:

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

  imports = [
    "${ham-packages}/linbpq/module.nix"
  ];

  services.linbpq = {
    enable = true;
    openFirewall = true;
  };
}
```

The module creates `/etc/linbpq`, `/var/lib/linbpq` and `/var/log/linbpq`
with the correct ownership. You must provide `bpq32.cfg` before the service
will start:

```bash
sudoedit /etc/linbpq/bpq32.cfg
sudo systemctl start linbpq
```

When `openFirewall` is enabled, the module opens TCP ports 8010 (telnet),
8011 (FBB/QtTermTCP) and 8080 (web) by default, but the actual listeners
are defined by `bpq32.cfg`; make the two match. See
[linbpq/README.md](linbpq/README.md) for all module options and BPQ setup
notes.

---

## tncd Service

tncd is an AGWPE-to-KISS bridge. The package in this overlay is the 2.0 Go
rewrite (beta), which supports serial, TCP and Bluetooth SPP TNCs. If you
need the more battle-tested 1.3.x Python line, install it from the upstream
APT/RPM repositories instead. The 2.0 package includes a NixOS module:

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

  imports = [
    "${ham-packages}/tncd/module.nix"
  ];

  services.tncd = {
    enable = true;
    settings = {
      server = {
        listen_host = "0.0.0.0";
        listen_port = 8000;
        callsign = "N0CALL";
      };
      "client.0" = {
        type = "serial";
        device = "/dev/ttyUSB0";
        serial_baudrate = 9600;
        ota_baudrate = 1200;
      };
    };
  };
}
```

Ports are numbered from zero and must be contiguous (`"client.0"`,
`"client.1"`, ...). Each port shows up in the AGWPE client's port selector.

Module options:

| Option | Default | Description |
|--------|---------|-------------|
| `enable` | `false` | Enable the bridge |
| `package` | `pkgs.tncd` | Package to use |
| `configFile` | `null` | Use an existing INI file instead of `settings` |
| `settings` | `{ }` | INI configuration generated from a Nix attribute set |
| `user` / `group` | `"tncd"` | Service account (added to `dialout`) |
| `bluetooth.enable` | `false` | Add the service user to `bluetooth` and order it after `bluetooth.service` |

For a Bluetooth TNC, pair and trust the device first, then use a `bluetooth`
client section:

```nix
services.tncd = {
  enable = true;
  bluetooth.enable = true;
  settings = {
    server = {
      listen_host = "0.0.0.0";
      listen_port = 8000;
      callsign = "N0CALL";
    };
    "client.0" = {
      type = "bluetooth";
      bdaddr = "AA:BB:CC:DD:EE:FF";
      ota_baudrate = 1200;
    };
  };
};
```

```bash
bluetoothctl pair AA:BB:CC:DD:EE:FF
bluetoothctl trust AA:BB:CC:DD:EE:FF
```

The Go binary always includes Bluetooth support, so `bluetooth.enable` only
handles group membership and service ordering. It does not install Python
D-Bus dependencies (the old 1.x package did).

For Benshi-protocol radios (BTech UV-PRO, Radioddity GA-5WB/DB-50B, Vero
VR-N76/VR-N7500) on a Bluetooth port, an optional hamlib Net rigctl server
lets PAT and other clients QSY the radio over the same link:

```nix
services.tncd.settings."rigctl.0" = {
  enabled = true;
  listen_host = "127.0.0.1";
  listen_port = 4532;
};
```

---

## xara Service

xara includes a NixOS module with typed options for every modem setting. Any
number of instances can run independently; each
`services.xara.instances.<name>` becomes a `xara-<name>` systemd unit. Set
`user` to run an instance as a systemd user service (for that user's PipeWire
session); otherwise it runs as a system service under the `xara` user.

```nix
{ config, pkgs, ... }:

let
  ham-packages = builtins.fetchGit {
    url = "https://github.com/ben-kuhn/nix-ham-packages";
    ref = "main";
  };
in
{
  nixpkgs.overlays = [ (import ham-packages) ];

  imports = [ "${ham-packages}/xara/module.nix" ];

  services.xara = {
    enable = true;

    instances.fm = {
      user = "alice";       # run as alice's systemd --user service
      call = "N0CALL";
      fm = "wide";
      audio = "pulse";
      capture = "alsa_input.usb-...";
      playback = "alsa_output.usb-...";
      radio = true;
      ptt = "rigctld:127.0.0.1:4532";
      port = 8302;          # command port; data port is port + 1
      kissPort = 8400;
      driveDb = -3;
      registered = true;
    };

    instances.hf = {
      call = "N0CALL";
      hf = 500;
      audio = "pulse";
      capture = "alsa_input.usb-...";
      playback = "alsa_output.usb-...";
      radio = true;
      ptt = "rigctld:127.0.0.1:4532";
      port = 8300;
      kissPort = null;      # disable KISS
      driveDb = -5;
      registered = true;
    };
  };
}
```

Each instance requires exactly one of `hf` (500, 2300 or 2750) or `fm`
(`"narrow"` or `"wide"`), plus `call`, `capture` and `playback`. `radio =
true` requires a `ptt` method (`vox`, `rigctld`, `cm108`, `rts` or `dtr`).
Port numbers below 65535 are enforced because the data port is `port + 1`.

Other useful instance options:

| Option | Default | Description |
|--------|---------|-------------|
| `enable` | `true` | Define this instance |
| `autoStart` | `true` | Start automatically; `false` defines the unit but leaves it stopped |
| `hf` / `fm` | `null` | HF bandwidth or FM mode (mutually exclusive) |
| `audio` | `"pulse"` | `pulse` (PipeWire/PulseAudio) or `alsa` |
| `capture` / `playback` | `""` | Audio device names |
| `radio`, `ptt` | `false`, `null` | Enable TX and select a PTT method |
| `pttLeadMs` / `pttTailMs` | `null` | PTT timing, 0–1000 ms |
| `pttMaxS` | `null` | Maximum keyed time, 1–120 s |
| `driveDb` | `null` | TX drive level in dB (must be ≤ 0) |
| `addr` / `port` | `"127.0.0.1"` / `8300` | Command bind address and port |
| `kissPort` | `8100` | KISS TCP port; `null` disables KISS |
| `persistence` | `null` | KISS p-persistence, 0–1 |
| `digi` | `null` | FM digipeater callsign (requires `fm`) |
| `registered`, `offerLevel` | `false`, `null` | Enable registered speeds and preferred level |
| `ui.*` | disabled | Web UI port/address/hosts/control/token |
| `stateDir`, `record` | `null` | State directory and RX/TX recording path |
| `preStart` / `postStart` | `""` | Shell snippets for sound-card setup and stream pinning |

`autoStart = false` defines the unit without enabling it (useful for A/B
testing). `preStart`/`postStart` can wait for sound cards and pin PulseAudio
streams. The package is built with registered mode enabled, so `registered =
true` turns on the higher VARA speeds. The module also installs xara's udev
rules for CM108/CM119/AIOC HID PTT. The package ships `xara-monitor`, a
passive VARA HF monitor. Without the module, run `xara` and `xara-monitor`
directly; both have man pages installed (`man xara`, `man xara-monitor`).

---

## Packet Browser Service

Packet Browser is a client/server web browser for packet radio. The server
runs behind a BPQ node and fetches pages with **headless Firefox** (driven by
geckodriver), filters and sanitizes them, then sends brotli-compressed,
base64-framed HTML over AX.25. The client supports **AX.25 via AGWPE**,
**VARA FM**, and **VARA HF/Mercury**, and exposes a local web proxy (default
`127.0.0.1:8088`).

### Server Configuration

The server runs behind a BPQ node and handles web page fetching:

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

  imports = [
    "${ham-packages}/packet-browser-server/module.nix"
  ];

  services.packet-browser-server = {
    enable = true;
    listenPort = 63004;
    portalUrl = "https://www.zeroretries.radio";
    idleTimeoutMinutes = 10;
    brotliQuality = 11;
    blocklistEnabled = true;
    blocklistUrls = [
      "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/ultimate.txt"
    ];
    openFirewall = true;
  };
}
```

The module supplies Firefox ESR and geckodriver and sets `FIREFOX_PATH`,
`GECKODRIVER_PATH` and `LD_LIBRARY_PATH` for the service. Chromium is **not**
used by current Packet Browser releases. Access logs are written to
`/var/log/packet-browser/access.log`.

Private, loopback and link-local CIDR ranges are blocked by default to prevent
SSRF; extend or replace `blockedRanges` if your setup needs it. The module also
exposes the server's cache-age settings and `allowedCallsigns` (for off-air
testing). See [packet-browser-server/README.md](packet-browser-server/README.md)
for all options and standalone runtime details.

### Client Configuration

The client runs on your local machine and connects to an AGWPE TNC, VARA FM,
or VARA HF/Mercury modem:

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

  imports = [
    "${ham-packages}/packet-browser-client/module.nix"
  ];

  services.packet-browser-client = {
    enable = true;
    myCallsign = "N0CALL";
    targetCallsign = "NODE1";
    agwpeHost = "127.0.0.1";
    agwpePort = 8000;
    bpqCommand = "WEB";
    listenAddr = "127.0.0.1:8088";
    # transport = "vara_hf";       # or "vara_fm"
  };
}
```

`myCallsign` is required; `targetCallsign` is the BPQ node running the
`WEB` application. After enabling the client service, open your browser to
`http://localhost:8088`. See
[packet-browser-client/README.md](packet-browser-client/README.md) for the
VARA endpoint options, cache settings and client configuration details.

See the [packet-browser documentation](https://github.com/ben-kuhn/packet-browser)
for the protocol and BPQ integration.

---

## BPQ Monitor

`bpq-monitor` is a small Go web UI that polls a BPQ node over its FBB port,
tails modem journals, and can start/stop/restart modem services through the
user's systemd manager.

It has no NixOS module and reads a TOML configuration file. A minimal
`bpq-monitor.toml` looks like this:

```toml
[bpq]
web_url = "http://127.0.0.1:8080"
fbb_port = 8011
username = "N0CALL"
password = "change-me"

[server]
listen = "127.0.0.1:9090"
action_password = "change-me"

[layout]
columns = 3

[[port]]
num = 2
label = "VHF"
service = "direwolf-vhf"
row = 0
col = 0
```

Then run:

```bash
bpq-monitor -config /etc/bpq-monitor.toml
```

`action_password` must not be empty, and at least one `[[port]]` is required.
Each port's `service` refers to a **systemd user** service name; run
`bpq-monitor` inside the same user manager as those services (for example as
a user service) or the action menu and journal views will not work. Set
`deaf_check = true` on a QtSoundModem port to restart it when no L2 frames
have been heard for an hour. See
[bpq-monitor/README.md](bpq-monitor/README.md) for a service unit example.

---

## PAT (Winlink)

`pat` is the Go Winlink client, packaged at 1.0.0 (upstream nixpkgs still has
0.19.1). It provides both a command line and a web UI, and is built with
`libax25` support on Linux so AX.25 transports are available.

```bash
# Create the initial configuration, then edit the JSON it opens
pat configure

# Start the web UI on http://127.0.0.1:8080
pat http

# Or use the interactive command shell
pat interactive
```

Configuration lives in `~/.config/pat/config.json`. `pat` can drive a radio
through Hamlib (`rigctld`) and connects to Winlink gateways over the
transports you configure. There is no NixOS module for PAT; run it as your
user or wrap it in your own systemd service.

---

## Tuxlink (Winlink)

`tuxlink` is a Linux-native Winlink client built with Rust, Tauri and React.
It is alpha software and deliberately tracks upstream pre-releases. It
currently builds on `x86_64-linux` only.

```bash
tuxlink
```

The package includes the desktop entry, icons and its polkit policy. It
expects a working desktop keyring and, depending on the features you use,
GPS/audio devices. There is no NixOS module.

---

## Mercury Modem

`mercury-modem` is Rhizomatica's HERMES HF modem. The package builds the
command-line engine (`mercury`), which presents a VARA-style TCP TNC
interface to logging and messaging software. The separate Go/Fyne
`mercury-ui` and Qt clients are not included.

```bash
mercury -h          # command-line reference
mercury -z          # list available sound cards
mercury             # run with settings from mercury.ini
```

Mercury reads `mercury.ini` from the current directory,
`~/.config/mercury/mercury.ini`, or `/etc/mercury/mercury.ini`; command-line
flags override it. See the
[Mercury documentation](https://rhizomatica.github.io/mercury/) for the
configuration file, modes, PTT backends and TCP interface. There is no NixOS
module.

---

## MODEM73

MODEM73 turns a sound-card interface into a KISS TNC for HF/VHF/UHF radios
with 2400 Hz of bandwidth. It supports rigctl, VOX, serial, GPIO and CM108
PTT, and decodes the OFDM, ROBUST and MFSK modem families simultaneously.

```nix
environment.systemPackages = [ pkgs.modem73 ];

# Required for non-root access to CM108 and GPIO PTT lines.
services.udev.packages = [ pkgs.modem73 ];
```

Then run the TUI:

```bash
modem73
```

Upstream's `README.md`, `QUICKSTART.md` and `CONTROL_PORT.md` are installed
under `share/doc/modem73` in the package output.

---

## Not1MM and cwdaemon

Not1MM connects to two external daemons over the network:

- **`rigctld`** (radio control) — provided by `hamlib` in upstream nixpkgs.
  Install it with `environment.systemPackages = [ pkgs.hamlib ];` and start
  `rigctld` yourself (for example, a systemd user service). The usual port
  is 4532.
- **`cwdaemon`** (CW keying) — provided by this overlay (`pkgs.cwdaemon`).
  Start it with your keyer device, for example:

  ```bash
  cwdaemon -d /dev/ttyUSB0
  ```

  cwdaemon listens on UDP port 6789 by default.

Configure Not1MM to point at the host and port of each running daemon. Both
daemons are deliberately not managed by this repository; use your own systemd
units or start them from a shell.

---

## Paracon, QtSoundModem and QtTermTCP

These are interactive clients:

- **Paracon** is a text-mode packet terminal that speaks AGWPE. It needs an
  AGWPE server such as Direwolf, tncd or LinBPQ. Start it from a directory
  where it may write its configuration and logs:

  ```bash
  mkdir -p ~/.local/share/paracon
  cd ~/.local/share/paracon
  paracon
  ```

  See [paracon/INSTALL.md](paracon/INSTALL.md) for the NixOS install snippet.

- **QtSoundModem** is a Qt sound modem. Run `QtSoundModem` and configure the
  sound devices and KISS ports in its GUI.

- **QtTermTCP** is a Qt terminal for BPQ nodes. Run `QtTermTCP`; it supports
  FBB, AGWPE, KISS and VARA connections.

Both Qt applications also appear in the desktop application menu after
installation.

---

## Python Libraries

`pyham-ax25` and `pyham-pe` are Python libraries used by Paracon. Add them to
a Python environment like this:

```nix
let
  python = pkgs.python3.withPackages (ps: [
    pkgs.pyham-ax25
    pkgs.pyham-pe
  ]);
in
{
  environment.systemPackages = [ python ];
}
```

Import them as `ax25` and `pe` respectively.

---

## Package Documentation

- [LinBPQ](linbpq/README.md) — full BPQ node setup, module options and ports
- [BPQ Monitor](bpq-monitor/README.md) — configuration file and user service
- [hams-local-relay](https://hams.com/manual/54-local-relay-installation-guide) — Hams.com Local Relay installation guide
- [mercury-modem](https://rhizomatica.github.io/mercury/) — HERMES HF modem
- [paracon](paracon/INSTALL.md) — packet radio terminal
- [Packet Browser server](packet-browser-server/README.md) — Firefox-backed page fetcher and options
- [Packet Browser client](packet-browser-client/README.md) — AX.25/VARA web proxy and options
- [packet-browser upstream](https://github.com/ben-kuhn/packet-browser) — protocol and architecture
- [qtsoundmodem](qtsoundmodem/INSTALL.md) — sound modem setup
- [qttermtcp](qttermtcp/INSTALL.md) — terminal client
- [tncd](https://tncd.dev) — AGWPE-to-KISS bridge
- [xara](https://github.com/x0rro/xara) — VARA-compatible modem
- [PAT](https://getpat.io/) — Winlink client
- [Tuxlink](https://github.com/cameronzucker/tuxlink) — native Linux Winlink client

## Resources

- [NixOS Manual - Overlays](https://nixos.org/manual/nixpkgs/stable/#chap-overlays)
- [LinBPQ Documentation](https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm)
- [Direwolf (AGWPE server)](https://github.com/wb2osz/direwolf)
