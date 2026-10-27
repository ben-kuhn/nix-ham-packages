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
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "x0rro";
    repo = "xara";
    rev = "v${version}";
    hash = "sha256-C7eSKEfiR3aXJ0xpjWQTSR1brQcxCl3d/ROk3QJwad8=";
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
    homepage = "https://github.com/x0rro/xara";
    changelog = "https://github.com/x0rro/xara/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "xara";
  };
}
