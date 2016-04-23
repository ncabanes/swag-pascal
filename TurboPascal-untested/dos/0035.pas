{===========================================================================
Date: 10-02-93 (04:20)
From: BILL BUCHANAN
  To: JON DERAGON
Subj: BOOT IT!

>        Hi everyone! Just wondering if anyone out there knows how to make
> the computer do a RESET using a small Pascal routine? Need it ASAP as
> part of a pretty large project currently in the final stages of
> completion. }

program Reboot;
begin
  Inline  ($EA/$F0/$FF/$00/$F0)
end.

Procedure ColdBoot;  Assembler;
   Asm
      Xor  AX, AX
      Mov  ES, AX
      Mov  Word PTR ES:[472h],0000h   {This is NOT a WARM boot}
      Mov  AX, 0F000h
      Push AX
      Mov  AX, 0FFF0h
      Push AX
      Retf
   End;
