(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0041.PAS
  Description: A short timing unit
  Author: JASPER VAN WOUDENBERG
  Date: 08-30-96  09:35
*)

{
I don't know if you have something similar already in SWAG, but I have made
a
unit that converts a time to a longint, in a different way than PackTime and
Unpacktime. The longint is gives can be used to calculate. You can, for
instance, calculate a remaining time of a specific action. Here's the source
code:
=== Cut === }

unit TimeIt;
{ TIMEIT.PAS was written by Jasper van Woudenberg and is donated to the
 public domain. If you use (part) of this code, I would appreciate some
 credit.
 You can contact the author at 2:2801/506.5
 TimeIt is a unit to convert Time into a LongInt, so you can calculate with
 it. Included are procedures to calculate the remaining time of an action. }
interface
type
 PEstTime = ^TEstTime;
 TEstTime = record                { Record used to calculate remaining time 
}
        BeginTime,
        TimeNow,
        TimeBusy,
        EstTime,
        TimeRem,
        LastTime,
        NumSteps,
        Step     : LongInt;
        Perc     : Real;
       end;
const
 MaxHour = 5964;
 MaxMin  = 59;
 MaxSec  = 59;
 MaxS100 = 99;
 MaxTime = (MaxHour * (MaxMin + 1) * (MaxSec + 1) * (MaxS100 + 1)) +
      (MaxMin * (MaxSec + 1) * (MaxS100 + 1)) +
      (MaxSec * (MaxS100 + 1)) +
      (MaxS100);
function Time2LInt(H, M, S, S100 : LongInt) : LongInt;
{ Convert Time to a LongInt }
procedure LInt2Time(L : LongInt; var H, M, S, S100 : LongInt);
{ Convert LongInt to a time }
function GetTimeLI : LongInt;
{ Get current time, return as longint }
procedure SetTimeLI(T : LongInt);
{ Set current time, given a longint }
procedure InitEstTime(var T : TEstTime; NS : LongInt);
{ Initiate the estimated time routine }
procedure CalcEstTime(var T : TEstTime);
{ Calculate remaining time }
implementation
uses
 Dos;
function Time2LInt(H, M, S, S100 : LongInt) : LongInt;
var
 L : LongInt;
begin
 if S100 > MaxS100 then
 begin
  S := S + (S100 div (MaxS100 + 1));
  S100 := S100 mod (MaxS100 + 1);
 end;
 if S > MaxSec then
 begin
  M := M + (S div (MaxSec + 1));
  S := S mod (MaxSec + 1);
 end;
 if M > MaxMin then
 begin
  H := H + (M div (MaxMin + 1));
  M := M mod (MaxMin + 1);
 end;
 if H > MaxHour then
  H := MaxHour;
 if H < 0 then
  H := 0;
 if M < 0 then
  M := 0;
 if S < 0 then
  S := 0;
 if S100 < 0 then
  S := 0;
 L := (H * (MaxMin + 1) * (MaxSec + 1) * (MaxS100 + 1)) +
    (M * (MaxSec + 1) * (MaxS100 + 1)) +
    (S * (MaxS100 + 1)) +
    (S100);
 if (L > MaxTime) or (L < 0) then
  L := MaxTime;
 Time2LInt := L;
end; { Time2LInt }
procedure LInt2Time(L : LongInt; var H, M, S, S100 : LongInt);
begin
 if (L > MaxTime) or (L < 0) then
  L := MaxTime;
 H := L div ((MaxMin + 1) * (MaxSec + 1) * (MaxS100 + 1));
 L := L - (H * ((MaxMin + 1) * (MaxSec + 1) * (MaxS100 + 1)));
 M := L div ((MaxSec + 1) * (MaxS100 + 1));
 L := L - (M * (MaxSec + 1) * (MaxS100 + 1));
 S := L div (MaxS100 + 1);
 L := L - (S * (MaxS100 + 1));
 S100 := L;
end; { LInt2Time }
function GetTimeLI : LongInt;
var
 H, M, S, S100 : LongInt;
begin
 H := 0;
 M := 0;
 S := 0;
 S100 := 0;
 GetTime(Word(H), Word(M), Word(S), Word(S100));
 GetTimeLI := Time2LInt(H, M, S, S100);
end; { GetTimeLI }
procedure SetTimeLI(T : LongInt);
var
 H, M, S, S100 : LongInt;
begin
 LInt2Time(T, H, M, S, S100);
 SetTime(Word(H), Word(M), Word(S), Word(S100));
end; { SetTimeLI }
procedure InitEstTime(var T : TEstTime; NS : LongInt);
begin
 FillChar(T, SizeOf(T), 0);
 T.BeginTime := GetTimeLI;
 T.NumSteps := NS;
 T.Step := 0;
end; { InitEstTime }
procedure CalcEstTime(var T : TEstTime);
begin
 with T do
 begin
  Step := Step + 1;
  Perc := Step / NumSteps * 100;
  if Perc <> 0 then
  begin
   TimeNow := GetTimeLI;
   if ((LastTime div 100) <> (TimeNow div 100)) and
     ((TimeNow div 100) > (BeginTime div 100)) then
   begin
    LastTime := GetTimeLI;
    TimeBusy := TimeNow - BeginTime;
    EstTime := Round(TimeBusy / Perc * 100);
    TimeRem := EstTime - TimeBusy;
   end;
  end;
 end;
end; { CalcEstTime }
end.

=== Cut ===
This is a little demo program that shows how to use the TimeIt unit:
=== Cut ===

program TimeItDemo;
{ TIDEMO.PAS was written by Jasper van Woudenberg and is donated to the
 public domain. If you use (part) of this code, I would appreciate some
 credit.
 You can contact the author at 2:2801/506.5
 TimeItDemo is a very simple demo program that shows how to use the TimeIt
 unit. }
uses
 Crt, TimeIt;
procedure WriteTime(Str : string; Time : LongInt);
var
 H, M, S, S100 : LongInt;
begin
 LInt2Time(Time, H, M, S, S100);
 WriteLn(Str, H, ':', M, ':', S, '.', S100, '  ');
end; { WriteTime }
var
 I             : Word;
 EstTime       : TEstTime;
begin
 ClrScr;
 InitEstTime(EstTime, 60000);
 for I := 1 to 60000 do
 begin
{ You can replace this little loop with a lot of things: a file copying 
loop,
 a sorting algorithm, or whatever has very similar repetitive actions. }
  CalcEstTime(EstTime);
  GotoXY(1, 1);
  with EstTime do
  begin
   WriteTime('Start time     : ', BeginTime);
   WriteTime('Time now       : ', TimeNow);
   WriteTime('Time busy      : ', TimeBusy);
   WriteTime('Estimated time : ', EstTime);
   WriteTime('Time remaining : ', TimeRem);
   WriteLn;
   WriteLn  ('Num steps      : ', NumSteps);
   WriteLn  ('Step           : ', Step);
   WriteLn  ('Percentage     : ', Round(Perc));
  end;
 end;
end.

