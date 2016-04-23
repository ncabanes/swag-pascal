
{NOTE: "VS" is the video segment, $B800 for color,
$B800 for mono. Attribute is "FORECOLOR + (BACKGROUND shl 4);" it is
normally set to 8. }

procedure SetChAttr(x, y, attr: byte);
begin
  Mem[VS:160*(Y-1)+2*(X-1)+1] := attr;
end;


procedure Shade(X, Y, X2, Y2, attr: byte);
var
  Cnt: byte;
  wh: word;
begin
  for Cnt := Y+1 to y2+1 do
   begin
     SetChAttr(x2+1, cnt, attr);
     SetChAttr(x2+2, cnt, attr);
   end;

  for Cnt := x+2 to x2-1 do
   begin
     SetChAttr(Cnt, y2+1, Attr);
     SetChAttr(Cnt+1, y2+1, Attr);
   end;
end;
