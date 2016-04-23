{
STEVE CONNET

Okay, here's the equations For 3D rotations...

x,y,z are the coordinates of the point you want to rotate.
rx,ry,rz are the amount of rotation you want (in degrees) For x,y,z
}

  x1 := round(cos(rad(ry)) * x  - sin(rad(ry)) * z);
  z1 := round(sin(rad(ry)) * x  + cos(rad(ry)) * z);
  x  := round(cos(rad(rz)) * x1 + sin(rad(rz)) * y);
  y1 := round(cos(rad(rz)) * y  - sin(rad(rz)) * x1);
  z  := round(cos(rad(rx)) * z1 - sin(rad(rx)) * y1);
  y  := round(sin(rad(rx)) * z1 + cos(rad(rx)) * y1);

{
Because in Turbo Pascal, COS and SIN require radians For the argument,
I wrote a short Function called RAD() that converts degrees into radians
(I find degrees much easier to visualize)
}

  Function Rad(i : Integer) : Real;
  begin
    Rad := i * (Pi / 360);
  end;

{
Of course, since most computers don't have 3D projection screens <G>,
use these equations to provide a sense of perspective to the Object,
but With 2D coordinates you can plot on a screen.

x,y,z are from the equations above, and xc,yc,zc are the center points
for the Object that you are rotating... I recommend setting xc,yc at 0,0
but zc should be very high (+100).
}
  x2 := trunc((xc * z - x * zc) / (z - zc));
  y2 := trunc((yc * z - y * zc) / (z - zc));

{
Alternatively, if you don't want to bother With perspective, just drop
the z values, and just plot the (x,y) instead.


To use these equations, pick a 3D Object and figure out what the 3D
coordinates are For each point on the Object.  You will have to have some
way to let the computer know which two points are connected.  For the
cube that I did, I had one Array For the points and one For each face
of the cube.  That way the computer can draw connecting lines For each
face With a simple for-loop.
}

Type
  FaceLoc  = Array [1..4] of Integer;
  PointLoc = Record
    x, y, z : Integer;
  end;

Const
  face_c : Array [1..6] of faceloc =(
    (1,2,3,4),
    (5,6,2,1),
    (6,5,8,7),
    (4,3,7,8),
    (2,6,7,3),
    (5,1,4,8));

  point_c : Array [1..8] of pointloc =(
    (-25, 25, 25),
    ( 25, 25, 25),
    ( 25,-25, 25),
    (-25,-25, 25),
    (-25, 25,-25),
    ( 25, 25,-25),
    ( 25,-25,-25),
    (-25,-25,-25));
{
There you go.  I'm not going to get much more complicated For now.  if you
can actually get these equations/numbers to work (and I haven't forgotten
anything!) leave me another message, and I'll give you some advice for
filling in the sides of the Object (so that you can only see 3 sides at
once) and some advice to speed things up abit.  if you have any problems
with whats here, show some other people, and maybe as a collective you can
figure it out.  Thats how I got this one started!
}
