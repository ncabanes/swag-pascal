{
 STG>Does anyone know off hand if I can be in text mode and window in a
 STG>window and put the wondow only in graphics mode?
 STG>I have a program that I need to have a graph in.  Does anyone have some
 STG>code for using the PLOT procedure to plot variables.  The values for
 STG>the Y axis are from 1 - 2000, and for the X axis from 1 - 24.

        Yes, it's possible... sort of.   If you have a VGA (or
EGA) you can have 2 separate character sets on screen at once.
Use one character set for text, and redefine the other for your
graphics window.  The only problem is that your graphics window
can only be composed of 256 characters total.  So, a 16 X 16
character square would only give you a vertical resolution of 256
pixels and a horizontal resolution of 128 pixels.  The following
code is an example of how one would do this.

                                                Dave

}

Program GraphicsInTextModeExample;

{================================================

         Graphics In Text Mode Example
            Programmed by David Dahl
                    12/24/93
    This program and source are PUBLIC DOMAIN

 ------------------------------------------------

   This example uses a second font as a pseudo-
   graphics window.  This program requires VGA.

 ================================================}

Uses  CRT;

Const { Dimentions of The Graphics Window in Characters }
      ChrSizeX = 32;
      ChrSizeY = 256 DIV ChrSizeX;
      { Dimentions of The Graphics Window in Pixels }
      MaxX     = ChrSizeX * 8;
      MaxY     = ChrSizeY * 16;

{-[ Set Character Width to 8 Pixels ]-------------------------------------}
Procedure SetCharWidthTo8; Assembler;
Asm
   { Change To 640 Horz Res }
   MOV DX, $3CC
   IN  AL, DX
   AND AL, Not(4 OR 8)
   MOV DX, $3C2
   OUT DX, AL
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 0
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Switch To 8 Pixel Wide Fonts }
   MOV DX, $3C4
   MOV AL, 1
   OUT DX, AL
   MOV DX, $3C5
   IN  AL, DX
   OR  AL, 1
   OUT DX, AL
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 0
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Center Screen }
   MOV DX, $3DA
   IN  AL, DX
   MOV DX, $3C0
   MOV AL, $13 OR 32
   OUT DX, AL
   MOV AL, 0
   OUT DX, AL
End;
{-[ Turn On Dual Fonts ]--------------------------------------------------}
Procedure SetDualFonts; Assembler;
ASM
   { Set Fonts 0 & 1 }
   MOV BL, 4
   MOV AX, $1103
   INT $10
END;
{-[ Turn On Access To Font Memory ]---------------------------------------}
Procedure SetAccessToFontMemory; Assembler;
ASM
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 1
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Change From Odd/Even Addressing to Linear }
   MOV DX, $3C4
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 7
   OUT DX, AL
   { Switch Write Access To Plane 2 }
   MOV DX, $3C4
   MOV AL, 2
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 4
   OUT DX, AL
   { Set Read Map Reg To Plane 2 }
   MOV DX, $3CE
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 2
   OUT DX, AL
   { Set Graphics Mode Reg }
   MOV DX, $3CE
   MOV AL, 5
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 0
   OUT DX, AL
   { Set Misc. Reg }
   MOV DX, $3CE
   MOV AL, 6
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 12
   OUT DX, AL
End;
{-[ Turn On Access to Text Memory ]---------------------------------------}
Procedure SetAccessToTextMemory; Assembler;
ASM
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 1
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Change To Odd/Even Addressing }
   MOV DX, $3C4
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Switch Write Access }
   MOV DX, $3C4
   MOV AL, 2
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3  {?}
   OUT DX, AL
   { Set Read Map Reg }
   MOV DX, $3CE
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 0
   OUT DX, AL
   { Set Graphics Mode Reg }
   MOV DX, $3CE
   MOV AL, 5
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, $10
   OUT DX, AL
   { Set Misc. Reg }
   MOV DX, $3CE
   MOV AL, 6
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 14
   OUT DX, AL
End;
{-[ Clear The Pseudo-Graphics Window by Clearing Font Definition ]--------}
Procedure ClearGraphicsWindow;
Begin
     SetAccessToFontMemory;
     FillChar (MEM[$B800:$4000], 32 * 256, 0);
     SetAccessToTextMemory;
End;
{-[ Turn The Cursor Off ]-------------------------------------------------}
Procedure TurnCursorOff; Assembler;
ASM
   MOV DX, $3D4
   MOV AL, $0A
   OUT DX, AL
   MOV DX, $3D5
   IN  AL, DX
   OR  AL, 32
   OUT DX, AL
End;
{-[ Turn The Cursor On ]--------------------------------------------------}
Procedure TurnCursorOn; Assembler;
ASM
   MOV DX, $3D4
   MOV AL, $0A
   OUT DX, AL
   MOV DX, $3D5
   IN  AL, DX
   AND AL, Not(32)
   OUT DX, AL
End;
{-[ Set Up The Pseudo-Graphics Window ]-----------------------------------}
Procedure SetGraphicsWindow (XCoord, YCoord    : Byte;
                             Color, BackGround : Byte);
Var CounterX,
    CounterY  : Byte;
Begin
     For CounterY := 0 to (ChrSizeY-1) do
         For CounterX := 0 to (ChrSizeX-1) do
             MEMW[$B800:CounterX*2 + XCoord*2 + (YCoord * 80 * 2) +
                 (CounterY * 80 * 2)] :=
                   (CounterX + CounterY * ChrSizeX) OR
                   (((Color OR 8) OR ((BackGround AND 15) SHL 4)) SHL 8);
End;
{-[ Plot a Pixel in The Pseudo-Graphics Window ]--------------------------}
Procedure PutPixel (Xin, Yin : Word);
Var RealY,
    RealX      : Word;
Begin
     If (Xin < MaxX) AND
        (Yin < MaxY)
     Then
     Begin
          RealX := (Xin DIV 8) * 32;
          RealY := (Yin MOD 16) + ((Yin DIV 16) * (32 * ChrSizeX));
          SetAccessToFontMemory;
          MEM[$B800:$4000 + RealX + RealY] :=
              MEM[$B800:$4000 + RealX + RealY] OR (128 SHR (Xin MOD 8));
          SetAccessToTextMemory;
     End;
End;
{-[ Draw A Line ]---------------------------------------------------------}
{ OCTANT DDA Subroutine converted from the BASIC listing on pages 26 - 27 }
{ from the book _Microcomputer_Displays,_Graphics,_ And_Animation_ by     }
{ Bruce A. Artwick                                                        }
Procedure Line (XStart, YStart, XEnd, YEnd : Word);
Var StartX,
    StartY,
    EndX,
    EndY    : Word;
    DX,
    DY      : Integer;
    CNTDWN  : Integer;
    Errr    : Integer;
    Temp    : Integer;
    NotDone : Boolean;
Begin
     NotDone := True;
     StartX := XStart;
     StartY := YStart;
     EndX   := XEnd;
     EndY   := YEnd;
     If EndX < StartX Then
     Begin
          { Mirror Quadrants 2,3 to 1,4 }
          Temp   := StartX;
          StartX := EndX;
          EndX   := Temp;
          Temp   := StartY;
          StartY := EndY;
          EndY   := Temp;
     End;
     DX := EndX - StartX;
     DY := EndY - StartY;
     If DY < 0 Then
     Begin
          If -DY > DX Then
          Begin
               { Octant 7 Line Generation }
               CntDwn := -DY + 1;
               ERRR   := -(-DY shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Dec(StartY);
                         Inc(Errr, DX);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartX);
                              Inc(Errr, DY);
                         End;
                    End;
               End;
          End
          Else
          Begin
               { Octant 8 Line Generation }
               CntDwn := DX + 1;
               ERRR   := -(DX shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartX);
                         Dec(Errr, DY);
                         If Errr >= 0 Then
                         Begin
                              Dec(StartY);
                              Dec(Errr, DX);
                         End;
                    End;
               End;
          End;
     End
     Else If DY > DX Then
          Begin
               { Octant 2 Line Generation }
               CntDwn := DY + 1;
               ERRR   := -(DY shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartY);
                         Inc(Errr, DX);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartX);
                              Dec(Errr, DY);
                         End;
                    End;
               End;
          End
          Else
          { Octant 1 Line Generation }
          Begin
               CntDwn := DX + 1;
               ERRR   := -(DX shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartX);
                         Inc(Errr, DY);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartY);
                              Dec(Errr, DX);
                         End;
                    End;
               End;
          End;
End;
{-[ Draw A Circle ]-----------------------------------------------------}
{ Algorithm based on the Pseudocode from page 83 of the book _Advanced  }
{ Graphics_In_C_ by Nelson Johnson                                      }
Procedure Circle (XCoord, YCoord, Radius : Integer);
Var   d     : Integer;
      X, Y  : Integer;
    Procedure Symmetry (xc, yc, x, y : integer);
    Begin
         PutPixel ( X+xc,  Y+yc);
         PutPixel ( X+xc, -Y+yc);
         PutPixel (-X+xc, -Y+yc);
         PutPixel (-X+xc,  Y+yc);
         PutPixel ( Y+xc,  X+yc);
         PutPixel ( Y+xc, -X+yc);
         PutPixel (-Y+xc, -X+yc);
         PutPixel (-Y+xc,  X+yc);
    End;
Begin
     x := 0;
     y := abs(Radius);
     d := 3 - 2 * y;
     While (x < y) do
     Begin
          Symmetry (XCoord, YCoord, x, y);
          if (d < 0) Then
             inc(d, (4 * x) + 6)
          else
          Begin
               inc (d, 4 * (x - y) + 10);
               dec (y);
          End;
          inc(x);
     End;
     If x = y then
        Symmetry (XCoord, YCoord, x, y);
End;
{-[ Draw A Rectangle ]----------------------------------------------------}
Procedure Rectangle (X1, Y1, X2, Y2 : Word);
Begin
     { Draw Top Of Box }
     Line (X1, Y1, X2, Y1);
     { Draw Right Side Of Box }
     Line (X2, Y1, X2, Y2);
     { Draw Left Side Of Box }
     Line (X1, Y1, X1, Y2);
     { Draw Botton Of Box }
     Line (X1, Y2, X2, Y2);
End;
{=[ Main Program ]========================================================}

Var C : Word;
    Key : Char;
Begin

     TextMode (C80);
     TurnCursorOff;
     SetCharWidthTo8;
     SetDualFonts;
     ClearGraphicsWindow;
     TextColor(LightGray);
     ClrScr;

     SetGraphicsWindow (40, 0, White, Blue);   {X, Y, Color, BGColor}

     Writeln ('Graphics In Text Mode Example');
     Writeln ('Programmed by David Dahl');
     Writeln ('This is PUBLIC DOMAIN');
     Writeln;
     Writeln ('The graphics window to the right is');
     Writeln ('made up of custom characters of the');
     Writeln ('second font.');
     Writeln;
     Writeln ('There are four graphics primitives');
     Writeln ('available in this example program.');
     Writeln ('Circle, Line, PutPixel, and ');
     Writeln ('Rectangle are avaiable for your own');
     Writeln ('use.');
     Writeln;

     Randomize;
     For C := 1 to 10 do
     Begin
          Line (Random(MaxX), Random(MaxY),
                Random(MaxX), Random(MaxY));

          Circle (Random(MaxX), Random(MaxY), Random(30));

          Rectangle (Random(MaxX), Random(MaxY),
                     Random(MaxX), Random(MaxY));
     End;

     Writeln ('Press [RETURN] to exit.');
     Readln;
     TurnCursorOn;
     TextMode (C80);
End.
