(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0008.PAS
  Description: DATE7.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
I have seen a number of Julian Date Functions showing up here lately.
None of them seem to agree With each other.  of course, if your Program
is the only thing using them, then it will remain consistent and work
fine. But if you need to find the JD For astronomical or scientific
purposes, then you will need to be able to agree With the accepted
method.  The following seems to work well For me.  Using Real For the
Var Types allows you to find the JD to great accuracy.
BTW, JD 0.0 is Greenwich Mean Noon, Jan. 1, 4713 BC (which is why if you
enter a "whole" day. ie. 1,2,3... your answer will have a '.5' at the
end.
}

Function JulianDate(Day, Month, Year : Real) : Real;
Var
  A, B, C, D : Real;
begin
  if Month <= 2 then
  begin
    Year  := Year - 1;
    Month := Month + 12;
  end;

  if Year >= 1582 then
  begin
    A := inT(Year / 100);
    B := inT((2 - A) + inT(A / 4));
  end
  else
    B := 0;

  if Year < 0 then
    C := inT((365.25 * Year) - 0.75)
  else
    C := inT(365.25 * Year);

  D := inT (30.6001 * (Month + 1));
  JulianDate :=  B + C + D + Day + 1720994.5;
end;


