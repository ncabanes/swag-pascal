(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0114.PAS
  Description: Euler's Indice to Prime Numbers
  Author: DANIEL DOUBROVKINE
  Date: 08-30-96  09:35
*)

(*
                Daniel Doubrovkine - dblock@infomaniak.ch
   part of the Expression Calculator 2.0 Multithread, destribute freely
              http://www.infomaniak.ch/~dblock/express.htm
    (ref. Haussman, Simple Algebra course at the University of Geneva)

                            "Euler's Indice"
       euler's indice is a insomorphe function phi: Zm->Z1*Z2...Zn
    means the decomposition of a number into a primes product is unique
    with phi(n):=n*(1-1/p1)*...*(1-1/pn) where pi are primes taken once
    from the decomposition.
    ex: (following algorith steps):
       168=2*84
       168=2*2*42
       168=2*2*2*21
       168=2*2*2*3*7 where all are primes!
  now, phi(168)=168*(1-1/2)(1-1/3)(1-1/7)=48 (this is always an integer!)
       thus, 168 has 48 primes to it.
*)

(*defining a dynamic primes array, so this function will never be limited*)
type
   PPrimesArray=^TPrimesArray;
   TPrimesArray=record
      Prime:longint;
      NextPrime:PPrimesArray;
      end;


   (*adding a prime to the array*)
   procedure PrimesAdd(var AllPrimes: PPrimesArray;Prime:longint);
   var
      TempPrimes:PPrimesArray;
   begin
      TempPrimes:=AllPrimes;
      while (TempPrimes<>nil) do begin
         if TempPrimes^.Prime=Prime then exit;
         TempPrimes:=TempPrimes^.NextPrime;
         end;
      new(TempPrimes);
      TempPrimes^.Prime:=Prime;
      TempPrimes^.NextPrime:=AllPrimes;
      AllPrimes:=TempPrimes;
      end;

   (*removing the primes array*)
   procedure PrimesRemove(AllPrimes: PPrimesArray);
   var
      TempPrimes:PPrimesArray;
   begin
      while AllPrimes<>nil do begin
         TempPrimes:=AllPrimes;
         AllPrimes:=AllPrimes^.NextPrime;
         Dispose(TempPrimes);
         end;
      end;

   (*by the way, this routine uses some code from swag*)
   function GeneratePrimes(var AllPrimes: PPrimesArray;n: longint):longint;
    procedure CalculateTPrime(n: longint);
    var
      TempPrime: PPrimesArray;
      CurrentPrime: LongInt;
      prime:boolean;
      number,max_div,divisor,lastprime:longint;
    begin
      CurrentPrime:=AllPrimes^.Prime;
      for number:=CurrentPrime to MaxLongInt do begin
         max_div:=Round(Sqrt(number)+0.5);
         prime:=number mod 2 <> 0;
         divisor:=3;
         while prime and (divisor<max_div) do begin
               prime:=number mod divisor <>0;
               divisor:=divisor+2;
               end;
         if prime then begin
         if AllPrimes^.Prime<CurrentPrime then PrimesAdd(AllPrimes,CurrentPrime);
            CurrentPrime:=number;
         if n<CurrentPrime then exit;
         end;
         end;
         end;

   var
      TempPrime: PPrimesArray;
      CurrentPrime: LongInt;
      prime:boolean;
      number,max_div,divisor,lastprime:longint;
   begin
     PrimesAdd(AllPrimes,1);
     PrimesAdd(AllPrimes,2);
      if (n>-1) and (n<1) then begin
         writeln('Prime requires values |x|>1');
         halt;
         end;
      if n>maxlongint then begin
         writeln('prime limit too large');
         halt;
         end;

      n:=abs(n);

      if (n<=AllPrimes^.Prime) then begin
      TempPrime:=AllPrimes;
         while TempPrime<>nil do begin
               CurrentPrime:=TempPrime^.Prime;
               if n>=TempPrime^.Prime then begin
                  GeneratePrimes:=TempPrime^.Prime;
                  exit;
                  end;
           TempPrime:=TempPrime^.NextPrime;
           end;
           end;
      CalculateTPrime(n);
      GeneratePrimes:=AllPrimes^.Prime;
      end;


function phi(var AllPrimes:PPrimesArray;Value:longint):longint;
var
   UsedPrimes:PPrimesArray;
   (*this is partailly from swag...*)
   procedure Factoring(lin:longint);
   var
      lcnt:longint;
   begin
      lcnt:=2;
      if GeneratePrimes(AllPrimes,lin)=lin then begin
         write(' ',lin);
         PrimesAdd(UsedPrimes,lin);
         end else
         while(lcnt*lcnt<=lin) do begin
            if (lin mod lcnt) = 0 then begin
               if GeneratePrimes(AllPrimes,lcnt)<>lcnt then factoring(lcnt)
                  else begin
                     write(' ',lcnt);
                     primesadd(UsedPrimes,lcnt);
                     end;
               if GeneratePrimes(AllPrimes,lin div lcnt)<>(lin div lcnt) then factoring(lin div lcnt)
                  else begin
                     write(' ',lin div lcnt);
                     primesadd(UsedPrimes,lin div lcnt);
                     end;
               exit;
               end;
         lcnt:=lcnt+1;
         end;
      end;

   var
      FinalResult:real;
      TempPrimes:PPrimesArray;
   begin
     if Value=0 then begin
        Phi:=0;
        exit;
        end;
     Value:=Abs(Value);
     FinalResult:=Value;
     UsedPrimes:=nil;
     write('Decomposition of ',Value:0,':');
     Factoring(Value);
     writeln;
     TempPrimes:=UsedPrimes;
     while TempPrimes<>nil do begin
        FinalResult:=FinalResult*(1-1/TempPrimes^.Prime);
        TempPrimes:=TempPrimes^.NextPrime;
        end;
     phi:=trunc(FinalResult);
     PrimesRemove(UsedPrimes);
     writeln('Euler''s indice for ',Value:0,' is ',trunc(FinalResult));
     writeln('(there are ',trunc(FinalResult),' primes to ',Value,')');
   end;

var
   AllPrimes: PPrimesArray;
begin
     Phi(AllPrimes,168);
     PrimesRemove(AllPrimes);
   end.



