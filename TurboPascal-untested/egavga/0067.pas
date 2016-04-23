{
MARC BIR

>My second problem is the video memory.  From my technical
>reference manual, it tells me that the address starts at segment A000H,
>offset 0000H.  I've been Programming the VGA 320x200x256 mode quite alot,
>but in the EGA address, whenever I Write to video memory, all I see is
>black and white, like monochrome.  if I will be happy if I get information
>about that.  Another thing that actually question me is that when I'm
>using the BIOS block palette to create a fade in/out, it makes the screen
>flicker, which is quite disturbing.  What Info I need is how the VGA port
JS>works on setting up the RGB palette.  Thanks.

How do you init. the mode?  Call int 10h With 13h?  if so then using
A000:0000 is correct.  As far as fading, use the following.
}

Type
 PalType = Array [0..255, 0..2] of Byte;

Procedure SetPalette(Color, Count : Byte; Palette : PalType);
Var
  Ct, Col : Byte;
begin
  Port[$3C8] := Color;     { First color to set, Change this to $3C7 to
                             read.  And switch the Port=Pal at bottom }
  For Ct := 1 to Count Do  { Count is the total number of DACs to set }
  For Col := 0 to 2 Do     { Sets the Red, Green and Blue }
    Port[$3C9] :=  Palette[Ct, Col];
end;

Procedure SetMode(Mode : Byte); Assembler;
Asm
  Mov AH, 0
  Mov AL, Mode
  Int 10h
end;

{You can test your mode set With this }
Procedure TestScreen;
Var
  X, Y : Integer;
begin
 For X := 0 to 319 Do
   For Y := 0 to 199 Do
     Mem[$A000 : Y * 320 + X] := (X * Y) Mod 256;
end;

begin
  SetMode($13);
  TestScreen;
end.
