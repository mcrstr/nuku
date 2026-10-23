unit nuku_keyboard;
{ DOS build: own IRQ1 (INT 9) handler, as DOS action games did.
  The handler only queues raw scancodes; poll_keyboard turns them into
  the key[] state table, indexed by the same codes the game logic uses. }
interface
uses sdl;

const SDLK_LAST = 512;

var key:array [0..SDLK_LAST] of boolean;
const scup = SDLK_UP;
      scdown = SDLK_DOWN;
      scleft = SDLK_LEFT;
      scright = SDLK_RIGHT;
      scenter = SDLK_RETURN;
      scesc = SDLK_ESCAPE;
      scspace = SDLK_SPACE;

procedure poll_keyboard;

implementation
uses go32,nuku_music;

var
  kbbuf: array[0..255] of byte;
  kbhead: byte;
  kbtail: byte;
  ds_alias: word; external name '___v2prt0_ds_alias';
  old_kbd, new_kbd: tseginfo;
  installed: boolean;
  extended: boolean;
  scan_map, ext_map: array[0..127] of word;

{$ASMMODE intel}
procedure kbd_handler; assembler; nostackframe;
asm
  push ds
  push eax
  push ebx
  mov ax, cs:[ds_alias]
  mov ds, ax
  in al, $60
  movzx ebx, byte ptr [kbhead]
  mov byte ptr [kbbuf+ebx], al
  inc bl
  mov byte ptr [kbhead], bl
  { acknowledge the keyboard controller (XT-style strobe) }
  in al, $61
  mov ah, al
  or al, $80
  out $61, al
  mov al, ah
  out $61, al
  { end of interrupt for the master PIC }
  mov al, $20
  out $20, al
  pop ebx
  pop eax
  pop ds
  iretd
end;
procedure kbd_handler_end; begin end;

procedure remove_keyboard;
begin
  if installed then
  begin
    set_pm_interrupt(9, old_kbd);
    installed := false;
  end;
end;

procedure install_keyboard;
begin
  kbhead := 0;
  kbtail := 0;
  extended := false;
  lock_data(kbbuf, sizeof(kbbuf));
  lock_data(kbhead, sizeof(kbhead));
  lock_data(ds_alias, sizeof(ds_alias));
  lock_code(@kbd_handler, ptruint(@kbd_handler_end) - ptruint(@kbd_handler));
  get_pm_interrupt(9, old_kbd);
  new_kbd.offset := @kbd_handler;
  new_kbd.segment := get_cs;
  set_pm_interrupt(9, new_kbd);
  installed := true;
  AddExitProc(@remove_keyboard);
end;

procedure set_map(sc: byte; k: word); begin scan_map[sc] := k; end;
procedure set_ext(sc: byte; k: word); begin ext_map[sc] := k; end;

procedure build_maps;
const
  row1: string = '1234567890-=';
  row2: string = 'qwertyuiop[]';
  row3: string = 'asdfghjkl;''`';
  row4: string = 'zxcvbnm,./';
var i: integer;
begin
  fillchar(scan_map, sizeof(scan_map), 0);
  fillchar(ext_map, sizeof(ext_map), 0);
  set_map($01, SDLK_ESCAPE);
  for i := 1 to length(row1) do set_map($01 + i, ord(row1[i]));
  set_map($0E, SDLK_BACKSPACE);
  set_map($0F, SDLK_TAB);
  for i := 1 to length(row2) do set_map($0F + i, ord(row2[i]));
  set_map($1C, SDLK_RETURN);
  set_map($1D, SDLK_LCTRL);
  for i := 1 to length(row3) do set_map($1D + i, ord(row3[i]));
  set_map($2A, SDLK_LSHIFT);
  set_map($2B, ord('\'));
  for i := 1 to length(row4) do set_map($2B + i, ord(row4[i]));
  set_map($36, SDLK_RSHIFT);
  set_map($38, SDLK_LALT);
  set_map($39, SDLK_SPACE);
  for i := 0 to 9 do set_map($3B + i, SDLK_F1 + i);
  set_map($57, SDLK_F11);
  set_map($58, SDLK_F12);
  { numeric keypad with NumLock off also steers }
  set_map($48, SDLK_UP);
  set_map($50, SDLK_DOWN);
  set_map($4B, SDLK_LEFT);
  set_map($4D, SDLK_RIGHT);

  set_ext($1C, SDLK_RETURN);
  set_ext($1D, SDLK_RCTRL);
  set_ext($38, SDLK_RALT);
  set_ext($48, SDLK_UP);
  set_ext($50, SDLK_DOWN);
  set_ext($4B, SDLK_LEFT);
  set_ext($4D, SDLK_RIGHT);
end;

procedure poll_keyboard;
var sc: byte;
    k: word;
begin
  while kbtail <> kbhead do
  begin
    sc := kbbuf[kbtail];
    inc(kbtail);
    if sc = $E0 then
    begin
      extended := true;
      continue;
    end;
    if sc = $E1 then continue;  { Pause key prefix }
    if extended then k := ext_map[sc and $7F]
                else k := scan_map[sc and $7F];
    extended := false;
    if (k <> 0) and (k <= SDLK_LAST) then
      key[k] := (sc and $80) = 0;
  end;
  music_poll();
end;

var i:integer;

initialization
  for i := 0 to SDLK_LAST do key[i] := false;
  build_maps;
  install_keyboard;
end.
