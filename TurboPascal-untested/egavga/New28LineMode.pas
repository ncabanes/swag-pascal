(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0132.PAS
  Description: New 28 Line Mode
  Author: BAS VAN GAALEN
  Date: 11-26-94  04:58
*)

{
> I found this code in SWAG at EGAVGA.SWG category however It
> doesn't switch my screen in 28 lines mode.

That's because all values must be hex. Add a 'h' to all numbers, and it should
be fine. Or try this:
}
program test28rows;

procedure switch28; assembler;
asm
  mov ax,1202h     { set up 400 scan lines }
  mov bl,30h
  int 10h
  mov ax,0003h     { set up normal text mode }
  int 10h
  mov ax,1111h     { load ega character set }
  mov bl,00h
  int 10h
END;

begin
  switch28;
end.

