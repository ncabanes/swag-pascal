(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0055.PAS
  Description: Get one Char from Font
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:25
*)

{ Get one char table from font buffer.
  Part of the Heartware Toolkit v2.00 (HTfont.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

type
  Font_Type  = array[1..4096] of byte;
  Char_Type  = array[1..16] of byte;

PROCEDURE Font_Get_Char(Fnt : Font_Type;
                      Char_ : byte;
            var Char_Buffer : Char_Type);

{ DESCRIPTION:
    Get one char table from font buffer.
  SAMPLE CALL:
    Font_Get_Char(Font_Table,176,Char_Table);
  RETURNS:
    Char_Buffer : Specified char table.
  NOTES:
    Works in VGA only, and with 8x16 fonts }

var
  P : word;

BEGIN { Font_Get_Char }
  P := Succ(16 * Char_);
  Move(Fnt[P],Char_Buffer,16);
END; { Font_Get_Char }

