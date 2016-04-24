(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0003.PAS
  Description: INTREXAM.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

Okay, well, For the most part, calling an interrupt from TP is fairly
simple.  I'll use Interrupt 10h (service 0) as an example:

Procedure CallInt;
Var
  Regs : Registers;
begin
  Regs.AH := 0;       { Specify service 0 }
  Regs.AL := $13;     { Mode number = 13 hex, MCGA 320x200x256 }
  Intr($10,Regs);     { Call the interrupt }
end;

This would shift the screen to the MCGA Graphics mode specified.  Now,
it's easier to call this in BAsm (built-in Assembler):

Procedure CallInt; Assembler;
Asm
  MOV AH,0            { Specify service 0 }
  MOV AL,13h          { Mode number = 13 hex, MCGA 320x200x256 }
  inT 10h             { Call the interrupt }
end;


