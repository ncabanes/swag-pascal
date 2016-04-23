{
MICHAEL NICOLAI

Re: Plotting a pixel.
In 320x200x256 mode it's very simple:
x : 0 to 319, y : 0 to 199
}

Procedure Plot(x,y Word; color : Byte);
begin
  mem[$A000 : (y * 200 + x)] := color;
end;

{You mean mem[$A000:y*320+x]:=color;  don't you? ????? ($UNTESTED)}
