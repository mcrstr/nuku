#!/bin/sh
# Native build (Linux/macOS): needs fpc, SDL 1.2 (or sdl12-compat) and libmikmod.
#   ./build.sh
# Windows x64 cross build: needs a win64 FPC RTL and the SDL unit built for win64.
#   WIN64_UNITS="/path/rtl/units/x86_64-win64 /path/sdl-win64" ./build.sh win64
set -e
cd "$(dirname "$0")"

if [ "$1" = "win64" ]; then
	mkdir -p buildw
	FU=""
	for d in $WIN64_UNITS; do FU="$FU -Fu$d"; done
	ppcx64 -Twin64 -n -Sg -Rintel -O2 -WG $FU -FEbuildw -FUbuildw nuku.pas
	echo "built buildw/nuku.exe (needs SDL.dll and libmikmod-3.dll next to it)"
else
	mkdir -p build
	fpc -Rintel -O2 -FEbuild -FUbuild nuku.pas
	echo "built build/nuku (run it from this folder, next to the game data)"
fi
