Function DnCase(Ch: Char): Char;
Var
  n : Byte Absolute ch;
begin
  Case ch of
    'A'..'Z': n := n or 32;
  end;
  DnCase := chr(n);
end;
