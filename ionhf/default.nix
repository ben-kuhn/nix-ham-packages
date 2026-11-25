{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  alsa-lib,
  libGL,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
}:

rustPlatform.buildRustPackage rec {
  pname = "ionhf";
  # Tracks main; upstream is still in the 0.1.0 alpha series.
  version = "0.1.0-alpha.6-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "jesseforkum";
    repo = "ion-hf";
    rev = "a2a2b7716e9f73f75efb8f51237b4d20a308c673";
    hash = "sha256-fmYmEMQVOyiMMN7kcvC7J/8dzD5+mWu8xs3Dp7vzbqc=";
  };

  cargoHash = "sha256-x2AfdCYx01AbLcOYK55vrYnGZrZnXNS7K4OeKLKosTE=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libGL
    libxkbcommon
    wayland
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxxf86vm
  ];

  buildAndTestSubdir = "crates/ionhf";

  # GUI and audio tests need a display, sound card and radio hardware.
  doCheck = false;

  postInstall = ''
    install -Dm644 $src/packaging/linux/ionhf.desktop \
      $out/share/applications/ionhf.desktop
    install -Dm644 $src/crates/ionhf/assets/icon.png \
      $out/share/icons/hicolor/256x256/apps/ionhf.png
    install -Dm644 $src/packaging/README.txt \
      $out/share/doc/ionhf/README.txt
    install -Dm644 $src/NOTICE $out/share/doc/ionhf/NOTICE
    install -Dm644 $src/LICENSE $out/share/doc/ionhf/LICENSE
  '';

  # winit/glutin load the windowing and GL libraries at runtime, so the Nix
  # store paths must be on the loader search path.
  postFixup = ''
    wrapProgram $out/bin/ionhf \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libGL
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxext
        libxi
        libxinerama
        libxrandr
        libxxf86vm
      ]}
  '';

  meta = with lib; {
    description = "Adaptive HF data modem for amateur radio";
    longDescription = ''
      Ion HF is an HF data modem with an adaptive ARQ link spanning MFSK
      through 64QAM OFDM, a VARA-style host interface for Winlink clients
      such as Pat, and KISS broadcast groups.
    '';
    homepage = "https://github.com/jesseforkum/ion-hf";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "ionhf";
  };
}
