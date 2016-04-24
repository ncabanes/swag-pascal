(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0005.PAS
  Description: Determine CPU Speed
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{
·    Subject: How to determine mhz using TP6.0...

It seems to work pretty well, but on a 486/33DX it gave inacurate results...
}

Program CpuSpeed;
Uses
  Crt;
Var
  Speed, DelayCalibrate : Word;
Const
  Offset = 9; { For TP 4.0, it should be 16 }


Procedure WaitForFloppy;
Var
  tickTil     : LongInt;
  TimerTicks  : LongInt Absolute $40 : $6C;
  motorStatus : Byte Absolute $40 : $3F;
begin
  if MotorStatus and $F > 0 then
  begin
    WriteLn('Loading...');
    TickTil := TimerTicks + 91;
    {There are $17FE80 ticks in a day}
    if TickTil > $17FE80 then
      Dec(TickTil, $17FE80);
    Repeat Until (MotorStatus and $F = 0) or (TimerTicks >= TickTil);
  end;
end;

begin
  WaitForFloppy;
  DelayCalibrate := MemW[Seg(CheckSnow): Ofs(CheckSnow)+Offset];
  WriteLn('Delay calibration value is ', DelayCalibrate);
  Speed := ((LongInt(1000) * DelayCalibrate) + 110970) div 438;
  Write('Calculated speed: ', Speed div 100,'.');
  WriteLn((speed div 10) MOD 10, speed MOD 10);
  Write('CPU speed is probably ');
  Case Speed OF
    0..499     : WriteLn('4.77MHz or below');
    500..699   : WriteLn('6MHz');
    700..899   : WriteLn('8MHz');
    900..1099  : WriteLn('10MHz');
    1100..1399 : WriteLn('12MHz');
    1400..1799 : WriteLn('16MHz');
    1800..2199 : WriteLn('20MHz');
    2200..2699 : WriteLn('25MHz');
    2700..3599 : WriteLn('30MHz');
    ELSE
      WriteLn('30MHz or MORE!');
  end;
end.

