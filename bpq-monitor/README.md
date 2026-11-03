# BPQ Monitor

`bpq-monitor` is a web UI for watching a BPQ packet node. It polls the BPQ
web/FBB interfaces for port status, tails modem journals, and can
start/stop/restart **systemd user** services from the browser.

The package installs a single `bpq-monitor` binary and has no NixOS module;
configuration is a TOML file passed with `-config`.

## Configuration

```toml
[bpq]
web_url = "http://127.0.0.1:8080"  # BPQ web interface
fbb_port = 8011                   # BPQ FBB port
username = "N0CALL"
password = "change-me"

[server]
listen = "127.0.0.1:9090"         # address the monitor's web UI binds to
action_password = "change-me"     # required; protects start/stop/restart

[layout]
columns = 3                       # monitor pane columns (default 3)

[[port]]
num = 2                           # BPQ port number
label = "VHF"
service = "direwolf-vhf"          # systemd --user service name
row = 0                           # optional grid position
col = 0
# deaf_check = true               # QtSoundModem: restart if no L2 frames for 1h
```

Notes:

- `server.action_password` must not be empty.
- At least one `[[port]]` must be configured.
- `bpq.fbb_port` defaults to `8011`; `server.listen` defaults to
  `127.0.0.1:9090`.
- A port with no `service` is still monitored, but has no start/stop/log
  controls.
- `deaf_check` is intended for QtSoundModem. It restarts the service when the
  "L2 frames heard" counter has not changed for an hour, even if BPQ still
  reports the port as connected.

## Running

```bash
bpq-monitor -config /etc/bpq-monitor.toml
```

The action menu and journal views use `systemctl --user`, so run
`bpq-monitor` in the same user manager as the modem services. A simple
systemd user unit:

```ini
# ~/.config/systemd/user/bpq-monitor.service
[Unit]
Description=BPQ Monitor
After=network.target

[Service]
ExecStart=/run/current-system/sw/bin/bpq-monitor -config %h/.config/bpq-monitor.toml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now bpq-monitor
journalctl --user -u bpq-monitor -f
```

Adjust `ExecStart` if you installed `bpq-monitor` only in a user profile
(for example `%h/.nix-profile/bin/bpq-monitor`) instead of system-wide.

Then open <http://127.0.0.1:9090>. If you change `server.listen`, adjust the
URL accordingly; binding to a non-loopback address exposes the action menu to
the network, so keep `action_password` strong.

## Watchdog

The monitor watches each configured service and restarts it when:

- it has been unhealthy for more than 15 minutes (not connected per BPQ port
  status, or not running per systemd), or
- it is marked `deaf_check = true` and has heard no L2 frames for an hour.

Watchdog restarts are logged to the monitor's own journal:

```bash
journalctl --user -u bpq-monitor -g watchdog
```

## Upstream

- <https://github.com/ben-kuhn/bpq-monitor>
