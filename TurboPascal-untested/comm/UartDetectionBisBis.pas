(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0036.PAS
  Description: Uart Detection
  Author: BJORN FELTEN
  Date: 01-27-94  12:24
*)

{
 > I'm looking for a small pascal V6 program to detect
 > the UART-type installed.

   Sure. How small do you need it? Here's one that'll compile to something just
below 3kb, will that do?
 }

function UART(Port: word): word; assembler;
{ Checks for UART, and, if one is present, what type.         }
{ Returns  0 if no UART,  1 if UART but no 16550,  2 if 16550 }
{ Donated to the public domain by Björn Felten @ 2:203/208    }
{ Partly from an asm program by Anders Danielsson @ 2:203/101 }
asm
   mov  cx,Port          {1..4}
   push ds
   mov  ds,seg0040       {Use BIOS table to find port addr}
   xor  si,si            {Offset 0 in BIOS table segment}
   rep  lodsw            {Get the right one}
   pop  ds
   or   ax,ax            {Test port address}
   jz   @no_uart         {If zero --> no port}
   mov  dx,ax            {Base address}
   add  dx,4             {Base+4}
   cli
   in   al,dx            {Modem Control Register}
   and  al,11100000b     {Check bit 5-7}
   jnz  @no_uart         {Non-zero --> no UART}
   sub  dx,2             {Base+2}
   jmp  @1               {Give hardware some time}
@1:
   in   al,dx            {Interrupt Identification Register}
   and  al,11110000b     {Check bit 4-7}
   cmp  al,11000000b     {FIFO enabled?}
   jz   @is16550         {Yes, it is a 16550}
   and  al,00110000b     {Check reserved bits}
   jnz  @no_uart         {Non-zero --> No UART}
   mov  al,00000111b     {16550 FIFO enable}
   out  dx,al            {FIFO control register}
   jmp  @2
@2:
   in   al,dx            {FIFO control register}
   and  al,11110000b     {Check bit 4-7}
   mov  ah,al            {Save for later}
   jmp  @3
@3:
   mov  al,00000110b     {16550 FIFO disable}
   out  dx,al            {FIFO control register}
   cmp  ah,11000000b     {FIFO still not enabled?}
   jz   @is16550         {Yes, it is a 16550}
   mov  ax,1
   jmp  @quit
@is16550:
   mov  ax,2
   jmp  @quit
@no_uart:
   xor  ax,ax
@quit:
   sti
end;

var P: word;
begin
  for P:=1 to 4 do
  case UART(P) of
    0: writeln('No UART on port COM',P);
    1: writeln('UART, but not 16550, on port COM',P);
    2: writeln('16550 UART on port COM',P);
  end
end.

