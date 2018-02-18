(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0035.PAS
  Description: Writing to Graphic Pages
  Author: RANDY PARKER
  Date: 11-02-93  05:49
*)

{
RANDY PARKER

    I've been playing With using the Absolute address $A000:0000 to do direct
video Writes in Graphics mode and was wondering if someone could tell me how
to get colors.  I use an Array of [1..NumOfBits].  NumOfBits being the number
of bits the current Graphic page Uses when it stores it's information.

The following is an example of what I mean:
}

Program UseFastGraf;
Uses
  Graph;

Type
  View = Array [1..19200] of Word;

Var
  I,
  GraphDriver,
  GraphMode    : Integer;
  (*View1        : View Absolute $A000:0000;
  View2        : View;*)

begin
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, 'e:\bp\bgi');
  For I := 1 to 1000 Do
  begin
    SetColor(Random(GetMaxColor));
    Line(Random(GetMaxX), Random(GetMaxY), Random(GetMaxX), GetMaxY);
  end;
  (*View2 := View1;
  SetColor(15);
  OutTextXY(100, 100, 'Press Enter To Continue : ');
  Readln;
  ClearDevice;
  OutTextXY(100, 100, 'Press Enter To See The Previous Screen');
  Readln;
  View1 := View2;*)
  Readln;
end.


