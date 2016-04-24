(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0028.PAS
  Description: Detect Which Memory
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  21:36
*)

Uses
  Dos;

Var
  HaveMem : Boolean;

procedure check_xms(VAR installed : boolean);
Var
  regs : registers;
begin
  regs.ax := $4300;
  intr($2F, regs);
  installed := regs.al = $80;
end;

procedure check_ems(VAR installed : boolean);
var
  regs : registers;
begin
  regs.ah := $46;
  intr($67, regs);
  installed := regs.ah = $00;
end;

begin
  check_xms(HaveMem);
  writeln('XMS: ',HaveMem);
  check_ems(HaveMem);
  writeln('EMS: ',HaveMem);
end.


