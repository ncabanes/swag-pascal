(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0013.PAS
  Description: Another Reboot
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{
KARIM SULTAN

Believe it or not,  Int 19h is not he way to go.  It will stimulate a warm
boot, but it is not very safe.  It doesn't do some of the shutdown work
necessary For some applications, and the preferred method is to set the Word
at location 40:72 and to jump to $FFFF:0.
Here are my Procedures For doing reboots from a Program:
}
Procedure ColdBoot;  Assembler;
Asm
  Xor  AX, AX
  Mov  ES, AX
  Mov  Word PTR ES:[472h],0000h   {This is not a WARM boot}
  Mov  AX, 0F000h
  Push AX
  Mov  AX, 0FFF0h
  Push AX
  Retf
end;

Procedure WarmBoot;  Assembler;
Asm
  Xor  AX, AX
  Mov  ES, AX
  Mov  Word PTR ES:[472h],1234h   {This is not a COLD boot}
  Mov  AX, 0F000h
  Push AX
  Mov  AX, 0FFF0h
  Push AX
  Retf
end;

