{
WILLIAM SITCH

> Okay, I've just finally got my hands on the formulas for
> doing good Graphics manipulations...well, I decided to start
> With something simple.  A rotating square.  But it DOESN'T
> WORK RIGHT.  I noticed the size seemed to shift in and out
> and a little testing showed me that instead of following a
> circular path (as they SHOULD), the corners (while spinning)
> actually trace out an OCTAGON. Why????  I've checked and
> rechecked the formula logic...It's just as I was given.  So
> there's some quirk about the code that I don't know about.
> Here's the rotating routine:

Ahhh... "rounding errors" is what my comp sci teacher explained to me, but
there isn't much you can do about it... I've included my (rather long)
spinning disc code to take a look at ... feel free to try to port it to your
application...

}

Uses
  Graph, Crt;

Procedure spin_disk;
Type
  pointdataType = Array [1..4] of Record x,y : Integer; end;
Const
  delVar = 10;

Var
  ch       :  Char;
  p, op    :  pointdataType;
  cx, cy,
  x, y, r  :  Integer;
  i        :  Integer;
  rot      :  Integer;
  tempx,
  tempy    :  Integer;
  theta    :  Real;
  down     :  Boolean;
  del      :  Real;
begin
  cx := getmaxx div 2;
  cy := getmaxy div 2;
  r := 150;
  circle(cx,cy,r);

  rot := 0;
  p[1].x := 100;  p[1].y := 0;
  p[2].x := 0;    p[2].y := -100;
  p[3].x := -100; p[3].y := 0;
  p[4].x := 0;    p[4].y := 100;
  del := 50;
  down := True;

  Repeat
    rot := rot + 2;
    theta := rot * 3.14 / 180;
    For i := 1 to 4 do
      begin
        tempx := p[i].x;
        tempy := p[i].y;
        op[i].x := p[i].x;
        op[i].y := p[i].y;
        p[i].x := round(cos(theta) * tempx - sin(theta) * tempy);
        p[i].y := round(sin(theta) * tempx + cos(theta) * tempy);
      end;
    setcolor(0);
    line(op[1].x + cx,cy - op[1].y,op[2].x + cx,cy - op[2].y);
    line(op[2].x + cx,cy - op[2].y,op[3].x + cx,cy - op[3].y);
    line(op[3].x + cx,cy - op[3].y,op[4].x + cx,cy - op[4].y);
    line(op[4].x + cx,cy - op[4].y,op[1].x + cx,cy - op[1].y);
    For i := 1 to 4 do
      line(op[i].x + cx,cy - op[i].y,cx,cy);
    setcolor(11);
    line(p[1].x + cx,cy - p[1].y,p[2].x + cx,cy - p[2].y);
    line(p[2].x + cx,cy - p[2].y,p[3].x + cx,cy - p[3].y);
    line(p[3].x + cx,cy - p[3].y,p[4].x + cx,cy - p[4].y);
    line(p[4].x + cx,cy - p[4].y,p[1].x + cx,cy - p[1].y);
    setcolor(10);
    For i := 1 to 4 do
      line(p[i].x + cx,cy - p[i].y,cx,cy);
    if (del < 1) then
      down := False
    else if (del > 50) then
      down := True;
    if (down) then
      del := del - delVar
    else
      del := del + delVar;
    Delay(round(del));
  Until (KeyPressed = True);
  ch := ReadKey;
  NoSound;
end;

Var
  Gd, Gm : Integer;

begin
  Gd := Detect;
  InitGraph(Gd, Gm, 'd:\bp\bgi');

  Spin_disk;

end.