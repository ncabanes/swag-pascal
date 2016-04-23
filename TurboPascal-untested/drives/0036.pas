{ Sets the current drive number.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE Set_Default_Drive(D : byte);
{ DESCRIPTION:
    Sets the current drive number.
  SAMPLE CALL:
    Set_Default_Drive(1);
  RETURNS:
    Nothing.
  NOTES:
    A = 0, B = 1, C = 2, etc. }

var
  HTregs : registers;

BEGIN { Set_Default_Drive }
  HTregs.AH := $0E;
  HTregs.DL := D;
  MsDos(HTregs);
END; { Set_Default_Drive }
