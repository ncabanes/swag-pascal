(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0015.PAS
  Description: PI1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{$N+}

Program CalcPI(input, output);

{ Not the most efficient Program I've ever written.  Mostly it's quick and
  dirty.  The infinite series is very effective converging very quickly.
  It's much better than Pi/4 = 1 - 1/3 + 1/5 - 1/7 ... which converges
  like molasses. }

{  Pi / 4 = 4 * (1/5 - 1/(3*5^3) + 1/(5*5^5) - 1/(7*5^7) + ...) -
                (1/239 - 1/(3*239^3) + 1/(5*239^5) - 1/(7*239^7) + ...) }

{* Infinite series courtesy of Machin (1680 - 1752).  I found it in my
   copy of Mathematics and the Imagination by Edward Kasner and
   James R. Newman (Simon and Schuster, New York 1940, p. 77)          * }

Uses
  Crt;


Var
  Pi_Fourths,
  Pi          : Double;
  Temp        : Double;
  ct          : Integer;
  num         : Integer;


Function Power(Number, Exponent : Integer) : double;
Var
  ct   : Integer;
  temp : double;

begin
  temp := 1.00;
  For ct := 1 to Exponent DO
    temp := temp * number;
  Power := temp
end;

begin
  ClrScr;
  ct  := 1;
  num := 1;
  Pi_Fourths := 0;

  While ct <  15 DO
  begin
    Temp := (1.0 / (Power(5, num) * num)) * 4;

    if ct MOD 2 = 1 then
      Pi_Fourths := Pi_Fourths + Temp
    ELSE
      Pi_Fourths := Pi_Fourths - Temp;

    Temp := 1.0 / (Power(239, num) * num);

    if ct MOD 2 = 1 then
      Pi_Fourths := Pi_Fourths - Temp
    ELSE
      Pi_Fourths := Pi_Fourths + Temp;

    ct := ct + 1;
    num := num + 2;
  end;

  Pi := Pi_Fourths * 4.0;
  Writeln( 'PI = ', Pi);
end.

