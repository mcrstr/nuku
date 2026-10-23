unit nuku_log;
{ The game prints a lot of debug lines. Windows GUI builds have no console,
  and on DOS the text would be drawn over the VGA picture, so in both cases
  the output goes to a log file next to the game. }
interface
implementation
{$if defined(windows) or defined(go32v2)}
initialization
  {$ifdef windows}
  if not IsConsole then
  {$endif}
  begin
    {$I-}
    Assign(Output,'nuku.log');
    Rewrite(Output);
    if IOResult<>0 then
    begin
      Assign(Output,'NUL');
      Rewrite(Output);
      if IOResult<>0 then ;
    end;
    {$I+}
  end;
{$endif}
end.
