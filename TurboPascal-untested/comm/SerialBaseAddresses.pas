(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0018.PAS
  Description: Serial Base Addresses
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:29
*)

FUNCTION Serial_Base_Addr(COM_Port : byte) : word;
{ DESCRIPTION:
    Base address for four serial ports.
  SAMPLE CALL:
    NW := Serial_Base_Addr(1);
  RETURNS:
    The base address for the specified serial port.
  NOTES:
    If the port is not used, then the returned value will be 0 (zero).
    The aceptable values for COM_Port are: 1,2,3 and 4. }

BEGIN { Serial_Base_Addr }
  Serial_Base_Addr := MemW[$0000:$0400 + Pred(COM_Port) * 2];
END; { Serial_Base_Addr }

