(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0026.PAS
  Description: Detect Phone Ringing
  Author: HERB BROWN
  Date: 08-27-93  21:51
*)

{
HERB BROWN

Anybody using any of the public domain fossil units?  You are? Great! Here is
a procedure to add ring detection to them.

Fos_ringing works by "peeking" into the buffers for a carriage return. After
a ring is detected by your modem, the CR will be the last character in your
buffer.  You could re-write the following to retrieve a connect string, if
you wanted. Since the fossil takes care of the dirty bussiness, at the moment
I wasn't worried about it.

Once you establish the phone rang, simply send an ATA to the modem and delay
for about 11-15 seconds for connection. (maybe more for higher speed modems.)

What really has me puzzled, though, of all the PD code for fossils, nothing
like this was ever included.
}

Function Fos_Ringing(ComPort : Byte) : Boolean;
var
  CC : Char;
begin
  Fos_Ringing := False;
  Regs.Ah := $0C;
  Regs.Dx := ComPort - 1;
  Intr($14, Regs);

  if regs.ax = $FFFF then
    Fos_ringing := false
  else
  begin
    cc := chr(regs.al);
    if cc = #13 then
      Fos_ringing := true;
  end;
end;


