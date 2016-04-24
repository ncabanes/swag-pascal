(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0029.PAS
  Description: Get/Set Screen Colors
  Author: SEAN PALMER
  Date: 08-27-93  21:53
*)

{
SEAN PALMER

> I want to know how to get and set the screen colors Without using the
> Crt Unit or ansi codes.  Any help is appreciated.

Change the Byte in video memory For the attribute For a Character.
}

Var
  ScreenMem : Array [0..24, 0..79, 0..1] of Char Absolute $B800 : 0;

Procedure changeColor(x, y, attrib : Byte);
begin
  screenMem[y - 1, x - 1, 1] := Char(attrib);
end;

{ For monochrome monitors it's Absolute $B000 : 0; }
begin
  ChangeColor(34, 12, $1C);
end.
