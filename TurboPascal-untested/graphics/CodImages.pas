(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0061.PAS
  Description: COD Images
  Author: KAI ROHRBACHER
  Date: 01-27-94  12:20
*)

{
> This doesn't have anything to do with the flicker problem, but I was
> wondering if you could tell me how to scale and rotate .COD images.

Although  I  posted  some code to flip COD's horizontally & vertically
some  time  ago,  I  won't make it a regular feature of AniVGA, as I'm
working on compiled bitmaps and thus, altering the "data" after having
it compiled into a procedure is close to impossible...
However,  if  you are speaking about scaling & rotation in MAKES: yes,
one  could  include  it.  To be honest, I was just to lazy to code all
that matrix crap necessary.
For  the  interested  reader: to scale the points (x,y) of a matrix by
some factor f, you just have to apply the matrix
(f 0)
(0 f)
to all its points.
A  rotation  by  an  angle  of  z  degrees  counterclockwise about the
rotation  center (u,v) is more complex: one first has to transform the
point coordinates to homogeneous coordinates (that is: append a one as
the  3rd  component: (x,y) -> (x,y,1); if during computations this 3rd
component  "c"  of  a vector (a,b,c) becomes <>1, then renormalize the
vector to (a/c,b/c,1)).
Having done so, the rotation consists of three steps:
a) make (u,v) the new origin of your pixels (instead of (0,0))
b) rotate the data by z degrees about the new origin (0,0)
c) retransform the true (0,0) origin

Step  a)  consists  of  applying the following matrix M1 to the pixels
(x,y,1):
( 1  0 0)
( 0  1 0)
(-u -v 1)

Likewise, step b) is done by the matrix M2:
( cos(z) sin(z) 0 )
(-sin(z) cos(z) 0 )
(   0      0    1 )

And step c) is done by M3:
( 1  0 0)
( 0  1 0)
(+u +v 1)

These  three  steps  can  be  squeezed  into one matrix application by
combining  the  three  matrices into one matrix M=M1*M2*M3 (with "*" =
matrix multiplication operator from linear algebra).


