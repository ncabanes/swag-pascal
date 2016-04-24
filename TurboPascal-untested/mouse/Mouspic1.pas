(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0001.PAS
  Description: MOUSPIC1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
>    I'm interested in how to change the default mouse cursor to
> another user defined shape.  if you know how to do that, can you
> please post the source For it?  Thanks in advance.
}


Uses
  Dos, Graph;

Var
   Regs : Registers;

Type
   CursorType = Array[0..31] of Word;   { to store the cursor shape }


{ define a cursor shape }
Const HourGlass : CursorType =

  { this specific Constant, when used in the Procedure to change the cursor
    shape will change it to an hourglass shaped cursor.  of course you can
    define your own cursor shape to suit your needs.
    the comments beside the hex numbers are what it will look like (binary),
    they help TREMendOUSLY in designing a cursor shape. }


  { Screen mask : the 0's will show up as the background colour, the 1's
    will show whatever is on the screen at that location }

   ($0001,  { 0000000000000001 }
    $0001,  { 0000000000000001 }
    $8003,  { 1000000000000011 }
    $C7C7,  { 1100011111000111 }
    $E38F,  { 1110001110001111 }
    $F11F,  { 1111000100011111 }
    $F83F,  { 1111100000111111 }
    $FC7F,  { 1111110001111111 }
    $F83F,  { 1111100000111111 }
    $F11F,  { 1111000100011111 }
    $E38F,  { 1110001110001111 }
    $C7C7,  { 1100011111000111 }
    $8003,  { 1000000000000011 }
    $0001,  { 0000000000000001 }
    $0001,  { 0000000000000001 }
    $0000,  { 0000000000000000 }

  { Cursor mask : the 1's will show up as white (or whatever color you have
    reassigned it to if you have done a SetPalette or SetRGBPalette) }

    $0000,  { 0000000000000000 }
    $7FFC,  { 0111111111111100 }
    $2008,  { 0010000000001000 }
    $1010,  { 0001000000010000 }
    $0820,  { 0000100000100000 }
    $0440,  { 0000010001000000 }
    $0280,  { 0000001010000000 }
    $0100,  { 0000000100000000 }
    $0280,  { 0000001010000000 }
    $0440,  { 0000010001000000 }
    $0820,  { 0000100000100000 }
    $1010,  { 0001000000010000 }
    $2008,  { 0010000000001000 }
    $7FFC,  { 0111111111111100 }
    $0000,  { 0000000000000000 }
    $0000); { 0000000000000000 }

Procedure SetMouseCursor(HotX, HotY: Integer; Var Pattern : CursorType);
begin
  Regs.AX := 9;    { Function 9 }
  Regs.BX := HotX; { X-ordinate of hot spot }
  Regs.CX := HotY; { Y-ordinate of hot spot }
  { the hot spots are the co-ordinates that will show up as being where
    the mouse is when reading the co-ordinates of the mouse }
  Regs.DX := ofs(Pattern);
  Regs.ES := Seg(Pattern);
  Intr($33, Regs);
end;

begin
   { [...initialize the Graphics screen etc...] }

   SetMouseCursor(7, 7, HourGlass);
   { this will set the mouse cursor to an hourglass shape With the hot spot
     right in the centre at position 7,7 from the top left of the shape }

   { [...continue Program...] }
end.

