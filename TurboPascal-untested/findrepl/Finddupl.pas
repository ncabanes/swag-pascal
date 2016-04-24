(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0007.PAS
  Description: FINDDUPL.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{
TRAVIS GRIGGS

> I have one question For you in return: could you send the current
> source code of your Program, or could you otherwise describe what
> your input Text File Characterizations are (how big can the File be,
> how long can the lines be, do you scan each line, or only taglines,

Here's the code.  Don't worry about the structure of it.  I know it is bad but
this was a quick and dirty little util I wrote up that I needed.  Have fun With
it and try to speed it up.  And whoever else wants to help have fun!

I hope this compiles I took out some stuff that would display a little picture
of a sWord and show the version and product name.  I also tried DJ's idea of
the buffer of 65535 but it said the structure was too large. So I used 64512.
}
Uses Crt;
Type
  BBT  = Array[0..64512] of Char;

Var
  BUFF        : ^BBT;
  TheFile,
  logFile     : Text;
  Looking,
  TempStr     : String[80];
  Numoflines,
  F, J, Point : LongInt;
  Divi, Multi : Real;

Procedure Stop;
begin
  Close(TheFile);
  Close(LogFile);
  Halt(1);
end;

Procedure CommandError(Err:  Byte);
begin
  TextColor(10);
  Case Err Of
    2 : WriteLn('You must specify a File on the command line.');
    3 : WriteLn('Can''t find "', ParamStr(1),'"');
    4 : WriteLn('Too many open Files to open ', ParamStr(1));
    5 : WriteLn('Error in reading ', ParamStr(1));
  end; { end total Case }
  WriteLn;
  Halt(1);
end; { end Procedure }

begin
  if Paramcount < 1 Then
    CommandError(2);
  ClrScr;
  Assign(TheFile,ParamStr(1));
  New(BUFF);
  SetTextBuf(TheFile,BUFF^);
  Assign(LogFile,'FINDDUPE.LOG');
  ReWrite(LogFile);
  Reset(TheFile);
  Case IoResult Of
    2 : CommandError(3);
    4 : CommandError(4);
    3,5..162 : CommandError(5);
  end;
  While not EOF(TheFile) Do
  begin
    Readln(TheFile);
    Inc(Numoflines);
  end;
  Writeln('There are ',Numoflines,' lines in this File.');
  Writeln;
  Writeln('Duplicate lines are being written to FINDDUPE.LOG');
  Writeln;
  Writeln('Press any key to stop the search For duplicate lines');
  Point := 0;
  Reset(TheFile);
  While Point <> Numoflines Do
  begin
    GotoXY(1, 7);
    if Point <> 0 Then
    begin
      Divi  := Point / Numoflines;
      Multi := Divi * 100;
      WriteLn(Multi : 3 : 2, '% Completed');
    end;
    Reset(TheFile);
    if Point <> 0 Then
      For J := 1 to Point Do
        Readln(TheFile);
    Readln(TheFile,Looking);
    Reset(TheFile);
    Inc(Point);
    For F := 1 to Numoflines Do
    begin
      if KeyPressed then
        Stop;
      Readln(TheFile, TempStr);
      if (Point <> F) and (TempStr = Looking) Then
        Writeln(LogFile,Looking);
    end;
  end;
  GotoXY(1, 7);
  Writeln('100.00% Completed');
  Close(TheFile);
  Close(LogFile);
end.

