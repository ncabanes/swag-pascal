{
WILLIAM SITCH

> I've been trying For some time to get a Pascal
> Procedure that can SCALE and/or ROTATE Graphic images. if
> anyone has any idea how to do this, or has a source code,
> PLEEEAASSEE drop me a line.. THANK YOU!

Here is some code to rotate an image (in MCGA screen mode $13) ... but it has a
few drawbacks... its kinda slow and the image falls apart during rotation... it
hasn't been tested fully either...
}

Procedure rotate(x1, y1, x2, y2 : Word; ang, ainc : Real);
Var
  ca, sa :  Real;
  cx, cy :  Real;
  dx, dy :  Real;
  h, i,
  j, k   :  Word;

  pinf   :  Array [1..12500] of Record
    x, y :  Word;
    col  :  Byte;
  end;

begin
  ca := cos((ainc / 180) * pi);
  sa := sin((ainc / 180) * pi);

  For h := 1 to round(ang / ainc) do
  begin
    k  := 0;
    cx := x1 + ((x2 - x1) / 2);
    cy := y1 + ((y2 - y1) / 2);
    For i := x1 to x2 do
      For j := y1 to y2 do
      begin
        inc(k);

        dx := cx + (((i - cx) * ca) - ((j - cy) * sa));
        dy := cy + (((i - cx) * sa) + ((j - cy) * ca));

        if (round(dx) > 0) and (round(dy) > 0) and
           (round(dx) < 65000) and (round(dy) < 65000) then
        begin
          pinf[k].x   := round(dx);
          pinf[k].y   := round(dy);
          pinf[k].col := mem[$A000 : j * 320 + i];
        end
        else
        begin
          pinf[k].x   := 0;
          pinf[k].y   := 0;
          pinf[k].col := 0;
        end;
      end;

      For i := x1 to x2 do
        For j := y1 to y2 do
          mem[$A000 : j * 320 + i] := 0;

      x1 := 320;
      x2 := 1;
      y1 := 200;
      y2 := 1;
      For i := 1 to k do
      begin
        if (pinf[i].x < x1) then
          x1 := pinf[i].x;
        if (pinf[i].x > x2) then
          x2 := pinf[i].x;

        if (pinf[i].y < y1) then
          y1 := pinf[i].y;
        if (pinf[i].y > y2) then
          y2 := pinf[i].y;

        if (pinf[i].x > 0) and (pinf[i].y > 0) then
          mem[$A000 : pinf[i].y * 320 + pinf[i].x] := pinf[i].col;
      end;
  end;
end;

{
It works, but DON'T try to use it For a main module or base a Program AROUND
it... instead try to change it to suit your needs, as right now it's kinda
optimized For my needs...

Sorry For not editing it to work With any screen mode, but I just don't have
the time.  MCGA memory is a linear block of Bytes, and you can access it using:
mem[$A000:offset].  So to find the color at screen position 10,10, you would
go:

mem[$A000 : y * 320 + x]
          ^     ^     ^-- x val, 10
          |     |----- screenwidth
          |-------- y val, 10
}