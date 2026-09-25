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
  version = "1.103-Beta+rigctl";

  # Field-testing Benshi rig control ahead of a tagged release: an optional
  # hamlib Net rigctl server ([rigctl.N]) that QSYs a BTech UV-PRO and
  # relatives over the same Bluetooth link tncd already holds for KISS. Also
  # carries the connect-setup fixes (a futile-relink budget, so an unreachable
  # station can no longer flap the Bluetooth link, and FRACK-sized SABM/SABME
  # retries). Pinned to a commit rather than a tag until this has on-air time;
  # restore the `rev = "v${version}"` form at the next release.
  #
  # Rig control writes the channel record the radio's active VFO points at --
  # on these radios a VFO is an index into the channel table, so that record
  # IS the VFO. It refuses to write anything that looks like a memory channel
  # (named, below vfo_channel_min, carrying a tx/rx split, or dual watch), but
  # the OTA checklist for it is not signed off yet. rigctl is off by default.
  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "tncd";
    rev = "b1843fa4de649e88196cb8b703366cf47ca8e713";
    hash = "sha256-u4vnb9U05FD8L0X7+HVmMuQymFIELYuQesiCZ7FJr/g=";
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
