(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0014.PAS
  Description: Drawing Graphic Circles
  Author: MICHAEL NICOLAI
  Date: 08-27-93  20:25
*)

{
MICHAEL NICOLAI


The basic formula (and quickest) For drawing a circle is: x^2 + y^2 = r^2.
The r stands For radius (half the diameter). You know this formula, i am
sure. A guy called Phytagoras set i up very long ago to calculate the
hypotenuse of a given triangle. (there has to be a 90° angel between a and b)


                   |\
                   | \
                 a |  \ c      c^2 = a^2 + b^2
                   |   \
                   |____\

                     b

Remember?

Now look at this:        ...|     a quater of the circle
                       ..   |
                      . ____|y
                     . |\   |
                    .  | \  |
                    .  | r\ |
                    .  |   \|
               --------------------------
                    r  x    |0
                            |
                            |


r is given and take 0 - r as a starting point For x. Then all you have to do
is to calculate y and plot the point.

    y = sqrt((r * r) - (x * x))      sqrt : square root

After each calculation x is increased Until it has reached 0. Then one
quarter of the circle is drawn. The other three quarters are symmetrical.

I have written a short Program For you to draw a circle in 320x200x256
Graphics mode. When you key in some values please remember that NO error
checking will be done. x has to be between 0 and 319, and y between 0 and
199. The radius must not be greater than x and y.

Example: x : 160; y : 100; r : 90

When you start this Program you will not get correct circles because in
Graphics mode ONE pixel is not square!!! You have to calculate an aspect
ratio to get nice looking circles.
}

Program circle;

Uses
  Crt, Dos;

Var
  regs    : Registers;
  x0, y0  : Word;
  x, y, R : Real;
  temp    : Real;
  c       : Char;

Procedure putpixel(x, y : Word; color : Byte);
begin
  mem[$A000: (y * 320 + x)] := color;
end;

begin
  ClrScr;
  Writeln('Enter coordinates of middle-point :');
  Writeln;
  Write('x : '); readln(x0);
  Write('y : '); readln(y0);
  Writeln;
  Write('Enter radius :'); readln(R);

  { Switch to 320x200x256 }

  regs.ax := $0013;
  intr($10, regs);

  x := (-1) * R;  { go from 0 - R to 0 }
  temp := R * R;
  Repeat
    y := sqrt(temp - (x * x));
    putpixel((x0 + trunc(x)), (y0 - trunc(y)), 15); { 4.th quadrant }
    putpixel((x0 - trunc(x)), (y0 - trunc(y)), 15); { 1.st quadrant }
    putpixel((x0 + trunc(x)), (y0 + trunc(y)), 15); { 3.rd quadrant }
    putpixel((x0 - trunc(x)), (y0 + trunc(y)), 15); { 2.nd quadrant }
    x := x + 0.1; { change this if you want coarse or fine circle. }
  Until (x >= 0.0);
  c := ReadKey;  { wait For keypress. }

  { Switch back to Textmode. }

  regs.ax := $0003;
  intr($10, regs);
end.

