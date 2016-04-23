{
I have a nifty all integer scale routine for vga 320x200 that I wouldn't
mind seeing in swag.  It is really a pretty simple scale, and demonstrates
the principle of an all-integer approach clearly.  I'll try to attach it to this
message.


this is a nifty little scale procedure I dreamed up while I was bored
one day.  It uses an all integer approach and I think it is roughly as
fast as gfx, although it doesn't support scaling backwards like gfx
does.  this is free for all to use.}

var
  scarr : record
            x,y : array[0..320] of word;
          end;


function min(x,y:word):word;
begin
  if x < y then min := x else min := y;
end;

procedure scalepic(x1,y1,x2,y2:word; sxsize,sysize:word; var picdata);

{
 (x1,y1)(x2,y2) top left and bottom right corners of DESTINATION rect.
 sxsize,sysize is the x and y sizes of the SOURCE image
 picdata is your SOURCE picture.}
var
  s1,o1,x,y,a,b,c,d : word;
  ax,ay : boolean;
begin
  s1 := seg(picdata);
  o1 := ofs(picdata);
  if (x2 = x1) or (y2 = y1) then exit;
  for x := 0 to x2 - x1 do
    scarr.x[x] := longint(x)*longint(sxsize) div (x2-x1);
  {you can remove the typecasting ONLY if you know you won't be
    scaling to a DESTINATION of over 255 pixels.  otherwise, you'll get
    a buncha junk}
  
  for x := 0 to y2 - y1 do
    scarr.y[x] := x*sysize div (y2-y1);
  for x := x1 to min(x2-1,317) do
    for y := y1 to min(y2,199) do
      {vseg is a word denoting the segment of your virtual screen}
      mem[vseg:y*320+x] := mem[s1:o1+scarr.y[y-y1]*sxsize+scarr.x[x-x1]];
end;
