
{
Here is an (TP 5.5) atom that will help you grab "extended"
keyboard scancodes.  I think the problem you're having has to
do with the fact that you can't trap hot keys inside ReadLn,
yes?  You need to build a set of routines that support
a-key-at-a-time input into a string, echoing the keystrokes
to the screen as you go.  This "atom" just handles keystrokes-
the string handling is probably _WAY_ too long to list here.
}

Program _;

Uses Crt;

Type KeyType = (Ascii,ExtendedKey,Escape);

Var
KtGlb : KeyType;
ChGlb : Char;

Procedure GetExtKey( Var Ch:Char;  Var Kt:KeyType; );
Begin
  Repeat
  Until KeyPressed;
  Kt := Ascii;
  Ch := ReadKey;
  If (Ch=#0) Then
    Begin
      Ch := ReadKey;
      If (Ord(Ch)=27) Then Kt := Escape Else Kt := ExtendedKey;
    End;
End;

Procedure Main
Begin
  Write('Press a key.');
  ChGlb := #0;
  KtGlb := Ascii;
  Repeat
    GotoXY(13,1);
    GetExtKey(ChGlb,KtGlb);
    GotoXY(1,2);
    ClrEol;
    GotoXY(1,2);
    Case KtGlb Of
      Ascii       : Write('Ascii,    ');
      ExtendedKey : Write('Extended, ');
      Escape      : Write('Escape,   ')
    End;
    Write('Scancode = ',Ord(Ch));
  Until (Kt=Escape);
  WriteLn;
  WriteLn;
End;

Begin
  ClrScr;
  Main;
End.

This should help you capture _any_ extended scan code from the keyboard.
PgUp, PgDn, Ctrl-PgUp, Alt-Shft-F5, etc...  Chapter Seventeen of "Turbo
Pascal 5.5, The Complete Reference" by O'Brien (Borland/Osborne/McGraw-
Hill ISBN 0-07-881501-0) covers the issue of buffered string input pretty
well.

And as for your next berrage of questions, "Turbo Pascal Advanced
Techniques" by Ohlsen & Stoker (Que Corp. ISBN 0-88022-432-0) covers
DOS windowing very nicely.  (Also many other goodies).

Hope it helped a little.
David Kandrat
