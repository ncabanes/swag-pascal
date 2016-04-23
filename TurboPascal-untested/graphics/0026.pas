{
SEAN PALMER

I was just toying around With a B-Spline curve routine I got out of an
old issue of Byte, and thought it was pretty neat. I changed it to use
fixed point fractions instead of Reals, and optimized it some...

by Sean Palmer
public domain
}

Var
  color : Byte;
Procedure plot(x, y : Word);
begin
  mem[$A000 : y * 320 + x] := color;
end;

Type
  coord = Record
    x, y : Word;
  end;

  CurveDataRec = Array [0..65521 div sizeof(coord)] of coord;

Function fracMul(f, f2 : Word) : Word;
Inline(
  $58/                   {pop ax}
  $5B/                   {pop bx}
  $F7/$E3/               {mul bx}
  $89/$D0);              {mov ax,dx}

Function mul(f, f2 : Word) : LongInt;
Inline(
  $58/                   {pop ax}
  $5B/                   {pop bx}
  $F7/$E3);              {mul bx}


Const
  nSteps = 1 shl 8;  {about 8 For smoothness (dots), 4 For speed (lines)}

Procedure drawBSpline(Var d0 : coord; nPoints : Word);
Const
  nsa  = $10000 div 6;
  nsb  = $20000 div 3;
  step = $10000 div nSteps;
Var
  i, xx, yy,
  t1, t2, t3,
  c1, c2, c3, c4 : Word;

  d : curveDataRec Absolute d0;

begin
  t1 := 0;
  color := 32 + 2;

  For i := 0 to nPoints - 4 do
  begin

   {algorithm converted from Steve Enns' original Basic subroutine}

    Repeat
      t2 := fracMul(t1, t1);
      t3 := fracMul(t2, t1);
      c1 := (Integer(t2 - t1) div 2) + nsa - fracmul(nsa, t3);
      c2 := (t3 shr 1) + nsb - t2;
      c3 := ((t2 + t1 - t3) shr 1) + nsa;
      c4 := fracmul(nsa, t3);
      xx := (mul(c1, d[i].x) + mul(c2, d[i + 1].x) +
             mul(c3, d[i + 2].x) + mul(c4, d[i + 3].x)) shr 16;
      yy := (mul(c1, d[i].y) + mul(c2, d[i + 1].y) +
             mul(c3, d[i + 2].y) + mul(c4, d[i + 3].y)) shr 16;
      plot(xx, yy);
      inc(t1, step);
    Until t1 = 0;  {this is why nSteps must be even power of 2}
   inc(color);
   end;
end;

Const
  pts = 24; {number of points} {chose this because of colors}

Var
  c : Array [-1..2 + pts] of coord;
  i : Integer;
begin
  Asm
    mov ax, $13
    int $10
  end;  {init vga/mcga Graphics}
  randomize;
  For i := 1 to pts do
  With c[i] do
  begin
    {x:=i*(319 div pts);}    {for precision demo}
    x := random(320);               {for fun demo}
    y := random(200);
  end;
  {for i:=1 to pts div 2 do c[i*2+1].y:=c[i*2].y;}    {fit closer}
  For i := 1 to pts do
  With c[i] do
  begin
    color := i + 32;
    plot(x, y);
  end;
  {replicate end points so curves fit to input}
  c[-1] := c[1];
  c[0]  := c[1];
  c[pts + 1] := c[pts];
  c[pts + 2] := c[pts];
  drawBSpline(c[-1], pts + 4);
  readln;
  Asm
    mov ax, 3
    int $10
  end;  {Text mode again}
end.
