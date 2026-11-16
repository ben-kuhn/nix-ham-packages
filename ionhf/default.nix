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
  version = "0.1.0-alpha.6-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "jesseforkum";
    repo = "ion-hf";
    rev = "1eb7dca01803e120eeb0924fd02d4ccc563557a4";
    hash = "sha256-R7+CdOl7fzeqHq45GZeE4SwKn0a+fAHz7yGCe6xe588=";
  };

  cargoHash = "sha256-kwQ09XGhLMKWqRo235znBBu9cmv0yWYvtbDPMH01in8=";

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
