{
SEAN PALMER

I've been playing around with it as a way to make 'heat-seeking
missiles' in games. Very interesting...

What I do is have the points set up as follows:

1   : current position
2&3 : current speed + the current position
4   : destination

and update current position by indexing somewhere into the curve (like
at $100 out of $FFFF

This works very well. Problem is that I don't know of a good way to
change the speed.

Here is a simple demo that makes a dot chase the mouse cursor (needs
VGA as written) that shows what I mean.

If ANYBODY can make this work smoother or improve on it in any way I
would appreciate being told how... 8)
}

uses
  mouse, crt;  { you will need to change accesses to the mouse unit }
               { to use a mouse package that you provide }
type
  coord = record
    x, y : word;
  end;
  CurveDataRec = array [0..65521 div sizeof(coord)] of coord;

const
  nSteps = 1 shl 8;  {about 8 for smoothness (dots), 4 for speed (lines)}

var
  color : byte;
  src, spd,
  dst, mov1,
  mov2 : coord;
  i : integer;

procedure plot(x, y : word);
begin
  mem[$A000 : y * 320 + x] := color;
end;

function fracMul(f, f2 : word) : word;
Inline(
  $58/                   {pop ax}
  $5B/                   {pop bx}
  $F7/$E3/               {mul bx}
  $89/$D0);              {mov ax,dx}

function mul(f, f2 : word) : longint;
inline(
  $58/                   {pop ax}
  $5B/                   {pop bx}
  $F7/$E3);              {mul bx}


{this is the original full BSpline routine}

procedure drawBSpline(var d0 : coord; nPoints : word);
const
  nsa  = $10000 div 6;
  nsb  = $20000 div 3;
  step = $10000 div nSteps;
var
  i, xx, yy : word;
  t1, t2, t3 : word;
  c1, c2, c3, c4 : word;
  d : curveDataRec absolute d0;
begin
  t1 := 0;
  color := 32 + 2;
  for i := 0 to nPoints - 4 do
  begin
    {algorithm converted from Steve Enns' original Basic subroutine}
    repeat
      t2 := fracMul(t1, t1);
      t3 := fracMul(t2, t1);
      c1 := (integer(t2 - t1) div 2) + nsa - fracmul(nsa, t3);
      c2 := (t3 shr 1) + nsb - t2;
      c3 := ((t2 + t1 - t3) shr 1) + nsa;
      c4 := fracmul(nsa, t3);
      xx := (mul(c1, d[i].x) + mul(c2, d[i + 1].x) +
             mul(c3, d[i + 2].x) + mul(c4, d[i + 3].x)) shr 16;
      yy := (mul(c1, d[i].y) + mul(c2, d[i + 1].y) +
             mul(c3, d[i + 2].y) + mul(c4, d[i + 3].y)) shr 16;
      plot(xx, yy);
      inc(t1, step);
    until t1 = 0;  {this is why nSteps must be even power of 2}
    inc(color);
  end;
end;


{find 1/nth point in BSpline}  {this is what does the B-Spline work}

procedure moveTowards(d1, d2, d3, d4 : coord; t1 : word; var mov : coord);
const
  nsa = $10000 div 6;
  nsb = $20000 div 3;
var
  t2, t3 : word;
  c1, c2,
  c3, c4 : word;
begin
  t2 := fracMul(t1, t1);
  t3 := fracMul(t2, t1);
  c1 := (integer(t2 - t1) div 2) + nsa - fracmul(nsa, t3);
  c2 := (t3 shr 1) + nsb - t2;
  c3 := ((t2 + t1 - t3) shr 1) + nsa;
  c4 := fracmul(nsa, t3);
  mov.x := (mul(c1, d1.x) + mul(c2, d2.x) + mul(c3, d3.x) + mul(c4, d4.x)) shr 16;
  mov.y := (mul(c1, d1.y) + mul(c2, d2.y) + mul(c3, d3.y) + mul(c4, d4.y)) shr 16;
end;

begin
  asm
    mov ax, $13
    int $10
  end;  {init vga/mcga graphics}

  {mouse.init;}
  mshow;

  src.x := 5;
  src.y := 5;
  spd.x := 5;
  spd.y := 5;
  dst.x := 315;
  dst.y := 190;

  repeat
   {for i:=0 to 23 do begin}
   { color:=i+32;}
   { inc(dst.x,i);}
    delay(10);
    {mouse.check;}  {this loads Mouse.X, Mouse.Y, Mouse.Button from driver}
    mhide;
    color := 15;
    plot(src.x, src.y);
    color := 14;
    plot(spd.x, spd.y);
    dst.x := mousex shr 1;
    dst.y := mousey;
    color := 1;
    plot(dst.x, dst.y);
    mshow;

    {the parameters in these next two lines can be changed}
    {I have played with almost all possible combinations and}
    {most work, but not well, so don't be afraid to play around}
    {But I think an entirely different approach is needed for the}
    {second moveTowards..}

    moveTowards(src, src, spd, dst, $0010, mov1);
    moveTowards(src, spd, dst, dst, $5000, mov2);
    src := mov1;
    longint(spd) := (longint(spd) * 7 + longint(mov2)) shr 3 and $1FFF1FFF;
  until 1=0;

  mhide;

  asm
    mov ax, 3
    int $10
  end; {text mode again}
end.

