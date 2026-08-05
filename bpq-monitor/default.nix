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
    rev = "995876135bd8b82731020ffb7722d4b296375a7f";
    hash = "sha256-gai0lqdShGm7gF817P9Dsnh+IKXqodQy3aMfLBLnVdo=";
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
