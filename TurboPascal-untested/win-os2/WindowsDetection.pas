(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0033.PAS
  Description: Windows Detection
  Author: ANDREW EIGUS
  Date: 08-24-94  17:55
*)


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
