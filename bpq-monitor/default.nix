{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "bpq-monitor";
  version = "0-unstable-2026-08-17";

  src = fetchFromGitHub {
    owner = "ben-kuhn";
    repo = "bpq-monitor";
    rev = "3dedd63b3bfa82f4441172f2f76ffdf3c841e00e";
    hash = "sha256-pNCDlMg6bVuioRpyq8tocrkzKdU6VSEh6V0Q6GDw0E8=";
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
