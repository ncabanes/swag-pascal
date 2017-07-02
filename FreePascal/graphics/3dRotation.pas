(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0046.PAS
  Description: 3D Rotation
  Author: PETER M. GRUHN
  Date: 01-27-94  11:51
*)

program BoxRot;

{PUBLIC DOMAIN  1993 Peter M. Gruhn

Program draws a box on screen. Allows user to rotate the box around
the three primary axes. Viewing transform is simple ignore z.

I used _Computer_Graphics:_Principles_and_Practice_, Foley et al
ISBN 0-201-12110-7 as a reference

RUNNING:
Borland Pascal 7. Should run on any graphics device supported by BGI.
If you have smaller than 280 resolution, change '+200' to something
smaller and/or change 75 to something smaller.

Since this machine is
not really set up for doing DOS graphics, I hard coded my BGI path, so
you have to find 'initgraph' and change the bgi path to something that
works on your machine. Try ''.

Okey dokey. This is kinda slow, and does a nice job of demonstrating the
problems of repeatedly modifying the same data set. That is, the more and
more you rotate the box, the more and more distorted it gets. This is
because computers are not perfect at calculations, and all of those little
errors add up quite quickly.

It's because of that that I used reals, not reals. I used floating point
because the guy doesn't know what is going on at all with 3d, so better to
look at only the math that is really happening. Besides, I still have to
think to use fixed point. Whaddaya want for .5 hour programming.

 DIRECTIONS:
   ',' - rotates around the x axis
   '.' - rotates around the y axis
   '/' - rotates around the z axis
   'q' - quits

   All rotations are done around global axes, not object axes.
}

uses
  graph,
  wincrt;

const
  radtheta = 1 {degrees} * 3.1415926535 {radians} / 180 {per degrees};
  { sin and cos on computers are done in radians. }

type
  tpointr = record   { Just a record to hold 3d points }
    x, y, z : real;
  end;

var
  box : array [0..7] of tpointr;   { The box we will manipulate }
  c   : char;                      { Our input mechanism }

procedure init;
var
  gd, gm : integer;
{ turns on graphics and creates a cube. Since the rotation routines
  rotate around the origin, I have centered the cube on the origin, so
  that it stays in place and only spins. }
begin
  gd := detect;
  initgraph(gd, gm, 'e:\bp\bgi');
  box[0].x := -75;  box[0].y := -75;  box[0].z := -75;
  box[1].x := 75;   box[1].y := -75;  box[1].z := -75;
  box[2].x := 75;   box[2].y := 75;   box[2].z := -75;
  box[3].x := -75;  box[3].y := 75;   box[3].z := -75;
  box[4].x := -75;  box[4].y := -75;  box[4].z := 75;
  box[5].x := 75;   box[5].y := -75;  box[5].z := 75;
  box[6].x := 75;   box[6].y := 75;   box[6].z := 75;
  box[7].x := -75;  box[7].y := 75;   box[7].z := 75;
end;

procedure myline(x1, y1, z1, x2, y2, z2 : real);
{ Keeps the draw routine pretty. Pixels are integers, so I round. Since the
 cube is centered around 0,0 I move it over 200 to put it on screen. }
begin
{ if you think those real mults are slow, here's some rounds too... hey, you
  may wonder, what happened to the stinking z coordinate? Ah, says I, this
  is the simplest of 3d viewing transforms. You just take the z coord out of
  things and boom. Looking straight down the z axis on the object. If I get
  inspired, I will add simple perspective transform to these.  There, got
  inspired. Made mistakes. Foley et al are not very good at tutoring
  perspective and I'm kinda ready to be done and post this. }
  line(round(x1) + 200, round(y1) + 200, round(x2) + 200, round(y2) + 200);
end;

procedure draw;
{ my model is hard coded. No cool things like vertex and edge and face lists.}
begin
  myline(box[0].x, box[0].y, box[0].z, box[1].x, box[1].y, box[1].z);
  myline(box[1].x, box[1].y, box[1].z, box[2].x, box[2].y, box[2].z);
  myline(box[2].x, box[2].y, box[2].z, box[3].x, box[3].y, box[3].z);
  myline(box[3].x, box[3].y, box[3].z, box[0].x, box[0].y, box[0].z);

  myline(box[4].x, box[4].y, box[4].z, box[5].x, box[5].y, box[5].z);
  myline(box[5].x, box[5].y, box[5].z, box[6].x, box[6].y, box[6].z);
  myline(box[6].x, box[6].y, box[6].z, box[7].x, box[7].y, box[7].z);
  myline(box[7].x, box[7].y, box[7].z, box[4].x, box[4].y, box[4].z);

  myline(box[0].x, box[0].y, box[0].z, box[4].x, box[4].y, box[4].z);
  myline(box[1].x, box[1].y, box[1].z, box[5].x, box[5].y, box[5].z);
  myline(box[2].x, box[2].y, box[2].z, box[6].x, box[6].y, box[6].z);
  myline(box[3].x, box[3].y, box[3].z, box[7].x, box[7].y, box[7].z);

  myline(box[0].x, box[0].y, box[0].z, box[5].x, box[5].y, box[5].z);
  myline(box[1].x, box[1].y, box[1].z, box[4].x, box[4].y, box[4].z);
end;

procedure rotx;
{if you know your matrix multiplication, the following equations
 are derived from

 [x   [ 1  0  0  0   [x',y',z',1]
  y     0  c -s  0 =
  z     0  s  c  0
  1]    0  0  0  1]
}
var
  i : integer;
begin
  setcolor(0);
  draw;
  for i := 0 to 7 do
  begin
    box[i].x :=  box[i].x;
    box[i].y :=  box[i].y * cos(radTheta) + box[i].z * sin(radTheta);
    box[i].z := -box[i].y * sin(radTheta) + box[i].z * cos(radTheta);
  end;
  setcolor(15);
  draw;
end;

procedure roty;
{if you know your matrix multiplication, the following equations
 are derived from

 [x   [ c  0  s  0   [x',y',z',1]
  y     0  1  0  0 =
  z    -s  0  c  0
  1]    0  0  0  1]
}
var
  i : integer;
begin
  setcolor(0);
  draw;
  for i := 0 to 7 do
  begin
    box[i].x := box[i].x * cos(radTheta) - box[i].z * sin(radTheta);
    box[i].y := box[i].y;
    box[i].z := box[i].x * sin(radTheta) + box[i].z * cos(radTheta);
  end;
  setcolor(15);
  draw;
end;

procedure rotz;
{if you know your matrix multiplication, the following equations
 are derived from

 [x   [ c -s  0  0   [x',y',z',1]
  y     s  c  0  0 =
  z     0  0  1  0
  1]    0  0  0  1]
}
var
  i : integer;
begin
  setcolor(0);
  draw;
  for i := 0 to 7 do
  begin
    box[i].x :=  box[i].x * cos(radTheta) + box[i].y * sin(radTheta);
    box[i].y := -box[i].x * sin(radTheta) + box[i].y * cos(radTheta);
    box[i].z :=  box[i].z;
  end;
  setcolor(15);
  draw;
end;


begin
  init;
  setcolor(14);
  draw;
  repeat
    c := readkey;
    case c of
      ',' : rotx;
      '.' : roty;
      '/' : rotz;
      else {who gives a};
    end; {case}
  until c = 'q';
  closegraph;
end.
