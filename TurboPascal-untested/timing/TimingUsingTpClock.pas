(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0006.PAS
  Description: Timing Using TP Clock
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{
> Does anyone know of a proFiler For TP 6, or is there a special
> command using TPC to activate a proFiler to tell how much time the
> Program takes doing a task. Thanks, Luke

Try this Unit.  Put a ClockOn and it will start timing then when the ClockOff
is reached it will tell you how long it took.  It's very nice For optimizing
pieces of code.
}

Unit Timer;

Interface

Procedure ClockOn;
Procedure ClockOff;

Implementation
Uses Dos;

Var
  H, M, S, S100 : Word;
  Startclock, Stopclock : Real;

Procedure ClockOn;
 begin
   GetTime(H, M, S, S100);
   StartClock := (H * 3600) + (M * 60) + S + (S100 / 100);
end;

Procedure ClockOff;
 begin
  GetTime(H, M, S, S100);
  StopClock := (H * 3600) + (M * 60) + S + (S100 / 100);
  WriteLn('Elapsed time = ', (StopClock - StartClock):0:2);
 end;

end.


