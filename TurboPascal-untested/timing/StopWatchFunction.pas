(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0017.PAS
  Description: Stop Watch Function
  Author: MARTIN ROMMEL
  Date: 05-26-94  06:18
*)

{

I am sure it is not the most elegant implementation. Except for the night
of February 29th to March 1st, it should work fine. You might want to
through out the escape and beep procedures. }



unit Time;  {JMR'91}    { Unit zur Bestimmung von Programmlaufzeiten }

interface

  uses DOS,Crt;

  procedure Start;
  procedure Elapsed(var Hour,Minute,Second,HundSec:Word); 
  function ElapsedStr:String;    { 'HH:MM:SS,HH' }
  { Elapsed und ElapsedStr ermitteln die Zeit, die seit dem Aufruf von  }
  { Start vergangen ist. Schaltjahre werden nicht berücksichtigt.  }
  procedure beep;           { gibt kurzen Ton }
  function escape:Boolean;  { true, wenn <Esc> gedrückt wurde (ReadKey) }
{***************************************************************************}

implementation

var Y,Month,Day,DoW,Month0,Day0,Hour0,Minute0,Second0,HundSec0:Word;

procedure Start;
  begin
    GetTime(Hour0,Minute0,Second0,HundSec0);
    GetDate(Y,Month0,Day0,DoW);
  end;

procedure Elapsed;
  begin
    GetTime(Hour,Minute,Second,HundSec);
    GetDate(Y,Month,Day,DoW);
    HundSec:=HundSec-HundSec0;
    if HundSec>99 then begin HundSec:=HundSec+100; dec(Second) end;
    Second:=Second-Second0;
    if Second>59 then begin Second:=Second+60; dec(Minute) end;
    Minute:=Minute-Minute0;
    if Minute>59 then begin Minute:=Minute+60; dec(Hour) end;
    Hour:=Hour-Hour0;
    Day:=Day-Day0;
    if Day>30 then if Month in [1,3,5,7,8,10,12] then Day:=Day+31
    else if Month<>2 then Day:=Day+30
         else Day:=Day+28;
    if Hour>23 then Hour:=Hour+24*Day;
  end;

function ElapsedStr;
  var Hour,Minute,Second,HundSec:Word;
  function LeadingZero(w:Word):String;
    var s:String;
    begin
      Str(w:0,s);
      if Length(s)=1 then s:='0'+s;
      LeadingZero:=s;
    end;
  begin
    Elapsed(Hour,Minute,Second,HundSec);
    ElapsedStr:=LeadingZero(Hour)+':'+LeadingZero(Minute)+':'
        +LeadingZero(Second){+','+LeadingZero(HundSec)};
  end;

procedure beep;
  begin
    sound(440);
    delay(10);
    nosound;
  end;

function Escape;
  var Taste:Char;
  begin
    if Keypressed then
 if Ord(ReadKey)=27 then Escape:=true
     else Escape:=false
    else Escape:=false;
  end;

end. { Unit Time }

