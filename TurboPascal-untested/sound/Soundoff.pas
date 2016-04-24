(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0011.PAS
  Description: SOUNDOFF.PAS
  Author: STEVEN TALLENT
  Date: 05-28-93  13:57
*)

{
STEVEN TALLENT

> I am look For a piece of code [...] that will turn off the speaker.

This is tested code, and should do the trick.  It does its work by
turning off the PC speaker 18.2 times per second.  This should reduce
any Sound to maybe a click or two.  Unfortunately, some games and
music software will bypass it (ModPlay, Wolfenstein), but most beeps
and whistles will be gone.  This is a TSR Program, and takes about 3k
memory (yuk), but you can load it high if you want.  I've found it
especially useful during late-night BBSing (no alarms at connect/File
xfer finish). Hope this does the trick!  Considering its size and
relative isolation from normal Programs, I didn't see fit to use CLI/STI.
}

{$M 1024,0,0}  {BTW, is there any way to make this smaller?!?}
{$N-,S-,G+} { Use g- For 8088 systems, g+ For V20 and above }
Program NoSpeak;
Uses
  Dos;

Procedure ShutOff; INTERRUPT;
begin
  Port [97] := Port[97] and 253; {Turn off speaker and disconnect timer}
end;

begin
  SetIntVec( $1C, @ShutOff);
  Keep(0);
end.


