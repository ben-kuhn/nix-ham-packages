# Packet Browser Server

`packet-browser-server` is the remote half of Packet Browser. It runs behind a
BPQ node, accepts a TCP connection from BPQ, fetches and sanitizes the
requested page with **headless Firefox**, then sends the result over AX.25 as
brotli-compressed, base64-framed, printable text.

Current Packet Browser releases use Firefox and geckodriver. **Chromium is no
longer used**, and the old `CHROMIUM_PATH` environment variable has been
removed.

## NixOS Module

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

  imports = [ "${ham-packages}/packet-browser-server/module.nix" ];

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

The module:

- adds `firefox-esr-unwrapped` and `geckodriver` as runtime dependencies;
- sets `FIREFOX_PATH`, `GECKODRIVER_PATH`, `LD_LIBRARY_PATH` (for NSS and
  p11-kit) and `SSL_CERT_FILE`;
- creates `/var/log/packet-browser` and writes the access log to
  `/var/log/packet-browser/access.log`;
- runs the server as the `packet-browser` system user under systemd.

Use the unwrapped Firefox build. geckodriver invokes the path given to it
directly and rejects the nixpkgs Firefox wrapper script because it is not an
ELF executable.

### Module Options

| Option | Default | Description |
|--------|---------|-------------|
| `enable` | `false` | Enable the service |
| `package` | `pkgs.packet-browser-server` | Server package |
| `firefoxPackage` | `pkgs.firefox-esr-unwrapped` | Firefox used for rendering |
| `geckodriverPackage` | `pkgs.geckodriver` | WebDriver driver |
| `user` / `group` | `"packet-browser"` | Service account |
| `listenPort` | `63004` | TCP port BPQ connects to |
| `portalUrl` | `https://www.zeroretries.radio` | Default home page |
| `idleTimeoutMinutes` | `10` | Idle session timeout |
| `brotliQuality` | `11` | Brotli compression level (0–11) |
| `blockedRanges` | loopback, private, link-local, `0.0.0.0/8` | CIDR ranges blocked for SSRF prevention |
| `blocklistEnabled` | `true` | Enable the hosts-format domain blocklist |
| `blocklistUrls` | `[ ]` | Blocklist URLs to fetch |
| `blocklistRefreshHours` | `24` | Blocklist refresh interval |
| `allowedCallsigns` | `[ ]` | Callsigns exempt from strict ITU validation (off-air testing) |
| `originCcHeadTimeoutMs` | `3000` | Origin `Cache-Control` HEAD probe timeout |
| `defaultMaxAgeSeconds` | `3600` | Cache max-age when the origin gives none |
| `maxMaxAgeSeconds` | `2592000` | Upper bound for origin-provided max-age |
| `openFirewall` | `false` | Open `listenPort` in the firewall |

`0.0.0.0/8` is blocked deliberately. It is IANA's reserved "this network"
range, not usable public address space, and on Linux a connection to
`0.0.0.0` is treated as localhost. Without the block, a URL such as
`http://0.0.0.0:<port>/` could reach services on the server itself and bypass
the loopback filter.

`allowedCallsigns` is useful with demo setups where LinBPQ injects synthetic
callsigns such as `DEMOUSR` or `W1TEST`. Matching is case-insensitive and an
SSID suffix is ignored.

## Running Without the Module

Install `pkgs.packet-browser-server` and point the server at Firefox and
geckodriver. Unlike the module, a standalone install does not set these for
you:

```bash
export FIREFOX_PATH="$(command -v firefox)"
export GECKODRIVER_PATH="$(command -v geckodriver)"
packet-browser-server
```

Use an unwrapped Firefox binary if geckodriver rejects your distribution's
Firefox wrapper. Other runtime settings are environment variables:

| Variable | Default |
|----------|---------|
| `LISTEN_PORT` | `63004` |
| `PORTAL_URL` | `https://www.zeroretries.radio` |
| `IDLE_TIMEOUT_MINUTES` | `10` |
| `BROTLI_QUALITY` | `11` |
| `BLOCKED_RANGES` | `0.0.0.0/8,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16` |
| `BLOCKLIST_ENABLED` | `true` |
| `BLOCKLIST_REFRESH_HOURS` | `24` |
| `BLOCKLIST_URLS` | *(empty)* |
| `ALLOWED_CALLSIGNS` | *(empty)* |
| `ORIGIN_CC_HEAD_TIMEOUT_MS` | `3000` |
| `DEFAULT_MAX_AGE_SECONDS` | `3600` |
| `MAX_MAX_AGE_SECONDS` | `2592000` |

The access log path is currently fixed at
`/var/log/packet-browser/access.log`; make sure the service user can create
and write that directory.

## BPQ Configuration

Add the server port to `CMDPORT` and register the application in
`bpq32.cfg`. The port's position in the list determines `HOST` (zero-based):

```ini
# Port 63004 is at position 3
CMDPORT=63001,63002,63003,63004

# APPLICATION <num>,<command>,C <port> HOST <position> S
APPLICATION 4,WEB,C 10 HOST 3 S
```

Adjust `C 10` to the BPQ port that carries your telnet/application users.

## Upstream

- <https://github.com/ben-kuhn/packet-browser>
