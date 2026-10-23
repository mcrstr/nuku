unit nuku_keyboard;
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
uses nuku_music,nuku_screen;


procedure poll_keyboard;
var event:TSDL_Event;
    sym:longword;
begin
	while SDL_PollEvent(@event)<>0 do
	begin
		case event.type_ of
			SDL_KEYDOWN:begin
				sym:=event.key.keysym.sym;
				if (sym=SDLK_RETURN) and ((event.key.keysym.modifier and KMOD_ALT)<>0) then
				begin
					nuku_screen.toggle_fullscreen();
					continue;
				end;
				if sym<=SDLK_LAST then key[sym]:=true;
                                case sym of
                                        SDLK_F8:nuku_screen.toggle_eagle();
                                        SDLK_F9:nuku_screen.cycle_scale();
                                        SDLK_F10:nuku_screen.toggle_fullscreen();
                                end;
			end;
			SDL_KEYUP:begin
				sym:=event.key.keysym.sym;
				if sym<=SDLK_LAST then key[sym]:=false;
			end;
			SDL_QUITEV:begin
				SDL_Quit();
                                halt(0);
			end;
		end;
	end;
        music_poll();
end;

var i:integer;

initialization
	for i:=0 to SDLK_LAST do key[i]:=false;
end.
