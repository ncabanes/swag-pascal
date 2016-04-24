(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0021.PAS
  Description: Base address - parallel
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:28
*)

{ Base address for four parallel ports.
  Part of the Heartware Toolkit v2.00 (HTparal.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Parallel_Base_Addr(LPT_Port : byte) : word;
{ DESCRIPTION:
    Base address for four parallel ports.
  SAMPLE CALL:
    NW := Parallel_Base_Addr(1);
  RETURNS:
    The base address for the specified parallel port.
  NOTES:
    If the port is not used, then the returned value will be 0 (zero).
    The aceptable values for LPT_Port are: 1,2,3 and 4. }

BEGIN { Parallel_Base_Addr }
  Parallel_Base_Addr := MemW[$0000:$0408 + Pred(LPT_Port) * 2];
END; { Parallel_Base_Addr }

