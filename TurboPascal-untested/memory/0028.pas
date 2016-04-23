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