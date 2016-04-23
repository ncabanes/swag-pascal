{
> Now what I want to do is calculate the total run-time of the overall
> event, from start to finish, i.e., parse the log file taking the last and
> first time entries and calculate the time. I'm sure there is an easier way
> to do this but I'm new to Pascal, and, open to suggestions.  Below is what
> appears in the event.log :
}

Unit Timer;

{       SIMPLE TIMER 1.0
        =================

 This is a Timer unit, it calculates time by system clock.  A few limitations
 are:

   1) Must not modify clock.
   2) Must not time more than a day
   3) Must StopTimer before displaying Time

   Usage:

      StartTimer;   Starts Timer
      StopTimer;    Stops Timer
      CalcTimer;    Calculates time
      DispTime:     Displays time between StartTimer and StopTimer,
                    you don't need to call CalcTimer if you call DispTime.

 This unit may be used in freeware and shareware programs as long as:

   1) The program is a DECENT program, no "Adult" or "XXX" type programs
      shall lawfully contain any code found within this file (modified or
      in original form) or this file after it's been compiled.

   2) This copyrighting is not added to, or removed from the program by
      any other person other than I, the author.

 This is copyrighted but may be used or modified in programs as long as the
 above conditions are followed.

 I may be reached at:

   1:130/709                              - Fidonet
   Chris.Boyd@f709.n130.z1.fidonet.org    - Internet
   Alpha Zeta, Ft. Worth (817) 246-3058   - Bulletin Board

 If you have any comments or suggestions (not complaints).  I assume no
 responsibility for anything resulting from the usage of this code.

                                                   -Chris Boyd

}

Interface

Uses
  Dos;

Type
  TimeStruct = record
    Hour,
    Minute,
    Second,
    S100   : Word;
  End;

Var
  StartT,
  StopT,
  TimeT   : TimeStruct;
  Stopped : Boolean;

procedure StartTimer;
procedure StopTimer;
procedure DispTime;
procedure CalcTimer;

Implementation

procedure TimerError(Err : Byte);
Begin
  Case Err of
    1 :
    Begin
      Writeln(' Error: Must Use StartTimer before StopTimer');
      Halt(1);
    End;

    2 :
    Begin
      Writeln(' Error: Timer can not handle change of day');
      Halt(2);
    End;

    3 :
    Begin
      Writeln(' Error: Internal - Must StopTimer before DispTime');
      Halt(3);
    End;
  End;
End;

procedure CalcTimer;
Begin
  If (Stopped = True) Then
  Begin
    If (StopT.Hour < StartT.Hour) Then
      TimerError(2);
    TimeT.Hour := StopT.Hour - StartT.Hour;

    If (StopT.Minute < StartT.Minute) Then
    Begin
      TimeT.Hour   := TimeT.Hour - 1;
      StopT.Minute := StopT.Minute + 60;
    End;
    TimeT.Minute := StopT.Minute - StartT.Minute;

    If (StopT.Second < StartT.Second) Then
    Begin
      TimeT.Minute := TimeT.Minute - 1;
      StopT.Second := StopT.Second + 60;
    End;
    TimeT.Second := StopT.Second - StartT.Second;

    If (StopT.S100 < StartT.S100) Then
    Begin
      TimeT.Second := TimeT.Second - 1;
      StopT.S100   := StopT.S100 + 100;
    End;
    TimeT.S100 := StopT.S100 - StartT.S100;
  End
  Else
    TimerError(3);
End;

procedure DispTime;
Begin
  CalcTimer;
  Write(' Time : ');
  Write(TimeT.Hour);
  Write(':');

  If (TimeT.Minute < 10) Then
    Write('0');
  Write(TimeT.Minute);
  Write(':');

  If (TimeT.Second < 10) Then
    Write('0');
  Write(TimeT.Second);
  Write('.');

  If (TimeT.S100 < 10) Then
    Write('0');
  Writeln(TimeT.S100);
End;

procedure StartTimer;
Begin
  GetTime(StartT.Hour, StartT.Minute, StartT.Second, StartT.S100);
  Stopped := False;
End;

procedure StopTimer;
Begin
  If (Stopped = False) Then
  Begin
    GetTime(StopT.Hour, StopT.Minute, StopT.Second, StopT.S100);
    Stopped := TRUE;
  End
  Else
    TimerError(1);
End;

End.

{
This is a unit that I wrote.  It will not change day without calling an error
in itself.  This can be modified though, I just haven't went about doing it.
For example, if you started the timer at 11:29 pm and stopped it at 1:00 am, it
wouldn't work, but if you started the timer at 12:00 am and stopped it at 11:59
pm in that same day it would work.  The TimeStruct type doesn't store day, just
time and the only thing you have to do to use it is:

In your main program:
}
Program MyProg;

Uses
  Timer;

Begin
{ Program stuff.... }
StartTimer;
{ More Program Stuff... }
StopTimer;
{ If you don't want to display the time to the screen, then you need to
  call CalcTimer, so that it modifies TimeT}
DispTime; {Whenever you want to display the time..  The calculated time is
stored in the record variable Timer.TimeT, if you wanted to access    it.  All
the fields of the record a word in type.  To access the hours for example,
you'd go like:

                Timer.TimeT.Hour    or    TimeT.Hour

           You probably will have to try both.}
End.

