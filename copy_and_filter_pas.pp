unit copy_and_filter_pas;
interface
type
        erg=longint;
        pword=^word;
        pbyte=^byte;
	
procedure copy_to_screen_and_blur(dest:pword; src:pbyte; pal:pword; p_w,p_h:longint); cdecl; external;
procedure copy_to_screen(dest:pword; src:pbyte; pal:pword; p_w,p_h:longint); cdecl; external;

implementation

{$LINKLIB copy_and_filter}


end.

