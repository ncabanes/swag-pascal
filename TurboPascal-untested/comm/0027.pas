{
MIKE MOSSERI

>  Does anyone have any bbs routines that they recommend.  I'd prefer if
>it came With source but one that doesn't is good.  Mostly I want the
>modem routines.  Also does anyone have a routine to answer the phone and
>tell the baud rate of connection?  I working on a bbs Program (mostly
>just For myself, small and quick) and Im doing it from scratch.  Im have
>some communication routines but Im looking For others made For bbs's.
}


Uses
  Dos, Crt;

Var
  REGS : Registers;

Function CheckRing(Comport : Byte) : Boolean;
begin
  fill(Regs, SizeOf(Regs), 0);    {Reset All Registers}
  Regs.AH := 3;
  Regs.DX := Comport - 1;
  Intr($14, Regs);
  CheckRing:= ((Regs.Al and $40) = $40);
end;

{
 The Function comes back True only when a ring is currently happening so
you can:
}

begin
  Repeat
  Until CheckRing(2);      {Or Whatever comport}
  Delay(1000);             {Give it a sec}
  Writeln_Fossil('ATA'); {Or Whatever you use to Interface w/ the fossil}
  While not CarrierDetect do Delay(250); {Suffecient Time}

{
  Well that should answer the phone, now if you want to check the baud
you can read a line from the modem or something.
}
