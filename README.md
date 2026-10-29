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

Built from `master`: the DOS build, [Nuku-DOS.zip](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-DOS.zip),
and an *enhanced* Windows build with window scaling and fullscreen,
[64-bit](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-win64-enhanced.zip) ·
[32-bit](https://github.com/mcrstr/nuku/releases/latest/download/Nuku-win32-enhanced.zip).

**Controls:** arrows to move, Up to jump, Right Ctrl for action, Enter in menus, F11 to pause.
Player 2: A/C to move, S to jump, V for action.
Esc during a level skips to the next one; to quit a level, pause with F11 and press Esc.

## For developers

### Why the 2019 port did not build or run

Notes for anyone who worked on the port, in the order the problems showed up.

**It did not compile**

- *SDL binding.* The port was written against a JEDI-SDL style binding with separate units
  (`sdl_video`, `sdl_events`, `sdl_keyboard`, `sdl_timer`) and names like `SDL_Surface`,
  `SDL_ColorArray`, `event.eventtype`, `SDL_EVENTQUIT`. Free Pascal ships a single `sdl` unit
  with `TSDL_Surface`, `PSDL_ColorArray`, `event.type_`, `SDL_QUITEV`. Only the names changed.
- *Inline assembly.* `nukusupl.pas` and `nukunit.pas` still had 16/32-bit `asm` blocks:
  `push edi`/`pop esi` and 16-bit address arithmetic are rejected on x86_64, and `in`/`out`
  to VGA and PIT ports cannot work in a user-mode program anyway. They were replaced with
  Pascal that does the same thing, quirks included: `MoveN`, `MoveI`, `MovesI` (transparent
  sprite copies), `MoveWPal`, `Perturb` (the RNG, including the carry from `shl`), `boxblue`,
  the tile blitter in `PutThing`, and the timer counters in `INT8PROC`. `PortOut`/`port`
  became no-ops, as nothing in the SDL code path needs them.

**It compiled, then crashed**

- *FPU exceptions.* Free Pascal unmasks FPU exceptions, the C libraries (SDL, X11, libmikmod)
  expect them masked. The first floating-point operation inside SDL ended with
  `EInvalidOp: Invalid floating point operation`. Fixed with `SetExceptionMask`.
- *Heap corruption.* `letra_rec` is `array[0..1959]`, but the font loader in `init` copies
  36 characters × 7 × 8 = 2016 bytes into it. The extra 56 bytes overwrite the heap and glibc
  aborts with `corrupted double-linked list` during startup. The array is now
  `[0..2015]`.
- *C prototypes.* `copy_and_filter_pas.pp` declared `p_w, p_h: integer`. Without `{$mode objfpc}`
  `integer` is 16-bit in Free Pascal, while the C side takes `int`, so the filter received
  garbage sizes. They are `longint` now.

**It ran, but levels were broken**

- *Level maps.* `initlev` reads `64000` bytes of the `.map` file, but each map is
  524 × 125 = 65500 bytes. The last 1500 bytes stayed zero, so the ground was missing at the
  start of level 1. It now reads 65500.

**Not fixed, left as in the port**

- `key[$19]` in `nukunit.pas` refills energy. `$19` is the DOS scancode of P; with SDL key codes
  the check never fires.
- Esc during a level sets `finished`, the same flag as reaching the end, so it skips the level.

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
