(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0003.PAS
  Description: CLRSCR3.PAS
  Author: MICHAEL NICOLAI
  Date: 05-28-93  13:56
*)

{
MICHAEL NICOLAI

You want to clear the entire screen? Then just Write 00 in every Byte!
You have to save the screen first, of course. :-)

This Procedure saves the screen, clears it, waits For a keystroke and
then restores the screen:
}

Uses
  Crt;

Procedure ClearScreen;
Const
  lines = 50;   { number of lines }
  length = 160 * lines - 1;
Var
  i      : Word;
  screen : Array [0..length] of Byte;
begin
 { save the screen }
 For i := 0 to length do
  screen[i] := mem[$B800 : i];
 { blank screen }
 For i := 0 to length do
  mem[$B800 : i] := 0;
 { wait For keystroke }
 While (NOT KeyPressed) do;
 { restore screen }
 For i := 0 to length do
  mem[$B800 : i] := screen[i];
end;

begin
  ClearScreen;
end.

