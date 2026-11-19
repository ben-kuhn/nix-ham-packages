{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "ba22d8ca0c519c51ebf1db1dac685253b75a5a1b";
  hash = "sha256-GQe8SpYV42fpO7T9y7c1F661NmV1Lak2Co/+paLfPYg=";
}
