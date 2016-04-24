(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0072.PAS
  Description: Prime Numbers
  Author: DAVE NEMETH
  Date: 08-24-94  13:51
*)

{
I'm studying pascal on my own and was given an assignment to determine if a
positive number is prime. This was in a chapter where functions were
discussed. I've struggled with this problem for a week and have given up. The
following code is the best I can come up with. It is not correct. Would
someone please evaluate this and tell me what is wrong with it?
}

PROGRAM PrimeNumbers;
{ Exercise to determine if a positive number is a prime }
VAR x : WORD;
 
FUNCTION prime (p : WORD) : BOOLEAN;
BEGIN { Prime }
 prime := (p MOD 2 <> 0) AND (p MOD 3 <> 0) AND (p MOD 5 <> 0)
END; { Prime }

BEGIN { Main }
 REPEAT
   WRITE ('Enter a positive number. 0 to quit: ');
   READLN (x);
   IF prime (x) THEN
      WRITELN (x, ' is a prime number')
   ELSE
      WRITELN (x, ' is NOT prime');
 UNTIL
       x = 0
 END. { Main }

