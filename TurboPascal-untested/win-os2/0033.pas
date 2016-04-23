
Function RunningUnderMSWindows : boolean; assembler;
Asm
  MOV AX,1600h
  INT 2Fh
End; { RunningUnderMSWindows }

or

Function RunningUnderMSWindows : boolean;
var Regs : registers;
Begin
  Regs.AX := $1600;
  Intr($2F, Regs);
  RunningUnderMSWindows := Boolean(Regs.AL)
End; { RunningUnderWindows }

