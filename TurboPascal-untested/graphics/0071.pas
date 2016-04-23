{
From: SEAN PALMER
Subj: 3d Landscape src
---------------------------------------------------------------------------
Check it out! Clean-room reverse-engineering of something pretty damn
similar to Comanche's patented Voxel-space technology... In Turbo!!

{by Sean Palmer}
{use I,J,K,L to look around, ESC ends}

uses crt;

const
 xSize=256;           {90 degrees}
 ySize=128;           {60 degrees}
 angleMask=xSize*4-1; {xSize must be power of 2 or and's won't work}
 mapSize=128;

var
 sinTab:array[0..angleMask]of integer;  {sin(xyAngle)*$7FFF}
 tanTab:array[0..ySize-1]of integer; {tan(zAngle)*$7FFF}

 map:array[0..mapSize-1,0..mapSize-1]of byte;

type
 fixed=record case boolean of
  false:(l:longint);
  true:(f:word;i:integer);
  end;

procedure drawScene(x,y,z,rot:integer);
var lastTan,lastAngle,h:integer;
    mapTan:longint;
var scrn:word;
var color,height:byte;
var xs,ys,ds:longint;
var xp,yp,dp:fixed;
begin
 fillchar(mem[$A000:0],320*200,0);
 for h:=0 to xSize-1 do begin
  lastAngle:=0;
  scrn:=h+320*(ySize-1);
  lastTan:=tanTab[lastAngle];
  xp.i:=x; xp.f:=0;
  yp.i:=y; yp.f:=0;
  dp.l:=0;
  xs:=longint(sinTab[(h+rot-(xSize shr 1))and angleMask])*2;
  ys:=longint(sinTab[(h+rot-(xSize shr 1)+xSize)and angleMask])*2; {cos}
  ds:=$FFFE;
  inc(xp.l,xs*16);
  inc(yp.l,ys*16);
  inc(dp.l,ds*16);
  while lastAngle<ySize do begin
   inc(xp.l,xs*2);
   inc(yp.l,ys*2);
   inc(dp.l,ds*2);
   inc(xs,xs div 32);
   inc(ys,ys div 32);
   inc(ds,ds shr 5);
   if word(xp.i)>mapSize-1 then
    break;
   if word(yp.i)>mapSize-1 then
    break;
   height:=map[xp.i,yp.i];
   mapTan:=(longint(height-z)*$7FFF)div dp.i;
   color:=32+(z-height);
   while(lastTan<=mapTan)and(lastAngle<ySize)do begin
    mem[$A000:scrn]:=color;
    dec(scrn,320);
    inc(lastAngle);
    lastTan:=tanTab[lastAngle];
    end;
   end;
  end;
 end;


procedure initTables; var i:integer; r:real; begin
 for i:=0 to angleMask do
  sinTab[i]:=round(sin(i*pi/512)*$7FFF);
 for i:=0 to ySize-1 do begin
  r:=(i-64)*pi/(3*ySize);
  tanTab[i]:=round(sin(r)/cos(r)*$7FFF);
  end;
 end;

procedure initMap; var x,y:integer; begin
 for x:=0 to 127 do
  for y:=0 to 127 do
   map[x,y]:=((longint(sinTab[(y*21-12)and angleMask])+sinTab[(x*31+296)and angleMask]div 2)shr 12)+120;
 end;


var c:char;
 x,y,z,r,a:integer;
 i:word;

begin
 asm mov ax,$13; int $10; end;
 initTables;
 initMap;
 randomize;
 x:=50+random(29);
 y:=50+random(29);
 z:=125+random(10);
 r:=random(angleMask);
 a:=64;
 repeat
  drawScene(x,y,z,r);
  c:=upcase(readkey);
  case c of
   'I':if tanTab[ySize-1]<30000 then for i:=0 to ySize-1 do inc(tanTab[i],500);
   'K':if tanTab[0]>-30000 then for i:=0 to ySize-1 do dec(tanTab[i],500);
   'J':r:=(r-32)and angleMask;
   'L':r:=(r+32)and angleMask;
   end;
  until c=^[;
 textMode(lastMode);
 end.

