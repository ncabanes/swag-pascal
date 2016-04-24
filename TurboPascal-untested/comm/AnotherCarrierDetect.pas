(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0005.PAS
  Description: Another Carrier Detect
  Author: SEAN PALMER
  Date: 05-28-93  13:35
*)

{
Author: Sean Palmer

> Does anyone know how to detect when the modem connects?? Thanks.

Check For a carrier: (periodically, like 2-4 times per second)
}

Const
  pBase = $3F8;  {change For which port you're using}
  pMSR  = pBase + 6; {modem status register}

Function carrier : Boolean;
begin
  carrier := (port[pMSR] and $80) <> 0;
end;


