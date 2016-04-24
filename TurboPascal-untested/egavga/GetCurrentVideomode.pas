(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0012.PAS
  Description: Get current Videomode
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
Here's a quick proc. to return the current video mode:
}

Uses
  Dos;

Function CurVidMode : Byte;

Var
  Regs : Registers;

begin;

  Regs.Ah :=$f;
  Intr($10, Regs);
  CurVidMode := Regs.Al;

end;

begin
  Writeln(CurVidMode);
end.


{
You can use that same color Procedure For the VGA 16 color mode because
although it can only do 16 colors, it can still change each of the 16
colors to 64*64*64 (262,144) colors, like the 256 color mode.

About the EGA palette - I'll have to get back to ya, that's more
complex.
}


