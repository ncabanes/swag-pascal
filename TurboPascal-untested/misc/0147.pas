{
From: bobs@dragons.nest.nl (Bob Swart)

On the BPASCAL forum on CompuServe, DJ Murdoch [71631,122] reported something
that isn't a Borland bug, but looks as though it'll affect BP programs when
they run on a Pentium:

64.  For certain very rare pairs x and y, a $N+ division x/y will only be
accurate to about 4 decimal digits when calculated on a Pentium produced before
Fall 1994.

Dr. Bob's further detailed analysis resulted in the following function which
will generate 11 series of infinite "buggy" numbers for which the following
does not hold on a Pentium chip (a reciprocal of a reciprocal):

 x = 1/1/x

Try it on a Pentium with for example the magic number... 357914069

I also found that a power of 2 times any number that goes wrong also goes wrong
(i.e. X, 2*X, 4*X, 8*X, etc).

Also, once you've found a "wrong number" (and the serie), you can start a new
serie by multiplying with 4 and adding 383 (= 256 + 128 - 1).

Below follows a general function that is able to produce 11 series of (just
about infinite) numbers that generate incorrect results. Note that the initial
difference (for the first digit in a serie) is 21 1/3, and the difference
increases with the same power of two as the original number...
}
 {$N+,E-}
 program DrBob5;
 {
   Digits found in one night (source for analysis):

   357914069, 715828138, 1431656276,
   1431655893 (new series = 4 * X - 383 )
 }

  function PentiumBug(Const Serie,Index: Word): Extended;
  { Serie max = 11 }
  Const Magic = 357914069;
        Factor= 256 + 128 - 1;
  var tmp: Extended;
      i: Integer;
  begin
    tmp := Magic;
    for i:=2 to Serie do tmp := 4.0 * tmp - Factor;
    for i:=2 to Index do tmp := tmp + tmp;
    PentiumBug := tmp
  end {PentiumBug};

var i,j: Integer;
    x,y,z: Double;
begin
  for i:=1 to 11 do
  begin
    for j:=1 to 16 do
    begin
      x := PentiumBug(i,j);
      y := 1 / x;
      z := 1 / y;
    { z should be x, but isn't... }
      writeln('x = ',x:12:0,' 1/x =',y,' 1/1/x = ',z:12:0,' diff ',x-z:5:0)
    end;
    writeln
  end
end.
{
The bug is in the FDIV instruction, which for about 1 in 10^10 pairs of
randomly chosen divisors suffers a catastrophic loss of precision, ending up
accurate to 4 to 6 digits instead of the usual 18.  Apparently Intel chose a
division algorithm which is fast but which isn't 100% guaranteed to work.

I still don't know why the difference is 0 again starting with the 12th serie,
but I'm sure given enough time I can reproduce the exact buggy FDIV algorithm
Intel uses...
}
