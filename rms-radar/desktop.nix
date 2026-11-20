{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  librsvg,
  ...
}@args:

# RMS Radar native desktop window (WebKitGTK). The web build in default.nix is
# CGO-free; this one requires webview_go and a platform webview runtime.
let
  # See default.nix: keep `src` out of the formal arguments so callPackage
  # cannot inject nixpkgs' unrelated `src` package.
  source = import ./source.nix {
    inherit fetchFromGitHub;
    src = args.src or null;
  };
in
buildGoModule rec {
  pname = "rms-radar-desktop";
  version = "1.0.6";

  src = source;
  vendorHash = "sha256-xp94e2pplRwZuOBs0WNIqSu268G/RTSboWNHmBbAjZ0=";

  env.CGO_ENABLED = "1";
  tags = [ "desktop" ];

  nativeBuildInputs = [ pkg-config librsvg ];
  buildInputs = [ gtk3 webkitgtk_4_1 ];

  # webview_go asks pkg-config for webkit2gtk-4.0; modern distributions ship the
  # compatible 4.1 ABI under a different package name.
  preBuild = ''
    mkdir -p webkit2gtk-shim
    cat > webkit2gtk-shim/webkit2gtk-4.0.pc <<EOF
Name: webkit2gtk-4.0
Description: WebKitGTK 4.1 compatibility shim for webview
Version: ${webkitgtk_4_1.version}
Requires: webkit2gtk-4.1
EOF
    export PKG_CONFIG_PATH="$PWD/webkit2gtk-shim''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  postInstall = ''
    mv $out/bin/rms-radar $out/bin/rms-radar-desktop
    install -Dm644 contrib/desktop/rms-radar-desktop.desktop \
      $out/share/applications/rms-radar-desktop.desktop
    install -Dm644 contrib/desktop/rms-radar.svg \
      $out/share/icons/hicolor/scalable/apps/rms-radar-desktop.svg
    install -Dm644 contrib/desktop/rms-radar-1024.png \
      $out/share/icons/hicolor/1024x1024/apps/rms-radar-desktop.png
    for size in 256 512; do
      install -d "$out/share/icons/hicolor/''${size}x''${size}/apps"
      rsvg-convert -w "$size" -h "$size" contrib/desktop/rms-radar.svg \
        -o "$out/share/icons/hicolor/''${size}x''${size}/apps/rms-radar-desktop.png"
    done
  '';

  meta = with lib; {
    description = "Native RMS Radar desktop map for Winlink gateways";
    homepage = "https://github.com/ben-kuhn/rms-radar";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "rms-radar-desktop";
  };
}
