Program Nuku;

uses {$ifndef go32v2}cmem,{$endif}nuku_log,math,nukumain,sdl,nuku_screen;

begin
	{ C libraries (SDL, X11, mikmod) expect FPU exceptions to be masked }
	SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);

	if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) < 0 then
		writeln('cannot initialize_sdl');

	init_screen();

	nukustart;

	SDL_Quit();
end.
