
{ Updated EGAVGA.SWG on May 26, 1995 }

{
From: ss8913@u.cc.utah.edu (Scott Stone)

Well, here it is.  A version of the unit that should calculate stuff
properly. :)  Also, it uses DOUBLE precision instead of REAL.  If it
won't work on your system (should, with the coprocessor-emulation
directive in there), then just change all the DOUBLEs back to REALs.

}
Unit Graph3d; {Version 0.02 1/12/95}

{Written 1/7/95 by Scott Stone <scott.stone@m.cc.utah.edu>
 I wrote this because nobody is willing to help a newbie who lacks this
 info, so go ahead and use it freely - I wouldn't mind a mention in your
 credits, however! }

{Keep in mind, all procedures that require inputs of an angular measurement
 require the measurement in DEGREES, due to the cosine/sine tables involved}

{This version uses DOUBLE precision, hence the new compiler directive.
 It also fixes the bug that prevents the previous version from working.}


Interface
{$N+}

Var
  sint,cost : array [0..359] of double;

function rd(radians : double) : double;
function dr(degrees : double) : double;
procedure maketables;
Procedure Rotatexy(ra : integer; ox,oy : double; var nx,ny : double);
Procedure Rotatexyz(rx,ry,rz : integer; ox,oy,oz : double; var nx,ny,nz :
double);
Procedure Rotate3X(rx : integer; ox,oy,oz : double; var nx,ny,nz : double);
Procedure Rotate3Y(ry : integer; ox,oy,oz : double; var nx,ny,nz : double);
Procedure Rotate3Z(rz : integer; ox,oy,oz : double; var nx,ny,nz : double);
Procedure C32(ox,oy,oz : double; ep : integer; var nx,ny : integer);
function arccos(ca : double) : double;
Function A2V(i1,j1,k1,i2,j2,k2 : double) : double;

Implementation

Function RD (radians : double) : double; {Converts Radians ==>> Degrees}
Begin
  rd:=((180*radians)/pi);
End;

Function DR (degrees : double) : double; {Converts Degrees =>> Radians}
Begin
  dr:=abs(degrees)*pi/180.0;
End;


Procedure MakeTables; {Makes Sine/Cosine tables for faster lookups}
Var
  cc : integer;
Begin                 {Defines SINT & COST - used in terms of degrees}
  for cc:=0 to 359 do
  begin
    sint[cc]:=sin(dr(cc));
    cost[cc]:=cos(dr(cc))
  end;
end;

Procedure Rotatexy(ra : integer; ox,oy : double; var nx,ny : double);
{Rotate a 2-D point about the origin - positive degrees are COUNTERclockwise}
{RA=amount to rotate, in degrees.  ox,oy = old X,Y.  nx,ny = new X,Y}
Begin
  nx:=(ox*(cost[ra]))-(oy*(sint[ra]));
  ny:=(ox*(sint[ra]))+(oy*(cost[ra]));
End;

Procedure Rotatexyz(rx,ry,rz : integer; ox,oy,oz : double; var nx,ny,nz :
double);
{Rotate a 3-D point.  rx,ry,rz=amount to rotate about each axis.}
{ox,oy,oz = old x,y,z.  nx,ny,nz=new x,y,z}
Var
  tx,ty,tz : double;
  tx1,ty1,tz1 : double;
Begin
  {first rotate about X-axis}
  tx:=ox;
  ty:=(oy*(cost[rx]))-(oz*(sint[rx]));
  tz:=(oy*(sint[rx]))+(oz*(cost[rx]));
  {now about the Y-axis}
  tx1:=(tx*(cost[ry]))+(tz*(sint[ry]));
  ty1:=ty;
  tz1:=-(tx*(sint[ry]))+(tz*(cost[ry]));
  {now about the Z-axis}
  nx:=(tx1*(cost[rz]))-(ty1*(sint[rz]));
  ny:=(tx1*(sint[rz]))+(ty1*(cost[rz]));
  nz:=tz1;
End;

Procedure Rotate3X(rx : integer; ox,oy,oz : double; var nx,ny,nz : double);
{Just rotate a 3-D point around X-axis - separates might be faster}
Begin
  if (rx<>0) then {don't do if rx=0 - might save some speed in some cases}
  begin
    nx:=ox;
    ny:=(oy*(cost[rx]))-(oz*(sint[rx]));
    nz:=(oy*(sint[rx]))+(oz*(cost[rx]))
  end;
End;

Procedure Rotate3Y(ry : integer; ox,oy,oz : double; var nx,ny,nz : double);
Begin
  if (ry<>0) then
  begin
    nx:=(ox*(cost[ry]))+(oz*(sint[ry]));
    ny:=oy;
    nz:=-(ox*(sint[ry]))+(oz*(cost[ry]))
  end;
end;

Procedure Rotate3Z(rz : integer; ox,oy,oz : double; var nx,ny,nz : double);
Begin
  if (rz<>0) then
  begin
    nx:=(ox*(cost[rz]))-(oy*(sint[rz]));
    ny:=(ox*(sint[rz]))+(oy*(cost[rz]));
    nz:=oz
  end;
End;

Procedure C32(ox,oy,oz : double; ep : integer; var nx,ny : integer);
{Converts 3-D point to 2-D point}
{EP = Expansion Factor - useful for 3-D starfields - set to 1 for doubleism}
Begin
  nx:=round((ox*ep)/oz);
  ny:=round((oy*ep)/oz); {have to round to integers for screen}
End; {* Note - Make sure you clip your screen points to fit screen res}

function arccos(ca : double) : double;
{While compiling this unit, TP7 said that there was no predefined ARCCOS
 function.  There is a pre-defined ARCTAN function, so this procedure
 finds the ARCCOS in terms of the ARCTAN.  This was the hardest part about
 writing this unit.  Isn't math cool? :)  BTW - if this doesn't work, let
 me know.  Better yet, let me know and tell me why it doesn't work. }

var
  r,r0,r1 : double;
begin
  r:=sqrt(1-(abs(sqr(ca))));
  r0:=r/ca;
  r1:=arctan(r0);
  arccos:=r1;
end;


Function A2V(i1,j1,k1,i2,j2,k2 : double) : double;
{Finds angle between two vectors - parameters are vector components}
Var
  theta : double;
  vm1,vm2 : double;
  dp : double;
  ff : double;
Begin
  vm1:=sqrt(abs(sqr(i1))+abs(sqr(j1))+abs(sqr(k1)));
  vm2:=sqrt(abs(sqr(i2))+abs(sqr(j2))+abs(sqr(k2)));
  dp:=(i1*i2)+(j1*j2)+(k1*k2);
  ff:=(dp/(vm1*vm2));
  theta:=arccos(ff);
  a2v:=theta;
End;


Begin
End.
