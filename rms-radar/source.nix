{ fetchFromGitHub, src ? null }:
if src != null then src else fetchFromGitHub {
  owner = "ben-kuhn";
  repo = "rms-radar";
  rev = "0a3f3950ed2be936dc4bbd3f04d754842ff9a1fa";
  hash = "sha256-3nG+If5VjcDk6tU8G5p2AiYOJn6bOsT9NO/3+ZPAmAo=";
}
