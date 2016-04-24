(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0202.PAS
  Description: Fire Code
  Author: ALEX CHALFIN
  Date: 05-26-95  23:06
*)

{
> Howdy, I am looking for some Pascal (no ASM please :) plasma or fire
> psudocode..

 Here is a 100% Pascal fire. It isn't very fast (well, its downright slow),
 but its all Pascal with no ASM (the video mode set is ASM, but that one is
 easy to understand). Please do not send updates to me, as I already know
 how to make it much faster.
}

Program Fire;
{ Alex Chalfin   12/26/94         }
{ Internet: achalfin@uceng.uc.edu }
{ FidoNet: 1:108/180              }

Uses Crt;

Var Buffer : Array[0..16000] of Byte;

Procedure SetBottom;
{ Set the bottom line of the buffer with hotspots }

Var  x : Integer;

Begin
  For x := 0 to 159 do
    Buffer[99*160+x] := Random(2) * 255;
End;

Procedure CalcFire;
{ Calculate the rest of the fire buffer }

Var
  x, y, ColorVal : Integer;

Begin
  For y := 98 downto 0 do
    For x := 159 downto 0 do
      Begin
        ColorVal := (Buffer[(Y+1)*160+x]+Buffer[(Y+1)*160+(x+1)]+
                     Buffer[(Y+1)*160+(x-1)]+Buffer[Y*160+x]) Shr 2;
        If ColorVal > 0
          Then ColorVal := ColorVal - 1;
        Buffer[Y*160+x] := ColorVal;
      End;
End;

Procedure CopyFire;
{ Copy the fire buffer, using 2x2 squares }

Var
  x,y : Integer;

Begin
  For y := 197 downto 0 do
    For x := 319 downto 0 do
      Mem[$A000:y*320+x] := Buffer[(y Shr 1)*160+(x Shr 1)];
End;

Procedure SetPalette;
{ Set a very basic fire palette }

Var
 x : Integer;

Begin
 For x := 255 Downto 0 do
   Begin
     Port[$3c8] := x;
     Port[$3c9] := x Div 4;
     Port[$3c9] := x Div 12;
     Port[$3c9] := 0;
   End;
End;


Begin
  Asm           { Sorry about the ASM, but it just sets the video mode }
    Mov  ax,13h { Set video mode $13 }
    Int  10h
  End;
  FillChar(Buffer, Sizeof(Buffer), 0);
  SetPalette;   { Set up a simple fire palette }
  Repeat
    SetBottom;
    CalcFire;
    CopyFire;
  Until KeyPressed;
  Asm
    Mov  ax,3   { Return back to text mode }
    Int  10h
  End;
End.

