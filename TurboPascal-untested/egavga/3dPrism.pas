(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0171.PAS
  Description: 3D Prism
  Author: KRISJANIS GALE
  Date: 11-26-94  04:59
*)

program Prism3D;
{Author: Krisjanis Gale, 10/06/94}
{MY FIRST WORKING 3D OBJECT!}
uses
    Gfx2,
    Crt;
{<■────────────────────────────────────────────────────────────────────────■>}
type
    vector=record
             x,y,z:integer;
           end;
{<■────────────────────────────────────────────────────────────────────────■>}
var
   deltaPRISM:array[0..11,0..1] of vector;
   ValCos:array[0..359] of real;
   ValSin:array[0..359] of real;
   k,sc:integer;
{<■────────────────────────────────────────────────────────────────────────■>}
const
     Zscale=256;  {total z-coord depth}
     deltaZ=256;  {by how much to move points "back" in z-plane}
     {A simple 8-sided prism}
     prism:array[0..11,0..1] of vector=
       ((( x:0;  y:0;  z:1 ),( x:1;  y:0;  z:0 )),
        (( x:0;  y:0;  z:1 ),( x:0;  y:1;  z:0 )),
        (( x:0;  y:0;  z:1 ),( x:-1; y:0;  z:0 )),
        (( x:0;  y:0;  z:1 ),( x:0;  y:-1; z:0 )),
        (( x:0;  y:0;  z:-1),( x:1;  y:0;  z:0 )),
        (( x:0;  y:0;  z:-1),( x:0;  y:1;  z:0 )),
        (( x:0;  y:0;  z:-1),( x:-1; y:0;  z:0 )),
        (( x:0;  y:0;  z:-1),( x:0;  y:-1; z:0 )),
        (( x:1;  y:0;  z:0 ),( x:0;  y:1;  z:0 )),
        (( x:0;  y:1;  z:0 ),( x:-1; y:0;  z:0 )),
        (( x:-1; y:0;  z:0 ),( x:0;  y:-1; z:0 )),
        (( x:0;  y:-1; z:0 ),( x:1;  y:0;  z:0 )));
{<■────────────────────────────────────────────────────────────────────────■>}
procedure Get2D(x,y,z:integer;var sX:integer;var sY:byte);
begin
     sX:=trunc(((x*Zscale)/z)+160);
     sY:=trunc(((y*Zscale)/z)+100)
end;
{<■────────────────────────────────────────────────────────────────────────■>}
function GetCos(i:integer):real;
var
   c:real;
begin
     if i<0 then
        i:=-(abs(i) mod 360)+360;
     c:=ValCos[i mod 360];
     GetCos:=c
end;
{<■────────────────────────────────────────────────────────────────────────■>}
function GetSin(i:integer):real;
var
   s:real;
begin
     if i<0 then
        i:=-(abs(i) mod 360)+360;
     s:=ValSin[abs(i) mod 360];
     GetSin:=s
end;
{<■────────────────────────────────────────────────────────────────────────■>}
procedure Rot3D(var X,Y,Z:integer;rotX,rotY,rotZ:integer);
  {Trigonometrically rotate an (x,y,z) coordinate by}
  {degrees of rotation on the three axes; K.Gale, 9/21/94}
var
   cosX,sinX,cosY,sinY,cosZ,sinZ:real;
   tX,tY,tZ:integer;
begin
     cosX:=GetCos(rotX);
     sinX:=GetSin(rotX);
     cosY:=GetCos(rotY);
     sinY:=GetSin(rotY);
     cosZ:=GetCos(rotZ);
     sinZ:=GetSin(rotZ);
     tX:=X; tY:=Y; tZ:=Z;
     tX:=trunc(X*cosY-Z*sinY);   {yaw}
     tZ:=trunc(X*sinY+Z*cosY);
     X:=trunc(tX*cosZ+Y*sinZ);   {pitch}
     tY:=trunc(Y*cosZ-tX*sinZ);
     Z:=trunc(tZ*cosX-tY*sinX);  {roll}
     Y:=trunc(tZ*sinX+tY*cosX)
end;

procedure DefinePrism(rotX,rotY,rotZ:integer;scale:byte);
var
   x,y,z:integer;
   i1:0..11;
   i2:0..1;
begin
     for i1:=0 to 11 do
     for i2:=0 to 1 do
     begin
          x:=(prism[i1,i2].x)*scale;
          y:=(prism[i1,i2].y)*scale;
          z:=(prism[i1,i2].z)*scale;
          Rot3D(x,y,z,rotX,rotY,rotZ);
          deltaPRISM[i1,i2].x:=x;
          deltaPRISM[i1,i2].y:=y;
          deltaPRISM[i1,i2].z:=z+deltaZ
     end
end;
{<■────────────────────────────────────────────────────────────────────────■>}
procedure DrawPrism(col:byte;where:word);
var
   i:0..11;
   x,y,z,sX1,sX2:integer;
   sY1,sY2:byte;
begin
     for i:=0 to 11 do
     begin
          x:=deltaPRISM[i,0].x;
          y:=deltaPRISM[i,0].y;
          z:=deltaPRISM[i,0].z;
          Get2D(x,y,z,sX1,sY1);
          x:=deltaPRISM[i,1].x;
          y:=deltaPRISM[i,1].y;
          z:=deltaPRISM[i,1].z;
          Get2D(x,y,z,sX2,sY2);
          line(sX1,sY1,sX2,sY2,col,where)
     end
end;
{<■────────────────────────────────────────────────────────────────────────■>}
begin

     for k:=0 to 359 do
     begin
          ValCos[k]:=cos(Deg2Rad(k));
          ValSin[k]:=sin(Deg2Rad(k))
     end;

     SetMCGA;
     DefinePrism(0,0,0,64);
     for k:=0 to 90 do
     begin
          DrawPrism(0,vga);
          DefinePrism(k div 6,k div 6,k*4,86);
          DrawPrism(15,vga)
     end;
     for k:=15 to 90 do
     begin
          DrawPrism(0,vga);
          DefinePrism(k,k,k,86);
          DrawPrism(15,vga)
     end;
     for k:=90 downto 0 do
     begin
          DrawPrism(0,vga);
          DefinePrism(k*4,k*2,k*8,86);
          DrawPrism(15,vga)
     end;
     while not keypressed do;
     SetText
end.

