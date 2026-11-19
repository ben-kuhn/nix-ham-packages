{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "440ef22b972ea5c84361ced10dc49b63361240a3";
  hash = "sha256-yS6E8tRs84aImviW4WuFWxiwrO2ZVxDklnsQeqO3BF8=";
}
