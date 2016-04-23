{
From: Robert Palmqvist <rpt@c3consult.comm.se>

> need to know how to display a high intensity background character set in
> text mode.  I remeber seeing something somewhere about sacrificing the
> blink attribute to get it, but I cant for the life of me remember how.

This is one way of doing it ... Hope that it will help you out
}
Uses DOS;

Function GotCGA: boolean;
var Monitor: byte absolute $0040:$0010;
begin
  GotCGA:= true;
  if Monitor and 48 = 48 then
    GotCGA:= false
  else
    if Monitor and 32 = 32 then
      GotCGA:= true;
end;

Function GotEGA: boolean;
var Regs: registers;
begin
  with Regs do
    begin
      AX:= $1200;
      BX:= $0010;
      CX:= $FFFF;
      Intr($10, Regs);
      GotEGA:= (CX <> $FFFF);
    end;
end;

Function GotVGA: boolean;
var Regs: registers;
begin
  with Regs do
    begin
      AX:= $1A00;
      Intr($10,Regs);
      GotVGA:= (AL = $1A);
    end;
end;

Procedure SetBlink(On : boolean);
{Enable text mode attribute blinking if On is True}
const
  PortVal: array[0..4] of byte = ($0C, $08, $0D, $09, $09);
var
  PortNum: word;
  Index, PVal: byte;
  Mode: byte absolute $0000:$0449;
begin
  if GotEGA then
    begin
      inline(
        $8A/$5E/<On/    {mov bl,[bp+<On]}
        $B8/$03/$10/    {mov ax,$1003}
        $CD/$10);       {int $10}
      exit;
    end
  else
    if GotCGA then
      begin
        PortNum:= $3D8;
        case Mode of
          0..3: Index := Mode;
        else
          exit;
        end;
      end
    else
      begin
        PortNum:= $3B8;
        Index:= 4;
      end;
  PVal:= PortVal[Index];
  if On then
    PVal:= PVal or $20;
  Port[PortNum]:= PVal;
end;

Procedure BlinkOff;
begin
  SetBlink(false);
end;

Procedure BlinkOn;
begin
  SetBlink(true);
end;

