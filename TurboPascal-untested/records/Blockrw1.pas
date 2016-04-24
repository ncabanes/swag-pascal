(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0001.PAS
  Description: BLOCKRW1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{
Does anyone have any examples of how to Write Text to a File using
blockWrite?
}
Program DemoBlockWrite;

Const
  { Carriage-return + Line-feed Constant. }
  co_CrLf = #13#10;

Var
  st_Temp : String;
  fi_Temp : File;
  wo_BytesWritten : Word;

begin
  { Assign 5 lines of Text to temp String. }
  st_Temp := 'Line 1 of Text File' + co_CrLf + 'Line 2 of Text File'
             + co_CrLf + co_CrLf + 'Line 4 of Text File' + co_CrLf +
             ' My name is MUD ' + co_CrLf;

  assign(fi_Temp, 'TEST.TXT');
  {$I-}
  reWrite(fi_Temp, 1);
  {$I+}
  if (ioresult <> 0) then
  begin
    Writeln('Error creating TEST.TXT File');
    Halt
  end;
  { Write 5 lines of Text to File. }
  BlockWrite(fi_Temp, st_Temp[1], length(st_Temp), wo_BytesWritten);
  { Check For errors writing Text to File. }
  if (wo_BytesWritten <> length(st_Temp)) then
  begin
    Writeln('Error writing Text to File!');
    Halt
  end;
  { Close File. }
  Close(fi_Temp);
  { Attempt to open Text File again. }
  Assign(fi_Temp, 'TEST.TXT');
  {$I-}
  Reset(fi_Temp, 1);
  {$I+}
  if (IOResult <> 0) then
  begin
    Writeln('Error opening TEST.TXT File');
    Halt
  end;
  st_Temp := 'Guy';
  { Position File-Pointer just before the 'MUD' in Text. }
  seek(fi_Temp, 77);
  { Correct my name by overwriting old Text With new. }
  blockWrite(fi_Temp, st_Temp[1], length(st_Temp), wo_BytesWritten);
  { Check For errors writing Text to File. }
  if (wo_BytesWritten <> length(st_Temp)) then
  begin
    Writeln('Error writing Text to File!');
    Halt
  end;
  Close(fi_Temp)
end.

