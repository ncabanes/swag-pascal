{
Does anyone have any routines to find the available memory outside of the
heap ?
}

Function GetFreeMemory : LongInt;
Var
  Regs : Registers;
begin
  Regs.AH := $48;
  Regs.BX := $FFFF;
  Intr($21,Regs);
  GetFreeMemory := LongInt(Regs.BX)*16;
end;
{

This Procedure tries to allocate 1MB memory (what's impossible).
Dos will give you the maximum of free memory back.
}