(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0076.PAS
  Description: Random Gaussian Variables
  Author: RANDALL ELTON DING
  Date: 08-25-94  09:08
*)

(*
From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)

>I a program I'm currently struggeling with, I need to get a random number
>from a Gaussian distribution. Anybody got any ideas or anybody able to point
>to something which does the job.

This does a pretty good job of generating a gaussian random variable
with mean `a` and standard deviation `d`.
This program also does a graphic plot to demonstrate the function.

First, here is the origional C source if the gaussian function
which I transcribed to beloved pascal..

/* ------------------------------------------------ *
 * gaussian -- generates a gaussian random variable *
 *             with mean a and standard deviation d *
 * ------------------------------------------------ */
 double gaussian(a,d)
 double a,d;
 {
   static double t = 0.0;
   double x,v1,v2,r;
   if (t == 0) {
     do {
       v1 = 2.0 * rnd() - 1.0;
       v2 = 2.0 * rnd() - 1.0;
       r = v1 * v1 + v2 * v2;
     } while (r>=1.0);
     r = sqrt((-2.0*log(r))/r);
     t = v2*r;
     return(a+v1*r*d);
   }
   else {
     x = t;
     t = 0.0;
     return(a+x*d);
   }
 }


* ----------------------------------------------------------------------
* now, the same thing in pascal
* ----------------------------------------------------------------------
*)

{$N+}
program testgaussian;

uses graph,crt;

const
  bgipath = 'e:\bp\bgi';

procedure initbgi;
  var
    errcode,grdriver,grmode: integer;

  begin
    grdriver:= detect;
    grmode:= 0;
    initgraph (grdriver,grmode,bgipath);
    errcode:= graphresult;
    if errcode <> grok then begin
      writeln ('Graphics error: ',grapherrormsg (errcode));
      halt (1);
    end;
  end;



function rnd: double;   { this isn't the best, but it works }
  var                   { returns a random number between 0 and 1 }
    i: integer;
    r: double;

  begin
    r:= 0;
    for i:= 1 to 15 do begin
      r:= r + random(10);
      r:= r/10;
    end;
    rnd:= r;
  end;



function gaussian(a,d: double): double;      { a is mean }
  const                                      { d is standard deviation }
    t: double = 0;   { pascal's equivalent to C's static variable }

  var
    x,v1,v2,r: double;

  begin
    if t=0 then begin
      repeat
        v1:= 2*rnd-1;
        v2:= 2*rnd-1;
        r:= v1*v1+v2*v2
      until r<1;
      r:= sqrt((-2*ln(r))/r);
      t:= v2*r;
      gaussian:= a+v1*r*d;
    end
    else begin
      x:= t;
      t:= 0;
      gaussian:= a+x*d;
    end;
  end;



procedure testplot;
  var
    x,mx,my,y1: word;
    y: array[1..999] of word;
              { ^^^ make this bigger if you have incredible graphics }
  begin
    initbgi;
    mx:= getmaxx+1;
    my:= getmaxy;
    fillchar(y,sizeof(y),#0);
    repeat
      x:= trunc(gaussian(mx/2,50));
      y1:= y[x];
      putpixel(x,my-y1,white);
      y[x]:= y1+1;
    until keypressed;
    closegraph;
  end;



begin
  randomize;
  testplot;
end.


