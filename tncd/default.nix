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
  version = "2.0.0-unstable-2026-10-09";

  # Track the main branch. The stable 1.x line lives on the `v1` branch and
  # in the APT/RPM repos; this package follows the 2.0 Go development tree.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "5e3004cfd10bf4e4402a646e239ac2564e4f907b";
    hash = "sha256-4zs9Dv6k2lsel76vJ0E20n5er2nXxY253wvmBaOyFuo=";
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
