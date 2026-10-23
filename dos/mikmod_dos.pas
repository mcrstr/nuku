unit mikmod_dos;
{ Minimal static binding to libmikmod built with DJGPP (dos/Makefile.dj).
  Only the calls Nuku uses. }
interface

const
  DMODE_16BITS     = $0001;
  DMODE_STEREO     = $0002;
  DMODE_SOFT_SNDFX = $0004;
  DMODE_SOFT_MUSIC = $0008;
  DMODE_HQMIXER    = $0010;
  DMODE_INTERP     = $0200;

type
  PMODULE = pointer;
  PSAMPLE = pointer;

procedure MikMod_RegisterAllDrivers; cdecl; external;
procedure MikMod_RegisterAllLoaders; cdecl; external;
function  MikMod_Init(params:PChar):longint; cdecl; external;
procedure MikMod_Exit; cdecl; external;
function  MikMod_SetNumVoices(music,sfx:longint):longint; cdecl; external;
function  MikMod_EnableOutput:longint; cdecl; external;
procedure MikMod_Update; cdecl; external;
function  MikMod_strerror(code:longint):PChar; cdecl; external;

function  Player_Load(fname:PChar; maxchan:longint; curious:longint):PMODULE; cdecl; external;
procedure Player_Start(m:PMODULE); cdecl; external;
procedure Player_Stop; cdecl; external;
procedure Player_Free(m:PMODULE); cdecl; external;

function  Sample_Load(fname:PChar):PSAMPLE; cdecl; external;
function  Sample_Play(s:PSAMPLE; start:longword; flags:byte):shortint; cdecl; external;

var
  md_mode:word; cvar; external;
  md_mixfreq:word; cvar; external;
  md_device:word; cvar; external;
  md_volume:byte; cvar; external;
  md_musicvolume:byte; cvar; external;
  md_sndfxvolume:byte; cvar; external;
  MikMod_errno:longint; cvar; external;

implementation

{$LINKLIB mikmod}
{$LINKLIB m}
{$LINKLIB gcc}
{$LINKLIB c}

end.
