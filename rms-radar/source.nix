{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "db3f01693e52cb7d7acfe62f49d95aa72e3a2ab3";
  hash = "sha256-pKYTjA1OdFmCIg7VToqO/e+zVahMXc6IHFrg/Q5iRBE=";
}
