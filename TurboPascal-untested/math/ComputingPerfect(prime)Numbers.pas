(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0108.PAS
  Description: Computing Perfect(prime) Numbers
  Author: SAMIEL@FASTLANE.NET
  Date: 05-31-96  09:16
*)

{
>Samiel (samiel@fastlane.net) wrote:
>: Here's my fast and elegant code... snarf it and add it to SWAG...
>: 
>: {****************************************************************
>: Perfect Numbers...
>: 
>: A Perfect number is a number whose divisors not including the original
>: number add up to the original number.  An example is 6, 6=3*2*1=3+2+1
>: and 28, 28=14*7*4*2*1=14+7+4+2+1.  The definition of a Perfect number
>: can also be defined as,
>: 2^(p-1)*(2^p-1) where p is prime and 2^p-1 is a Mersenne prime...
>: 
>: A Mersenne prime is defined as,
>: 2^p-1 where p is prime and 2^p-1 is prime, so 2^2-1=3 is a Mersenne
>: prime where p is 2, and 2^3-1=5 is a Mersenne prime where p is 3.
>: 
>: Mersenne primes under 2^32 (32-bit) are:
>:   [2] -> 3
>:   [3] -> 7
>:   [5] -> 31
>:   [7] -> 127
>: [13] -> 8191
>: [17] -> 131071
>: [19] -> 524287
>: [31] -> 2147483647
>: 
>: (Values of p are in braces [])
>: 
>: The Perfect numbers under 2^32 are:
>: Perfect numbers...
>:   [2] 6
>:   [3] 28
>:   [5] 496
>:   [7] 8128
>: [13] 33550336
>: 
>: (Values of p are in braces [])
>: 
>: Here is my code...
>:
>: ****************************************************************}

 PROGRAM Perfect;
 {Computes Perfect Numbers...}

 VAR
   tmp,num:longint; {Long Integer signed 32-bit (31-bit on each side)}
   j,k:byte;

 { Slow? Fast? way to find primes, dividing by odd numbers }
 Function IsPrime(num:longint):boolean;
 Var
   tmp:boolean;
   j:longint;
 Begin
   tmp:=true;
   if num mod 2=0 then
     tmp:=false;
   for j:=3 to round(sqrt(num)) do
     if odd(j) then
       if num mod j=0 then
         tmp:=false;
   if num=2 then
      tmp:=true;
   IsPrime:=tmp;
 End;

 BEGIN
   tmp:=2; {2^1}
   writeln('Perfect numbers...');
   for j:=2 to 31 do
     begin
       tmp:=tmp*2; {Raise 2 to another power}
       if IsPrime(j) then
         begin
           num:=tmp-1;
           if IsPrime(num) then
             begin
               num:=num*(tmp div 2);
               writeln(num:1,' is perfect'); {Ignore negatives}
             end;
         end;
     end;
 END.


>: - Samiel
>: samiel@fastlane.net
>: http://www.fastlane.net/~samiel
>: 

>Considering that 2^859433-1 is prime(and is the largest known prime), there
>are obviously better methods.  Use the Lucas-Lehmer test.

>B(n+1) = B(n)^2 - 2 mod (2^p-1) where B(0)=4

>if B(n-1) = 0 then 2^p-1 is prime.  The division is a special case and is
>done easily because of the all ONE's when 2^p-1 is written in binary.  All
>that is necessary is a fast implementation of multiplication and this can
>be done with FFT's.

>See http://www.utm.edu/research/primes/mersenne.shtml

>or for software
>http://ourworld.compuserve.com/homepages/justforfun/prime.htm

Well, considering we are looking at numbers under 32 bits, your code
would probably not get done as fast as mine, though in the long run,
(say over 64 bits or so) it would.  All the FFT's and rather long
multiplication would slow it down considerably.  Even if you could get
a really fast implementation of FFT's and multiplications, we're
talking about a net savings of about .625 seconds or so with numbers
under 32 bits on a computer with a Math Processor... so mine's good
enough... although a few of multiplications could be taken out...

- Samiel
samiel@fastlane.net
http://www.fastlane.net/~samiel

