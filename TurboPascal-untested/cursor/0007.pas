Uses
  Dos;

Procedure FindXY(Var X, Y : Byte; Page : Byte);
{X = Row of Cursor}
{Y = Colum of Cursor}
{Page = Page Nummber}
Var
  Regs : Registers;
begin
  Regs.Ah := 3;
  Regs.Bh := Page;
  intr($10, Regs);
  X := Regs.Dl;
  Y := Regs.Dh;
end;
