{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  libax25,
  installShellFiles,
  wl2k-go-src ? null,
}:

buildGoModule rec {
  pname = "pat";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "la5nta";
    repo = "pat";
    rev = "v${version}";
    hash = "sha256-5pWah0l/JuSh6ZmqPOLXFGkFwzY3avmo2fjHf2N1O6U=";
  };

  vendorHash = "sha256-oyhPgo7wc0B27l6pQ24MDZLNmvH5cnEI1qOMgc2QpHA=";

  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = lib.optional stdenv.hostPlatform.isLinux [ libax25 ];

  tags = lib.optionals stdenv.hostPlatform.isLinux [ "libax25" ];

  preBuild = lib.optionalString (wl2k-go-src != null) ''
    # Download all modules first so we can patch wl2k-go before compilation
    go mod download
    wl2k_dir="$(go env GOMODCACHE)/github.com/la5nta/wl2k-go@v1.0.1"
    echo "Replacing $wl2k_dir with local source from ${wl2k-go-src}"
    chmod -R u+w "$wl2k_dir"
    rm -rf "$wl2k_dir"
    cp -r ${wl2k-go-src} "$wl2k_dir"
    chmod -R u+w "$wl2k_dir"
  '';

  postInstall = ''
    installManPage man/pat-configure.1 man/pat.1
  '';

  meta = {
    description = "Cross-platform Winlink client written in Go";
    homepage = "https://getpat.io/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "pat";
  };
}
