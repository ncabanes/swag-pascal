(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0014.PAS
  Description: PERMUTA5.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
>it. While I'm at it, does anyone have any ideas For an algorithm to generate
>and test all possible combinations of a group of letters For Real Words.

I'm sure it wouldn't take long to modify this Program I wrote, which
produces all combinations of "n" numbers.

I got the idea from "Algorithms", by Robert Sedgewick.  Recommended.
}
Program ShowPerms;

Uses
  Crt;

Const
  digits = 4; {How many digits to permute: n digits = n! perms!}

Var
  PermArray : Array [1..digits] of Byte; {Permutation holder}
  ThisDigit : Integer;

Procedure WritePerm;
Var
  loop : Byte;
begin
  For loop := 1 to 4 do
    Write(PermArray[loop]);
  Writeln;
end;

Procedure PermuteAtLevel(Level : Integer);
Var
  loop : Integer;

begin
  inc(ThisDigit);
  PermArray[Level] := ThisDigit;
  if ThisDigit = digits then
    Writeperm; {if we've accounted For all digits}
  For loop := 1 to digits do
    if PermArray[loop] = 0 then
      PermuteAtLevel(loop);
  dec(ThisDigit);
  PermArray[Level] := 0;
end;

begin
  ClrScr;
  ThisDigit := -1; {Left of Left-hand-side}
  FillChar (PermArray, sizeof(PermArray),#0); {Make it zeroes}
  PermuteAtLevel(0); {Start at the bottom}
end.
-
