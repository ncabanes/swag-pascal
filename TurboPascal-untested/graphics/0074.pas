{
From: SCOTT BRADSHAW
Subj: RIP BEZIER CURVES
---------------------------------------------------------------------------
Well, I had a whole RIP unit I made for Turbo Pascal over the modem,
but it got lost in a HD crash. I am really not that interested in
RIP anymore, but I will give you mu source to the Bezier Curve. It
should be pretty close to what your looking for...
}
program bezier;
uses graph,crt;

procedure Bezier_2D_Curve( x, y, cx,cy,a,b,ca,cb:integer;incr:real);
var
   qx, qy :real;
   q1, q2, q3, q4:real;
   plotx, ploty:integer;
   t:real;

    begin
      t := 0;
    while (t <= 1) do begin
      q1 := t*t*t*-1 + t*t*3 + t*-3 + 1;
      q2 := t*t*t*3 + t*t*-6 + t*3;
      q3 := t*t*t*-3 + t*t*3;
      q4 := t*t*t;
      qx := q1*x + q2*cx + q3*a + q4*ca;
      qy := q1*y + q2*cy + q3*b + q4*cb;
      plotx := round(qx);
      ploty := round(qy);
      putpixel( plotx, ploty, 15);
      t := t + incr;
   end;
end;

var gd,gm:integer;
    c:char;
begin
   gd := VGA;
   gm := VGAHI;
   initgraph(gd,gm,'\turbo\tp');
   setcolor( BLUE );
   Bezier_2D_Curve( 100, 400, 25, 450, 120, 275, 300, 455,0.003 );
   c:=readkey;
   Bezier_2D_Curve( 310, 200, 360, 150, 510, 200, 460, 250,0.003 );
   c:=readkey;
end.

