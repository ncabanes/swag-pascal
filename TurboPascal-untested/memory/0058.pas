

Uses Dos;

Procedure Flush_Cache;
{ This will work with SmartDrive 4.00+ and PC-Cache 8.0+. }

Var Reg: Registers;

Begin
  Reg.AX:=$4A10;
  Reg.BX:=$0001;
  Intr($2F,Reg);
End;

BEGIN
Flush_Cache;
END.

