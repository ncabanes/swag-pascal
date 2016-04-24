(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0018.PAS
  Description: REVERSE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
 a problem.  I am asked to find the reverse of a positive Integer.  For
 example the reverse of 123 is 321 or the reverse of 1331 is 1331.
 My teacher said that we should use div and MOD.
}

Var
  X, Y: Integer;

begin
  X := PositiveInteger;
  Y := 0;

  While X > 0 do
  begin
    Y := (Y * 10) + (X mod 10);
    X := X div 10;
  end;

{
The result will be in Y.  Just so you do learn something of use out of this: It
is a fact that the difference between two transposed (reversed) numbers will be
evenly divisible by 9. This can be of help if you are doing something
accounting related and are trying to figure out why your numbers don't jive. if
the amount you are out is evenly divisible by 9, it is most likely a
transposing error.
}

