(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0004.PAS
  Description: TIMELOOP.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{$A+,B-,D-,E-,F-,I-,N-,O-,R-,S-,V-}

Program TimeNullRoutine;

Uses
  TpTimer;

Var
  Count : Byte;

Procedure DoNothing;
begin
end;

Var
  Loop : Word;
  Start,
  Stop : LongInt;

begin
  Start := ReadTimer;
  For Loop := 1 to 1000 do
    DoNothing;
  Stop := ReadTimer;
  WriteLn('Time = ', ElapsedTimeString(Start, Stop), ' ms')
end.

{
  ...Well running the Program listed above, 1000 nul loops time
  in at 3.007 miliseconds on my 386SX-25.
}
