{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "8a2c35d5bf497e7d8068b1106504bb5e30e76620";
  hash = "sha256-2agpaCmi8ghrOgUtY2dBnnqt5nzmIyhVAaBmRNC3TII=";
}
