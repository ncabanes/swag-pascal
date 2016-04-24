(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0035.PAS
  Description: Get the BOOT Drive
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:26
*)

{ Gets the startup (boot) drive.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Startup_Drive : byte;
{ DESCRIPTION:
    Gets the startup (boot) drive.
  SAMPLE CALL:
    NB := Startup_Drive;
  RETURNS:
    1 : drive A
    2 : drive B
    and so on... }

var
  HTregs : registers;

BEGIN { Startup_Drive }
  HTregs.AX := $3305;
  MsDos(HTregs);
  Startup_Drive := HTregs.DL;
END; { Startup_Drive }

