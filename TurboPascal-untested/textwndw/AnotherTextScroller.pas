(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0028.PAS
  Description: Another Text Scroller
  Author: CHRISTIAN LAND
  Date: 08-30-96  09:35
*)

{
Here's a little TEXTMODE Scroller I wrote some time ago. Feel free to release
it in the SWAG Files ;)

---------------------------------= CUT HERE =---------------------------------

{ This is a VERY simple Textmode Scroller. Feel free to use it in your
  programs .                                                                 }


Uses Crt;

Const Bits    : Array [0..7] of Byte = (128,64,32,16,8,4,2,1);
      Text    : String = ' THiS LiTTLE SCROLLER WAS DONE BY ROGUE/'+
                'DiGiTAL PROJECTS             ';
      YPos    = 7;

Var
   FSeg,FOfs,i  : Word;
   BitMap       : Array [0..80,0..7] of Byte;

Procedure Scroll;
Var
   i,j                                  : Word;
   CharPos,CharNo,Color,Character,nc    : Byte;
   c                                    : Byte;
Begin
     CharNo:=1;
     Repeat
           Character:=Ord(Text[CharNo]);

           For CharPos:=0 to 7 do
           Begin
                For i:=0 to 7 do
                    If Mem[FSeg:FOfs+(Character shl 3)+i] and
                       Bits[CharPos]<>0 then
                       BitMap[80,i]:=15  { Char-Color }
                    Else
                        BitMap[80,i]:=0; { Background Color }

                Asm
                   mov   dx, $3da
                   @L1:
                   in    al, dx
                   test  al, $08
                   jnz   @L1
                   @L2:
                   in    al, dx
                   test  al, $08
                   jz    @L2
                End;

                For j:=0 to 7 do
                    For i:=0 to 79 do
                    Begin
                         { Draw }
                         Mem[$B800:(i shl 1)+((j+YPos)*160)]:=219;
                         Mem[$B800:(i shl 1)+((j+YPos)*160)+1]:=BitMap[i,j];
                         { Scroll left }
                         BitMap[i,j]:=BitMap[i+1,j];
                    End;
           End;
           Inc(CharNo);
           If CharNo>Length(Text) then
              CharNo:=1;
     Until Keypressed;
     readkey;
End;

Procedure GetFont; Assembler;
Asm
   mov  ax, $1130
   mov  bh, $01
   int  $10
   mov  fseg, es
   mov  fofs, bp
End;

Begin
     ClrScr;
     GetFont;
     Scroll;
End.

