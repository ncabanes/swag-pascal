(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0037.PAS
  Description: Is the MOUSE driver loaded?
  Author: DANIEL J. WOJCIK
  Date: 05-31-96  09:16
*)

{I need a code snippet that will test to determine whether a mouse driver
is loaded. }


FUNCTION DriverInstalled : boolean; {this checks for a mouse driver!}
CONST
  iret = 207;
VAR
  driverOff, driverSeg : Integer;
Begin
  driverOff := MemW[0000:0204];
  driverSeg := MemW[0000:0206];
  IF ((driverSeg <> 0) and (driverOff <> 0)) THEN
    Begin
      IF (Mem [driverSeg:driverOff] <> iret) THEN DriverInstalled := true
       ELSE DriverInstalled := false
    End
       ELSE DriverInstalled := false
End;


