(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0075.PAS
  Description: Re: Random Number Generator
  Author: DANIEL MAILLY
  Date: 05-31-96  09:17
*)

(************************************* function  Generate   *************)
function Generate (var Seed: longint): real;

{  Algorithm 2 from CACM, pg. 1195, vol. 31, no. 10, (October, 1988).    }
{  modified for longint values as recommended in Cooper, D. 1993         }
{  Oh! Pascal!, 3rd edition, pp. A16-A17                                 }

const
   MODULUS    = 2147483647;
   MULTIPLIER = 16807;
   QUOTIENT   = 127773;    {MODULUS div MULTIPLIER}
   REMAINDER  = 2836;      {MODULUS mod MULTIPLIER}

var
   Low, Hi, Test: longint;

begin
{First, perform the calculation while avoiding overflow.}
   Hi   := Seed div QUOTIENT;
   Low  := Seed mod QUOTIENT;
   Test := (MULTIPLIER * Low) - (REMAINDER * Hi);

{Second, update the seed for next time.}
   if Test > 0 then
      Seed := Test
   else
      Seed := Test + MODULUS;

{Third, return a value in the range 0.0 < Generate  < 1.0}
   Generate := Seed / MODULUS;
end;
(************************************* function  Generate end ***********)


