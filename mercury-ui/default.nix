{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  pkg-config,
  hamlib_4,
  hidapi,
  libpulseaudio,
  alsa-lib,
  openssl,
  libGL,
  libxkbcommon,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  wayland,
}:

buildGoModule rec {
  pname = "mercury-ui";
  version = "1.9.21";

  src = fetchFromGitHub {
    owner = "Rhizomatica";
    repo = "mercury";
    rev = "v${version}";
    hash = "sha256-nDdXMyKWY+iJ1feFcZIG+FdvHu6kDfcg0H6ZixoTff0=";
  };

  modRoot = "gui_interface/fyne-ui";

  vendorHash = "sha256-79IdxVowSvfMkxDJ75BNfJYFZWg0QuJYRvJffA19dk0=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    hamlib_4
    hidapi
    libpulseaudio
    alsa-lib
    openssl
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

  env.CGO_ENABLED = "1";
  # go-gl/glfw's Wayland sources include generated xdg-shell headers that
  # live in the vendored GLFW tree; point cgo at them explicitly.
  env.CGO_CFLAGS = "-I${src}/gui_interface/fyne-ui/third_party/glfw-v3.4/glfw/include";
  env.CGO_LDFLAGS = "-lhidapi-hidraw -lssl -lcrypto";

  # The upstream go.mod requires Go 1.26.9, which is newer than the Go
  # toolchain in the current nixpkgs release. The code does not use any
  # 1.26.9-only language features, so relax the minimum for the Nix build.
  postPatch = ''
    sed -i 's/^go 1\.26\.9$/go 1.26.4/' \
      gui_interface/fyne-ui/go.mod \
      gui_interface/mercury-client/go.mod
  '';

  # Build the C engine that the Fyne GUI links into the binary. The module
  # vendor derivation has no C dependencies, so skip this step there.
  preBuild = ''
    make -C ../.. libmercury_core.a
  '';

  overrideModAttrs = _: _: {
    preBuild = "";
  };

  tags = [ "mercury_embedded" ];

  subPackages = [ "." ];

  # The upstream tests start the engine and expect audio/radio hardware.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.coreBuildID=dev"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "mercury-ui";
      desktopName = "Mercury";
      exec = "mercury-ui";
      icon = "mercury-ui";
      categories = [ "Network" "HamRadio" ];
      comment = "HERMES HF modem";
    })
  ];

  postInstall = ''
    if [ -e $out/bin/mercury-fyne-ui ]; then
      mv $out/bin/mercury-fyne-ui $out/bin/mercury-ui
    fi

    install -Dm644 mercury-ui.png \
      $out/share/icons/hicolor/256x256/apps/mercury-ui.png
  '';

  meta = with lib; {
    description = "Fyne desktop GUI for the Mercury HERMES HF modem";
    homepage = "https://github.com/Rhizomatica/mercury";
    changelog = "https://github.com/Rhizomatica/mercury/releases/tag/v${version}";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mercury-ui";
  };
}
