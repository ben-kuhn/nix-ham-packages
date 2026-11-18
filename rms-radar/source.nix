{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "96345e0e083d6fc6ff4d07241b83518c564d65db";
  hash = "sha256-REM7GxW+6ZRnqafCaWKgRNCa/0ZZlIRsIpvGhQbP5MI=";
}
