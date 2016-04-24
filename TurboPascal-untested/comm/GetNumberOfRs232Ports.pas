(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0019.PAS
  Description: Get number of RS232 Ports
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:29
*)

FUNCTION Serial_Ports : byte;
{ DESCRIPTION:
    Gets the number of RS232 ports available in a system.
  SAMPLE CALL:
    NB := Serial_Ports; }

BEGIN { Serial_Ports }
  Serial_Ports := (MemW[$0000:$0410] shl 4) shr 13;
END; { Serial_Ports }

