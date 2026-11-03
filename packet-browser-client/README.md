# Packet Browser Client

`packet-browser-client` is the local half of Packet Browser. It connects to a
packet modem, opens an AX.25 or VARA session to a BPQ node, and serves a local
web proxy that renders pages fetched by the remote server.

Supported transports:

- **AX.25 via AGWPE** — Direwolf, tncd, LinBPQ or another AGWPE server.
- **VARA FM** — VARA FM or a compatible modem.
- **VARA HF / Mercury** — VARA HF or the Mercury HF modem.

The web interface defaults to `http://127.0.0.1:8088`.

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

  imports = [ "${ham-packages}/packet-browser-client/module.nix" ];

  services.packet-browser-client = {
    enable = true;
    myCallsign = "N0CALL";
    targetCallsign = "NODE1";
    bpqCommand = "WEB";
    listenAddr = "127.0.0.1:8088";

    agwpeHost = "127.0.0.1";
    agwpePort = 8000;

    # Enable one of these instead of AX.25 if desired.
    # transport = "vara_hf";
    # varaHf = {
    #   cmdPort = 8300;
    #   dataPort = 8301;
    #   bandwidth = "bw500";
    # };
    #
    # transport = "vara_fm";
    # varaFm = {
    #   cmdPort = 8400;
    #   dataPort = 8401;
    #   bandwidth = "vwide";
    # };
  };
}
```

`myCallsign` is required. `targetCallsign` is the BPQ node that runs the
browser application (`WEB` by default). Open `http://localhost:8088` after
starting the service.

The module generates an INI file in the Nix store and passes it to the client
with `--config`. Change settings through Nix, not by editing that file. The web
UI's **Save Configuration** button writes to the client's normal per-user
config path instead of the generated file, so declarative settings remain
authoritative after a restart.

### Module Options

| Option | Default | Description |
|--------|---------|-------------|
| `enable` | `false` | Enable the service |
| `package` | `pkgs.packet-browser-client` | Client package |
| `user` / `group` | `"packet-browser"` | Service account |
| `listenAddr` | `"127.0.0.1:8088"` | Local web proxy address |
| `allowedHosts` | `[ ]` | Extra hostnames accepted in the Host header |
| `dontLaunchBrowser` | `true` | Do not launch a desktop browser at startup |
| `agwpeHost` | `"127.0.0.1"` | AGWPE TNC host (AX.25 transport) |
| `agwpePort` | `8000` | AGWPE TNC port |
| `myCallsign` | *(required)* | Operator callsign |
| `targetCallsign` | `""` | Target BPQ node callsign |
| `bpqCommand` | `"WEB"` | BPQ APPLICATION command |
| `skipBpqApp` | `false` | Skip sending the BPQ APPLICATION command |
| `transport` | `"ax25"` | Default transport: `ax25`, `vara_fm`, or `vara_hf` |
| `varaHf.cmdHost` / `cmdPort` | `127.0.0.1` / `8300` | VARA HF/Mercury command channel |
| `varaHf.dataHost` / `dataPort` | `127.0.0.1` / `8301` | VARA HF/Mercury data channel |
| `varaHf.bandwidth` | `"bw500"` | `bw250`, `bw500`, `bw2300`, or `bw2750` |
| `varaFm.cmdHost` / `cmdPort` | `127.0.0.1` / `8400` | VARA FM command channel |
| `varaFm.dataHost` / `dataPort` | `127.0.0.1` / `8401` | VARA FM data channel |
| `varaFm.bandwidth` | `"vwide"` | `vnarrow` or `vwide` |
| `cache.enable` | `true` | Enable the client page cache |
| `cache.maxBytes` | `209715200` | Cache size limit (200 MiB) |
| `cache.maxTtlSeconds` | `86400` | Maximum cache entry lifetime |
| `cache.dir` | `/var/cache/packet-browser` | Cache directory |
| `connection.responseTimeoutSecs` | `30` | Server response timeout |
| `connection.autoReconnect` | `true` | Reconnect after a transport loss |
| `extraArgs` | `[ ]` | Extra command-line arguments |

The service uses systemd's `CacheDirectory=packet-browser`; when `cache.dir`
is changed, make sure the service user can write the new location.

## Config File

For a manual install, the client reads an INI file. A complete example:

```ini
[server]
agwpe_host = 127.0.0.1
agwpe_port = 8000

[session]
my_callsign = N0CALL
target_callsign = NODE1
bpq_command = WEB
skip_bpq_app = false

[transport]
default = ax25

[cache]
enabled = true
max_bytes = 209715200
max_ttl_seconds = 86400
# dir = /home/operator/.cache/packet-browser

[connection]
response_timeout_secs = 30
auto_reconnect = true

[vara_hf]
cmd_host = 127.0.0.1
cmd_port = 8300
data_host = 127.0.0.1
data_port = 8301
bandwidth = bw500

[vara_fm]
cmd_host = 127.0.0.1
cmd_port = 8400
data_host = 127.0.0.1
data_port = 8401
bandwidth = vwide
```

`transport.default` accepts `ax25`, `vara_fm`, or `vara_hf`.

## Command-Line Options

```text
packet-browser-client [OPTIONS]

  -c, --config <PATH>          Configuration file (INI)
      --agwpe-host <HOST>      Override the AGWPE host
      --agwpe-port <PORT>      Override the AGWPE port
      --listen-addr <ADDR>     Web proxy listen address [default: 127.0.0.1:8088]
      --bpq-command <CMD>      BPQ APPLICATION command [default: WEB]
      --allowed-hosts <HOSTS>  Extra Host-header hostnames (comma-separated)
      --dont-launch-browser    Do not open a desktop browser at startup
  -v, --verbose...             Increase verbosity (-v, -vv, -vvv)
  -V, --version                Print version
  -h, --help                   Print help
```

Once started, open the web UI. The Connect page lets you choose the transport,
enter or confirm callsigns, connect the modem, and connect to the BPQ node.
The Configuration page edits the AGWPE and VARA endpoints and can save the
client's per-user configuration.

## Upstream

- <https://github.com/ben-kuhn/packet-browser>
