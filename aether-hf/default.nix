{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gtk3,
  glib-networking,
  libayatana-appindicator,
  librsvg,
  openssl,
  alsa-lib,
  udev,
}:

let
  version = "0.2.0-beta.178";

  src = fetchFromGitHub {
    owner = "KK4ODA";
    repo = "aether-hf";
    tag = "v${version}";
    hash = "sha256-SMpx+ZXXRC58HRIa+tCjx7JJaPDelgATIGDzCUnuTMA=";
  };

  # The modem daemon, built on its own: this is what a headless gateway (and
  # the BBS) runs.  The desktop shell below carries the same binary as a
  # sidecar, so both packages expose `aetherd`.
  aetherd = rustPlatform.buildRustPackage {
    pname = "aetherd";
    inherit version src;

    cargoRoot = "core";
    buildAndTestSubdir = "core";
    cargoHash = "sha256-1n2YFvNTsqY+FpguWCJmb4xiRfMhK/NTATTHH8ykEp4=";
    cargoBuildFlags = [ "-p" "aetherd" ];

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      alsa-lib
      udev
    ];

    # The suite opens sound cards, radios and channels; packaging needs only
    # the release build.
    doCheck = false;

    postInstall = ''
      install -Dm644 ${src}/deploy/aetherd.service \
        $out/share/aetherd/aetherd.service
      install -Dm644 ${src}/docs/user/gateway-kit.md \
        $out/share/doc/aetherd/gateway-kit.md
      install -Dm644 ${src}/LICENSE-MIT $out/share/doc/aetherd/LICENSE-MIT
      install -Dm644 ${src}/LICENSE-APACHE $out/share/doc/aetherd/LICENSE-APACHE
    '';

    meta = with lib; {
      description = "Aether HF modem daemon";
      longDescription = ''
        The headless Aether HF station daemon: sound card, PTT, busy detection
        and the modem run loop, with the VARA-compatible host interface and the
        control API used by the desktop panel and gateways.
      '';
      homepage = "https://github.com/KK4ODA/aether-hf";
      license = with licenses; [ mit asl20 ];
      maintainers = [ ];
      platforms = platforms.linux;
      mainProgram = "aetherd";
    };
  };
in
rustPlatform.buildRustPackage {
  pname = "aether-hf";
  inherit version src;

  cargoRoot = "app/src-tauri";
  buildAndTestSubdir = "app/src-tauri";
  cargoHash = "sha256-033zCrZawB3E3wBQbJ3j9f+3L6EiV5T4VDQR4atIE0k=";

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    glib-networking
    libayatana-appindicator
    librsvg
    openssl
  ];

  # Tauri bundles external binaries from binaries/<name>-<target-triple>.
  # Build the daemon once and stage it where the bundler expects it.
  preBuild = ''
    install -Dm755 ${aetherd}/bin/aetherd \
      app/src-tauri/binaries/aetherd-${stdenv.hostPlatform.rust.rustcTarget}
  '';

  doCheck = false;

  passthru = { inherit aetherd; };

  meta = with lib; {
    description = "Open-source HF data modem for amateur radio";
    longDescription = ''
      Aether HF is an open-source ARQ HF modem with a published air interface
      and a VARA-compatible host interface.  This package installs the desktop
      station panel and the `aetherd` modem daemon it supervises.
    '';
    homepage = "https://github.com/KK4ODA/aether-hf";
    changelog = "https://github.com/KK4ODA/aether-hf/releases/tag/v${version}";
    license = with licenses; [ mit asl20 ];
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "aether-hf";
  };
}
