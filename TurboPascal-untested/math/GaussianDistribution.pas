(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0085.PAS
  Description: Gaussian Distribution
  Author: RANDALL ELTON DING
  Date: 11-26-94  05:00
*)

{
>Now I need a fast way of generating random numbers in Gaussian Distribution

This is my code for gaussian and uniform distribution.
After the unit there is a graphic test program.

From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)
}

unit rndgauss;


interface


function rnd: double;                  { returns uniform [0..1] }

function gauss(a,d: double): double;   { a is mean, d is std deviation }


implementation


function rnd: double;
  const
    bias = 1023;

  var
    data: record
            b: byte;
            d: double;
          end;
    x: array[0..8] of byte absolute data;
    e,i,j: word;

  begin
    for i:= 0 to 7 do x[i]:= lo(random(256));
    e:= bias;
    repeat
      j:= 0;
      for i:= 0 to 7 do begin
        j:= (x[i] shl 1) + hi(j);
        x[i]:= lo(j);
      end;
      e:= e-1;
      if (bias-e) mod 8 = 0 then x[0]:= lo(random(256));
    until (x[7] and $10) = $10;
    x[7]:= (x[7] and $0F) or lo(e shl 4);
    x[8]:= lo(e shr 4);
    rnd:= data.d;
  end;



function gauss(a,d: double): double;
  const
    t: double = 0;

  var
    v1,v2,r: double;

  begin
    if t=0 then begin
      repeat
        v1:= 2*rnd-1;
        v2:= 2*rnd-1;
        r:= v1*v1+v2*v2
      until r<1;
      r:= sqrt((-2*ln(r))/r);
      t:= v2*r;
      gauss:= a+v1*r*d;
    end
    else begin
      gauss:= a+t*d;
      t:= 0;
    end;
  end;



begin
end.


{---------------------- cut ---------------------------------}


program gaussiantest;

uses crt,graph,rndgauss;

const
  bgipath = 'c:\bp\bgi';
  largestx = 999;


procedure testplot;
  var
    htarry: array[0..largestx] of integer;
    x,y,w,h,m,v: word;

  begin
    fillchar(htarry,sizeof(htarry),#0);
    w:= getmaxx+1;
    h:= getmaxy;
    m:= getmaxx div 2;
    v:= getmaxx div 8;
    while not keypressed do begin
      x:= trunc(gauss(m,v));
      if x<=largestx then begin
        y:= htarry[x];
        if y<=h then begin
          putpixel(x,h-y,white);
          htarry[x]:= y+1;
        end;
      end;
    end;
  end;



procedure initbgi;
  var errcode,grmode,grdriver: integer;
  begin
    grdriver:= detect;
    initgraph (grdriver,grmode,bgipath);
    errcode:= graphresult;
    if errcode <> grok then begin
      writeln ('Graphics error: ',grapherrormsg (errcode));
      halt (1);
    end;
  end;



begin
  initbgi;
  testplot;
  closegraph;
end.


