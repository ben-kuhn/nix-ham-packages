{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "30fe1dffa11d695cdbd3548d6881d73fa8d5d0b2";
  hash = "sha256-MFHB+dPd3PkmFJQQOnwK63S785iw7vbSqvQa4rshSsE=";
}
