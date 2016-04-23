{
Here a small BPW source which implements a Delay(ms : Word); just like
in the DOS version. Limitations are that only a minimum delay is
guaranteed, so timing is not exact. This is due to the task switching
nature of windows which makes it impossible to generate accurate delays.
For large values it's however quite good.

The timer used has msec accuracy and has overflow every 49 days (if
windows lasts that long in one session.
}

Uses
  Winprocs;

Procedure Delay(ms : Word);

Var
  theend,
  marker  : Longint;

Begin
{----Potential overflow if windows runs for 49 days without a stop}
  marker:=GetTickCount;
{$R-}
  theend:=Longint(marker+ms);
{$R+}
{----First see if timer overrun will occur and wait for it. Then test as
usual}
  If (theend<marker)
    Then While (GetTickCount>=0) DO;
  While (theend>GettickCount) Do;
End; {of Delay}
