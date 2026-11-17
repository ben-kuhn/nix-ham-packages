{
  lib,
  buildGoModule,
  fetchFromGitHub,
  src ? null,
}:

# open-rmslist — Winlink RMS gateway map (Go, zero external dependencies).
#
# `src` defaults to the upstream GitHub release. It can also be built from a
# local checkout with (run from the nix-ham-packages dir):
#   nix build --impure --expr \
#     'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./open-rmslist { src = ../../open-rmslist; }'
let
  source = if src != null then src else fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "open-rmslist";
    rev = "b09f1dcfe191d1fd5b96bdcba3ccbe5235d207c1";
    hash = "sha256-/OEKld/zYw2m2rT7w5dP6Iehae59lkEbkSdcDwh7hsE=";
  };
in
buildGoModule rec {
  pname = "open-rmslist";
  version = "0.1.2";

  src = source;

  # Zero Go dependencies: no vendoring.
  vendorHash = null;

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Winlink RMS gateway map with service-code filtering and propagation ranking";
    longDescription = ''
      A minimal, self-hostable web service that periodically refreshes the
      Winlink RMS gateway list, maps gateways on OpenStreetMap, and lets users
      filter and rank stations by service code (e.g. MERCURY), band, and mode
      and mode using current propagation conditions.
    '';
    homepage = "https://github.com/ben-kuhn/open-rmslist";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "open-rmslist";
  };
}
