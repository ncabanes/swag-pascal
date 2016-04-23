{
> Could someone please post an Asm equivalent of
> Repeat Until KeyPressed;

Well, here it is using the Dos Unit instead of the Crt....  :)
}
Uses Dos;
Var
  r : Registers;

Function _ReadKey : Char;
begin
  r.ax := $0700;
  intr($21, r);
  _ReadKey := chr(r.al);
end;

Function _KeyPressed : Boolean;
begin
  r.ax := $0b00;
  intr($21,r);
  if r.al = 255 then
    _KeyPressed := True
  else
    _KeyPressed := False;
end;
begin
  Repeat Until _keypressed;
end.