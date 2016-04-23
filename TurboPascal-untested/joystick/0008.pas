{
> Can anybody give me any info on how to read signals from pins on say
> COM2: or from LPT1: or even from The joystick port? I think it has
> been done with the PORT command or something, but what are the values
> to use to read them with?

As mentioned in the Neural_Net Echo:
}

UNIT joys;

{Joystick interface for Turbo Pascal.}
{Copyright 1993 by Wesley R. Elsberry.  Released for noncommercial use.}
{NO WARRANTY.}

INTERFACE

VAR
  xcor, ycor,
  fire1, fire2 : WORD;

PROCEDURE joy;     { basic info for first joystick }
PROCEDURE testjoy; { minimal test routine }

IMPLEMENTATION

{ Significant aid was had from the example given in:
  programm to read joystick : turbo c 2.0 - Jean-Yves Vinet }

CONST
  JOYPORT = $201;
  STROUT  = $FF;
  STRCMP  = $FFFF;

VAR
  inread,
  temp   : BYTE;

PROCEDURE joy;
VAR
  done : BOOLEAN;
BEGIN
  done := FALSE;
  xcor := 0;
  ycor := 0;
  port[JOYPORT] := STROUT;

  while (NOT done) DO
  BEGIN
    if ((port[JOYPORT] AND 1) = 0) then
      done := TRUE;
    INC(xcor);
    if (xcor = STRCMP) then
      done := true;
  END;

  while ((port[JOYPORT] AND 2) <> 0) DO ;

  done := FALSE;
  port[JOYPORT] := STROUT;

  while (NOT done) DO
  BEGIN
    if ((port[JOYPORT] AND 2) = 0) then
      done := TRUE;
    INC(ycor);
    if (ycor = STRCMP) then
      done := TRUE;
  END;

  inread := port[JOYPORT];

  { Button A at $10, B at $20, C at $40, D at $80. }
  if ((inread AND $10) <> $10) then
    fire1 := 1;
  if ((inread AND $20) <> $20) then
    fire2 := 1;
END;

{If you want to grab the second joystick values, the X coordinate
should be gotten from comparing port[JOYPORT] to 4, the Y coordinate
from comparing port[JOYPORT] to 8.}

PROCEDURE testjoy;
BEGIN
  while TRUE do
  BEGIN
    joy;
    WRITELN(xcor : 5, '  ', ycor, '  ', fire1, '  ', fire2);
    xcor  := 0;
    ycor  := 0;
    fire1 := 0;
    fire2 := 0;
  END;
END;

BEGIN
  {No initialization required.}
END.

{
The above was a pretty quick and dirty approach to grabbing values
off the game card.  I'm sure that there are better means of doing it,
but I haven't put in the time to find them.  Interestingly enough,
the Turbo C version mentioned in the comments of the unit above does
not give as large a value for the maximum displacement of a joystick,
which is an indicator that the Turbo Pascal code is faster than its
equivalent Turbo C counterpart.
}
