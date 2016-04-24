(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0226.PAS
  Description: Shearing
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:27
*)

{
> I am trying to learn how to, and do, scaling and rotaing of images. I
> can put the image on a extrnal page and then I would like to do stuff
> with it.  Please help.

 Scaling, rotation, shearing, translations etc are all simple affine
transformations. I assume you have the math, no?

 Anyhow to sum it up:

 Shearing

   Qx = Px + G*Py
   Qy = Py + H*Px

   Where: Q = new point.
          P = old point.
          G = x shear factor
          H = y shear factor

  H & G are decimal numbers normally, here's an interesting demo of
a shear - it almost looks like 3-d rotation, but it's definitely not.
Btw you need somesort of fast graphics unit that is 1 based (ie 1,1 is
the top point - or rewrite the routines). Personally I'm using x320x240
by Sean Palmer, but I've added a bunch of stuff to it..
}

Program Shearing;
Uses Crt,x320x240; { by John Stephenson, 1995 }

{ Almost looks like rotation, eh? It's NOT! :-) It's just that the triangle }
{ when sheared goes down to 0, creating the effects that it is being        }
{ rotated, pretty neat, eh?                                                 }

Type
  tPoint = record
    x,y: word;
  end;
  tTriangle = record
    color: byte;
    a,b,c: tPoint;
  end;

Procedure DrawTriangle(var tri: tTriangle);
begin
  with tri do begin
    line(a.x,a.y,b.x,b.y,color);
    line(b.x,b.y,c.x,c.y,color);
    line(c.x,c.y,a.x,a.y,color);
  end;
end;

Procedure ShearPoint(var xold,yold,x,y: word; xshear,yshear: Real);
Begin
  x := xOld+round(yOld*xShear);
  y := yOld+round(xOld*yShear);
End;

Procedure ShearTriangle(var tri,stri: tTriangle; xshear,yshear: real);
Begin
  with tri.a do ShearPoint(x,y,stri.a.x,stri.a.y,xshear,yshear);
  with tri.b do ShearPoint(x,y,stri.b.x,stri.b.y,xshear,yshear);
  with tri.c do ShearPoint(x,y,stri.c.x,stri.c.y,xshear,yshear);
End;

Var
  oldsTri,sTri,Tri: tTriangle;
  yshear,xshear,xdir,ydir: real;
  loop: byte;
Begin
  graphbegin;
  Setcolor(0,0,0,0);
  For loop := 1 to 127 do setcolor(loop,255-loop div 2,0,loop div 2);
  For loop := 128 to 255 do setcolor(loop,loop div 2,0,255-loop div 2);

  with tri do begin
    a.x := 5;
    a.y := 30;
    b.x := 30;
    b.y := 1;
    c.x := 50;
    c.y := 30;

    color := 1;
  end;
  stri := tri;
  oldstri := stri;

  xshear := 0;
  yshear := 0;
  ydir := 0.05;
  xdir := 0.05;
  repeat
    cycle(1,255,1);
    xshear := xshear+xdir;
    yshear := yshear+ydir;
    if (xshear > 4) or (xshear <= 0) then xdir := -xdir;
    if (yshear > 4) or (yshear <= 0) then ydir := -ydir;
    oldstri := stri;
    sheartriangle(Tri,sTri,xshear,yshear);

    { Delete the old one }
    oldstri.color := 0;
    retrace;
    drawtriangle(oldsTri);
    { Make the new one }
    drawtriangle(sTri);
  until keypressed;
  readkey;
  graphend;
  textattr := lightgray;
  clrscr;
  textattr := lightcyan;
  writeln('Shearing demo, by John Stephenson');
End.

{
Rotations are interesting.. basically the general idea is:

  Qx := (Px * cos theta) - (Py * sin theta);
  Qy := (Px * sin theta) + (Py * cos theta);
  
  Now Q and P are the same for shearing, etc. Theta if you don't know is
how many degrees you want to rotate it by. In Pascal cos & sin use something
called radians. There are 2pi (you've heard of 2*pi*r to calculate the
circumference, right? It's based on that) radians in a circle, contrasted 
to 360 degrees in a circle. The begining point is at (radius,0) (middle 
left side) - and that's where the point of 0 radians starts for Pascal.

Btw does anyone know what GRAD means? On my scientific calculator I have
RAD, DEG, and GRAD. I don't get GRAD...
  
Here's a simple program to illustrate:
}

Program Rotation;
Uses Crt,x320x240; { by John Stephenson, 1995 }

Type
  tPoint = record
    x,y: integer;
  end;
  tTriangle = record
    color: byte;
    a,b,c: tPoint;
  end;

Procedure DrawTriangle(var tri: tTriangle);
begin
  with tri do begin
    line(a.x,a.y,b.x,b.y,color);
    line(b.x,b.y,c.x,c.y,color);
    line(c.x,c.y,a.x,a.y,color);
  end;
end;

Procedure RotatePoint(var oldx,oldy,x,y,aroundx,aroundy: integer; rad: real);
Begin
  x := aroundx+round(oldx*cos(rad) - oldy*sin(rad));
  y := aroundy+round(oldx*sin(rad) + oldy*cos(rad));
End;

Procedure RotateTriangle(var tri,rtri: tTriangle; ax,ay: integer; rad: real);
{ Rotate triangle "tri" into "rTri" around "ax","ay" "rad" radians }
Begin
  with tri.a do rotatepoint(x,y,rTri.a.x,rTri.a.y,ax,ay,rad);
  with tri.b do rotatepoint(x,y,rTri.b.x,rTri.b.y,ax,ay,rad);
  with tri.c do rotatepoint(x,y,rTri.c.x,rTri.c.y,ax,ay,rad);
End;

Var
  oldsTri,sTri,Tri: tTriangle;
  rad: real;
  loop: byte;
Begin
  graphbegin;
  Setcolor(0,0,0,0);
  For loop := 1 to 127 do setcolor(loop,255-loop div 2,0,loop div 2);
  For loop := 128 to 255 do setcolor(loop,loop div 2,0,255-loop div 2);

  with tri do begin
    a.x := 5;
    a.y := 30;
    b.x := 30;
    b.y := 1;
    c.x := 50;
    c.y := 30;

    color := 1;
  end;
  stri := tri;
  oldstri := stri;

  rad := 0;
  repeat
    cycle(1,255,1);
    rad := rad + 0.05;
    if rad > 2*pi then rad := 0;

    oldstri := stri;
    RotateTriangle(tri,stri,xmid,ymid,rad);

    { Delete the old one }
    oldstri.color := 0;
    retrace;
    drawtriangle(oldsTri);
    { Make the new one }
    drawtriangle(sTri);
  until keypressed;
  readkey;
  graphend;
  textattr := lightgray;
  clrscr;
  textattr := lightcyan;
  writeln('Rotation demo, by John Stephenson');
End.

{
To translate something it's pretty easy.. ie just:

Qx = Px + h
Qy = Py + g

Where h, and g are the directions.. simple idea.

  Lets see.. there's a whole bunch of affine and inverse affine
transformations that are worth taking a look at. If you haven't taken
atleast grade 12 or OAC math learn the basics of Cosine, Sine, and
Tangent (or if you have, skip that).. then pick up a computer graphics
book (hopefully for Pascal) :)

  We've gotta remember this is a pascal programming echo, and not a math
echo :) Hopefully this has helped out a bit.. Basically remember when
you're rotating an image, all you're -really- doing is applying the
rotation formulae to each pixel, and same with shearing.
}

