{
 I've seen a lot of Spline and B-Spline code floating around.  Most of it
 is very slow even running with a math unit.  This code is quite reasonably
 fast and will draw very accurate 3-point Splines at a rate of about 180
 splines per second on my 386/40 with _no_ math unit.

 Enjoy!
}

Program CUrves; {Spline curve demo (C) 1994 by Wil Barath}
Uses Tgr12; {Mode 12h graphics unit by me available from SWAG}

Procedure Spline(x1,y1,x2,y2,x3,y3:Integer);
Var sx,sy,dx1,dx2,dy1,dy2,sdx,sdy,l:LongInt;deep,deep2,ox,oy:Integer;
Begin
{  Circle(x1,y1,3);Circle(x2,y2,3);Circle(x3,y3,3);{}
  dx1:=(x2-x1); dx2:=(x3-x2); dy1:=(y2-y1); dy2:=(y3-y2);
  Deep:=32; deep2:=Deep*Deep;
  sdx:=dx1*Pred(deep*2)-dx2;
  sdy:=dy1*Pred(deep*2)-dy2;
  Inc(dx1,dx1); Inc(dx2,dx2); Inc(dy1,dy1); Inc(dy2,dy2);
  sx:=0; sy:=0; x2:=x1; y2:=y1;
  For l:=0 to Deep do
  Begin
    ox:=x2; oy:=y2; x2:=x1+sx Div Deep2; y2:=y1+sy Div Deep2;
    Line(x2,y2,ox,oy); Inc(sx,sdx); Inc(sy,sdy);
    Inc(sdx,dx2-dx1); Inc(sdy,dy2-dy1);
  end;
  Line(x2,y2,x3,y3);{}
end;
COnst
  Tail=15;
  m:Word=1;

Var
  px:Array[0..tail*3] of Integer;py:Array[0..Tail*3] of Integer;
  dx:Array[0..2] of Integer;dy:Array[0..2] of Integer;
  l,c:Integer;
Begin
  Randomize;
  For l:=0 to 2 do
  Begin
    px[l]:=Random(600)+20;
    py[l]:=Random(400)+40;
    dx[l]:=Random(15)+3; dy[l]:=Random(12)+3;
  end;
  For l:=3 to Tail*3 do Begin px[l]:=l;py[l]:=l;end;
  VideoMode($12);
  Repeat
  Begin
    Move(px,px[3],Tail*6-6);
    Move(py,py[3],Tail*6-6);
    For l:=0 to 2 do
    Begin
      Inc(px[l],dx[l]); if (px[l]<20) or (px[l]>620) then dx[l]:=-dx[l];
      Inc(py[l],dy[l]); if (py[l]<20) or (py[l]>460) then dy[l]:=-dy[l];
    end;
    c:=m;
    SetColor(c);If m<15 then inc(m) else m:=1;
    Spline(px[0],py[0],px[1],py[1],px[2],py[2]);
{    WaitVBL;{}
    SetColor(0);
    Spline(px[Tail*3-3],py[Tail*3-3],px[Tail*3-2],
    py[Tail*3-2],px[Tail*3-1],py[Tail*3-1]);
  end;
  Until keypressed;
  readkey;
end.

