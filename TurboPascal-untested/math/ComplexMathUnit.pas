(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0066.PAS
  Description: Complex Math Unit
  Author: STEVE ROGERS
  Date: 05-25-94  08:02
*)


{Just for grins, here's a complex number unit I wrote come time back:}

unit complex;
(*
 polar/rectangular conversions and complex math
 Steve Rogers, ~1993
*)

{----------------------}
interface

type
  tComplex=record
    r,             { real component }
    x              { imaginary component }
      : real;
  end;

procedure r2p(var r,p : tComplex);
procedure p2r(var p,r : tComplex);
procedure c_add(var c1,c2,c3 : tComplex);
procedure c_sub(var c1,c2,c3 : tComplex);
procedure c_mult(var c1,c2,c3 : tComplex);
procedure c_div(var c1,c2,c3 : tComplex);

implementation

const
  RADS=0.0174532; { degree to radian conversion constant }

{----------------------}
procedure r2p(var r,p : tComplex);
{ returns polar in degrees in p, given rectangular in r }
begin
  p.r:= sqrt(sqr(r.r)+sqr(r.x));
  p.x:= arctan(r.x/r.r)/RADS;
end;

{----------------------}
procedure p2r(var p,r : tComplex);
{ returns rectangular in r, given polar in degrees in p }
begin
  r.r:= p.r*cos(p.x*RADS);
  r.x:= p.r*sin(p.x*RADS);
end;

{----------------------}
procedure c_add(var c1,c2,c3 : tComplex);
{ adds c2 to c1, places result in c3 }
begin
  c3.r:= c1.r+c2.r;
  c3.x:= c1.x+c2.x;
end;

{----------------------}
procedure c_sub(var c1,c2,c3 : tComplex);
{ subtracts c2 from c1, places result in c3 }
begin
  c3.r:= c1.r-c2.r;
  c3.x:= c1.x-c2.x;
end;

{----------------------}
procedure c_mult(var c1,c2,c3 : tComplex);
{ multiplies c1 by c2, places result in c3  }
begin
  c3.r:= (c1.r*c2.r)-(c1.x*c2.x);
  c3.x:= (c1.r*c2.x)+(c1.x*c2.r);
end;

{----------------------}
procedure c_div(var c1,c2,c3 : tComplex);
{ divides c1 by c2, places result in c3  }
var
  p1,p2,p3 : tComplex;

begin
  r2p(c1,p1);                          { convert c1 to polar form }
  r2p(c2,p2);                          { convert c2 to polar form }
  p3.r:= p1.r/p2.r;                    { divide real component    }
  p3.x:= p1.x-p2.x;                    { subtract imaginary component }
  if (p3.x<0) then p3.x:= p3.x+180;    { Pretty it up                 }
  p2r(p3,c3);                          { convert c3 back to rectangular }
end;

