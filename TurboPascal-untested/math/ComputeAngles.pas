(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0042.PAS
  Description: Compute Angles
  Author: LOU DUCHEZ
  Date: 11-02-93  06:31
*)

{
LOU DUCHEZ

>I'm looking for the way turbo pascal computes the angle.
>Now how can I compute for the Angles C & B.

>  b, c, a, B_angle, C_angle: real;

>            ┌─┐B angle
>            │ └─────┐      a
>           b│       └─────┐
>            │             └─────┐
>            │A = 90             └─────┐
>            └─────────────────────────┘ C angle
>                       c

Okay, you've got b and c.  There is an ArcTan function that returns
an angle in radians.  Try this:
}

  b := abs(b);        { these lines keep the operator from getting "cute" }
  c := abs(c);
  if c <> 0 then
  begin        { prevents "division by zero" thing }
    C_angle := arctan(b/c);
    B_angle := (pi/2) - C_angle;  { 90 degrees minus the one angle }
  end
  else
  if b <> 0 then
  begin  { ditto }
    B_angle := arctan(c/b);
    C_angle := (pi/2) - B_angle;
  end
  else
  begin                 { you'll get here only if b = c = 0 }
    B_angle := 0;
    C_angle := 0;
    writeln('That''s a dot, not a triangle!');
  end;
{
Might I recommend that you have the user do data entry in a "repeat" loop,
so that he can get out only when he's put in actual positive values?  I
think you'll discover that a little caution at data-entry time is worth it
in spared headaches later.  (Note all the error-checking I had to do ...)

Oh, you wanted degrees, minutes, seconds.  I don't know of any built-in
routines for this (I admit I may have missed something), but here's some
totally untested code to convert radians to degrees, minutes, seconds:
}
procedure r2dms(rad : real; var deg, min, sec : real);
begin
  deg := rad * 180 / pi;    { conversion to degrees }
  min := frac(deg) * 60;    { convert remainder to minutes }
  deg := trunc(deg);        { lose the remainder on degrees }
  sec := frac(min) * 60;    { convert "minutes" remainder to seconds }
  min := trunc(min);        { lose the remainder on minutes }
end;

{ Here's the reverse journey: }

procedure dms2r(deg, min, sec : real; var rad : real);
begin
  rad := pi * (deg + 60 * min + 3600 * sec) / 180;
end;

