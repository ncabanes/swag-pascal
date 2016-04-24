(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0039.PAS
  Description: Re: CPU-time
  Author: NUSRET TASCI
  Date: 02-21-96  21:04
*)

{
Mattias Hansson (d92mh@efd.lth.se) wrote:
: I wonder if there is any way to check how fast a program is executing.
: The program should look like this

: ...
: starttime:="CPU-time"
: ... doing something ...
: stoptime:="CPU-time"
: execution-time:=stoptime-starttime
: ...

: IS IT POSSIBLE IN PASCAL ?

I mad somethink LONG LONG ago, so it may be wrong, slow buggy etc.. 

-- CUT HERE ---
}
unit DURATION;

interface

uses dos;

var  starttime,endtime,dauer : STRING[22];

procedure startzeit;
{r da, um die StartZeit festzulegen }
procedure endzeit;
{r da, um die EndZeit festzulegen }
procedure zeitformat;
{ Berechnet die Dauer, und Formatiert die Strings }

implementation

var hour,minute,second,thousend     : integer;
    hour1,minute1,second1,thousend1,
    hour2,minute2,second2,thousend2 : word;

procedure startzeit;
begin
  GetTime(hour1,minute1,second1,thousend1);
end;

procedure endzeit;
begin
  GetTime(hour2,minute2,second2,thousend2);
end;

PROCEDURE zeitformat;
VAR strngs : STRING[2];
BEGIN
  starttime:='';       { Etwas kompliziert zu lesen, mir fiel aber }
  endtime :='';        { nichts anderes ein...                     }
  dauer   :='';
  Str(hour1,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  starttime:=starttime+strngs+':';
  Str(minute1,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  starttime:=starttime+strngs+':';
  Str(second1,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  starttime:=starttime+strngs+'.';
  Str(thousend1,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  starttime:=starttime+strngs;
  Str(hour2,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  endtime:=endtime+strngs+':';
  Str(minute2,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  endtime:=endtime+strngs+':';
  Str(second2,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  endtime:=endtime+strngs+'.';
  Str(thousend2,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  endtime:=endtime+strngs;
  IF hour1>hour2 THEN
    BEGIN
      hour:=24+hour2-hour1;
    END
  ELSE hour:=hour2-hour1;
  IF minute1>minute2 THEN
    BEGIN
      minute:=60+minute2-minute1;
      hour:=hour-1;
    END
  ELSE minute:=minute2-minute1;
  IF second1>second2 THEN
    BEGIN
      second:=60+second2-second1;
      minute:=minute-1;
    END
  ELSE second:=second2-second1;
  IF thousend1>thousend2 THEN
    BEGIN
      thousend:=100+thousend2-thousend1;
      second:=second-1;
    END
  ELSE thousend:=thousend2-thousend1;
  Str(hour,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  dauer:=dauer+strngs+':';
  Str(minute,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  dauer:=dauer+strngs+':';
  Str(second,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  dauer:=dauer+strngs+'.';
  Str(thousend,strngs);
  IF Length(strngs)<2 THEN Insert('0',strngs,1);
  dauer:=dauer+strngs;
END;

end.

