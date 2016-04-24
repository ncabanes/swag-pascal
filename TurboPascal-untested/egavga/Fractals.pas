(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0083.PAS
  Description: Fractals!
  Author: MIGUEL MARTINEZ
  Date: 01-27-94  12:02
*)

{
For all of you who are interested on fractals, here is a little program,
taken from a source code in Modula-2, that will draw a Mandelbrot fractal.

Just one problem: If your computer doesn't have a math coprocessor, the
program will run "a bit" slow :).

Try modifying all the constants, you'll get strange results :).
}
{$N+}
{$X+ Enable Extended Syntax                                       }
Program Mandelbrot;     {Using real numbers. For TP 6.0 and above }

Uses Crt;               {Only to use "ReadKey" Function.          }

Const Colours=255;       {Number of colors to be on the image.     }
      Width=320;        {Width of the image.                      }
      Height=200;       {Height of the image.                     }
      Limit=8.0;        {Until when we calculate.                 }
      XRMin=-2.0;       {Left limit of the fractal.               }
      XRMax=1.0;        {Right limit of the fractal.              }
      YRMin=-1.3;       {Lower limit of the fractal.              }
      YRMax=1.3;        {Upper limit of the fractal.              }

Type Palette=Array[0..767] of Byte;  {MCGA/VGA palette type       }

Var XPos,YPos:Word;

{Sets the desired video mode (13h)                                }
Procedure SetVideoMode(VideoMode:Byte); Assembler;
Asm
  xor ax,ax                 {BIOS Function 00h: Set Video Mode.   }
  mov al,VideoMode          {Desired Video Mode.                  }
  int 10h
End;

{Creates a palette: Black --> red --> yellow                      }
Procedure MakePalette;
Var CPal:Palette;
    i:Byte;

  {Sets the palette.                                              }
  Procedure SetPalette(Pal:Palette); Assembler;
  Asm
    push es
    mov ax,1012h            {BIOS function 10h, subfunction 12h.  }
    xor bx,bx               {first color register.                }
    mov cx,20h              {number of color registers.           }
    les dx,Pal              {ES:DX Segment:Offset of color table. }
    Int 10h
    pop es
  End;

Begin
  For i:=0 to 15 do
  Begin
    CPal[3*i]:=4*i+3; CPal[3*i+1]:=0; CPal[3*i+2]:=0;
    CPal[3*i+48]:=63; CPal[3*i+49]:=4*i+3; CPal[3*i+50]:=0;
  End;
  SetPalette(CPal);
End;

{Draws a Plot of the desired color on screen.                     }
Procedure DrawPixel(XPos,YPos:Word; PlotColour:Byte);
Begin
  Mem[$A000:YPos*320+XPos]:=PlotColour;
End;

{Needs to be explained? ;-)                                       }
Procedure Beep;
Begin
  Sound(3000); Delay(90); Sound(2500); Delay(90);
  NoSound;
End;

{Calculates the color for each point.                             }
Function ComputeColour(XPos,YPos:Word):Byte;
Var RealP,ImagP:Real;
    CurrX,CurrY:Real;
    a2,b2:Real;
    Counter:Byte;

Begin
CurrX:=XPos/Width*(XRMax-XRMin)+XRMin;
  CurrY:=YPos/Height*(YRMax-YRMin)+YRMin;
  RealP:=0;
  ImagP:=0;
  Counter:=0;
  Repeat
    a2:=Sqr(RealP);
    b2:=Sqr(ImagP);
    ImagP:=2*RealP*ImagP+CurrY;
    RealP:=a2-b2+CurrX;
    Inc(Counter);
  Until (Counter>=Colours) or (a2+b2>=Limit);
  ComputeColour:=Counter-1;
End;

Begin
  Writeln('Program to draw Fractals of Mandelbrot.');
  Writeln('Written by Miguel Martínez. ');
  Writeln('Press any key to continue...');
  If ReadKey=#0 Then ReadKey;   {Skip double codes.               }

  SetVideoMode(19);             {Set 320x200x256 graphics mode.   }
  MakePalette;
  For YPos:=0 to (Height-1) do
For XPos:=0 to (Width-1) do
      DrawPixel(XPos,YPos,ComputeColour(XPos,YPos));
  Beep;                         {Beep when finished.              }
  If ReadKey=#0 Then ReadKey;
  ReadKey;
  SetVideoMode(3);              {Restore text mode.               }
End.

