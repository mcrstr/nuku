unit nuku_screen;
interface
uses sdl,nukusupl;

const

      SCREEN_WIDTH  = 640;
      SCREEN_HEIGHT = 400;


var screen:PSDL_Surface;
    color_palette:array[0 .. 255] of word;
    color_palette_sdl:array[0 .. 255] of TSDL_Color;

procedure toggle_eagle();
procedure cycle_scale();
procedure toggle_fullscreen();

function init_screen : boolean;

function fill_screen_with_buffer(var src:Vpage) : boolean;

procedure set_color_palette(color,r,g,b:byte);

implementation
uses sysutils,nuku_music;

var
	use_eagle:boolean;
        fullscreen:boolean;
        scale:longint;
        desktop_w,desktop_h:longint;
        frame:array[0..SCREEN_WIDTH*SCREEN_HEIGHT-1] of byte;
        last_src:PByte;

procedure toggle_eagle();
begin
        use_eagle := not use_eagle;
end;

procedure set_color_palette(color,r,g,b:byte);
       var aux:word;
begin
        aux:=(b shr 1);
        aux:= aux or ((g shr 1) shl 5);
        aux:= aux or ((r shr 1) shl 10);
        color_palette[color]:=aux;
        color_palette_sdl[color].r:=(r and 63) shl 2;
        color_palette_sdl[color].g:=(g and 63) shl 2;
        color_palette_sdl[color].b:=(b and 63) shl 2;
end;

{ Plain 2x pixel doubling, 320x200 -> 640x400 }
procedure copy_to_screen(dst:PByte; src:PByte);
var y,x:longint;
    row0,row1:PByte;
    c:byte;
begin
        for y:=0 to 199 do
        begin
                row0:=dst+(y*2)*SCREEN_WIDTH;
                row1:=row0+SCREEN_WIDTH;
                for x:=0 to 319 do
                begin
                        c:=src[y*320+x];
                        row0[x*2]:=c; row0[x*2+1]:=c;
                        row1[x*2]:=c; row1[x*2+1]:=c;
                end;
        end;
end;

{ Eagle-style smoothing filter, port of the original copy_and_filter.c }
procedure copy_to_screen_and_blur(dst:PByte; src:PByte);
var i,j:longint;
    f00,f01,f02,f10,f11,f12,f20,f21,f22:byte;
    n00,n01,n02,n10,n12,n20,n21,n22:word;
    r0,r1:PByte;

    function fix(v:byte):word; inline;
    begin
            fix:=color_palette[v] and $739C;
    end;

begin
        copy_to_screen(dst,src); { fills the borders }
        for i:=1 to 198 do
        begin
                r0:=dst+(i*2)*SCREEN_WIDTH;
                r1:=r0+SCREEN_WIDTH;
                for j:=1 to 318 do
                begin
                        f00:=src[320*(i-1)+j-1];
                        f01:=src[320*(i)+j-1];
                        f02:=src[320*(i+1)+j-1];
                        f10:=src[320*(i-1)+j];
                        f11:=src[320*(i)+j];
                        f12:=src[320*(i+1)+j];
                        f20:=src[320*(i-1)+j+1];
                        f21:=src[320*(i)+j+1];
                        f22:=src[320*(i+1)+j+1];

                        n00:=fix(f00); n01:=fix(f01); n02:=fix(f02);
                        n10:=fix(f10); n12:=fix(f12);
                        n20:=fix(f20); n21:=fix(f21); n22:=fix(f22);

                        if (n10=n12) and (n10=n01) and (n10=n21) then
                        begin
                                r0[j*2]:=f11; r0[j*2+1]:=f11;
                                r1[j*2]:=f11; r1[j*2+1]:=f11;
                        end else
                        begin
                                if (n00=n01) and (n00=n10) then r0[j*2]:=f10 else r0[j*2]:=f11;
                                if (n20=n21) and (n20=n10) then r0[j*2+1]:=f20 else r0[j*2+1]:=f11;
                                if (n02=n01) and (n02=n12) then r1[j*2]:=f02 else r1[j*2]:=f11;
                                if (n22=n21) and (n22=n12) then r1[j*2+1]:=f12 else r1[j*2+1]:=f11;
                        end;
                end;
        end;
end;

{ Copies the 640x400 frame to the window, enlarged by an integer factor
  and centred (black borders in fullscreen) }
procedure present;
var s,ox,oy,y,x,k:longint;
    srow,drow:PByte;
    c:byte;
begin
        if fullscreen then
        begin
                s:=screen^.w div SCREEN_WIDTH;
                if screen^.h div SCREEN_HEIGHT < s then s:=screen^.h div SCREEN_HEIGHT;
                if s<1 then s:=1;
        end else s:=scale;
        ox:=(screen^.w-SCREEN_WIDTH*s) div 2;
        oy:=(screen^.h-SCREEN_HEIGHT*s) div 2;
        if ox<0 then ox:=0;
        if oy<0 then oy:=0;

	if SDL_MUSTLOCK(screen) then
		if SDL_LockSurface(screen) < 0 then exit;

        for y:=0 to SCREEN_HEIGHT-1 do
        begin
                if oy+y*s+s>screen^.h then break;
                srow:=@frame[y*SCREEN_WIDTH];
                drow:=PByte(screen^.pixels)+(oy+y*s)*screen^.pitch+ox;
                if s=1 then
                        move(srow^,drow^,SCREEN_WIDTH)
                else
                begin
                        for x:=0 to SCREEN_WIDTH-1 do
                        begin
                                c:=srow[x];
                                fillchar(drow[x*s],s,c);
                        end;
                        for k:=1 to s-1 do
                                move(drow^,(drow+k*screen^.pitch)^,SCREEN_WIDTH*s);
                end;
        end;

	if SDL_MUSTLOCK(screen) then SDL_UnlockSurface(screen);

	SDL_SetColors(screen,@color_palette_sdl[0],0,256);
	SDL_UpdateRect(screen,0,0,0,0);
end;

procedure clear_screen;
begin
	if SDL_MUSTLOCK(screen) then
		if SDL_LockSurface(screen) < 0 then exit;
        fillchar(screen^.pixels^,screen^.pitch*screen^.h,0);
	if SDL_MUSTLOCK(screen) then SDL_UnlockSurface(screen);
end;

function set_mode:boolean;
var s:PSDL_Surface;
begin
        s:=nil;
        if fullscreen and (desktop_w>0) and (desktop_h>0) then
                s:=SDL_SetVideoMode(desktop_w,desktop_h,8,SDL_SWSURFACE or SDL_HWPALETTE or SDL_FULLSCREEN);
        if s=nil then
        begin
                fullscreen:=false;
                s:=SDL_SetVideoMode(SCREEN_WIDTH*scale,SCREEN_HEIGHT*scale,8,SDL_SWSURFACE or SDL_HWPALETTE);
        end;
        if s=nil then
        begin
                scale:=1;
                s:=SDL_SetVideoMode(SCREEN_WIDTH,SCREEN_HEIGHT,8,SDL_SWSURFACE or SDL_HWPALETTE);
        end;
        if s<>nil then screen:=s;
        set_mode:=s<>nil;
        if s<>nil then
        begin
                SDL_ShowCursor(ord(not fullscreen));
                clear_screen;
                present;
        end;
end;

procedure cycle_scale();
var maxs:longint;
begin
        if fullscreen then exit;
        maxs:=4;
        if desktop_w>0 then
        begin
                maxs:=desktop_w div SCREEN_WIDTH;
                if desktop_h div SCREEN_HEIGHT < maxs then maxs:=desktop_h div SCREEN_HEIGHT;
                if maxs<1 then maxs:=1;
        end;
        inc(scale);
        if scale>maxs then scale:=1;
        set_mode;
end;

procedure toggle_fullscreen();
begin
        fullscreen:=not fullscreen;
        set_mode;
end;

function fill_screen_with_buffer(var src:Vpage) : boolean;
begin
        last_src:=@src[0];
        if use_eagle then
	        copy_to_screen_and_blur(@frame[0],@src[0])
        else
	        copy_to_screen(@frame[0],@src[0]);

        present;

        music_poll();
        fill_screen_with_buffer:=true;
end;


function init_screen : boolean;
var info:PSDL_VideoInfo;
    env:string;
    code:integer;
begin
    SDL_WM_SetCaption('Nuku',nil);

    desktop_w:=0; desktop_h:=0;
    info:=SDL_GetVideoInfo();
    if info<>nil then
    begin
            desktop_w:=info^.current_w;
            desktop_h:=info^.current_h;
            if (desktop_w<320) or (desktop_w>20000) or (desktop_h<200) or (desktop_h>20000) then
            begin
                    desktop_w:=0; desktop_h:=0;
            end;
    end;

    { biggest integer scale that leaves room for the taskbar and window frame }
    scale:=2;
    if desktop_w>0 then
    begin
            scale:=(desktop_w-40) div SCREEN_WIDTH;
            if (desktop_h-120) div SCREEN_HEIGHT < scale then scale:=(desktop_h-120) div SCREEN_HEIGHT;
            if scale<1 then scale:=1;
            if scale>3 then scale:=3;
    end;
    env:=GetEnvironmentVariable('NUKU_SCALE');
    if env<>'' then
    begin
            val(env,scale,code);
            if (code<>0) or (scale<1) or (scale>8) then scale:=2;
    end;
    fullscreen:=GetEnvironmentVariable('NUKU_FULLSCREEN')='1';

    fillchar(color_palette_sdl,sizeof(color_palette_sdl),0);
    fillchar(frame,sizeof(frame),0);
    use_eagle:=true;

    if not set_mode then
    begin
	writeln('Cannot set video mode');
	init_screen:=true;
    end else
        init_screen:=false;
end;

end.
