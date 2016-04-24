(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0255.PAS
  Description: Watery Ripples
  Author: MORTEN HANSEN
  Date: 09-04-95  11:02
*)

{
 DD> could anyone tell me how to simulate realtime moving watersurface ripples
 DD> on a mode13h vga graphic picture ? something like getting the location of a
 DD> pixel and then set that pixel at another location according to a sine orr
 DD> a cos wave or something... i feel it has to be something lake that..

Is this what you had in mind?

{$G+}

Uses
   Crt;

Const
   SinTabSize                   = 2048;
   SinTabAmp                    = 128;

Type
   ScrType                      = Array[0..199,0..319] of Byte;
   ScrPtr                       = ^ScrType;
   SinTabType                   = Array[0..SinTabSize-1] of Integer;
   SinTabPtr                    = ^SinTabType;

Var
   VisualScreen,BufferScreen    : ScrPtr;
   SinTab                       : SinTabPtr;

Procedure SetMode13;Assembler;
Asm
   mov   ax,0013h
   int   10h
End;

Procedure PutPixel(Scr:ScrPtr;x:Integer;y,Col:Byte);Assembler;
Asm
   les   di,Scr
   xor   bh,bh
   mov   bl,y
   shl   bx,6
   add   bh,y
   add   bx,x
   add   bx,di
   mov   al,Col
   mov   es:[bx],al
End;

Procedure CopyScr(Source,Dest:ScrPtr);Assembler;
Asm
   push  ds
   les   di,Dest
   lds   si,Source
   mov   cx,16000
   db    66h
   rep   movsw
   pop   ds
End;

Procedure FillScr(Scr:ScrPtr;Col:Byte);Assembler;
Asm
   les   di,Scr
   mov   al,Col
   mov   ah,al
   db    66h
   shl   ax,16
   mov   al,col
   mov   ah,al
   mov   cx,16000
   db    66h
   rep   stosw
End;

Procedure SetupSinTab;
Var
   n                            : Integer;
   a,ast                        : Real;
Begin
   a:=0;
   ast:=2*pi/SinTabSize;
   For n:=0 to SinTabSize-1 do
   Begin
      SinTab^[n]:=Round(SinTabAmp*Sin(a));
      a:=a+ast
   End
End;

Procedure DrawRipples;
Var
   Ang1,Ang2                    : Integer;
   x,z                          : Integer;
   Px,Py,Height                 : Integer;
Begin
   Ang1:=0;
   Ang2:=0;
   Repeat
      FillScr(BufferScreen,200);
      For z:=-30 to -10 do
         For x:=-20 to 20 do
         Begin
            Height:=
                    SinTab^[(Ang1+x*32) and (SinTabSize-1)]+
                    SinTab^[(Ang2+z*32) and (SinTabSize-1)];
            Px:=64*x div z;
            Py:=(Height+240) div z;
            PutPixel(
                     BufferScreen,
                     159+Px,
                     99-Py,
                     31-((Height+256) div 64)
                    )
         End;
      CopyScr(BufferScreen,VisualScreen);
      Ang1:=Ang1+17;
      Ang1:=Ang1 and (SinTabSize-1);
      Ang2:=Ang2+12;
      Ang2:=Ang2 and (SinTabSize-1)
   Until KeyPressed
End;

Begin
   VisualScreen:=Ptr($A000,0);
   New(BufferScreen);
   New(SinTab);
   SetupSinTab;
   SetMode13;
   DrawRipples;
   TextMode(LastMode)
End.

