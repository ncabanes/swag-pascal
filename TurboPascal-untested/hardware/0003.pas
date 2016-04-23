{
> Is there any way to find the size of each allocation Unit in a Hard drive?
}

Uses Dos;

Function clustsize (drive : Byte) : Word;
Var
  regs : Registers;
begin
  regs.cx := 0;         {set For error-checking just to be sure}
  regs.ax := $3600;     {get free space}
  regs.dx := drive;     {0=current, 1=a:, 2=b:, etc.}
  msDos (regs);
  clustsize := regs.ax * regs.cx;      {cluster size!}
end;

begin
  Writeln(ClustSize(0));
end.