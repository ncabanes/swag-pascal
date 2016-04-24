(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0043.PAS
  Description: Pascal Triangle
  Author: LOU DUCHEZ
  Date: 11-02-93  10:30
*)

{
LOU DUCHEZ

>Also, does anyone have anycode to do Pascal's Triangle?

The pattern is:

    1 1
   1 2 1
  1 3 3 1
 1 4 6 4 1

where each element = the sum of the two above it.

Arrange it like this:

0110     --  The zeros are needed so that the algorithm can process the 1's.
01210
013310
0146410

I'd have two Arrays: one shows the last row's figures, and the other holds
the current row's figures.  Each "new" element (call the index "i") = the
sum of "previous" element "i" + "previous" element "i - 1".
}

Procedure CalcPascalRow(r : Word);      { which row to calculate }

Var
  prows   : Array[0..1, 0..100] of Word;{ your two Arrays }
  thisrow,
  lastrow : Byte;                       { point to this row & last row }
  i, j    : Word;                       { counters }

begin
  lastrow := 0;                         { set up "which row is which" }
  thisrow := 1;
  prows[lastrow, 0] := 0;               { set up row "1": 0110 }
  prows[lastrow, 1] := 1;
  prows[lastrow, 2] := 1;
  prows[lastrow, 3] := 0;
  For j := 2 to r do
  begin  { generate each "line" starting w/2 }
    prows[thisrow, 0] := 0;
    For i := 1 to j + 1 do
    begin  { each "new" element = sum of "old" }
      prows[thisrow, i] :=   { element + predecessor to "old" }
        prows[lastrow, i] +  { element }
        prows[lastrow, i - 1];
    end;
    prows[thisrow, j + 2] := 0;
    lastrow := thisrow;                 { prepare For next iteration }
    thisrow := (thisrow + 1) mod 2;
  end;
  For i := 1 to r + 1 do
  { Write each element of desired line }
    Write(prows[lastrow, i] : 4);
  Writeln;
end;

