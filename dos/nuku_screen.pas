unit nuku_screen;
{ DOS build: VGA mode 13h (320x200, 256 colours). The palette goes
  straight to the DAC through ports $3C8/$3C9, frames are copied to
  video memory at A000:0000 after waiting for the vertical retrace. }
interface
uses nukusupl;

const
      SCREEN_WIDTH  = 320;
      SCREEN_HEIGHT = 200;

var color_palette:array[0 .. 255] of word;

procedure toggle_eagle();
function init_screen : boolean;
function fill_screen_with_buffer(var src:Vpage) : boolean;
procedure set_color_palette(color,r,g,b:byte);

implementation
uses go32,nuku_music;

var
  vsync: boolean;
  in_graphics: boolean;

procedure toggle_eagle();
begin
  { the smoothing filter belongs to the 2019 port; on DOS this key
    toggles waiting for the vertical retrace instead }
  vsync := not vsync;
end;

procedure set_color_palette(color,r,g,b:byte);
begin
  color_palette[color]:=(b shr 1) or ((g shr 1) shl 5) or ((r shr 1) shl 10);
  outportb($3C8, color);
  outportb($3C9, r and 63);
  outportb($3C9, g and 63);
  outportb($3C9, b and 63);
end;

procedure wait_retrace;
begin
  while (inportb($3DA) and 8) <> 0 do ;
  while (inportb($3DA) and 8) = 0 do ;
end;

function fill_screen_with_buffer(var src:Vpage) : boolean;
begin
  if vsync then wait_retrace;
  dosmemput($A000, 0, src[0], 64000);
  music_poll();
  fill_screen_with_buffer:=true;
end;

procedure text_mode;
var r: trealregs;
begin
  if in_graphics then
  begin
    r.ax := $0003;
    realintr($10, r);
    in_graphics := false;
  end;
end;

function init_screen : boolean;
var r: trealregs;
begin
  r.ax := $0013;
  realintr($10, r);
  in_graphics := true;
  AddExitProc(@text_mode);
  vsync := true;
  init_screen := false;
end;

end.
