
{I think the following will work, If not the net gods will comment.}

function sgn (a : real) : real;
begin
  if a < 0  then  sgn := -1;
            else  sgn :=  1;
end;

function atan2 (y, x : real) : real;
begin
  if x > 0       then  atan2 := arctan (y/x)
  else if x < 0  then  atan2 := arctan (y/x) + pi
  else                 atan2 := pi/2 * sgn (y);
end;

I think you should seriously consider using the FPATAN instruction for this!

This x87 opcode implements an IEEE-compliant ATAN2() function, with full extended
precision, and the hardware will handle all the special cases for you.

If you have numeric exceptions enabled, and input bogus values, the x87 chip will 
raise the appropriate signal, without the need for upfront testing of parameters.

A BP/TP/Delphi-compatible version would look like this:

Function atan2(y : extended; x : extended): Extended;
Assembler;
asm
  fld [y]
  fld [x]
  fpatan
end;

Total execution time is less than 200 cycles on a Pentium, with less than 1 ulp 
maximum error, unless you have a Pentium with the FDIV bug, where it could fail
almost anywhere after the first 15-20 OK bits!  :-)

The library function ArcTan(x) is implemented as fpatan(1.0,x), as long as you
compile with IEEE reals {$N+} set.

Terje
