(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0008.PAS
  Description: MATHSPD.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
> I was just wondering how to speed up some math-intensive
> routines I've got here. For example, I've got a Function
> that returns the distance between two Objects:

> Function Dist(X1,Y1,X2,Y2 : Integer) : Real;
> begin
>   Dist := Round(Sqrt(Sqr(X1-X2)+Sqr(Y1-Y2)));
> end;

> This is way to slow. I know assembly can speed it up, but
> I know nothing about as. so theres the problem. Please
> help me out, any and all source/suggestions welcome!

X1, Y1, X2, Y2 are all Integers.  Integer math is faster than Real (just
about anything is).  Sqr and Sqrt are not Integer Functions.  Try for
fun...
}

Function Dist( X1, Y1, X2, Y2 : Integer) : Real;
Var
  XTemp,
  YTemp : Integer;
{ the allocation of these takes time.  if you don't want that time taken,
  make them global With care}
begin
  XTemp := X1 - X2;
  YTemp := Y1 - Y2;
  Dist  := Sqrt(XTemp * XTemp + YTemp * YTemp);
end;

{
if you have a math coprocessor or a 486dx, try using DOUBLE instead of
Real, and make sure your compiler is set to compile For 287 (or 387).
}

begin
  Writeln('Distance Between (3,9) and (-2,-3) is: ', Dist(3,9,-2,-3) : 6 : 2);
end.
