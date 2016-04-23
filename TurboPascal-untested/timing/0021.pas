
UNIT Timer;
INTERFACE

TYPE
  tTimerObject = object
    TimerTicks : LONGINT;
    MaxSeconds : LONGINT;
    PROCEDURE Start(Amount : LONGINT);
    FUNCTION  ElapsedSeconds : LONGINT;
    FUNCTION  Remaining : LONGINT;
    FUNCTION  Expired : BOOLEAN;
    FUNCTION  PrintableTimer(Tics : LONGINT) : STRING;
  END;

IMPLEMENTATION
VAR
  TicksSinceMidnight : LONGINT ABSOLUTE $0040 : $006c;

  PROCEDURE tTimerObject.Start(Amount : LONGINT);
  BEGIN
    TimerTicks := TicksSinceMidnight;
    MaxSeconds := Amount;
  END;

  FUNCTION tTimerObject.ElapsedSeconds : LONGINT;  { elapsed time in seconds }
  CONST
    TicksPerDay = 1573040;
    TicksPerSecond = 18.20648;
  VAR
    ElapsedTicks : LONGINT;

  BEGIN
    ElapsedTicks := TicksSinceMidnight;
    IF (ElapsedTicks >= TimerTicks) THEN
      ElapsedTicks := ElapsedTicks - TimerTicks
    ELSE      { Midnight rollover occurred }
      ElapsedTicks := TicksPerDay - TimerTicks + ElapsedTicks;
    ElapsedSeconds := ROUND (ElapsedTicks / TicksPerSecond);
  END;

  FUNCTION tTimerObject.Expired : BOOLEAN;  { Has this timer expired ?? }
  BEGIN
  Expired := (ElapsedSeconds > MaxSeconds);
  END;

  FUNCTION tTimerObject.Remaining : LONGINT;  { How many seconds remain? }
  BEGIN
  IF Expired THEN Remaining := 0 ELSE
     Remaining := MaxSeconds - ElapsedSeconds;
  END;

  FUNCTION tTimerObject.PrintableTimer(Tics : LONGINT) : STRING;
  { return a printable time string }

    VAR
      S, T : STRING;
      Hour, Min, Sec, Time : LONGINT;
      i : INTEGER;

    BEGIN
    Hour := (Tics div 3600);
    Min  := (Tics div 60);
    Sec  := Tics - (Min * 60);
    STR(Min : 2, T);
    IF T[1] = #32 THEN T[1] := '0';
    S := T + ':';
    STR(Sec : 2, T);
    IF T[1] = #32 THEN T[1] := '0';
    S := S + T;
    PrintableTimer := S;
    END;
END.

{ ----------------------------   DEMO   ----------------------- }

uses
  CRT, Timer;
var
  t : tTimerObject;

begin
  ClrScr;
  t.Start(10);  { set a 10 second timer }
  GoToXY(1,1); Write(t.TimerTicks);
  repeat
  GoToXY(1,2); Write(t.PrintableTimer(t.Remaining));
  GoToXY(1,3); Write(t.PrintableTimer(t.ElapsedSeconds));
  until (t.Expired);  { wait until it expires }
  Readkey;
end.
