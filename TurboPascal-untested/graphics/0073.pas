{
From: SEAN PALMER
Subj: RIP Bezier Curve
---------------------------------------------------------------------------
 NO> Does anyone have any code for constructing a RIP Bezier curve that is
 NO> exactly the same as the one used by Telegrafix developers. I have some
 NO> code that comes close, but close isn't good enough. I need this to be
 NO> dead on accurate.
 NO> PS. I'm willing to share my code with others that are interested in
 NO> RIP.

{Public domain by Sean Palmer}
{converted from Steve Enns' original Basic subroutines by Sean Palmer}

var color:byte;
procedure plot(x,y:word);begin
 mem[$A000:y*320+x]:=color;
 end;

type
 coord=record x,y:integer; end;
 CurveDataRec=array[0..65521 div sizeof(coord)]of coord;

procedure drawBSpline(var d0:coord;nPoints,nSteps:word);
 const nsa=1/6; nsb=2/3;
 var
  i,i2,xx,yy:integer;
  t,ta,t2,t2a,t3,t3a,nc1,nc2,nc3,nc4,step:real;
  d:curveDataRec absolute d0;
begin
 step:=1/nSteps;
 for i:=0 to nPoints-4 do begin
  color:=i+32+2;
  t:=0.0;
  for i2:=pred(nSteps)downto 0 do begin
   t:=t+step;
   ta:=t*0.5; t2:=t*t; t2A:=t2*0.5; t3:=t2*t; t3A:=t3*0.5;
   nc1:=-nsa*t3+t2A-ta+nsa;
   nc2:=t3a-t2+nsb;
   nc3:=-t3a+t2a+ta+nsa;
   nc4:=nsa*t3;
   xx:=round(nc1*d[i].x+nc2*d[succ(i)].x+nc3*d[i+2].x+nc4*d[i+3].x);
   yy:=round(nc1*d[i].y+nc2*d[succ(i)].y+nc3*d[i+2].y+nc4*d[i+3].y);
   plot(xx,yy);
   end;
  end;
 end;

procedure drawBezier(var d0:coord;nPoints,nSteps:word);
 const nsa=1/6; nsb=2/3;
 var
  i,i2,i3,xx,yy:integer;
  t,tm3,t2,t2m3,t3,t3m3,nc1,nc2,nc3,nc4,step:real;
  d:curveDataRec absolute d0;
begin
 step:=1/nSteps;
 for i2:=0 to pred(nPoints) div 4 do begin
  i:=i2*4;
  t:=0.0;
  for i3:=pred(nSteps) downto 0 do begin
   t:=t+step;
   tm3:=t*3.0; t2:=t*t; t2m3:=t2*3.0; t3:=t2*t; t3m3:=t3*3.0;
   nc1:=1-tm3+t2m3-t3;
   nc2:=t3m3-2.0*t2m3+tm3;
   nc3:=t2m3-t3m3;
   nc4:=t3;

   xx:=round(nc1*d[i].x+nc2*d[succ(i)].x+nc3*d[i+2].x+nc4*d[i+3].x);
   yy:=round(nc1*d[i].y+nc2*d[succ(i)].y+nc3*d[i+2].y+nc4*d[i+3].y);
   plot(xx,yy);
   end;
  end;
 end;

const numpoints=40;

var c:array[-1..2+numPoints]of coord;
var i:integer;
begin
 asm mov ax,$13; int $10; end;  {init vga/mcga graphics}
 randomize;
 for i:=1 to numPoints do with c[i] do begin
  x:=i*(319 div numPoints);    {for precision demo}
 {x:=random(320);}             {for fun demo}
  y:=random(200);
  end;
 for i:=1 to numPoints div 2 do c[i*2+1].y:=c[i*2].y;    {fit closer}
 for i:=1 to numPoints do with c[i] do begin color:=i+32; plot(x,y); end;
 c[-1]:=c[1]; c[0]:=c[1];  {replicate end points so curves fit to input}
 c[numPoints+1]:=c[numPoints]; c[numPoints+2]:=c[numPoints];
 drawBSpline(c[-1],numPoints+4,256); {set third parm to 256 for precision, 64 f}
 readln;
 asm mov ax,3; int $10; end;  {text mode again}
 end.

