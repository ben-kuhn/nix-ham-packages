{ lib
, stdenv
, fetchFromGitHub
, libax25
, linuxHeaders
}:

stdenv.mkDerivation rec {
  pname = "ldsped";
  version = "1.16";

  src = fetchFromGitHub {
    owner = "ampledata";
    repo = "ldsped";
    rev = "bd0cc6e9ffa71ed1c70a23670afbc5b3b7020995";
    sha256 = "1xwpankfdlkcq7kilca5zx0g76d978im3279y3yjwlgnyg8zrw6q";
  };

  buildInputs = [ libax25 ];
  nativeBuildInputs = [ linuxHeaders ];

  # The configure script is pre-generated, no need for autoreconfHook
  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--mandir=${placeholder "out"}/share/man"
  ];

  # Patch the source to use Linux kernel headers for AX.25 definitions
  # The original code expects netax25/ax25.h or netax25/kernel_ax25.h,
  # but modern libax25 doesn't include these. The kernel headers provide
  # the necessary AX.25 type definitions.
  prePatch = ''
    # Create compatibility headers that bridge to Linux kernel headers
    # Modern libax25 doesn't include kernel_ax25.h or kernel_rose.h,
    # so we create shims that point to the kernel headers
    mkdir -p compat/netax25 compat/netrose

    # AX.25 compatibility header
    cat > compat/netax25/ax25.h << 'EOF'
/* Compatibility header for ldsped - bridges to Linux kernel AX.25 headers */
#ifndef _COMPAT_NETAX25_AX25_H
#define _COMPAT_NETAX25_AX25_H

#include <linux/ax25.h>

/* Define ax25_fwd_struct if not present (for configure check compatibility) */
#ifndef ax25_fwd_struct
typedef struct {
    ax25_address port_from;
    ax25_address port_to;
} ax25_fwd_struct;
#endif

#endif /* _COMPAT_NETAX25_AX25_H */
EOF
    cp compat/netax25/ax25.h compat/netax25/kernel_ax25.h

    # ROSE compatibility header
    cat > compat/netax25/kernel_rose.h << 'EOF'
/* Compatibility header for ldsped - bridges to Linux kernel ROSE headers */
#ifndef _COMPAT_NETAX25_KERNEL_ROSE_H
#define _COMPAT_NETAX25_KERNEL_ROSE_H

#include <linux/rose.h>

#endif /* _COMPAT_NETAX25_KERNEL_ROSE_H */
EOF
    cat > compat/netrose/rose.h << 'EOF'
/* Compatibility header for ldsped - bridges to Linux kernel ROSE headers */
#ifndef _COMPAT_NETROSE_ROSE_H
#define _COMPAT_NETROSE_ROSE_H

#include <linux/rose.h>

#endif /* _COMPAT_NETROSE_ROSE_H */
EOF

    # Fix K&R style function definitions for modern GCC
    # Only fix the function definition (line 304), not function calls
    # The definition has format "static void check_external(monsock) {"
    sed -i 's/static void check_external(monsock)/static void check_external(int monsock)/g' ldsped.c
  '';

  # Set the AX25 paths and include our compatibility headers
  # Legacy code requires relaxed warnings and compatibility flags:
  # -fcommon: allow tentative definitions (legacy C style with globals in headers)
  # -Wno-pointer-sign: suppress char*/unsigned char* mismatch warnings
  # -Wno-format-security: suppress format string security warnings (legacy syslog calls)
  # -Wno-stringop-truncation: suppress strncpy truncation warnings (intentional in code)
  # -Wno-format-overflow: suppress sprintf overflow warnings (legacy buffer handling)
  preConfigure = ''
    export AX25_SYSCONFDIR="/etc/ax25"
    export AX25_LOCALSTATEDIR="/var/ax25"
    export CPPFLAGS="-I$(pwd)/compat -I${linuxHeaders}/include $CPPFLAGS"
    export CFLAGS="-I$(pwd)/compat -I${linuxHeaders}/include -fcommon -Wno-pointer-sign -Wno-format-security -Wno-stringop-truncation -Wno-format-overflow $CFLAGS"
  '';

  postInstall = ''
    # Install the example configuration file to share directory
    # (config files go in /etc/ax25/ which is outside the Nix store)
    install -Dm644 ldsped.conf.example $out/share/doc/ldsped/ldsped.conf.example
  '';

  meta = with lib; {
    description = "Open-source, multi-platform replacement for AGWPE (AGW Packet Engine)";
    longDescription = ''
      ldsped is an open-source replacement for AGWPE, a packet radio application.
      It provides AX.25 packet radio connectivity, APRS support, beacon generation,
      and call logging utilities for amateur radio operators.

      Note: ldsped must be run as root since it needs to connect to system sockets.

      Configuration: Copy the example config to /etc/ax25/:
        sudo mkdir -p /etc/ax25
        sudo cp "$(dirname "$(readlink -f "$(which ldsped)")")/../share/doc/ldsped/ldsped.conf.example" /etc/ax25/ldsped.conf
    '';
    homepage = "https://github.com/ampledata/ldsped";
    license = licenses.gpl2Only;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "ldsped";
  };
}
