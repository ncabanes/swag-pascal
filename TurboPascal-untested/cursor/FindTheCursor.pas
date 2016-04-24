(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0007.PAS
  Description: Find The Cursor
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

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
