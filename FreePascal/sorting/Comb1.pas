(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0006.PAS
  Description: COMB1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
>Has anyone successfully converted the Combsort algorithm (I think it was
>published in DDJ or Byte about two years ago) from C to Pascal?  I've
>lost the original C source For this, but if anyone has any info, I would
>appreciate it.
}

Program TestCombSort; { Byte magazine, April '91 page 315ff }
Const
  Size = 25;
Type
  SortType = Integer;
Var
  A: Array [1..size] of SortType;
  i: Word;

Procedure CombSort (Var Ain);
Var
  A: Array [1..Size] of SortType Absolute Ain;
  Switch: Boolean;
  i, j, Gap: Word;
  Hold: SortType;
begin
  Gap := Size;
  Repeat
    Gap := Trunc (Gap / 1.3);
    if Gap < 1 then
      Gap := 1;
    Switch := False;
    For i := 1 to Size - Gap do
    begin
      j := i + Gap;
      if A [i] > A [j] then { swap }
      begin
        Hold := A [i];
        A [i] := A [j];
        A [j] := Hold;
        Switch := True;;
      end;
    end;
  Until (Gap = 1) and not Switch;
end;

begin
  Randomize;
  For i := 1 to Size do
    A [i] := Random (32767);
  WriteLn;
  WriteLn ('Unsorted:');
  For i := 1 to Size do
    Write (A [i]:8);
  WriteLn;
  CombSort (A);
  WriteLn ('Sorted:');
  For i := 1 to Size do
    Write (A [i]:8);
  WriteLn;
end.
