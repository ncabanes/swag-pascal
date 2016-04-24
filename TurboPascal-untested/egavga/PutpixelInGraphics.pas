(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0022.PAS
  Description: PUTPIXEL in Graphics
  Author: MICHAEL NICOLAI
  Date: 05-28-93  13:39
*)

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
