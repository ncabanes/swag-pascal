{
I Write the following Procedure to shadow Text behind a box.  It works
fine (so Far), but am not sure if there is a quicker, easier way.
}

Procedure Shadow(x, y, xlength, ylength : Byte);
Var
  xshad,
  yshad : Word;
  i     : Byte;
begin
  xlength := xlength shl 1;     { xlength * 2 }
  xshad := ((x*2)+(y*160)-162) + ((ylength+1) * 160) + 4;   { x coord }
  yshad := ((x*2)+(y*160)-162) + (xlength);                 { y coord }
  if Odd(Xshad) then Inc(XShad);            { we want attr not Char }
  if not Odd(YShad) then Inc(YShad);        { " }
  For i := 1 to xlength Do
    if Odd(i) then
      Mem[$B800:xshad+i] := 8;              { put x shadow }
  For i := 1 to ylength Do
  begin
    Mem[$B800:yshad+(i*160)] := 8;          { put y shadows }
    Mem[$B800:yshad+2+(i*160)] := 8
  end
end;
