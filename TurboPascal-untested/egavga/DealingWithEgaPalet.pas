(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0008.PAS
  Description: Dealing with EGA Palet
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
> I once saw a Procedure that set the palette With RGB inputs, like the
> 256- colour palette setter (RGBSetPalette).  It used some SHLs
> and SHRs to reduce the inputted values For red, green, and
> blue to 2-bit values (or somewhere around there).
}

Procedure EGAPalette(c_index, red, green, blue : Byte);
Var
  i    : Integer;
  regs : Registers;
begin
  red   := red SHR 6;
  green := green SHR 6;
  blue  := blue SHR 6;
  i     := (red SHL 4) + (green SHL 2) + blue;
  regs.AH := $10;
  regs.AL := 0;
  regs.BH := i;
  regs.BL := c_index;  { the colour index to change }
  Intr($10, regs);
end;


