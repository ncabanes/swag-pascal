{
> I Write the following Procedure to shadow Text behind a box.  It works
> fine (so Far), but am not sure if there is a quicker, easier way.

You are searching through the video-RAM For the Char and Attr, you want to
change. Perhaps, it is easier and faster to use the interrupt, that returns
you the Char under the Cursor , than you can change the attribute.
}
Uses
  Dos, Crt;

Procedure Shadow(x1, y1, x2, y2 : Byte);
Var
  s, i, j : Byte;

  Procedure Z(x, y : Byte);
  Var
    r : Registers;
  begin
    r.ah := $02;
       { Function 2hex (Put Position of Cursor) }
    r.bh := 0;
    r.dh := y - 1;        { Y-Position }
    r.dl := x - 1;        { X-Position }
    intr($10,r);
    r.ah := $08;
       { Fkt. 8hex ( Read Char under cursor ) }
    r.bh := 0;
    intr($10, r);
    Write(chr(r.al));
  end;

begin
  s := TextAttr; { save Attr }
  TextAttr := 8;
  For i := y1 + 1 to y2 + 1 do
    For j := x1 + 1 to x2 + 1 do
      z(i, j);
  TextAttr := s; { Attr back }
end;

begin
  Shadow(10,10,20,20);
  ReadKey;
end.