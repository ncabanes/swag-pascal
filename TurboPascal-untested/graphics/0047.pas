{
>> I was wondering if anyone could show me the equations (and perhaps a
>> demo in standard pascal) of the following shapes. What I need to know is
>> where to plot the point.
>> Circle. (I've tried using the equation taught to me at school, but it
>> Line  (What I would like would be to be able to plot a line by giving it

There seems yet again to be enough interest/need so I'll post this stuff just
ONCE more.... somebody put this in SWAG or something.... PLEASE!!!

 [Okay Sean, here you go!  -Kerry]

You need a plot(x,y) procedure and a global color variable to use these as
posted.
}

{bresenham's line}
procedure line(x, y, x2, y2 : integer);
var
  d, dx, dy,
  ai, bi,
  xi, yi : integer;
begin
  if (x < x2) then
  begin
    xi := 1;
    dx := x2 - x;
  end
  else
  begin
    xi := - 1;
    dx := x - x2;
  end;

  if (y < y2) then
  begin
    yi := 1;
    dy := y2 - y;
  end
  else
  begin
    yi := - 1;
    dy := y - y2;
  end;

  plot(x, y);

  if dx > dy then
  begin
    ai := (dy - dx) * 2;
    bi := dy * 2;
    d  := bi - dx;
    repeat
      if (d >= 0) then
      begin
        inc(y, yi);
        inc(d, ai);
      end
      else
        inc(d, bi);

      inc(x, xi);
      plot(x, y);
    until (x = x2);
  end
  else
  begin
    ai := (dx - dy) * 2;
    bi := dx * 2;
    d  := bi - dy;
    repeat
      if (d >= 0) then
      begin
        inc(x, xi);
        inc(d, ai);
      end
      else
        inc(d, bi);

      inc(y, yi);
      plot(x, y);
    until (y = y2);
  end;
end;


{filled ellipse}
procedure disk(xc,  yc,  a,  b : integer);
var
  x, y      : integer;
  aa, aa2,
  bb, bb2,
  d, dx, dy : longint;
begin
  x   := 0;
  y   := b;
  aa  := longint(a) * a;
  aa2 := 2 * aa;
  bb  := longint(b) * b;
  bb2 := 2 * bb;
  d   := bb - aa * b + aa div 4;
  dx  := 0;
  dy  := aa2 * b;
  vLin(xc, yc - y, yc + y);

  while (dx < dy) do
  begin
    if (d > 0) then
    begin
      dec(y);
      dec(dy, aa2);
      dec(d, dy);
    end;
    inc(x);
    inc(dx, bb2);
    inc(d, bb + dx);
    vLin(xc - x, yc - y, yc + y);
    vLin(xc + x, yc - y, yc + y);
  end;

  inc(d, (3 * (aa - bb) div 2 - (dx + dy)) div 2);
  while (y >= 0) do
  begin
    if (d < 0) then
    begin
      inc(x);
      inc(dx, bb2);
      inc(d, bb + dx);
      vLin(xc - x, yc - y, yc + y);
      vLin(xc + x, yc - y, yc + y);
    end;
    dec(y);
    dec(dy, aa2);
    inc(d, aa - dy);
  end;
end;

