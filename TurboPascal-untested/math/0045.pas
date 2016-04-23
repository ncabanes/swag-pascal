{
LOU DUCHEZ

ATTENTION, whoever was trying to calculate PI!  Here's a swell program,
as a follow-up to a recent post of mine about approximating techniques!

}

program calcpi;  { Calculates pi by getting the area of one-quarter of a
                   circle of radius 1, and then multiplying by 4.  The area
                   is an approximation, derived by Simpson's method: see
                   previous post for explanation of that technique. }

uses
  crt;

const
  lowerbound  = 0;  { The interval we're evaluating is from 0 to 1. }
  higherbound = 1;  { I put the 0 and 1 here for clarity. }

var
  incs    : word;
  quartpi,
  h, x    : real;

function y(x : real) : real;  { Feed it an x-value, and it tells you the }
begin                         { corresponding y-value on the unit circle. }
  y := sqrt(1 - x * x);       { A no-brainer. }
end;

begin
  { I leave you to do the error-checking on input. }
  clrscr;
  write('Enter a WORD (1 - 32767) for the number of parabolas to do: ');
  readln(incs);

  { The answer for a quarter of pi will be accumulated into QuartPi. }
  quartpi := 0;

  { H is the interval to increment on.  X is the "middle" x value for each
    parabola in Simpson's method.  Here it is set equal to one interval
    above the lower bound: Simpson's method looks at points on either side
    of "X", so my reasoning is obvious.  Note also that, by magical
    coincidence, the last evaluation will have "X" equal to the higher
    bound of the interval minus H. }

  h := (higherbound - lowerbound) / (1 + 2 * incs);
  x := lowerbound + h;

  { This loop accumulates a value for pi/4. }
  while incs > 0 do
  begin
    if x < 0 then
      x := 0;
    quartpi := quartpi + y(x - h) + 4 * y(x) + y(x + h);

    { Move X two increments to the right, and decrease the number of parabolas
      we still have to do. }
    x := x + 2 * h;
    dec(incs);
  end;

  { Simpson's method has you multiply the sum by H/3. }
  quartpi := h * quartpi / 3;

  { Print answer. }
  writeln(4 * quartpi : 12 : 8);
  writeln('This has been a display of Simpson''s method.  D''ohh!');
end.
