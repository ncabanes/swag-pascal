(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0049.PAS
  Description: Clearing the Screen
  Author: MARK LEWIS
  Date: 01-27-94  11:55
*)

{
> If you're not using the CRT unit, that should write through the ansi
> driver just fine.  I don't know about the codes you used, but they
> won't be written directly to video memory.  If you're using the CRT
> unit then he's right, it won't work without a slight modification.
 >My whole point behind this was that you DON'T need CRT to
> clear the screen like this.  You only need ANSI.SYS loaded.

you don't even need ANSI.SYS if you 'cheat' like borland did -=B-)
}

procedure clrscr; assembler;
Asm
  MOV    AX, 0600h    {BIOS Scroll Up}   { <<---- !!!!!! }
  MOV    BH, 07h      {Mono Attribute}
  XOR    CX, CX       {top left = 0,0}
  MOV    DX, 184fh    {bottom right = 24,79}
  INT    10h          {BIOS interrupt}   { do the clear }
  MOV    AH, 02h      {BIOS Set Cursor Position}  { now let's }
  XOR    DX, DX       {DH = Row = 00, DL = Col = 00}
  XOR    BH, BH       {Do it on Page 0}    { move the cursor to }
  INT    10h          {BIOS Interrupt}     { the top left corner }
End;

{ yeah, it's hardcoded for 25 lines and 80 columns }

uses
  DOS;
procedure clrscr;
var
  regs : registers;
Begin
  regs.AX := $0600;   {BIOS Scroll Up}   { <<---- !!!!!! }
  regs.BH := $07;     {Mono Attribute}
  regs.CX := $0000;   {top left = 0,0}
  regs.DX := $184F;   {bottom right = 24,79}
  INTR($10, regs);    {BIOS interrupt}   { do the clear }
  regs.AH := $02;     {BIOS Set Cursor Position}  { now let's }
  regs.DX := $0000;   {DH = Row = 00, DL = Col = 00}
  regs.BH := $0000;   {Do it on Page 0}    { move the cursor to }
  INTR($10, regs);    {BIOS Interrupt}     { the top left corner } End;
end;

