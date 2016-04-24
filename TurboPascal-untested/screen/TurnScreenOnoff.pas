(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0031.PAS
  Description: Turn Screen On/Off
  Author: POON ROJANASOONTHON
  Date: 08-27-93  21:55
*)

{
Poon Rojanasoonthon

>I use alot of line draws and some text on the screen....the lines come out
>first and then the text a second or two later....is there a way so that the
>whole output comes at once.  I tried Setvisualpage and setactivepage but the
>the whole output screen is off.

To Turn On/Off the Screen you may use these procedures
}

Procedure ScreenOn;
Begin
  Port[$3C4] := 1;
  Port[$3C5] := $00;
end;

Procedure ScreenOff;
Begin
  Port[$3C4] := 1;
  Port[$3C5] := Port[$3C5] or $20;
end;

{
>And my last question is.....I am also writing a card game in graphics.  I kn
>the ASCII values for the heart, club, spades and diamonds are thru 3-6.  The
>come out in the TEXT mode but they won't show on the screen in GRAPHICS.  Is
>there a way to display them or not?  Thanks.
To Put text in graphics screen you should turn off the directvideo to off first.
        DirectVideo:=False;
}

begin
  Writeln('Turning Screen Off...');
  Readln;
  ScreenOff;
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Writeln('Can you see this??');
  Readln;
  ScreenOn;
  Readln;
end.

