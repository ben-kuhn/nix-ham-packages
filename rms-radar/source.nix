{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "5d0312a28bff34929504f712d2410e7e7ca480de";
  hash = "sha256-XsvpT/+2LKsHsdYTQdUtegdLlx8IB50DU0Tgpse/KBU=";
}
