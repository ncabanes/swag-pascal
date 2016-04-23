
{    Here's a little OOP stopwatch unit that may help: }

unit StopWtch;
(*
  Written by Steve Rogers - sometime in 1993
  Released to Public Domain sometime in 1995 - enjoy
*)

interface

type
  tStopWatchObject=object
    StartTicks : longint;
    procedure Start;
    function Elapsed : longint;
  end;

implementation
var
  TicksSinceMidnight : longint ABSOLUTE $0040:$006c;

  {-----------------------}
  procedure tStopWatchObject.Start;
  begin
    StartTicks:= TicksSinceMidnight;
    repeat until (TicksSinceMidnight<>StartTicks);
  end;

  {-----------------------}
  function tStopWatchObject.Elapsed : longint;  { elapsed time in seconds }
  const
    TicksPerDay=1572480;
    TicksPerSecond=18.2;

  var
    ElapsedTicks : longint;

  begin
    ElapsedTicks:= TicksSinceMidnight;

    if (ElapsedTicks > StartTicks) then
      ElapsedTicks:= ElapsedTicks - StartTicks
    else      { Midnight rollover occurred }
      ElapsedTicks:= TicksPerDay - StartTicks + ElapsedTicks;

    Elapsed:= round(ElapsedTicks / TicksPerSecond);
  end;

  {-----------------------}
end.
