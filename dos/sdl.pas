unit sdl;
{ DOS build: stand-in for the few SDL identifiers the game logic uses
  (key codes, millisecond clock, delay). No SDL library is involved:
  the clock comes from the PC timer chip, keys from the keyboard IRQ. }
interface

type
  TSDLKey = longword;

const
  SDLK_BACKSPACE = 8;
  SDLK_TAB       = 9;
  SDLK_RETURN    = 13;
  SDLK_ESCAPE    = 27;
  SDLK_SPACE     = 32;
  SDLK_0 = 48; SDLK_1 = 49; SDLK_2 = 50; SDLK_3 = 51; SDLK_4 = 52;
  SDLK_5 = 53; SDLK_6 = 54; SDLK_7 = 55; SDLK_8 = 56; SDLK_9 = 57;
  SDLK_a = 97;  SDLK_b = 98;  SDLK_c = 99;  SDLK_d = 100; SDLK_e = 101;
  SDLK_f = 102; SDLK_g = 103; SDLK_h = 104; SDLK_i = 105; SDLK_j = 106;
  SDLK_k = 107; SDLK_l = 108; SDLK_m = 109; SDLK_n = 110; SDLK_o = 111;
  SDLK_p = 112; SDLK_q = 113; SDLK_r = 114; SDLK_s = 115; SDLK_t = 116;
  SDLK_u = 117; SDLK_v = 118; SDLK_w = 119; SDLK_x = 120; SDLK_y = 121;
  SDLK_z = 122;
  SDLK_UP    = 273;
  SDLK_DOWN  = 274;
  SDLK_RIGHT = 275;
  SDLK_LEFT  = 276;
  SDLK_F1 = 282; SDLK_F2 = 283; SDLK_F3 = 284; SDLK_F4 = 285;
  SDLK_F5 = 286; SDLK_F6 = 287; SDLK_F7 = 288; SDLK_F8 = 289;
  SDLK_F9 = 290; SDLK_F10 = 291; SDLK_F11 = 292; SDLK_F12 = 293;
  SDLK_RSHIFT = 303;
  SDLK_LSHIFT = 304;
  SDLK_RCTRL  = 305;
  SDLK_LCTRL  = 306;
  SDLK_RALT   = 307;
  SDLK_LALT   = 308;

const
  SDL_INIT_AUDIO = $10;
  SDL_INIT_VIDEO = $20;

function SDL_Init(flags: longword): longint;
function SDL_GetTicks: longword;
procedure SDL_Delay(ms: longword);
procedure SDL_Quit;

implementation

uses go32;

{ Milliseconds since start, from the BIOS tick counter (18.2 Hz, kept by the
  BIOS timer IRQ) refined with the current countdown of PIT channel 0. }
var
  start_ms: double;

function raw_ms: double;
var
  t1: longint;
  lo_, hi_, irr: byte;
  cnt: longint;
begin
  disable;
  outportb($43, $00);            { latch channel 0 }
  lo_ := inportb($40);
  hi_ := inportb($40);
  outportb($20, $0A);            { read the PIC's interrupt request register }
  irr := inportb($20);
  t1 := meml[$40:$6C];
  enable;
  cnt := lo_ or (longint(hi_) shl 8);
  if cnt = 0 then cnt := 65536;
  { the counter has already wrapped but the BIOS has not counted the tick yet }
  if ((irr and 1) <> 0) and (cnt > 32768) then inc(t1);
  raw_ms := t1 * (65536.0 * 1000.0 / 1193182.0)
            + (65536 - cnt) * (1000.0 / 1193182.0);
end;

var
  last_ms: longword;

function SDL_GetTicks: longword;
var
  v: double;
  r: longword;
begin
  v := raw_ms - start_ms;
  if v < 0 then v := v + 86400000.0;   { midnight rollover of the BIOS counter }
  r := trunc(v);
  { the latched fraction can jitter slightly; never go backwards }
  if r < last_ms then r := last_ms;
  last_ms := r;
  SDL_GetTicks := r;
end;

procedure SDL_Delay(ms: longword);
var
  t0: longword;
begin
  t0 := SDL_GetTicks;
  while SDL_GetTicks - t0 < ms do ;
end;

procedure SDL_Quit;
begin
end;

function SDL_Init(flags: longword): longint;
begin
  SDL_Init := 0;
end;

procedure restore_pit;
begin
  { back to the BIOS default: mode 3, divisor 65536 (18.2 Hz) }
  outportb($43, $36);
  outportb($40, 0);
  outportb($40, 0);
end;

initialization
  { Channel 0 to mode 2 (rate generator), same 18.2 Hz divisor, so the
    counter falls linearly from 65536 to 0 once per BIOS tick }
  outportb($43, $34);
  outportb($40, 0);
  outportb($40, 0);
  AddExitProc(@restore_pit);
  last_ms := 0;
  start_ms := 0;
  start_ms := raw_ms;
end.
