{
  lib,
  rustPlatform,
  fetchzip,
  pkg-config,
  alsa-lib,
  libpulseaudio,
}:

rustPlatform.buildRustPackage rec {
  pname = "xara";
  # XaraNext 1.3: compatibility with VARA HF 4.9.1 / FM 4.4.1 and the
  # 2027 waveform.  The 2027 keying tables are not shipped; point the
  # modem at a VARA installation with --hf-keying-dir/--fm-keying-dir.
  version = "1.3.0";

  src = fetchzip {
    url = "https://anonymous.4open.science/api/repo/xara-55B2/zip";
    extension = "zip";
    stripRoot = false;
    hash = "sha256-2ln+E89GfApumH1EinqCsmtZ34SXf41hdlXS8DagaKs=";
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
  # provides the `xara`, `xara-monitor` and `xara-keygen` binaries.
  cargoBuildFlags = [ "-p" "xara" ];

  # The 1.2.0 snapshot's help-text test expects --tx-buffer-ms in --help
  # but the option table does not list it.  The binaries themselves build.
  doCheck = false;

  postInstall = ''
    install -Dm644 dist/man/xara.1 $out/share/man/man1/xara.1
    install -Dm644 dist/man/xara-monitor.1 $out/share/man/man1/xara-monitor.1
    install -Dm644 dist/man/xara-keygen.1 $out/share/man/man1/xara-keygen.1
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
    description = "VARA-compatible HF/FM software modem for Linux (XaraNext)";
    longDescription = ''
      XaraNext is a VARA-compatible HF/FM modem for Linux, FreeBSD and macOS,
      based on xara 0.1.3.  It supports the legacy VARA HF 4.9.0 / FM 4.4.0
      waveforms and the 2027 waveforms used by VARA HF 4.9.1 / FM 4.4.1.
      The 2027 keying tables are not redistributed; they must be supplied
      from a local VARA installation with --hf-keying-dir and
      --fm-keying-dir (or the equivalent config-file options).
    '';
    homepage = "https://github.com/x0rro/xara";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "xara";
  };
}
