(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0006.PAS
  Description: FREEMEM1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

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
