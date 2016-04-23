{ LOU DUCHEZ }
program mathtest;
uses
  calculus;

var
  answer : real;

{$F+} { WARNING!  YOU NEED "FAR" FUNCTIONS! }
function y(x : real) : real;
begin
  y := 2 * sqrt(4 - x * x);
end;
{$F-}

begin
  Writeln;
  Writeln('Function: y = 2 * (4 - x^2)^(1/2) (i.e., Circle Radius 2)');
  Writeln;

{ Calc operations here are: }

{ Integrate function from -2 to 2, in increments of 0.001. A half circle. }
{ However since equation multiplies it by 2, then we get area of full circle }
{ Get slope of function at 0 by evaluating points 0.01 away from each other. }
{ Find extremum of function, starting at 0.4, initially looking at points
  0.1 on either side of 0.4, and not stopping until we have two x-values
  within 0.001 of each other. }

  answer := integral(-2, 2, 0.001, @y);    writeln('Integ: ', answer:13:9);
  answer := derivative(1, 0.001, @y);      writeln('Deriv: ', answer:13:9);
  answer := extremum(0.4, 0.1, 0.001, @y); writeln('Extrm: ', answer:13:9);
  Writeln(4*Pi:0:6);
end.
