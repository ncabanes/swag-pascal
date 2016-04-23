{
> Could someone please explain how to plot a 3-D points? How do you convert
> a 3D XYZ value, to an XY value that can be plotted onto the screen?
}

Function x3d(x1, z1 : Integer) : Integer;
begin
  x3d := Round(x1 - (z1 * Cos(Theta)));
end;

Function y3d(y1, z1 : Integer) : Integer;
begin
  y3d := Round(y1 - (z1 * Sin(Theta)));
end;

{
So a Function that plots a 3d pixel might look like this:

Procedure plot3d(x, y, z : Integer);
begin
  plot(x3d(x, z), y3d(y, z));
end;

The theta above is the angle on the screen on which your are "simulating"
your z axis.  This is simplistic, but should get you started.  Just remember
you are simulating 3 dimensions on a 2 dimension media (the screen).  Trig
helps. ;-)
}