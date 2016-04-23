{
According to a message I just saw on Usenet, many Pentiums have a bug in
their implementation of the FDIV (floating point divide) instruction.
Supposedly the following program prints the value 256.0000, rather than
0.0000, on one of these:
}
{$N+,E-}
program pentbug;
var
  x,y,z : double;
begin
    x := 4195835;
    y := 3145727;
    z := x - (x/y)*y;
    writeln('z=',z:0:4,' (should be 0.0000)');
end.

{
Does anyone out there have a Pentium to try this on?  It prints 0.0000 on my
486DX.
}
