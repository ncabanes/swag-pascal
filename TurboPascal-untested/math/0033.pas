{ Updated NUMBERS.SWG on November 2, 1993 }

{
LOU DUCHEZ

Hey everybody!  This unit performs calculus operations via basic numerical
methods : integrals, derivatives, and extrema.  By Lou DuChez.  I don't
want any money for this; please just leave my name in the source code
somewhere, since this is the closest I'll ever get to being famous.

All functions return real values.  The last parameter in each function is
a pointer to a "real" function that takes a single "real" parameter:
for example, y(x).  See prior message to Timothy C. Novak for sample prog }

unit calculus;
interface

function integral(a, b, h : real; f : pointer) : real;
function derivative(x, dx : real; f : pointer) : real;
function extremum(x, dx, tolerance : real; f : pointer) : real;

implementation

type
  fofx = function(x : real) : real;     { needed for function-evaluating }

function integral(a, b, h : real; f : pointer) : real;
var
  x, summation : real;
  y            : fofx;
begin                                 { Integrates function from a to b,  }
  @y := f;                            { by approximating function with    }
  summation := 0;                     { rectangles of width h. }
  x := a + h/2;
  while x < b do
  begin                               { Answer is sum of rectangle areas, }
    summation := summation + h*y(x);  { each area being h*y(x).  X is at  }
    x := x + h;                       { the middle of the rectangle.      }
  end;
  integral := summation;
end;

function derivative(x, dx : real; f : pointer) : real;
var
  y : fofx;
begin                 { Derivative of function at x: delta y over delta x }
  @y := f;                                       { You supply x & delta x }
  derivative := (y(x + dx/2) - y(x - dx/2)) / dx;
end;


function extremum(x, dx, tolerance : real; f : pointer) : real;
{ This function uses DuChez's Method for finding extrema of a function (yes,
  I seem to have invented it): taking three points, finding the parabola
  that connects them, and hoping that an extremum of the function is near
  the vertex of the parabola.  If not, at least you have a new "x" to try...

  X is the initial value to go extremum-hunting at; dx is how far on either
  side of x to look.  "Tolerance" is a parameter: if two consecutive
  iterations provide x-values within "tolerance" of each other, the answer
  is the average of the two. }
var
  y           : fofx;
  gotanswer,
  increasing,
  decreasing  : boolean;
  oldx        : real;
  itercnt     : word;
begin
  @y := f;
  gotanswer := false;
  increasing := false;
  decreasing := false;
  itercnt := 1;
  repeat                               { repeat until you have answer }
    oldx := x;
    x := oldx - dx*(y(x+dx) - y(x-dx)) /    { this monster is the new value }
         (2*(y(x+dx) - 2*y(x) + y(x-dx)));  { of "x" based DuChez's Method }
    if abs(x - oldx) <= tolerance then
      gotanswer := true                     { within tolerance: got an answer }
    else
    if (x > oldx) then
    begin
      if decreasing then
      begin              { If "x" is increasing but it }
        decreasing := false;                { had been decreasing, we're }
        dx := dx/2;                         { oscillating around the answer. }
      end;                                { Cut "dx" in half to home in on }
      increasing := true;                   { the extremum. }
    end
    else
    if (x < oldx) then
    begin
      if increasing then
      begin              { same thing here, except "x" }
        increasing := false;                { is now decreasing but had }
        dx := dx/2;                         { been increasing }
      end;
      decreasing := true;
    end;
  until gotanswer;

  extremum := (x + oldx) / 2;               { spit out answer }
end;

end.



{
I've put together a unit that does calculus.  This unit could be used, for
example, to approximate the area under a curve (like a circle).

Because of the funny way my offline reader breaks up messages, I'm going
to send you a "test" program first -- which just happens to calculate
the area under a quarter circle -- then the following message (I hope)
will be the unit source code.
}

program mathtest;
uses
  calculus;

var
  answer : real;

{$F+}                       { WARNING!  YOU NEED "FAR" FUNCTIONS! }
function y(x : real) : real;
begin
  y := 4 * sqrt(1 - x * x);
end;

begin
  writeln('Function: y = (1 - x^2)^(1/2) (i.e., top half of a circle)');
  writeln;

{ Calc operations here are: }

{ Integrate function from 0 to 1, in increments of 0.001. A quarter circle. }
{ Get slope of function at 0 by evaluating points 0.01 away from each other. }
{ Find extremum of function, starting at 0.4, initially looking at points
  0.1 on either side of 0.4, and not stopping until we have two x-values
  within 0.001 of each other. }

  answer := integral(0, 1, 0.001, @y);
  writeln('Integ: ', answer:13:9);

  answer := derivative (0, 0.01, @y);
  writeln('Deriv: ', answer:13:9);

  answer := extremum(0.4, 0.1, 0.001, @y);
  writeln('Extrm: ', answer:13:9);
end.

