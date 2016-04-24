(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0010.PAS
  Description: PERMUTA1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
> Does anyone have an idea to perform permutations With pascal 7.0 ?
> As an example finding the number of 5 card hands from a total of 52 cards.
> Any help would be greatly appreciated.

This Program should work fine.  I tested it a few times and it seemed to work.
It lets you call the Functions For permutation and combination just as you
would Write them: P(n,r) and C(n,r).
}

{$E+,N+}
Program CombPerm;

Var
  Result:Extended;
Function Factorial(Num: Integer): Extended;
Var
  Counter: Integer;
  Total: Extended;
begin
  Total:=1;
  For Counter:=2 to Num do
    Total:=Total * Counter;
  Factorial:=Total;
end;

Function P(N: Integer;  R: Integer): Extended;
begin
  P:=Factorial(N)/Factorial(N-R);
end;

Function C(N: Integer;  R: Integer): Extended;
begin
  C:=Factorial(N)/(Factorial(N-R)*Factorial(R));
end;

begin
  Writeln(P(52,5));
end.
