(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0034.PAS
  Description: Get Installed diskettes
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:26
*)

{ Gets the number of installed diskette drives in a system.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Installed_Diskettes : byte;
{ DESCRIPTION:
    Gets the number of installed diskette drives in a system.
  SAMPLE CALL:
    NB := Installed_Diskettes;
  RETURNS:
    The number of installed diskette drives. }

BEGIN { Installed_Diskettes }
  Installed_Diskettes := Succ((MemW[$0000:0410] shl 8) shr 14);
END; { Installed_Diskettes }

