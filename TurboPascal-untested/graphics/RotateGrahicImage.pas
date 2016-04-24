(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0022.PAS
  Description: Rotate Grahic Image
  Author: MIKE BRENNAN
  Date: 08-27-93  21:52
*)

{
MIKE BRENNAN

> I've been trying For some time to get a Pascal Procedure that can
> SCALE and/or ROTATE Graphic images. if anyone has any idea how to do

    Here are a couple of Procedures I made For rotating images, 2D and 3D.  I
basically had to rotate each dot individually, and then form the image by
connecting the specified dots.  Here they are...
}

Procedure Rotate(cent1, cent2 : Integer;     { Two centroids For rotation }
                 angle : Real;               { Angle to rotate in degrees }
                 Var coord1, coord2 : Real); { both coordinates to rotate }
Var
  coord1t, coord2t : Real;
begin
  {Set coordinates For temp system}
  coord1t := coord1 - cent1;
  coord2t := coord2 - cent2;

  {set new rotated coordinates}
  coord1 := coord1t * cos(angle * pi / 180) - coord2t * sin(angle * pi / 180);
  coord2 := coord1t * sin(angle * pi / 180) + coord2t * cos(angle * pi / 180);

  {Change coordinates from temp system}
  coord1 := coord1 + cent1;
  coord2 := coord2 + cent2;
end;

Procedure Draw3d(x, y, z : Real; {coordinates} a, b : Real; {View angles}
                 Var newx, newy : Integer); {return coordinates}
Var
  Xd, Yd, Zd : Real;
begin
  Xd := cos(a * pi / 180) * cos(b * pi / 180);
  Yd := cos(b * pi / 180) * sin(a * pi / 180);
  Zd := -sin(b * pi / 180);
  {Set coordinates For X/Y system}
  newx:= round(-z * Xd / Zd + x);
  newy:= round(-z * Yd / Zd + y);
end;

{
For the first Procedure, you can rotate an image along any two axes, (ie
X,Y...X,Z...Y,Z).  Simply calculate the centroid For each axe, (the average X
coordinate, or Y or Z), then pass the angle to rotate (use a negative For other
direction) and it will pass back the new rotated coordinates.

    The second Procedure is For 3D drawing only. It transforms any 3D dot into
its corresponding position on a 2D plan (ie your screen).  The new coordinates
are returned in the NewX, and NewY. Those are what you would use to plot your
dot on the screen.
}
