(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0205.PAS
  Description: Fire Code III
  Author: EVAN JONES
  Date: 05-26-95  23:06
*)

{
    Fire v1.0
    Written By Evan Jones

The Flame Effect :-

  X = Pixel  A,B,C = Values to average  DV = Decay Value

  123  123
  4X5  4X5
  678  ABC  X's colour = A+B+C / 3 ( beacause were adding 3 values ) - DV
        ^────────────────────────────────┐
  ^ X and its surrounding pixel colours. └> X and the pixels we've chosen

The basics of the flame effect are to choose as many of the 8 pixels
( you could use others ) arround the pixel, you are trying to finds
colour, as you want.  Then find the average ( add up all the values and
divide by the ammount of values you added ) of the pixels and then
use this as the pixel's colour.  You have to do this for every one of the
pixels in your pixel array.
Because were calculating values then putting them in the array you can't
just use the screen.  So you are going to have to use another array to do
all your calculations and then move that to the screen.

This file is provided so that you programmers who want to write demos and
stuff like that can learn how to.  I've commented most of the source and
have only used a couple of assembler statments so those of you ( you know
who you are ) who don't know how to write in assembler can still know what
is going on, although I can't guarentee that.

I would like it if you could send me a message saying what you think of this
and if you have added things I'd also like a copy of the source. You can
mail me at :-

  Evan.Jones@Millenium.Cbr.Fidonet.Org
  - Or by Fidonet -
  "Evan Jones" at 3:620/265
}

Program Flames;

Const
  Pal : array[1..768-16*3] Of Byte =
  (   0,  0,  0,  0,  0, 24,  0,  0, 24,  0,  0, 28,
  0,  0, 32,  0,  0, 32,  0,  0, 36,  0,  0, 40,
  8,  0, 40, 16,  0, 36, 24,  0, 36, 32,  0, 32,
  40, 0, 28, 48,  0, 28, 56,  0, 24, 64,  0, 20,
  72, 0, 20, 80,  0, 16, 88,  0, 16, 96,  0, 12,
  104,0, 8, 112,  0,  8,120,  0,  4,128,  0,  0,
  128,0, 0, 132,  0,  0,136,  0,  0,140,  0,  0,
  144,  0,  0,144, 0,  0,148,  0,  0,152,  0,  0,
  156,  0,  0,160, 0,  0,160,  0,  0,164,  0,  0,
  168,  0,  0,172,  0,  0,176,  0,  0,180,  0,  0,
  184,  4,  0,188,  4,  0,192,  8,  0,196,  8,  0,
  200, 12,  0,204, 12,  0,208, 16,  0,212, 16,  0,
  216, 20,  0,220, 20,  0,224, 24,  0,228, 24,  0,
  232, 28,  0,236, 28,  0,240, 32,  0,244, 32,  0,
  252, 36,  0,252, 36,  0,252, 40,  0,252, 40,  0,
  252, 44,  0,252, 44,  0,252, 48,  0,252, 48,  0,
  252, 52,  0,252, 52,  0,252, 56,  0,252, 56,  0,
  252, 60,  0,252, 60,  0,252, 64,  0,252, 64,  0,
  252, 68,  0,252, 68,  0,252, 72,  0,252, 72,  0,
  252, 76,  0,252, 76,  0,252, 80,  0,252, 80,  0,
  252, 84,  0,252, 84,  0,252, 88,  0,252, 88,  0,
  252, 92,  0,252, 96,  0,252, 96,  0,252,100,  0,
  252,100,  0,252,104,  0,252,104,  0,252,108,  0,
  252,108,  0,252,112,  0,252,112,  0,252,116,  0,
  252,116,  0,252,120,  0,252,120,  0,252,124,  0,
  252,124,  0,252,128,  0,252,128,  0,252,132,  0,
  252,132,  0,252,136,  0,252, 136,   0,252, 140,   0,
  252,152,  0,252, 152,   0,252, 156,   0,252, 156,   0,
  252,160,  0,252, 160,   0,252, 164,   0,252, 164,   0,
  252,168,  0,252, 168,   0,252, 172,   0,252, 172,   0,
  252,176,  0,252, 176,   0,252, 180,   0,252, 180,   0,
  252,184,  0,252, 184,   0,252, 188,   0,252, 188,   0,
  252,196,  0,252, 196,   0,252, 196,   0,252, 190,   0,
  252,200,  0,252, 200,   0,252, 204,   0,252, 208,   0,
  252,208,  0,252, 208,   0,252, 208,   0,252, 208,   0,
  252,212,  0,252, 212,   0,252, 212,   0,252, 212,   0,
  252,216,  0,252, 216,   0,252, 216,   0,252, 216,   0,
  252,216,  0,252, 220,   0,252, 220,   0,252, 220,   0,
  252,224,  0,252, 228,   0,252, 228,   0,252, 228,   0,
  252,228,  0,252, 228,   0,252, 232,   0,252, 232,   0,
  252,236,  0,252, 236,   0,252, 240,   0,252, 240,   0,
  252,240,  0,252, 240,   0,252, 240,   0,252, 244,   0,
  252,248,  0,252, 248,   0,252, 248,   0,252, 252,   0,
  252,252,  4,252, 252,   8,252, 252,  12,252, 252,  16,
  252,252, 20,252, 252,  24,252, 252,  28,252, 252,  32,
  252,252, 36,252, 252,  40,252, 252,  40,252, 252,  44,
  252,252, 48,252, 252,  52,252, 252,  56,252, 252,  60,
  252,252, 64,252, 252,  68,252, 252,  72,252, 252,  76,
  252,252, 82,252, 252,  84,252, 252,  86,252, 252,  88,
  252,252, 92,252, 252,  96,252, 252, 100,252, 252, 104,
  252,252,108,252, 252, 112,252, 252, 116,252, 252, 120,
  252,252,124,252, 252, 124,252, 252, 128,252, 252, 132,
  252,252,136,252, 252, 140,252, 252, 144,252, 252, 148,
  252,252,152,252, 252, 154,252, 252, 162,252, 252, 164,
  252,252,168,252, 252, 168,252, 252, 172,252, 252, 176,
  252,252,180,252, 252, 184,252, 252, 188,252, 252, 192,
  252,252,196,252, 252, 200,252, 252, 204,252, 252, 208,
  252,252,208,252, 252, 212,252, 252, 216,252, 252, 220,
  252,252,224,252, 252, 228,252, 252, 232,252, 252, 236,
  252,252,240,252, 252, 244,252, 252, 248,252, 252, 252);

Var
  FlameArr      : Array[0..99,0..159] Of Byte;
  {^ the array to calculate everything }
  B,P           : Byte;
  { ^ some dummy variables }

Procedure PlotPixel ( X, Y : Word; C : Byte ); Assembler;
{ Sorry it's in assembler but I would be even slower if I didn't}
Asm
  Mov   AX, 320
  Mul   Y           { Get the Y Pos ( Y * 320 cuz were in 320x200 mode ) }
  Mov   DI, AX
  Add   DI, X       { add the X value to find the offset }
  Mov   AX, 0A000h
  Mov   ES, AX      { set ES to the video seg }
  Mov   AL, C
  Mov   [ES:DI], AL { move the colour to the video memory }
End;

Procedure CalcFlames;
Var
  X, Y    : Word;
  { two variables for accessing the points in the array and screen }
  Calc    : Word;
  { a temp value for CALCulating things }

Begin
{ For flame effect scroll through every pixel and  }
{ choose some other pixels around it. Divide by    }
{ the ammount of pixels you added up and then      }
{ subtract a decay ammount.                        }
{                                        2          }
{  123   A23   X = 1+5+6/3 - Decay Value. = 4 - DV }
{  3X5   3XB       ^ ^ ^                           }
{  692   C92       A+B+C/3                         }
{                                                  }
{ X = Pixel                                        }
{                                                  }
  For Y := 0 To 99 Do  { number of rows }
    For X := 0 To 159 Do { number of cols }
      Begin
        Calc := FlameArr[Y+1,X] + FlameArr[Y+1,X-1] +
          FlameArr[Y+1,X+1] + FlameArr[Y,X];
          { add the values of the surrounding pixels }
        FlameArr[Y,X] := Calc Div 4;
        { divide by the number of pixels added up }
        If FlameArr[Y,X] > 2 Then
          Dec ( FlameArr[Y,X], 2 );
        { decrement by the decay value }
      End;
  For X := 0 To 159 Do                    { Comment this and the next line }
    FlameArr[99,X] := Random ( 204 ) + 11;{ for interesting effect }
  { set a new bottom line }
  For Y := 0 To 97 Do
    For X := 0 To 159 Do
      Begin
        { plot the pixels to the screen }
        PlotPixel ( X+80, Y+50, FlameArr[Y,X] );
        { added 80 to X and 50 to Y to center on screen}
       {PlotPixel ( X * 2, Y * 2, FlameArr[Y,X] );
        PlotPixel ( X * 2+1, Y * 2+1, FlameArr[Y,X] );
       {^^ Un-comment these two lines for a "Grid" Effect }
      End;
End;

Procedure SetColour ( Index, R, G, B : Byte );
{ Sets a colour to a specific RGB value }
Begin
  Port[$3C8] := Index;
  Port[$3C9] := R;
  Port[$3C9] := G;
  Port[$3C9] := B;
End;

Begin
  { Change to MCGA 320x200x256 mode }
  Asm
    Mov AX, 13h
    Int 10h
  End;
  { Initalize random seed }
  Randomize;
  { Clear the Flame Array }
  FillChar ( FlameArr, SizeOf ( FlameArr ), 0 );
  { calculate a new bottom line }
  For B := 0 To 159 Do
    FlameArr[99,B] := Random ( 204 ) + 11;
  { make a the colours go from black to red }
  For B := 0 To 255 Do
    SetColour ( B, ( B * 43 ) Shr 7, 0, 0 );
  Repeat
    { calculate the flames }
    CalcFlames;
  { until ESC is pressed }
  Until ( Port[$60] = $81 );
  { go back to 80x25x16 text mode }
  Asm
    Mov AX, 3
    Int 10h
  End;
End.---

