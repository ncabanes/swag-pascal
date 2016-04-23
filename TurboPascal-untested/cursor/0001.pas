{> And how can I hide my cursor ? I know it's something With INT 10 but
> that's all I know...

Try this:
SType 'C' or 'M' - Color or monchrome display
Size 'S' or 'B' or 'O' cursor small, big, or none (invisible)
}
Uses Dos;

Procedure CursorSize(SType, Size : Char);

Var
  Regs : Registers;
  i : Integer;

begin
  Size := UpCase(Size);
  if UpCase(SType) = 'M' then
    i := 6
  ELSE
   i := 0;

Regs.AH := $01;
CASE Size of
'O' :
  begin
   Regs.CH := $20;
   Regs.CL := $20;
  end;
'B' :
  begin
   Regs.CH := $0;
   Regs.CL := $7 + i;
  end;
'S' :
  begin
   Regs.CH := $6+i;
   Regs.CL := $7+i;
  end;
end;
Intr($10, Regs);
end;

begin
  CursorSize('C','B');
  readln;
end.