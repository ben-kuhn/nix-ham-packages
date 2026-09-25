{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# tncd 2.0 — pure-Go rewrite of the AGWPE-to-KISS AX.25 bridge.
# (The 1.x Python line lives on the `v1` git branch and the stable
#  APT/RPM repos; this package tracks the 2.0 Go beta line.)
buildGoModule rec {
  pname = "tncd";
  version = "1.103-Beta";

  # Tracks the latest TAGGED release, deliberately. This overlay is public and
  # other people's configs reference it, so it must not point at whatever main
  # happens to be. Ben's own fleet tests main by a separate `tncd-src` flake
  # input that overrides this package's src -- see nixos-config's
  # modules/ham-radio.nix -- which keeps "what the fleet is testing" and "what
  # this overlay ships to everyone else" independent.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "v${version}";
    hash = "sha256-mCJ1PFeA9HkxOJyPsnF3Bcfw3APWe/RKunrL1dJhLwU=";
  };

  # go.mod is unchanged since the tncd-go dev package; same vendorHash.
  vendorHash = "sha256-iRvDXz9Dn7Pi6m2rA+nwgDYCgqd3KWJATBMSKvxwRZ8=";

  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/tncd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ben-kuhn/tncd/v2/internal/version.Version=${version}"
  ];

  postInstall = ''
    install -Dm644 tncd.ini $out/share/tncd/tncd.ini.example
  '';

  meta = with lib; {
    description = "AGWPE-to-KISS Translation Bridge (Go)";
    longDescription = ''
      A bridge that allows AGWPE-client applications (PAT/Winlink, Paracon,
      Xastir) to communicate with KISS TNCs over serial, TCP, or Bluetooth SPP.
      Implements AX.25 layer-2 connected mode. Pure-Go 2.0 rewrite.
    '';
    homepage = "https://tncd.dev";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "tncd";
  };
}
