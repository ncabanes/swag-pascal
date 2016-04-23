{ Gets the ROM BIOS date in a ASCII string.
  Part of the Heartware Toolkit v2.00 (HTelse.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION ROM_Bios_Date : String8;
{ DESCRIPTION:
    Gets the ROM BIOS date in a ASCII string.
  SAMPLE CALL:
    S := ROM_Bios_Date
  RETURNS:
    e.g., '06/10/85'.
  NOTES:
    Later versions of the Compaq have this release date shifted by 1 byte,
      to start at F000:FFF6h }

var
  Tmp : String8;

BEGIN { ROM_Bios_Date }
  FillChar(Tmp,0,8);
  Tmp[0] := Chr(8);
  Move(Mem[$F000:$FFF5],Tmp[1],8);
  ROM_Bios_Date := Tmp;
END; { ROM_Bios_Date }
