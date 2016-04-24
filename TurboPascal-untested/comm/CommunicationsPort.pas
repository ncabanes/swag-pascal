(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0004.PAS
  Description: Communications Port
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{  >1. Let me look at the RING line from the modem
  >2. Let me determine the condition of CARRIER DETECT.

 The Modem Status Register (MSR) Byte contains this info.

 Carrier Detect:  MSR bit 7 will be set it there is a carrier
 detected.  Bit 3 indicates if there has been a change in the
 carrier detect status since the last time the MSR was read.

 Ring:  is indicated by MSR bit 6.  Bit 2 indicates if there
 was a change in bit 6 since the last time the MST was read.

 Bits 2 and 3 are cleared each time the MSR is read.

 Obtaining the MSR Byte may be done by directly reading the
 port value, or by calling the BIOS modem services interrupt $14.

 I've Typed in the following without testing.

 Using the BIOS...

        ...
}
Function GetMSR( COMport :Byte ) :Byte;
{ call With COMport 1 or 2 }
Var
  Reg : Registers;
begin
  Reg.DX := COMport - 1;
  Reg.AH := 3;
  Intr( $14, Reg );
  GetMSR := Reg.AL
end;
(*
...
MSRByte := GetMSR(1);   { MSR For COM1 (clears bits 0..3) }
...

 Using direct access: For COM1, the MSR is at port $3FE; For COM2
 it's at $2FE...

        ...
        MSRByte := Port[$3FE];  { MSR For COM1 (clears bits 0..3) }
        ...

 To test the status...

        ...
*)
IF ( MSRByte and $80 ) <> 0 then
  CarrierDetect := True
ELSE
  CarrierDetect := False;
IF ( MSRByte and $40 ) <> 0 then
  Ring := True;
ELSE
  Ring := False;
{

 Similar logic can be used With bits 2 and 3, which will inform
 you of whether or not a change occurred in bit 6 or 7 since the
 last read of the MSR.
}
