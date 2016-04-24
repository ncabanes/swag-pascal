(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0080.PAS
  Description: Simple Ring Detect
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:07
*)

{
> how do I detect a 'RING' signal from the modem at COMx?  (I want to
> write a tsr that makes the monitor flash red (like fading color 0 from
> black to red and back - that would be no problem, but the TSR and the
> modem part sure is)

Sure, here's how you can do it without monitoring the actual output
of the modem, and would definetaly be the best way to do it with a TSR.
}

Const
  MSR = $06;

Function Ringing(cb: word): boolean;
begin
  ringing := port[cb+MSR] and $40 = $40;
end;

begin
  cb := $3F8;
  writeln(ringing(cb));
end.

