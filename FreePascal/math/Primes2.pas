(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0018.PAS
  Description: PRIMES2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
BRIAN PAPE

>   Go to the library and look up the Sieve of Eratosthenes; it's a very
>interesting and easy method For "finding" prime numbers in a certain
>range - and kinda fun to Program in Pascal, I might add...
}

Program aristophenses_net;
{
 LCCC Computer Bowl November 1992 Team members:
 Brian Pape, Mike Lazar, Brian Grammer, Kristy Reed - total time: 5:31
}

Const
  size = 5000;
Var
  b     : Array [1..size] of Boolean;
  i, j,
  count : Integer;

begin
  count := 0;
  Writeln;
  Write('WORKING: ', ' ' : 6, '/', size : 6);
  For i := 1 to 13 do
    Write(#8);
  fillChar(b, sizeof(b), 1);

  For i := 2 to size do
    if b[i] then
    begin
      Write(i : 6, #8#8#8#8#8#8);
      For j := i + 1 to size do
        if j mod i = 0 then
          b[j] := False;
    end;  { For }

  Writeln;

  For i := 1 to size do
    if b[i] then
    begin
      Write(i : 8);
      inc(count);
    end;

  Writeln;
  Write('The number of primes from 1 to ', size, ' is ', count, '.');
end.
