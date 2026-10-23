#!/bin/sh
# Builds NUKU.EXE for DOS (32-bit protected mode, go32v2 / DPMI).
#
# Needs:
#   FPC_CROSS   ppcross386 built for go32v2 (make crossall CPU_TARGET=i386 OS_TARGET=go32v2)
#   FPC_RTL     its go32v2 unit directory (rtl/units/go32v2)
#   DJGPP       DJGPP cross toolchain root (binutils + libc), i586-pc-msdosdjgpp-*
#   MIKMOD_DOS  directory holding libmikmod.a built with libmikmod/dos/Makefile.dj
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
TOP="$(dirname "$HERE")"
: "${FPC_CROSS:?set FPC_CROSS}"; : "${FPC_RTL:?set FPC_RTL}"
: "${DJGPP:?set DJGPP}"; : "${MIKMOD_DOS:?set MIKMOD_DOS}"

STAGE="$TOP/build-dos"
rm -rf "$STAGE"; mkdir -p "$STAGE/units"
# shared game logic + DOS platform units
cp "$TOP"/nuku.pas "$TOP"/nukumain.pas "$TOP"/nukunit.pas "$TOP"/nukusupl.pas \
   "$TOP"/fastkeys.pas "$TOP"/nuku_log.pas "$STAGE"/
cp "$HERE"/sdl.pas "$HERE"/nuku_screen.pas "$HERE"/nuku_keyboard.pas \
   "$HERE"/nuku_music.pas "$HERE"/mikmod_dos.pas "$STAGE"/

export PATH="$DJGPP/bin:$PATH"
GCCLIB="$(dirname "$(i586-pc-msdosdjgpp-gcc -print-libgcc-file-name)")"
cd "$STAGE"
"$FPC_CROSS" -Tgo32v2 -n -Sg -Rintel -O2 -XPi586-pc-msdosdjgpp- -Xs \
  -Fu"$FPC_RTL" -Fl"$MIKMOD_DOS" -Fl"$DJGPP/i586-pc-msdosdjgpp/lib" -Fl"$GCCLIB" \
  -FUunits -FE. -oNUKU.EXE nuku.pas
echo "built $STAGE/NUKU.EXE"
