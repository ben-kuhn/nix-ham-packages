{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "62226132bc3e5af7c9fa0deb8ee2c17fa05e365c";
  hash = "sha256-j0kUq0GgSM2gKvVDaD0yewUlgCIrQWCa01/svI1kN6c=";
}
