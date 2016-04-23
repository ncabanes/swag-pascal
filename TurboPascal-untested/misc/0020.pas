UNIT Timer;

{ TIMER - Fine resolution timer functions              }

INTERFACE
USES Crt,Dos;
CONST
   TixSec  = 18.20648193;
   TixMin  = TixSec * 60.0;
   TixHour = TixMin * 60.0;
   TixDay  = TixHour * 24.0;
TYPE
   DiffType = String[16];
VAR
   tGet       : Longint ABSOLUTE $0040:$006C;
FUNCTION tStart: Longint;
FUNCTION tDiff(StartTime,EndTime: Longint) : Real;
FUNCTION tFormat(T1,T2:Longint): DiffType;
PROCEDURE GetTime(H,M,S,S100:Word);

IMPLEMENTATION

VAR
   TimeDiff   : DiffType;

{ tStart - wait for a new tick, and return the
  tick number to the caller.  The wait allows
  us to be sure the user gets a start at the
  beginning of the second.                             }

FUNCTION tStart: Longint;
VAR
   StartTime : Longint;
BEGIN
          StartTime := tGet;
   WHILE StartTime = tGet DO;
          tStart := tGet
END;

{ tDiff - compute the difference between two
  timepoints (in seconds). }

FUNCTION tDiff(StartTime,EndTime: Longint) : Real;
BEGIN
   tDiff := (EndTime-StartTime)/TixSec;
END;

PROCEDURE GetTime(H,M,S,S100:Word);
VAR
   Regs : Registers;
BEGIN
   Regs.AH := $2C;
   MsDos(Regs);
   H := Regs.CH;
   M := Regs.CL;
   S := Regs.DH;
   S100 := Regs.DL
END;

{ tFormat - given two times, return a pointer
  to a (static) string that is the difference
  in the times, formatted HH:MM:SS }

FUNCTION tFormat(T1,T2:Longint): DiffType;

FUNCTION rMod(P1,P2: Real): Real;
BEGIN
   rMod := Frac(P1/P2) * P2
END;

VAR
        Temp : Real;
   tStr : String;
   TempStr : String[2];
   TimeValue : ARRAY [1..4] OF Longint;
   I : Integer;
BEGIN
   Temp := t2-t1;           { Time diff. }
   {Adj midnight crossover}
   IF Temp < 0 THEN
          Temp := Temp + TixDay;
          TimeValue[1] := Trunc(Temp/TixHour);  {hours}
          Temp := rMod(Temp,TixHour);
   TimeValue[2] := Trunc(Temp/TixMin); {minutes}
   Temp := rMod(Temp,TixMin);
   TimeValue[3] := Trunc(Temp/TixSec); {seconds}
   Temp := rMod(Temp,TixSec);     {milliseconds}
   TimeValue[4] := Trunc(Temp*100.0/TixSec+0.5);
   STR(TimeValue[1]:2,tStr);
   IF tStr[1] = ' ' THEN tStr[1] := '0';
   FOR I := 2 TO 3 DO
      BEGIN
         STR(TimeValue[I]:2,TempStr);
         IF TempStr[1]=' ' THEN
                            TempStr[1]:='0';
         tStr := tStr + ':'+ TempStr
      END;
   STR(TimeValue[4]:2,TempStr);
   IF TempStr[1]=' ' THEN TempStr[1]:='0';
   tStr := tStr + '.' + TempStr;
   tFormat := tStr
END;

END.
