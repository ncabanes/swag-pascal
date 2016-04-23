{
> I am writing some Pascal Units for speech synthesis to be added
> to a DOS based application. In a part of the application, character
> strings are written to the screen. I need to capture those
> strings from the video buffer and pass them as parameters to
> some functions. How do I do this? If anyone can provide code,
> I would really appreciate it!

Well, that's easy, with an CGA/EGA/VGA graphics card, the video
memory resides at $B800:0000, and is always Character-Attribute,
two bytes, so to grab something from screen try this:
}

function onscreen(where_x, where_y, how_long : byte);
var
  dumb : string;
  x    : word;
begin
  dumb := '';
  for x := 0 to how_long - 1 do
    dumb := dumb + chr(mem[$b800 : where_y * 160 + (where_x + x * 2)]);
  onscreen := dumb;
end.
