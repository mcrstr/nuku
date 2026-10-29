# Nuku — 2019 port, minimal changes

A game programmed in 1996 by Juan Linietsky and Pablo Selener in Borland Pascal for DOS.

This branch is the 2019 SDL 1.2 port from [reduz/nuku](https://github.com/reduz/nuku)
with only what is needed to compile and run it. No new features. The DOS build and
the version with extra conveniences are in the `master` branch.

Ready-made builds for Windows x86 and x64 are in [Releases](../../releases).

## What was changed

- inline 16/32-bit assembly replaced with equivalent Pascal (tile and sprite blits, palette, RNG);
- names adapted to the stock Free Pascal SDL 1.2 binding (`sdl` unit instead of
  `sdl_video`, `sdl_events`, `sdl_keyboard`, `sdl_timer`);
- the prototypes of the C scaler (`copy_and_filter.c`) use 32-bit ints; the C code itself is unchanged;
- libmikmod is loaded as `libmikmod-3.dll` on Windows;
- FPU exceptions are masked, otherwise the C libraries crash the game;
- two bugs fixed: the font buffer was 56 bytes too small for what the loader writes into it,
  and level maps were read only partially, so ground was missing at the start of level 1.

## Building

Linux (32- or 64-bit) or cross-compiling for Windows with Free Pascal 3.2.2:

```
gcc -c copy_and_filter.c -O3 -ffast-math -funroll-loops   # i686- or x86_64-w64-mingw32-gcc for Windows
ar rc libcopy_and_filter.a copy_and_filter.o
fpc -Sg -Rintel -O2 -Fl. nuku.pas                        # add -Twin32 or -Twin64 for Windows
```

Runtime libraries: SDL 1.2 and libmikmod 3. On Windows put `SDL.dll` and `libmikmod-3.dll`
next to `nuku.exe`.

## License

The game is under the MIT license, see [LICENSE.md](LICENSE.md).
SDL 1.2 and libmikmod are under the LGPL.

