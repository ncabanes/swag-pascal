(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0026.PAS
  Description: Stop Screen Output
  Author: ANDREW EIGUS
  Date: 11-26-94  05:05
*)

{
 JP> I've got a problem. I'm writing a program that uses a lot of
 JP> compression programs with just a simple shell command. It
 JP> works fine with all of them except from LHA. I execute the
 JP> the line 'LHA E FILENAME.LZH BAH.TXT >NUL', and the '>NUL'
 JP> is enough for all the others, thou not LHA. It still writes
 JP> a lot of crap to the screen. How do I prevent this ?

With the following technique:
}

Program PreventFromScreenOutput;
{ Written by Andrew Eigus of 2:5100/33 or andrew@cs.rau.lv }
{ Public domain, source that runs any program and prevents it from output
  to a screen }

{$M $4000,0,0} { 16k stack, no heap }

uses Dos;

Procedure NewInt10Vector; interrupt; assembler;
{ This is a simple IRET instruction to all of Int 10h functions }
Asm
End; { NewInt10Vector }

Procedure Execute(Command : string);
var OldInt10Vector : pointer;
Begin
  if Command <> '' then
    Command := '/C ' + Command + ' >nul' else Exit;
  GetIntVec($10, OldInt10Vector);
  SetIntVec($10, @NewInt10Vector);
  SwapVectors;
  Exec(GetEnv('COMSPEC'), Command);
  SwapVectors;
  if DosError <> 0 then
    WriteLn('Bad command or file name');
  SetIntVec($10, OldInt10Vector)
End; { Execute }

var Command : ComStr;

Begin
  if ParamCount > 0 then
    Command := ParamStr(1)
  else
  begin
    Write('Enter command or file name: ');
    ReadLn(Command);
  end;
  Execute(Command)
End.


BTW, it even runs gfx programs and runs with no screen output! And tested with
LHA. It temporary eliminates the video bios support (Int 10h) thus preventing
hardware writes to the screen. It is quite a rude approach but it works!


