(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0031.PAS
  Description: Get first CD-ROM Drive
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:24
*)

{ Gets the first installed CD-ROM drive letter in a system.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION First_CD_ROM_Drive : byte;
{ DESCRIPTION:
    Gets the first installed CD-ROM drive letter in a system.
  SAMPLE CALL:
    NB := First_CD_ROM_Drive;
  RETURNS:
    0 : drive A
    1 : drive B
    and so on... }

var
  HTregs : registers;

BEGIN { First_CD_ROM_Drive }
  HTregs.AX := $1500;
  HTregs.BX := $0000;
  Intr($2F,HTregs);
  First_CD_ROM_Drive := HTregs.CL;
END; { First_CD_ROM_Drive }

