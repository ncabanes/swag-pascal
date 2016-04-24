(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0037.PAS
  Description: Complex Math
  Author: ROBERT ROTHENBURG
  Date: 11-02-93  05:27
*)

{
ROBERT ROTHENBURG

> Can you compute complex numbers and/or "i" in Pascal...if so, how.

Not too hard. I've done that With some fractal Programs, which were
written For TP5 (it might be easier using OOP With the later versions).

I use two Variables For a complex number of a+bi, usually expressed as
xa and xb (or x.a and x.b as a Record).

For addition/subtraction (complex z=x+y):

 z.a:=x.a+y.a;
 z.b:=x.b+y.b;

For multiplication:

 z.a:=(x.a*y.a)-(x.b*y.b);
 z.b:=(x.a*y.b)+(x.b*y.a);
}

