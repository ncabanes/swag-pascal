(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0079.PAS
  Description: Virtual Coords
  Author: JAMIE MORTIMER
  Date: 08-25-94  09:12
*)

{
You can do a basic horizontal starfeild where all you need is an array of
x,y locations, a routine to draw the stars in the next position, a routine
to remove the old stars, and a routine to update the position array.  Or one
routine to do all that. That gets boring once you write one.  So you want one
you can fly into. Now you need x,y and a z coord.  To get the virtual x,y
screen coords for each point, take their 3d-x coord and divide by the 3d-z
coord, and do the same for the y.  This will give you a real number, and
reals are slow so here's an example of just that math using only integers.
}
  X  : Integer; {3d x coord  -maxint to maxint, left to right}
  Y  : Integer;    {y            "         "    top to bottom}
  Z  : Integer;    {z   -1..-1023 where '-' is into screen}
  xx : integer; {2d x coord}
  yy : integer;    {y}

xx:=vidwidth div 2  + longint(x)*1024 div z;
yy:=vidheight div 2 + longint(y)*1024 div z;
{
That'll give you just plain depth scaling for one star.  For many stars,
just keep an array like this for each of those:
}
  X  : array [1..maxstars] of integer;
{
You'd basically follow this pattern:
}
 for t:=1 to maxstars do
   begin
     {if star is visible, clear it}
     if getpixel(xx[t],yy[t])=starcolor then
       putpixel(xx[t],yy[t],backgroundcolor);
     {update star position}
     whatever math you want.  Maybe just:
     inc(z[t]);
     if z<=0 then
       begin
         x:=random(2048)-1024;
         y:=random(2048)-1024;
         z:=-1024;
       end;
     {translate 3d to 2d}
     xx[tt]:= {etc from above}
     {draw new points}
     if getpixel(xx[t],yy[t])=backgroundcolor then
       putpixel(xx[t],yy[t],starcolor);
   end;
{
of course this won't compile, but I assume you like to code and so I'm
only giving you a general idea.  Then you can put another variable in, a
for example, which is not an array but just a constant which indicated
the "angle" of rotation around the z axis. (spinning)  it's easy to
implement that into the equation without any 3d math stuff.
}
xx[tt]:=longint(x[t])*1024 div z[t] * sintable[a mod 360]
        div (sin table precision constant, usually 256);

yy[tt]:=longint(y[t])*1024 div z[t] * costable[a mod 360]
        div 256;

