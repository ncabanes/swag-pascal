(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0054.PAS
  Description: Get the active font
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:23
*)

{ Get the active font table in buffer #0.
  Part of the Heartware Toolkit v2.00 (HTfont.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }


type
  Font_Type  = array[1..4096] of byte;

PROCEDURE Font_Get(var Fnt : Font_Type);

{ DESCRIPTION:
    Get the active font table in buffer #0.
  SAMPLE CALL:
    Font_Get(Font_Table);
  RETURNS:
    The font table.
  NOTES:
    Works in VGA only, and with 8x16 fonts }

var
  Regs : registers;

BEGIN { Font_Get }
  Regs.AH := $11;
  Regs.AL := $30;
  Regs.BH := 6;                        { VGA: 8 x 16 }
  Intr($10,Regs);
  Move(Mem[Regs.ES:Regs.BP],Fnt,4096);
END; { Font_Get }

