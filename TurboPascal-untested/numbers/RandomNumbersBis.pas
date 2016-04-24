(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0052.PAS
  Description: Random Numbers
  Author: BRIAN RICHARDSON
  Date: 08-24-94  13:54
*)

{
 HG> Did any one have an algorithm to generate random numbers?
 HG> I know Borland Pascal have de function RANDOM but what I realy
 HG> want is the code to do that. Any Language is ok, but I prefer
 HG> Pascal.

 Here's a small random number unit that is quite good..
}

unit Random;

interface

procedure SeedRandomNum(ASeed : word);
procedure InitRandom;
function  RandomNum : word;
function  RandomRange(ARange : word): word;

implementation

var
   Fib   : array[1..17] of word;
   i, j  : word;

procedure SeedRandomNum(ASeed : word);
var x : word;
begin
   Fib[1] := ASeed;
   Fib[2] := ASeed;
   for x := 3 to 17 do
      Fib[x] := Fib[x-2] + Fib[x-1];
   i := 17;
   j := ASeed mod 17;
end;

procedure InitRandom;
begin
   SeedRandomNum(MemW[$40:$6C]);
end;

procedure SeedRandom(ASeed : word);
var x : word;
begin
   Fib[1] := ASeed;
   Fib[2] := ASeed;
   for x := 3 to 17 do
      Fib[x] := Fib[x-2] + Fib[x-1];
   i := 17;
   j := ASeed mod 17;
end;

function RandomNum : word;
var k : word;
begin
   k := Fib[i] + Fib[j];
   Fib[i] := k;
   dec(i);
   dec(j);
   if i = 0 then i := 17;
   if j = 0 then j := 17;
   RandomNum := k;
end;

function RandomRange(ARange : word): word;
begin
   RandomRange := RandomNum mod ARange;
end;

end.

