(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0146.PAS
  Description: Copper Bar Effects
  Author: THILO WAGNER
  Date: 11-26-94  04:58
*)

{
> I'm trying to do a copper bars effect in Turbo Pascal. At
> the moment, I have three different coloured _LINES_ which go
> up and down etc. etc.

Here is a copper-car-routine which I found in an old issue of an german
computer-magazine. Maybe it helps you..:
}
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X-}       { For TP 6.0 }
Program RedBar;
Uses
  Crt;

Var
  C       : Byte;
  C2,
  C3,
  C4      : Word;
  SinTab  : Array [0..127] of Word;
  HeadPtr : Word Absolute $0040:$001A;
  TailPtr : Word Absolute $0040:$001C;
  Zaehler : Word;

Begin
  For C := 0 to 127 do
    SinTab[C] := Trunc((Sin((2 * Pi / 128) * C) + 1) * 135);

  C3 := 0;

  Repeat
    Inline($FA);   {CLI}

    Repeat Until (Port[$3DA] and 8) > 0;
    Repeat Until (Port[$3DA] and 8) = 0;

    For C4 := 0 to SinTab[C3 and 127] do
    Begin
      Repeat Until (Port[$3DA] and 1) = 0;
      Repeat Until (Port[$3DA] and 1) > 0;
    End;

    For C := 0 to 63 do
    Begin
      Repeat Until (Port[$3DA] and 1) > 0;
      Port[$3C8] := 0;
      Port[$3C9] := 0;
      Port[$3C9] := C;
      Port[$3C9] := 63-C;
      Repeat Until (Port[$3DA] and 1) = 0;
    End;

    For C := 63 downTo 0 do
    Begin
      Repeat Until (Port[$3DA] and 1) > 0;
      Port[$3C8] := 0;
      Port[$3C9] := 0;
      Port[$3C9] := C;
      Port[$3C9] := 63-C;
      Repeat Until (Port[$3DA] and 1) = 0;
    End;

    Inc(C3);
    Inline($FB); {STI}

  Until HeadPtr <> TailPtr;

  HeadPtr := TailPtr;
  Port[$3C8] := 0;
  Port[$3C9] := 0;
  Port[$3C9] := 0;
  Port[$3C9] := 0;
End.

