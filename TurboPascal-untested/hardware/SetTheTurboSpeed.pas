(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0011.PAS
  Description: Set the TURBO speed
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  22:08
*)

{
 Does anyone out there know how to set the Software Turbo Speed on Mother
 boards without hitting the Turbo Switch or the <Ctrl> <Alt> <-> key to
 slow the system and or Speed it up again? Thanks...
}

Uses
  Dos;

Procedure SetSpeed(Turbo : Boolean);
Var
  Regs   : Registers;
  OldMem : Byte;

begin
  {OldMem := Mem[$40 : $17];}
  If Turbo then
    Regs.AL := 78
  else
    Regs.AL := 74;

  {Mem[$40 : $17] := 140;}
  Regs.AH := $4F;
  Intr($15, Regs);
  {Mem[$40 : $17] := OldMem;}
end;

begin
  SetSpeed(False);
end.

