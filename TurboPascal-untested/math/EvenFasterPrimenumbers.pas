(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0126.PAS
  Description: Even faster Primenumbers!!!
  Author: TOBIAS OLSSON
  Date: 05-30-97  18:17
*)


(*I was looking for a faster sqr routine (still am), when I stumbled over
all of your prime
  number programs. Although I don't know all about Turbo Pascal I do know
how to
  make a faster Prime tester for Numbers < 31-bit, If you like it, copy it,
use routines
  or whatever, but please think about leaving me credits

  This program builds on the (theory) that a prime is always equal to
(X*6+1) or
  (X*6-1) this I read of in a magazine. And it seems to work... I have with
this been
  able to take lead (I think) with 50% faster routine than the others

  by Tobias Olsson
*)


Unit Primtal;

Interface
Function Prime(Prim: LongInt): Boolean;

implementation


Function Prime(Prim: LongInt): Boolean;
Var
Z         : Real;
Max       : LongInt;
Divisor   : LongInt;

Begin
  Prime:= False;
  IF (Prim and 1) = 0 then Exit;
  Z := Sqrt(Prim);
  Max := Trunc(Z)+1;
  Divisor := 3;
  While Max > Divisor do
  Begin
    IF (Prim mod Divisor) = 0 then Exit;
    Inc(Divisor,2);
    IF (Prim mod Divisor) = 0 then Exit;
    Inc(Divisor,4);
  End;
  Prime := True;
End;



BEGIN
END.


