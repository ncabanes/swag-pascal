{
SEAN PALMER

> Does anyone have any quick Procedures For detecting the number of
> lines as passed through the Dos "MODE" command? Ie, 25 lines, 43 or 50
> line mode? This way, when Programming a door, I can place the status
> line on the correct area of screen.

Try this, anything that correctly updates the bios when it changes modes
should be reported correctly.
}

Var
  rows : Byte;

Function getRows : Byte; Assembler;
Asm
  mov ax, $1130
  xor dx, dx
  int $10
  or  dx, dx
  jnz @S   {cga/mda don't have this fn}
  mov dx, 24
 @S:
  inc dx
  mov al, dl
end;

begin
  writeln(getrows);
end.
