{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  src ? null,
}:

# RMS Radar native desktop window (WebKitGTK). The web build in default.nix is
# CGO-free; this one requires webview_go and a platform webview runtime.
let
  source = import ./source.nix { inherit fetchFromGitHub src; };
in
buildGoModule rec {
  pname = "rms-radar-desktop";
  version = "0.2.8";

  src = source;
  vendorHash = "sha256-xp94e2pplRwZuOBs0WNIqSu268G/RTSboWNHmBbAjZ0=";

  env.CGO_ENABLED = "1";
  tags = [ "desktop" ];

  nativeBuildInputs = [ pkg-config ];
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
