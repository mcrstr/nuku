# Nuku — 2019 port, minimal changes

A game programmed in 1996 by Juan Linietsky and Pablo Selener in Borland Pascal for DOS.

This branch is the 2019 SDL 1.2 port from [reduz/nuku](https://github.com/reduz/nuku)
with only what is needed to compile and run it. No new features. The DOS build and
the version with extra conveniences are in the [`master`](https://github.com/mcrstr/nuku) branch.

## Screenshots

<p>
  <img src="screenshots/screen1.png" width="32%" alt="Main menu">
  <img src="screenshots/screen2.png" width="32%" alt="Bonus level">
  <img src="screenshots/screen3.png" width="32%" alt="Crossing the river, level intro">
</p>
<p>
  <img src="screenshots/screen4.png" width="32%" alt="Level with mountains">
  <img src="screenshots/screen5.png" width="32%" alt="Boss fight">
  <img src="screenshots/screen6.png" width="32%" alt="Bonus level intro">
</p>

## Download and play

Built from this branch:

- **Windows 64-bit**: [Nuku-win64-port2019.zip](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-win64-port2019.zip)
- **Windows 32-bit**: [Nuku-win32-port2019.zip](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-win32-port2019.zip)

Unpack the whole folder and run `nuku.exe`. A console window with debug messages opens
next to the game; that is how the 2019 port works.

The DOS build is [Nuku-DOS.zip](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-DOS.zip),
built from `master`.

**Controls:** arrows to move, Up to jump, Right Ctrl for action, Enter in menus, F11 to pause.
Player 2: A/C to move, S to jump, V for action.
Esc during a level skips to the next one; to quit a level, pause with F11 and press Esc.

## For developers

### What was changed

- inline 16/32-bit assembly replaced with equivalent Pascal (tile and sprite blits, palette, RNG);
- names adapted to the stock Free Pascal SDL 1.2 binding (`sdl` unit instead of
  `sdl_video`, `sdl_events`, `sdl_keyboard`, `sdl_timer`);
- the prototypes of the C scaler (`copy_and_filter.c`) use 32-bit ints; the C code itself is unchanged;
- libmikmod is loaded as `libmikmod-3.dll` on Windows;
- FPU exceptions are masked, otherwise the C libraries crash the game;
- two bugs fixed: the font buffer was 56 bytes too small for what the loader writes into it,
  and level maps were read only partially, so ground was missing at the start of level 1.

### Building

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
