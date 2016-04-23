
FUNCTION sign (r : real) : integer;
{ Returns 1 if r>0, 0 if r=0 or -1 if r<0 }
BEGIN
  IF r > epsilon
  THEN
     sign := 1
  ELSE
     IF r < -epsilon
     THEN
        sign := -1
     ELSE
        sign := 0;
END;

FUNCTION orient (p1, p2, p3 : vector2) : integer;
{ Returns the orientation of the polygon with consecutive vertices
  p1, p2 and p3. -1 -> Clockwise orientation
                 +1 -> Anticlockwise orientation
                  0 -> Degenerate, i.e. Line or Point }
VAR d1, d2 : vector2;
BEGIN
  d1.x := p2.x - p1.x; d1.y := p2.y -p1.y;
  d2.x := p3.x - p2.x; d2.y := p3.y -p2.y;
  orient := sign(d1.x*d2.y - d1.y*d2.x);
END;

{
You can use this routine to determine if the vertices of a
two-dimensional polygon are oriented clockwise or
anti-clockwise. If the orientation is wrong you can invert
the order of the points, and there you go ...

The corresponding routine for 3-D is as follows ...
}

PROCEDURE vectorproduct (p,q : vector3; VAR v : vector3);
{ Calculates the vector (cross) product of two vectors p and q }
BEGIN
   v.x := p.y*q.z - p.z*q.y;
   v.y := p.z*q.x - p.x*q.z;
   v.z := p.x*q.y - p.y*q.x;
END;

FUNCTION dot3 (v1, v2 : vector3) : REAL;
BEGIN
   dot3 := v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
END;

FUNCTION orient3 (p1, p2, p3, e : vector3) : integer;
{ Returns the orientation of the polygon with consecutive vertices
  p1, p2 and p3, as viewed from position 'e'
      -1 : Clockwise
      +1 : Anti-clockwise
       0 : Degenerate - Line or Point }
VAR d1, d2, d1xd2, v : vector3;
BEGIN
   d1.x := p2.x - p1.x; d1.y := p2.y - p1.y; d1.z := p2.z - p1.z;
   d2.x := p3.x - p2.x; d2.y := p3.y - p2.y; d2.z := p3.z - p2.z;
   vectorproduct (d1, d2, d1xd2);
   v.x := e.x - p1.x; v.y := e.y - p1.y; v.z := e.z - p1.z;
   orient3 := sign(dot3(d1xd2, v));
END;

{ You will probably need the following definitions as well :- }

TYPE vector2 = RECORD
        x, y : real;
     END;

     vector3 = RECORD
        x, y, z : real;
     END;

CONST epsilon = 0.00001;

