{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "7b123434e95d21571b087ba866053da978f34b48";
  hash = "sha256-UrG41F+9VDcK8Iaq+Lxa4tl4PYcgUPA1ghOsqpwQIOA=";
}
