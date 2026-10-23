program sndtest;
{ Sound check for the DOS build: plays LL-NUKTR.IT and a sound effect
  for 15 seconds in text mode, without the game's video/keyboard/timer code.
    SNDTEST       16-bit stereo, 22050 Hz (what NUKU.EXE uses)
    SNDTEST 8     8-bit mono, 22050 Hz
    SNDTEST 11    8-bit mono, 11025 Hz }
uses go32,dos,strings,mikmod_dos;

{$L sbinfo.o}
procedure sbinfo_static(buf:PChar); cdecl; external;
procedure sbinfo_buffer(buf:PChar); cdecl; external;
procedure sbinfo_live(buf:PChar); cdecl; external;
var info:array[0..255] of char;

function ticks:longint; begin ticks:=meml[$40:$6C]; end;

function keypressed:boolean;
var r:trealregs;
begin
  r.ax:=$0100; realintr($16,r);
  keypressed:=(r.flags and $40)=0;
end;

var m:PMODULE; s:PSAMPLE; t0,last,upd:longint; arg:string;
begin
  arg:=paramstr(1);
  writeln('BLASTER=',GetEnv('BLASTER'));
  MikMod_RegisterAllDrivers;
  MikMod_RegisterAllLoaders;
  md_mode:=DMODE_SOFT_MUSIC or DMODE_SOFT_SNDFX;
  if arg='' then begin md_mode:=md_mode or DMODE_16BITS or DMODE_STEREO; md_mixfreq:=22050; end
  else if arg='8' then md_mixfreq:=22050
  else md_mixfreq:=11025;
  writeln('mode: ',md_mode,'  rate: ',md_mixfreq);
  if MikMod_Init('')<>0 then begin writeln('MikMod_Init failed: ',MikMod_strerror(MikMod_errno)); halt(1); end;
  writeln('driver #',md_device,' (1=GUS 2=WSS 3=Sound Blaster 4=none)');
  if md_device=3 then begin sbinfo_static(info); writeln(info); end;
  m:=Player_Load('LL-NUKTR.IT',64,0);
  if m=nil then begin writeln('cannot load LL-NUKTR.IT: ',MikMod_strerror(MikMod_errno)); halt(1); end;
  s:=Sample_Load('s1.wav');
  MikMod_SetNumVoices(-1,2);
  MikMod_EnableOutput;
  Player_Start(m);
  if md_device=3 then begin sbinfo_buffer(info); writeln(info); end;
  writeln('Playing for 15 seconds, any key stops.');
  t0:=ticks; last:=-1; upd:=0;
  while (ticks-t0<273) and not keypressed do
  begin
    MikMod_Update; inc(upd);
    if (ticks-t0) div 18<>last then
    begin
      last:=(ticks-t0) div 18;
      if s<>nil then Sample_Play(s,0,0);
      if md_device=3 then sbinfo_live(info) else info[0]:=#0;
      writeln('  ',last,' s  updates=',upd,'  ',info);
    end;
  end;
  Player_Stop; Player_Free(m); MikMod_Exit;
  writeln('done');
end.
