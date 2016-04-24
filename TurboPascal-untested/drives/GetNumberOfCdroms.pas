(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0032.PAS
  Description: Get Number of CD-ROMS
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:24
*)

{ Gets the number of installed CD-ROM drives in a system.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION CD_ROM_Units : byte;

{ DESCRIPTION:
    Gets the number of installed CD-ROM drives in a system.
  SAMPLE CALL:
    NB := CD_ROM_Units;
  RETURNS:
    0    : driver not installed
    else : number of CD-ROM units }

var
  HTregs : registers;

BEGIN { CD_ROM_Units }
  HTregs.AX := $1500;
  HTregs.BX := $0000;
  Intr($2F,HTregs);
  CD_ROM_Units := HTregs.BL;
END; { CD_ROM_Units }

