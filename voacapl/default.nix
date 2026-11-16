{
  lib,
  stdenv,
  fetchFromGitHub,
  gfortran,
}:

stdenv.mkDerivation rec {
  pname = "voacapl";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "jawatson";
    repo = "voacapl";
    tag = "v${version}";
    hash = "sha256-xqxqvZD9luFC0pCeQm1bdZkl+AiYUqVK5lkvSBvMmcc=";
  };

  nativeBuildInputs = [ gfortran ];

  # The Fortran module dependencies are not declared, so a parallel build
  # races cant99.mod against the two programs that `use Cant99`.
  enableParallelBuilding = false;

  # The build has no meaningful test target; the installed coeffbin and
  # related generators create the itshfbc database during make install.
  doCheck = false;

  meta = with lib; {
    description = "Linux port of the VOACAP HF propagation prediction engine";
    longDescription = ''
      voacapl is a GFortran port of the VOACAP HF propagation model.  It
      installs the prediction engine and the itshfbc coefficient, antenna,
      geographic and database files used by Pat and other VOACAP clients.

      The data directory is share/voacapl/itshfbc in the package output;
      Pat can use it read-only because voacapl supports --run-dir.
    '';
    homepage = "https://github.com/jawatson/voacapl";
    # Core engine: U.S. Government public domain (NTIA/ITS). J.A. Watson's
    # modifications: CC0. dst2csv/dst2ascii: GPL-3+.
    license = [ licenses.publicDomain licenses.cc0 licenses.gpl3Plus ];
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "voacapl";
  };
}
