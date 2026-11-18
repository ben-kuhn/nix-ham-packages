{
  lib,
  buildGoModule,
  fetchFromGitHub,
  src ? null,
}:

# RMS Radar — Winlink RMS gateway map (Go; the web build is CGO-free).
#
# `src` defaults to the upstream GitHub release. It can also be built from a
# local checkout with (run from the nix-ham-packages dir):
#   nix build --impure --expr \
#     'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./rms-radar { src = ../../rms-radar; }'
let
  source = if src != null then src else fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "rms-radar";
    rev = "57342049b9e21e8155961c769dd46b91d449d1de";
    hash = "sha256-OuvdTfUVna8TRMnv+1WPaBsRxiD8ycirnRToSTK9toY=";
  };
in
buildGoModule rec {
  pname = "rms-radar";
  version = "0.2.7";

  src = source;

  # webview_go (desktop build only) is vendored; the web build stays CGO-free.
  vendorHash = "sha256-xp94e2pplRwZuOBs0WNIqSu268G/RTSboWNHmBbAjZ0=";

  env.CGO_ENABLED = "0";

  postInstall = ''
    install -Dm644 contrib/desktop/rms-radar.desktop $out/share/applications/rms-radar.desktop
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "RMS Radar — Winlink RMS gateway map with service-code filtering and propagation ranking";
    longDescription = ''
      A minimal, self-hostable web service that periodically refreshes the
      Winlink RMS gateway list, maps gateways on OpenStreetMap, and lets users
      filter and rank stations by service code (e.g. MERCURY), band, and mode
      and mode using current propagation conditions.
    '';
    homepage = "https://github.com/ben-kuhn/rms-radar";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "rms-radar";
  };
}
