{
KAI ROHRBACHER

  As  promised,  here  is  some  TP-code  to  check whether your machine
  supports  the  extended timing services of the AT's-BIOS: if all works
  fine,  the  Program should give two beeps, the 2nd exactly 5secs after
  the 1st one -and then terminate.

  (To  all  others  reading  this:  this  timing  scheme  normally works
  _asynchrone_ to whatever you are doing in the "foreground" Program and
  thus  is  great  For  timing  events.  What's  more:  the  clock has a
  resolution of some microseconds!)
}

Const
  WaitTime = 5000;
Var
  IsAT,
  TimeFlag  : Byte;
  CycleTime : LongInt;

Function AT : Boolean;
{ in: - }
{out: True/False, if the machine is (at least) an AT}
begin
  AT := MEM[$F000 : $FFFE] = $FC;
end;

Procedure SetWaitingTime(milliseconds : Word);
{ in: milliseconds = time to wait in ms}
{out: CycleTime := that same value in microseconds}
{     TimeFlag  := $80}
{rem: won't work With PC's}
begin
  TimeFlag  := $80;
  CycleTime := LongInt(milliseconds) * LongInt(1000);
  if (milliseconds <> 0) and AT then
    IsAT := 0      {yes, use timing mechanism}
  else
    IsAT := $80;   {no, don't use that extended service}
end;

Procedure Wait;
begin
  Asm
    MOV AL, IsAT
    or  AL, AL
    JNE @L11
    MOV TimeFlag,AL
    MOV DX, Word PTR CycleTime
    MOV CX, Word PTR CycleTime+2
    MOV BX, OFFSET TimeFlag
    MOV AX, DS
    MOV ES, AX
    MOV AX, 8300h
    INT 15h
   @L11:

   @L10:
    MOV AL, TimeFlag {look at bit 7: 1/0 = time over/not over}
    and AL, $80
    JE  @L10
  end;
end;

begin
  if not AT then
  begin
    WriteLN('Sorry, this Program requires the extended BIOS-' +
            'services, available on AT''s only!');
    Halt(1);
  end;
  WriteLN('The time between the two beeps should be exactly ', WaitTime,
          ' milliseconds!');
  Write(#7);
  SetWaitingTime(5000);
  Wait;
  Write(#7);
end.
