(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0075.PAS
  Description: Carrier Detect
  Author: WAYNE BOYD
  Date: 02-28-95  09:53
*)

unit carrier;
{ detects carrier on modem line }

interface
uses dos;

implementation

Function carrierDetected( ComPort : byte ) : Boolean;
const
 MSR            = 6;
 BASEPORT      : Array[1..4] Of Word = ($03F8, $02F8, $03E8, $02E8);

begin
   CarrierDetected := (Port[basePort[ComPort] + MSR] And 128) <> 128;
{true = no carrier}
end;

end.

