{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  cacert,
  hamlib_4,
  libpulseaudio,
  libusb1,
  openssl,
  udev,
}:

# hams.com's Local Hardware Relay is a proprietary, pre-built Rust daemon.
# Upstream publishes it as a Debian package (also available from their APT
# repository).  We repackage that binary for Nix rather than building from
# source, because the relay source is only available after registering on
# hams.com and is not licensed for redistribution.
stdenv.mkDerivation rec {
  pname = "hams-local-relay";
  version = "0.3.3";

  src =
    if stdenv.hostPlatform.isx86_64 then
      fetchurl {
        url = "https://hams.com/relay/apt/pool/main/h/${pname}/${pname}_${version}-1_amd64.deb";
        hash = "sha256-LfNYy0+QY+JUVcweK5forUlGLdql8wotJwe9bCKV1es=";
      }
    else if stdenv.hostPlatform.isAarch64 then
      fetchurl {
        url = "https://hams.com/relay/apt/pool/main/h/${pname}/${pname}_${version}-1_arm64.deb";
        hash = "sha256-ZuGIqOLHMOOEp8vMg97b89Jq77QUF2ePFTj+XX1sHD0=";
      }
    else
      throw "hams-local-relay: unsupported platform ${stdenv.hostPlatform.system}";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    hamlib_4
    libpulseaudio
    libusb1
    openssl
    (lib.getLib stdenv.cc.cc)
    udev
  ];

  # The daemon and its RADE codec library are loaded from the same directory
  # (upstream installs both into /usr/bin); keep that layout and make sure
  # the dynamic loader can find librade.so.0.1.
  appendRunpaths = [ "$ORIGIN" ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar -x --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/hams-local-relay
    mkdir -p $out/share/hams-local-relay
    mkdir -p $out/share/doc/hams-local-relay

    install -Dm755 usr/bin/hams-local-relay \
      $out/libexec/hams-local-relay/hams-local-relay
    install -Dm644 usr/bin/librade.so.0.1 \
      $out/libexec/hams-local-relay/librade.so.0.1

    # Optional DKMS sources and helper for the ch341 USB serial driver.
    # NixOS kernels normally ship ch341 already; this is kept for people who
    # need to build it out-of-tree.
    cp -r usr/lib/hams-local-relay/dkms $out/share/hams-local-relay/
    install -Dm755 usr/lib/hams-local-relay/install_usb_serial_driver.sh \
      $out/share/hams-local-relay/install_usb_serial_driver.sh

    cp -r usr/share/doc/hams-local-relay/. $out/share/doc/hams-local-relay/

    # tqsl is not included: it is a GUI application with a very large
    # dependency closure (about 1 GB) and the relay only needs it when the
    # user enables Logbook of the World uploads.  Install pkgs.tqsl and put
    # it on PATH if you use that feature.
    makeWrapper $out/libexec/hams-local-relay/hams-local-relay \
      $out/bin/hams-local-relay \
      --prefix LD_LIBRARY_PATH : "$out/libexec/hams-local-relay:${
        lib.makeLibraryPath [
          libpulseaudio
          libusb1
          udev
        ]
      }" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hams.com Local Hardware Relay (proprietary pre-built daemon)";
    longDescription = ''
      A per-user daemon that bridges a ham operator's radio hardware (via
      Hamlib) and audio devices to the hams.com Web Shack over an encrypted
      control channel.  Supports FT8, WSPR, PSK31, RTTY, FreeDV/RADE,
      satellite tracking, LoTW, and CAT sharing.

      Upstream distributes this program as a pre-built binary; the source is
      available from hams.com after registration but is not open source.
    '';
    homepage = "https://hams.com/shack/download";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "hams-local-relay";
  };
}
