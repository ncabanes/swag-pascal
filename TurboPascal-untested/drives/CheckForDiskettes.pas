(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0029.PAS
  Description: Check for diskettes
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:23
*)

{ Cheks if there are diskettes drives present.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Diskettes_Present : boolean;
{ DESCRIPTION:
    Cheks if there are diskettes drives present.
  SAMPLE CALL:
    B := Diskettes_Present;
  RETURNS:
    TRUE  : There are diskettes drives
    FALSE : There aren't diskettes drives }

BEGIN { Diskettes_Present }
  Diskettes_Present := (MemW[$0000:0410] and $0001) <> 0;
END; { Diskettes_Present }

