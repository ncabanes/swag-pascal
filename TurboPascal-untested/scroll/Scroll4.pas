(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0004.PAS
  Description: SCROLL4.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{> I need to be able to scroll the Text display in my File viewer,
> both left and right, to allowing reading of lines that extend past
> column 80.

UnFortunately there's no way to scroll horizontally by BIOS or by another
service Function. You have to implement it on your own. Here are two Procedures
that I use in my Programs (in Case they must scroll left or right ;-)):
}

{$ifNDEF VER70}
Const
  Seg0040   = $0040;
  SegB000   = $B000;
  SegB800   = $B800;
{$endif}

Type
  PageType  = Array [1..50,1..80] of Word;

Var
  Screen    : ^PageType;
  VideoMode : ^Byte;

Procedure ScrollRight(X1,Y1,X2,Y2,Attr : Byte);
Var
  Y      : Byte;
  Attrib : Word;
begin
  Attrib := Word(Attr SHL 8);
  Y      := Y1-1;
  Repeat
    Inc(Y);
    Move(Screen^[Y,X1],Screen^[Y,X1+1],(X2-X1)*2);
    Screen^[Y,X1] := Attrib+32;
  Until Y=Y2;
end;

Procedure ScrollLeft(X1,Y1,X2,Y2,Attr : Byte);
Var
  Y      : Byte;
  Attrib : Word;
begin
  Attrib := Word(Attr SHL 8);
  Y      := Y1-1;
  Repeat
    Inc(Y);
    Move(Screen^[Y,X1+1],Screen^[Y,X1],(X2-X1)*2);
    Screen^[Y,X2] := Attrib+32;
  Until Y=Y2;
end;

begin
  VideoMode := Ptr(Seg0040,$0049);
  if VideoMode^=7 then
    Screen := Ptr(SegB000,$0000)
  else
    Screen := Ptr(SegB800,$0000);
end.

{
X1, Y1, X2 and Y2 are the coordinates of the Windows to be scrolled. Attr is
the color of the vertical line that occurs after scrolling. ;-)
}

