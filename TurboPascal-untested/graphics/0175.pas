{
>Can someone post code for drawing a circle in Mode-X?

Here is a Circle procedure that will work in all Graphic modes (it's
even pretty fast...), as long as you have a putpixel procedure that
works.  It only works up until a radius of 50 or so, after that holes
start appearing.  I know why it happens, but I'm too lazy to fix it.

(This code is just cut and pasted from other units, so I have not
tested it.  It should work though...).
}

Unit Circle;

Interface

 Const
{ Fixed Math Const }
  ShiftFixed = 16;

{ Mode X (320x240) PutPixel Const }
  PlaneWidth = 80;     { Width of each plane in bytes        }
  ScreenSeg  = $A000;  { Segment of Display Memory In Mode X }
  MapMask    = $02;    { Index in SC of Map Mask register    }
  SCIndex    = $03C4;  { Sequence Controller Index           }

 Var
  SinTable,                             { Sin Table with 16 bits of Accuracy }
  CosTable : Array[0..360] Of FixedT;   { Cos Table with 16 bits of Accuracy }
  Color    : Byte                       { Color of Circle to be drawn        }

 Procedure PutPixel;                    { PutPixel Procedure from DDJ }
 Procedure Circle(X, Y, Radius : Word); { My Circle Procedure         }

Implementation

 Procedure InitSinCosTables;
  Var
   I      : Word;
   Radian : Real;
  Begin
   For I := 0 To 360 Do
    Begin
     Radian := I * 3.1415926535 / 180;
     SinTable[I] := Trunc(Sin(Radian) * 65536);
     CosTable[I] := Trunc(Cos(Radian) * 65536);
    End;
  End;

 Procedure PutPixel(X, Y : Word); Assembler;
  Asm
   Mov  AX, PlaneWidth
   Mul  [Y]                { offset of pixel's scan line in page         }
   Mov  DI, [X]
   ShR  DI, 2              { X/4 = offset of pixel in scan line          }
   Add  DI, AX             { offset of pixel in page                     }

   Mov  AX, ScreenSeg
   Mov  ES, AX             { point ES:DI to the pixel's address          }

   Mov  CL, Byte Ptr [X]
   And  CL, 011b           { CL = pixel's plane                          }
   Mov  AX, 0100h+MapMask  { AL = index in SC of Map Mask reg            }
   ShL  AH, CL             { set only the bit for the pixel's plane to 1 }
   Mov  DX, SCIndex        { set the Map Mask to enable only the         }
   Out  DX, AX             { pixel's plane                               }

   Mov  AL, [Color]
   Mov  ES:[DI], AL        { draw the pixel in the desired color         }
  End;

 Procedure Circle(X, Y, Radius : Word);
  Var
   XC, YC : Word;
  Begin
   For I := 0 To 360 Do
    Begin
     XC := X + (Radius * CosTable[I] ShR ShiftFixed);
     YC := Y + (Radius * SinTable[I] ShR ShiftFixed);
     PutPixel(XC, YC);
    End;
  End;

Begin
 InitSinCosTables;
End.

