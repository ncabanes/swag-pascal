{ SB> Has anyone by any chance written a Procedure For calculating the amount
 SB> of time a Program runs.  I understand how to use getTime, etc, but I am
 SB> trying to figure out a way around all the possibilities...i.e. someone
 SB> starts a Program at 23:59:03.44, and it's finished at 00:02:05.33.
 SB>
 SB> Anyway, if someone already has this figured out, I'd sure appreciate it
 SB> or even some ideas...

Scott,
    try:

    Var
        Timer : LongInt Absolute $0040:$006c;

    That's the Tic counter, stored at Segment 0040h, offset 006Ch. It
stores the number of ticks since you turned the Computer on and so will
only wrap after MorE THAN 3 YEARS, if you never close the machine ;-)

    it is incremented 18.2 times/sec, so divide it by 18.2 to get the
number of seconds. You can figure out the rest ;-)

    Store its content to another LongInt at the start of the Program,
again at the end. Substract the first value from the second and you have
the number of ticks elapsed during the Program's execution.

Oh what the heck, here is a Complete Unit, all you have to do is include
it in your Uses clause nothing more unless you want to save the time in
a log File or something.
}

{$A+,B-,D+,E-,F+,G+,I-,L+,N-,O+,P+,Q-,R-,S-,T-,V-,X+,Y+}
{$M 8192,0,0}
Unit TimePrg;
(**) Interface (**)
(**) Implementation (**)
Uses
  Dos;
Type
  CmdLine = String[127];
Var
  TimerTicks : LongInt Absolute $0040:$006C;
  OldCommandLine, NewCommandline : CmdLine;
  CommandLine : ^CmdLine;
  TimeIn, TimeOut, Spent : LongInt;
  Years, Days, Hours, Minutes, Seconds, ms : Byte;
  ExitBeForeTimePrg : Pointer;
  D : DirStr;
  N : NameStr;
  E : ExtStr;
  Index : Integer;

Function Strfunc(Value:Byte):String;
Var
  temp : String;
begin
  Str(Value:0, Temp);
  StrFunc := #32+temp;
end;

Procedure TimePrgExit; Far;
begin
  TimeOut := TimerTicks;
  ExitProc := ExitBeForeTimePrg;
  Spent := TimeOut - TimeIn;
  ms := (Spent - trunc(Spent / 18.2))*55;
  Spent := Trunc(Spent / 18.2);
  Years := Spent div (3600*24*365);
  Spent := Spent mod (3600*24*365);
  Days := Spent div (3600*24);
  Spent := Spent mod (3600*24);
  Hours := Spent div 3600;
  Spent := Spent mod 3600;
  Minutes := Spent div 60;
  Spent := Spent mod 60;
  Seconds := Spent;
  CommandLine := Ptr(PrefixSeg, $80);
  OldCommandLine := CommandLine^;
  NewCommandLine := '';
  if Years>0 then
    NewCommandLine := NewCommandLine + Strfunc(Years) + ' Years';
  if Days>0 then
    NewCommandLine := NewCommandLine + Strfunc(Days) + ' Days';
  if Hours>0 then
    NewCommandLine := NewCommandLine + Strfunc(Hours) + ' Hours';
  if Minutes>0 then
    NewCommandLine := NewCommandLine + Strfunc(Minutes) + ' Minutes';
  if Seconds>0 then
    NewCommandLine := NewCommandLine + Strfunc(Seconds)        + ' Seconds';
  if ms>0 then
    NewCommandLine := NewCommandLine + Strfunc(ms) + ' milli-seconds';
  CommandLine^ := NewCommandLine;
  Write('Thanks For spending ');
  Case Paramcount of
    0: Write('so little time');
    2: Write(ParamStr(1),#32, Paramstr(2));
  else
    For Index := 1 to ParamCount - 3 do begin
      Write(Paramstr(Index));
      if odd(Index) then
        Write(' ')
      else
        Write(', ');
    end;
    Write(Paramstr(Index+1), ' and ',
    Paramstr(Index+2), ' ', Paramstr(Index+3));
  end;
  CommandLine^ := OldCommandLine;
  Fsplit(Paramstr(0), D, N, E);
  Writeln(' In ', N);
end;

begin
  TimeIn := TimerTicks;
  ExitBeForeTimePrg := ExitProc;
  ExitProc := @TimePrgExit;
end.
