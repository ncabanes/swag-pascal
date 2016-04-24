(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0025.PAS
  Description: Setting Graphics Mode
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
Well, there are two basic ways of using Graphics mode.
1) Use the BIOS routines to enter this mode.
2) Use the BGI (Borland Graphics Interface) used With the Graph Unit
   and the appropriate BGI File (as mentioned by you).

Since you intend to display PCX Files, I guess you have no business
with the Graph Unit and the BGI, so I suggest the first way.

Example:
}

Program Enter256;

Uses
  Dos;

Var
  Regs : Registers;

begin
  Regs.Ah := 0;
  Regs.Al := $13;
  Intr($10, Regs);

  Readln;
end.

{
  At the end of this Program you will be in 320x200 256 color mode.
}
