{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pnpm_10,
  nodejs,
  cmake,
  pkg-config,
  wrapGAppsHook4,
  webkitgtk_4_1,
  glib-networking,
  gtk3,
  libsecret,
  libax25,
  libheif,
  libde265,
  libwebp,
  openssl,
  libsoup_3,
  libayatana-appindicator,
  librsvg,
  xdotool,
  dbus,
  alsa-lib,
  udev,
}:

rustPlatform.buildRustPackage rec {
  pname = "tuxlink";
  version = "0.94.0";

  src = fetchFromGitHub {
    owner = "cameronzucker";
    repo = "tuxlink";
    rev = "v${version}";
    hash = "sha256-09uGwmdcLUZ6cw0X96Xi70GFfkGeAbbjMTOvQkcDHso=";
  };

  sourceRoot = "${src.name}";

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  pnpmDeps = pnpm_10.fetchDeps {
    inherit pname version src;
    fetcherVersion = 1;
    hash = "sha256-p2hqrMHpJdrKemmxS2UleCNpB7uHR+r8WZPNlaD/fv4=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    pnpm_10.configHook
    nodejs
    cmake
    rustPlatform.bindgenHook
  ];

  # cmake is only needed by the whisper-rs-sys build script (whisper.cpp);
  # this is not a top-level cmake project, so keep its setup hook from
  # taking over the configure phase.
  dontUseCmakeConfigure = true;

  buildInputs = [
    webkitgtk_4_1
    glib-networking
    gtk3
    libsecret
    libax25
    libheif
    libde265
    libwebp
    openssl
    libsoup_3
    libayatana-appindicator
    librsvg
    xdotool
    dbus
    alsa-lib
    udev
  ];

  preBuild = ''
    pnpm run build

    # libsqlite3-sys 0.38.1 and rusqlite 0.40.1 use the unstable
    # `cfg_select!` macro. Inject `#![feature(cfg_select)]` at the crate
    # root and update the vendor checksum so cargo accepts the patched copy.
    patch_crate_root() {
      local crate_dir=$1 root_file=$2
      pushd "$crate_dir"
      sed -i '1i#![feature(cfg_select)]' "$root_file"
      local new_hash
      new_hash=$(sha256sum "$root_file" | cut -d' ' -f1)
      sed -i "s|\"$root_file\":\"[a-f0-9]*\"|\"$root_file\":\"$new_hash\"|" \
        .cargo-checksum.json
      popd
    }
    sqlite_sys=$(find /build -type d -name 'libsqlite3-sys-0.38.1' -print -quit)
    rusqlite_dir=$(find /build -type d -name 'rusqlite-0.40.1' -print -quit)
    patch_crate_root "$sqlite_sys" build.rs
    patch_crate_root "$rusqlite_dir" src/lib.rs
  '';

  # Needed for the `#![feature(cfg_select)]` enabled in the patched
  # libsqlite3-sys build script.
  env.RUSTC_BOOTSTRAP = "1";

  cargoBuildFlags = [
    "--bin"
    "tuxlink"
    "--bin"
    "tuxlink-gps-fix"
  ];

  # Tests rely on a running keyring / network / radio hardware.
  doCheck = false;

  preInstall = ''
    gps_fix=$(find /build -name tuxlink-gps-fix -type f -executable -print -quit)
    install -Dm755 "$gps_fix" $out/libexec/tuxlink-gps-fix
  '';

  postInstall = ''
    src_root=/build/source
    install -Dm644 $src_root/src-tauri/packaging/com.tuxlink.app.policy \
      $out/share/polkit-1/actions/com.tuxlink.app.policy

    mkdir -p $out/share/applications
    substitute $src_root/scripts/tuxlink.desktop \
      $out/share/applications/tuxlink.desktop \
      --replace-fail "/usr/bin/env tuxlink" "$out/bin/tuxlink"
    chmod 644 $out/share/applications/tuxlink.desktop

    install -Dm644 $src_root/src-tauri/icons/32x32.png \
      $out/share/icons/hicolor/32x32/apps/tuxlink.png
    install -Dm644 $src_root/src-tauri/icons/128x128.png \
      $out/share/icons/hicolor/128x128/apps/tuxlink.png
  '';

  meta = {
    description = "Linux-native Winlink-compatible amateur-radio email client";
    homepage = "https://github.com/cameronzucker/tuxlink";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "tuxlink";
  };
}
