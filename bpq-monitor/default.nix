{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "bpq-monitor";
  version = "0-unstable-2026-08-05";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "bpq-monitor";
    rev = "708ff9aff3bd3f2f8fbe3b45da6c610caa8692a9";
    hash = "sha256-kVFiPr7uIBO1Cg0jF5GkPyL8gc1zmjI9GSqdF6gkPHg=";
  };

  # All dependencies are vendored in the repo.
  vendorHash = null;

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Web UI for monitoring BPQ node modem traffic and status";
    homepage = "https://github.com/ben-kuhn/bpq-monitor";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "bpq-monitor";
  };
}
