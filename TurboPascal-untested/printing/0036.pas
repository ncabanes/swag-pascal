{
From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)

All those c/pascal flames are becoming nauseating.
My kill file leaves me with about 10 articles per day now.
For people like me ignoring this B.S., here is something
for fun.

This very elegantly plots a cycloid in 3d with hidden lines.
Remember that a cycloid is what you get when you trace a single
point of a circle in rolling motion.

Email me if you would like the normal cartesian plotter.

------------------------------------------------------------------

(*  Three Dimensional Plotter (modified for this parametric equ.)
    written by Randy Ding
    randyd@alpha2.csd.uwm.edu
    original  December 1983 (UCSD pascal)
    update    April 13,1991 (turbo pascal)   *)
}
{$N+}
program plotter;

uses graph;


const
  bgipath = 'e:\bp\bgi';   { !set this to your bgi directory }


const
  displaysizex= 9.75;   { inches, for width/height ratios }
  displaysizey= 7;      { inches }
  maxrightscreen= 999;  { !make this bigger if you have incredible graphics }

type
  realtype= single;
  scrnarry= array [0..maxrightscreen] of integer;  { for hidden line data }

var
  toplim,botlim,previousx,botscreen,rightscreen: integer;
  colr: word;
  top,bot: scrnarry;
  alpha,beta,scale,centerx,centery,posx,negx,posy,negy,stepx,stepy: realtype;


procedure hideline (x,y,x2,y2: integer);
  var slope,yr: realtype;

  procedure vline (ytop,ybot: integer);     { at x with colr }
    var temp: integer;

    begin
      if (x>=0) and (x<=rightscreen) then begin
        if ytop > ybot then begin
          temp:= ytop;  ytop:= ybot;  ybot:= temp;
        end;
        if x <> previousx then begin
          toplim:= top [x];
          botlim:= bot [x];
        end;
        if ytop < top [x] then top [x]:= ytop;
        if ybot > bot [x] then bot [x]:= ybot;
        while ytop <= ybot do begin
          if (ytop < toplim) or (ytop > botlim) then putpixel (x,ytop,colr);
          ytop:= ytop+1;
        end;
      end;
      previousx:= x;
    end;

  begin
    yr:= y;
    if x <> x2 then begin
      slope:= (y2-y)/(x2-x);
      while x <> x2 do begin
        yr:= yr+slope;
        vline (y,trunc(yr));
        y:= trunc(yr);
        if x < x2 then inc(x) else dec(x);
      end;
    end;
    vline (y,y2);
  end;


procedure initline;
  var x:integer;

  begin
    for x:= 0 to rightscreen do begin
      top [x]:= botscreen+1;
      bot [x]:= -1;
    end;
  end;


{ The regular cartesian plot routine has been modified to plot this
  parametric equation and a slope counter has been added to make the
  plotting slow down near the points, helping to make them crisp.
  The cycloid parametric function: x=u-sin(u), y=cos(u) }

procedure plot;
  var
    correction,sa,ca,sb,cb,x,y,z,rho,lou,hiu,du,u,dy,oldz: realtype;
    oldx,oldy,screenx,screeny,slopecounter: integer;
    newline: boolean;
    ch: char;

  begin
    correction:= scale*(displaysizey/(botscreen+1))
                 /(displaysizex/(rightscreen+1));
    sa:= sin(alpha*pi/180);
    ca:= cos(alpha*pi/180);
    sb:= sin(beta*pi/180);
    cb:= cos(beta*pi/180);
    previousx:= -1;
    x:= posx;
    while x >= negx do begin
      newline:= true;
      y:= negy;
      while y <= posy do begin
        rho:= sqrt(sqr(x)+sqr(y));
        lou:= rho-1;
        hiu:= rho+1;
        repeat               { solve the parametric equation by iteration }
          u:= (lou+hiu)/2;
          du:= rho-(u-sin(u));   { u-sin(u) is an increasing function }
          if du>0 then lou:= u else hiu:= u;
        until abs(du) < 0.001;
        z:= 3*cos(u);   { user parametric function x=u-sin(u), y=cos(u) }
        screenx:= trunc ((y*ca-x*sa)*correction+centerx);
        screeny:= trunc (centery-((y*sa+x*ca)*sb+z*cb)*scale);
        if newline then begin
          slopecounter:= 0;
          dy:= stepy;     { make dy normal for long straight runs }
        end
        else if (z-oldz)/dy > 1.5 then begin
          slopecounter:= 5;
          dy:= stepy/10;      { make dy small close to the peaks }
        end
        else if slopecounter=0 then dy:= stepy else dec(slopecounter);
        y:= y + dy;
        oldz:= z;
        if not newline then hideline(oldx,oldy,screenx,screeny)
        else newline:= false;
        oldx:= screenx;
        oldy:= screeny;
      end;
      x:= x - stepx;
    end;
  end;


procedure setdefault;
  { with no rotation, x axis is out of the screen, y axis is to the right
    and z axis is up;  alpha and beta make the figure rotate
    (pos is clockwise) within the fixed coordinate axis
    draw figure from screen front to back for hidden lines to work properly }

  begin
    alpha:= 30;    { rotates figure clockwise about z axis }
    beta:= -40;    { rotates figure clockwise about y axis }
    scale:= 10;
    centerx:= (rightscreen+1)/2;
    centery:= (botscreen+1)/2;
    posx:= 20;   { currently set up for functions z of x,y }
    negx:= -posx;  { change user function z above in plot procedure }
    posy:= 20;
    negy:= -posy;
    stepx:= 0.5;
    stepy:= 0.1;
    colr:= white;
  end;


procedure initbgi;
  var errcode,grmode,grdriver: integer;
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


begin
  initbgi;
  botscreen:= getmaxy;
  rightscreen:= getmaxx;
  initline;
  setdefault;
  plot;
  readln;
  closegraph;
end.

