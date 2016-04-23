{
DAVID DAHL

I never posted it as a Unit.  I just posted a couple routines to set the
timer.  They're actually a part of another, larger project I've been working
on to play digitized Sound out of several different output devices.  When I
was asked if it were possible to speed up the tick and still have Dos's timer
Function behave normally, I threw them into a Unit and wrote the Program you
quoted from to illustrate how it would be done.  Here are the timer routines
as a Unit:

The routines perform no error checking on input values, so be careful
with them.  The Procedure Set8253Channel should never have a
channel value of more than 2 since the 8253 only has 3 channels
(0 - 2).
}

Unit C8253;

(* PUBLIC DOMAIN *)

Interface

Procedure SetPlaySpeed(Speed : LongInt);
Procedure SetDefaultTimerSpeed;
Procedure Set8253Channel(ChannelNumber : Byte; ProgramValue  : Word);

Implementation

Const
  C8253ModeControl   = $43;
  C8253OperatingFreq = 1193180;
  C8253Channel : Array [0..2] of Byte = ($40, $41, $42);

{=[ 8253 Timer Programming Routines ]=====================================}
Procedure Set8253Channel(ChannelNumber : Byte; ProgramValue  : Word);
begin
  Port[C8253ModeControl] := 54 or (ChannelNumber SHL 6); { XX110110 }
  Port[C8253Channel[ChannelNumber]] := Lo(ProgramValue);
  Port[C8253Channel[ChannelNumber]] := Hi(ProgramValue);
end;
{-[ Set Clock Channel 0 (INT 8, IRQ 0) To Input Speed ]-------------------}
Procedure SetPlaySpeed (Speed : LongInt);
Var
  ProgramValue : Word;
begin
  ProgramValue := C8253OperatingFreq div Speed;
  Set8253Channel(0, ProgramValue);
end;
{-[ Set Clock Channel 0 Back To 18.2 Default Value ]----------------------}
Procedure SetDefaultTimerSpeed;
begin
  Set8253Channel (0, 0);
end;

end.


