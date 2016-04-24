(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0105.PAS
  Description: VGA Detection
  Author: GARETH BRAID
  Date: 05-25-94  08:24
*)

{
PF> Can anyone give me the source code for a vga detection
PF> routine taht doesnt use the bgi driver. Thanks in advance PF> for your
help.

PF> Patrick Fox

To detect a VGA card simply <g> call Interrupt 10h with ah set as 1Ah, if al is
now 1A then there is a VGA present - otherwise it must be something else...

i.e. ( regs is declared as of type registers from the DOS unit)
}

begin
  with regs do
   begin
    ah:=$1A;
    al:=00;
    intr ($10, regs);
    If al=$1A then Writeln ('VGA Detected...'); {or whatever...}
   end;
end.

or in the built-in assembler something like this...

Function isVGA:Boolean; Assembler;

asm
   mov AH, $1A
   mov al, $00
   Int $10
   cmp al, $1A
   jne @@NOVGABIOS
   mov al, 1
   jmp @@EXIT
  @@NOVGABIOS:
   mov al, 0
  @@EXIT:
end;

