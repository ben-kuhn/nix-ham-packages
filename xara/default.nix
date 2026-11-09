{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  libpulseaudio,
}:

rustPlatform.buildRustPackage rec {
  pname = "xara";
  # NR5P's fork carries the post-0.1.2 audio/throughput fixes.  Pin the exact
  # main commit so the build is reproducible; bump this when tracking newer
  # main.  (The x0rro upstream repo/tags are no longer reachable.)
  version = "0.1.2-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "NR5P";
    repo = "xara";
    rev = "bd8300a36e4f76fae7d561335bf08649474bdc6d";
    hash = "sha256-JDJYiuE6M+irtfJtd2Rh5EO4qRQypTPD3odOQo5Nih8=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ];

  # Both audio backends are enabled by default: PulseAudio/PipeWire is the
  # default backend, ALSA is selected at runtime with `--audio alsa`.
  buildInputs = [
    libpulseaudio
    alsa-lib
  ];

  # Build only the `xara` package rather than every workspace member; it
  # provides both the `xara` and `xara-monitor` binaries.
  cargoBuildFlags = [ "-p" "xara" ];

  # Registered mode (higher VARA speeds) is opt-in at build time upstream.
  # This only gates the `--registered` flag; run xara with `--registered`.
  buildFeatures = [ "registered" ];

  postInstall = ''
    install -Dm644 dist/man/xara.1 $out/share/man/man1/xara.1
    install -Dm644 dist/man/xara-monitor.1 $out/share/man/man1/xara-monitor.1
    install -Dm644 dist/xara.conf.example $out/share/doc/xara/xara.conf.example

    install -Dm644 dist/udev/60-xara-ptt.rules \
      $out/lib/udev/rules.d/60-xara-ptt.rules
    install -Dm644 dist/sysusers.d/xara.conf $out/lib/sysusers.d/xara.conf

    # Upstream units assume /usr/bin/xara; point them at the store path.
    install -Dm644 dist/systemd/xara@.service \
      $out/lib/systemd/system/xara@.service
    substituteInPlace $out/lib/systemd/system/xara@.service \
      --replace-fail "/usr/bin/xara" "$out/bin/xara"

    install -Dm644 dist/systemd/xara.service \
      $out/lib/systemd/user/xara.service
    substituteInPlace $out/lib/systemd/user/xara.service \
      --replace-fail "/usr/bin/xara" "$out/bin/xara"
  '';

  meta = with lib; {
    description = "VARA-compatible HF/FM software modem for Linux";
    longDescription = ''
      xara is a VARA-compatible HF/FM modem for Linux. It exposes the usual
      command, data and KISS TCP ports, supports PTT over serial RTS/DTR,
      CM108/CM119 HID GPIO, hamlib rigctld and VOX, and offers a web UI.
      The package also includes xara-monitor, a passive VARA HF monitor.
    '';
    homepage = "https://github.com/NR5P/xara";
    changelog = "https://github.com/NR5P/xara/blob/bd8300a36e4f76fae7d561335bf08649474bdc6d/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "xara";
  };
}
