unit nuku_music;
{ DOS build: libmikmod compiled with DJGPP and linked in statically.
  It detects the card from the BLASTER / ULTRASND environment variables
  (Sound Blaster, Gravis Ultrasound, Windows Sound System) and falls back
  to silence when none is found. }
interface

procedure music_poll();
procedure music_play_song(fname:PChar);
procedure music_play_sndfx(p_which:integer);

implementation
uses math,dos,mikmod_dos;

var
  module:PMODULE;
  idx:word;
  samples:array[1..7] of PSAMPLE;
  sound_ok:boolean;

const
  samplenames:array[1..7] of PChar = ('s1.wav','s2.wav','s3.wav','s4.wav','s5.wav','s6.wav','s7.wav');

procedure music_poll();
begin
  if sound_ok then MikMod_Update();
end;

procedure music_play_song(fname:PChar);
begin
  if not sound_ok then exit;
  if module<>nil then
  begin
    Player_Stop();
    Player_Free(module);
  end;
  module := Player_Load(fname, 64, 0);
  if module<>nil then Player_Start(module);
end;

procedure music_play_sndfx(p_which:integer);
begin
  if not sound_ok then exit;
  if (p_which in [1..7]) and (samples[p_which]<>nil) then
    Sample_Play(samples[p_which], 0, 0);
end;

function device_name(d:word):string;
begin
  case d of
    1: device_name:='Gravis Ultrasound';
    2: device_name:='Windows Sound System';
    3: device_name:='Sound Blaster';
  else device_name:='none (silent)';
  end;
end;

var report:string;

procedure shutdown_sound;
begin
  { printed after the game is back in text mode, so it stays on screen }
  writeln(StdErr, report);
  if sound_ok then
  begin
    if module<>nil then
    begin
      Player_Stop();
      Player_Free(module);
      module:=nil;
    end;
    MikMod_Exit();
    sound_ok:=false;
  end;
end;

initialization
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  module:=nil;
  for idx:=1 to 7 do samples[idx]:=nil;

  MikMod_RegisterAllDrivers();
  MikMod_RegisterAllLoaders();
  md_mode := md_mode or DMODE_SOFT_MUSIC or DMODE_SOFT_SNDFX or DMODE_16BITS or DMODE_STEREO;
  md_mixfreq := 22050;

  sound_ok := MikMod_Init('') = 0;
  if not sound_ok then
    report:='NUKU sound: init failed: '+strpas(MikMod_strerror(MikMod_errno))
  else
    report:='NUKU sound: '+device_name(md_device);
  report:=report+'   BLASTER='+GetEnv('BLASTER');
  if GetEnv('ULTRASND')<>'' then report:=report+'  ULTRASND='+GetEnv('ULTRASND');
  writeln(report);
  Flush(Output);
  if not sound_ok then AddExitProc(@shutdown_sound)
  else
  begin
    for idx:=1 to 7 do
      samples[idx]:=Sample_Load(samplenames[idx]);
    MikMod_SetNumVoices(-1, 2);
    MikMod_EnableOutput();
    AddExitProc(@shutdown_sound);
  end;
end.
