(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0075.PAS
  Description: Another Bezier Curve
  Author: NICK ONOUFRIOU
  Date: 02-03-94  09:19
*)

{
From: NICK ONOUFRIOU
Subj: RIP Bezier Curves
---------------------------------------------------------------------------
SP> I can't post the code I have that IS Telegrafix-compatible (for obvious
SP> reasons) but if you post your code I can try and modify it to make it
SP> work correctly.

Here it is. It comes close, but can't get it to create the same curves that
Telegrafix creates. Thanks for any help Sean. Are you writing the RIP code
for TELIX?
}

procedure DrawBezierCurve(px1,py1,px2,py2,px3,py3,px4,py4,count : integer);

function pow(x : real; y : word) : real;
var
  nt     : word;
  result : real;
begin
 result := 1;
 for nt := 1 to y do
     result := result * x;
 pow := result;
end;

procedure Bezier(t : real; var x, y : integer);
begin
 x := round(pow(1 - t, 3) * px1 + 3 * t * pow(1 - t, 2) * px2 +
                3 * t * t * (1 - t) * px3 + pow(t, 3) * px4);
 y := round(pow(1 - t, 3) * py1 + 3 * t * pow(1 - t, 2) * py2 +
                3 * t * t * (1 - t) * py3 + pow(t, 3) * py4);
end;

var
 resolution,t : real;
 xc, yc       : integer;
begin
        if count = 0 then exit;
        resolution:=1/count;

        Moveto(px1,py1);
        t := 0;
        while t < 1 do begin
           Bezier(t, xc, yc);
           lineto(xc, yc);
           t := t + resolution;
        end;
        LineTo(px4,py4);
end;


