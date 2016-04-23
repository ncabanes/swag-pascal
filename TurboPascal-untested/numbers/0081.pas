
Hi,
Here is a simple but good working randdom number generator for
32 bit machines with a period of 2^31-2. It generates uniformally
distributed integer  numbers in the range from 0 to 2^31-3, limits
included. The version of type real generates uniformally distributed
reals in the range from 0 to 1, limits included.

 VAR seed:longint;

 PROCEDURE ranset(s:longint);
 BEGIN
   seed:=s
 END;

 FUNCTION random:longint;
 CONST
   a=       16807; {This is just a lucky prime number}
   m=  2147483647; {This is 2^31-1, must be the same as in realrandom}
   q=      127773; {This is m div a}
   r=        2836; {This is m mod a}
 BEGIN
   seed:= a*(seed mod q) - r*(seed div q);
   IF seed <=0 THEN seed:=seed+m;
   random:=seed-1
 END;

 FUNCTION realrandom:real;
 CONST m=2147483647; {Must be the same as in random}
 BEGIN
   realrandom:=random/(m-2)
 END;
