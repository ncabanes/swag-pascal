(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0166.PAS
  Description: Line & Circle routines
  Author: ALLYN CROSS
  Date: 02-28-95  10:06
*)

{
You asked for =F=A=S=T This line procedure is quite fast considering it
is done in Pascal and not assembler.
The Rectangle works well also.
Sorry my Circle routine is rather Slow and Does not make a perfect (or
fairly perfect) circle so I will not enclose it. <G>

Where is a word segment to a screen address.
You can define the VGAScreen's address like this.
Const  VGASCREEN = $a000;
}

Procedure line(a,b,c,d,col:integer;Where:Word);
  { This draws a line from a,b to c,d of color col. }
Function sgn(a:real):integer;
   BEGIN
        if a>0 then sgn:=+1;
        if a<0 then sgn:=-1;
        if a=0 then sgn:=0;
   END;
var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
BEGIN
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := INT(m / 2);
     FOR i := 0 TO round(m) DO
     BEGIN
          putpixel(a,b,col,where);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a +round(d1x);
               b := b + round(d1y);
          END
          ELSE
          BEGIN
               a := a + round(d2x);
               b := b + round(d2y);
          END;
     END;
END;

Procedure Rect(x1,y1,x2,y2,Color : integer;Where:word);
begin
     Line(x1,y1,x2,y1,color,Where);
     Line(x1,y1,x1,y2,color,where);
     Line(x2,y1,x2,y2,color,where);
     Line(x1,y2,x2,y2,color,where);
 
end;

