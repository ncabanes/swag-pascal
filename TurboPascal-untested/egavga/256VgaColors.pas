(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0050.PAS
  Description: 256 VGA Colors
  Author: WILBER VAN LEIJEN
  Date: 05-31-93  08:09
*)

==============================================================================
 BBS: «« The Information and Technology Exchan
  To: DOUGLAS BAKER                Date: 11-11─91 (20:18)
From: WILBERT VAN.LEIJEN         Number: 2147   [101] PASCAL
Subj: 256 TEXT COLORS?           Status: Public
------------------------------------------------------------------------------
Hi Doug,

 > I was wondering if anyone knows if 256 text colors can be accessed
 > with a VGA adaptor. I figured that since such programs as VGADimmer
 > exist, (to change the brightness) I should be able to change the
 > intensity ofd each color to simulate the 256 colors. Any help and TP
 > 5.5 or 6.0 routines would be appreciated.

You can have no more than 16 colours in text mode.  These colours can be
selected on the VGA from 255 registers and changed at will.  Each register can
also be programmed to hold a specific Red, Blue and Green value ranging from
0..63, giving 64*64*64 = 262,144 unique colours.
The registers are referred to as the 'DAC registers'.

Program ShowDoug;

{$X+ }

uses Crt;

Const
  MinIntensity = 0;
  MaxIntensity = 63;

Type
  ColourRange  = MinIntensity..MaxIntensity;
  RGBType      = Record
                   r, g, b   : ColourRange;
                 end;

{ Store colour information to DAC register }

Procedure SetRegister(register : Byte; colour : ColourRange); Assembler;

ASM
        MOV     BH, colour
        MOV     BL, register
        MOV     AX, 1000h
        INT     10h
end;  { SetRegister }

{ Store the Red, Green and Blue intensity into a DAC register }

Procedure SetRGBValue(register : Byte; RGB : RGBType); Assembler;

ASM
        PUSH    DS
        LDS     SI, RGB
        XOR     BX, BX
        MOV     BL, register
        LODSB
        MOV     DH, AL
        LODSW
        XCHG    CX, AX
        XCHG    CH, CL
        MOV     AX, 1010h
        INT     10h
        POP     DS
end;  { SetRGBValue }

Var
  i, j, t : Integer;
  RGB : RGBType;

Begin
  ClrScr;
  Randomize;
  TextBackground(black);
  For i := 1 to 25 Do
    Begin
      t := 0;
      For j := 1 to 80 Do
        Begin
          TextColor(t);
          If j mod 5 = 0 Then
            Inc(t);
          If not ((j = 80) and (i = 25)) Then
            Write(#219);
      end;
    end;
  Repeat                          { fiddle with the registers }
    SetRegister(Random(16), Random(64));
    Delay(200);
  Until KeyPressed;
  ReadKey;
  Repeat                           { fiddle with the R, G, B values }
    RGB.r := Random(255);
    RGB.g := Random(255);
    RGB.b := Random(255);
    SetRGBValue(Random(64), RGB);
  Until KeyPressed;
end.


--- Dutchie V2.91d
 * Origin: Point Wilbert | 'I think, therefore I ASM'. (2:500/12.10956)

