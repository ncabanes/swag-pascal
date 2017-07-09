(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0015.PAS
  Description: RANDOM1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{Another method to acComplish this (which only requires an order of n
itterations is to generate an Array initialized from 2 to 1000 and then
randomize that Array.  For your 400 numbers, just take 400 values in the
new sequence (starting at the index of your lowest number). You can do
that as follows:
}

Const MaxNumber = 2000;
Type SeqArray = Array [1..MaxNumber] of Integer;

{================================================================}
Procedure RandomizeSeq (first, last: Integer; Var iseq: SeqArray);
{================================================================}

Var           i, iran,
           temp, imax : Integer;
                    r : Real;
{
  Operation:  A random number within the range 1..last is generated
  on each pass and the upper limit of the random number generated is
  decreased by 1.  The value stored at the highest index of the last
  pass is moved to the location of the last number selected.

  Parameters:
    first = lowest number in sequence.
     last = highest number in sequence.
     iseq = Sequence Array
}
begin
   { initialize sequence Array }
   For i := first to last do iseq[i] := i;
   Randomize;
   { randomize the sorted Array }
   For imax := last downto first do begin
      { get a random number between 0 and 1 and scale up to
        an Integer in the range of first to last }
      r := random;
      iran := Trunc(r*imax) + first;
      { replace With value at highest index }
      temp := iseq[iran];
      iseq[iran] := iseq[imax];
      iseq[imax] := temp
   end;
end;

{ Example of generating 20 random numbers from 2 to 100: }

Var i : Integer;
    a : SeqArray;
begin
   RandomizeSeq(2,100,a);
   For i := 2 to 21 do Write(a[i]:3); Writeln;
end.

