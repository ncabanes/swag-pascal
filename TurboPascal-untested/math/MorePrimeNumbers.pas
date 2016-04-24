(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0028.PAS
  Description: More Prime Numbers
  Author: JONATHAN WRITE
  Date: 08-27-93  21:45
*)

{
JONATHAN WRIGHT

Here is source For finding primes.  I just pulled this off of an OLD backup
disk, so I don't Really know how optimized it is, but it works:
}

Const
  FirstPrime = 2;
  MaxPrimes  = 16000; (* Limit 64k For one Array, little more work For more *)

Var
  Primes      : Array [1..MaxPrimes] of LongInt;

  PrimesFound : LongInt;
  TestNumber  : LongInt;
  Count       : LongInt;

  IsPrime     : Boolean;

begin
  PrimesFound := 1;
  TestNumber  := FirstPrime + 1;

  For Count := 1 to MaxPrimes DO
    Primes[Count] := 0;

  Primes[1] := FirstPrime;

  Repeat
    Count   := 1;
    IsPrime := True;

    Repeat
      if Odd (TestNumber) then
        if TestNumber MOD Primes[Count] = 0 then
          IsPrime := False;
          INC (Count);
    Until (IsPrime = False) or (Count > PrimesFound);

    if IsPrime = True then
    begin
      INC (PrimesFound);
      Primes[PrimesFound] := TestNumber;
      Write (TestNumber, ', ');
    end;
    INC (TestNumber);
  Until PrimesFound = MaxPrimes;
end.

