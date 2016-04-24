(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0030.PAS
  Description: More Primes Yet !!
  Author: JANOS SZAMOSFALVI
  Date: 08-27-93  21:46
*)

{
JANOS SZAMOSFALVI

the following routine uses a brute force approach with some
optimization; it took less than 3 minutes with a 286/12 to find
and print all primes up to 32768, about 50 seconds w/o printing
them; it becomes a bit slow when you get into a 6 digit range
}

PROGRAM Primes;
VAR
  number,
  max_div,
  divisor : INTEGER;
  prime   : BOOLEAN;
BEGIN
  writeln('Primes:');
  writeln('2');
  FOR number := 2 TO MAXINT DO
  BEGIN
    max_div := Round(sqrt(number) + 0.5);
    prime   := number MOD 2 <> 0;
    divisor := 3;
    WHILE prime AND (divisor < max_div) DO
    BEGIN
      prime   := number MOD divisor <> 0;
      divisor := divisor + 2;
    END;
    IF prime THEN
      writeln(number);
  END;
END.

