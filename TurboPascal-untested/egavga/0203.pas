{
>Well... Does anyone know how to make flames? is it a fractal
>or something? does anyone can explain it (Formula ETC.) ???

Actually, it's pretty simple.  Look at this diagram...

 { ...      . - A Pixel                     }
 { .X.      X - Pixel we're on              }
 { 123      1, 2, 3 - Pixels to be averaged }

 {  - fill the bottom row with random numbers             }
 {    - for each row:                                     }
 {      - for each pixel:                                 }
 {        - average the three pixels below it and itself  }
 {        - decrease by one (if not already zero)         }
{
If that wasn't very clear, here's some source (sorry there's asm).
}

{$A+,B-,D+,E+,F-,G+,I+,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
Program Fire;
 Uses Crt;

 Const
  VGASeg = $A000;

 Type
  VGAMem  = Array[0..63999] Of Byte;

 Var
  VideoMem : VGAMem Absolute VGASeg:0;
  OldMode,
  Color    : Byte;
  I        : Word;

Procedure InitMode13h; Assembler;
 Asm
  Mov AH, 0Fh       { Get Current Video Mode    }
  Int 10h
  Mov [OldMode], AL { Save it                   }
  Mov AX, 13H       { Init 320x200x256 Graphics }
  Int 10H
 End;

Procedure CloseMode13h; Assembler;
 Asm
  Xor AH, AH
  Mov AL, [OldMode] { Init Old Video Mode }
  Int 10H
 End;

Procedure PutPixel(X, Y : Word; Color : Byte); Assembler;
 Asm
  Mov AX, VGASeg
  Mov ES, AX
  Mov BX, Y
  Mov DI, X
  Mov AH, BL
  Add DI, AX
  ShR AX, 2
  Add DI, AX
  Mov AL, Color
  Mov ES:[DI], AL
 End;

Procedure MakePalette;
 Begin
  Port[$3C6] := $FF;
  Port[$3C8] := 0;
  For I := 0 To 255 Do
   Begin
    Port[$3C9] := I ShR 2;
    Port[$3C9] := I ShR 4;
    Port[$3C9] := 0;
   End;
 End;

Procedure UpDateFire;
 Begin
  For I := 0 To 319 Do
    If Random(2) = 1 Then
      Putpixel(I, 199, 0) Else
        Putpixel(I, I, 0);
   Asm
    Mov DI, 0A000h     { ES := Pixel Location (Segment) }
    Mov ES, DI
    Mov DI, 63999-320  { DI := Current Pixel location (Offset) }
    Mov CX, 32000      { Number of pixels to put (Counter)     }
    Xor DH, DH
   @PixLoop:
    Mov AL, ES:[DI]     { AX := Average of colors       }
    Mov DL, ES:[DI+319] { DL := Temp Reg to hold colors }
    Add AX, DX
    Mov DL, ES:[DI+320]
    Add AX, DX
    Mov DL, ES:[DI+321]
    Add AX, DX
    ShR AX, 2
    JZ @Skip
    Dec AL
   @Skip:
    Mov ES:[DI], AL
    Dec DI
    Dec CX
    JNZ @PixLoop
   End;
 End;

Begin
 Randomize;
 InitMode13h;
 MakePalette;
  Repeat
   UpDateFire;
  Until KeyPressed;
 ReadKey;
 CloseMode13h;
 Writeln('This Program was written by Rick Haines in Turbo Pascal 7.0');
End.
