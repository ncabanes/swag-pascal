(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0012.PAS
  Description: Smooth Text Scroll
  Author: DAVID DAHL
  Date: 01-27-94  12:22
*)

{
> Does anybody know if it is possible to accomplish a smooth-text scroller
> (like in the old c64 dayz) in text mode? If so, please let me know and

> Well, it's impossible, you'll have to switch to a graphic mode.

        No, it's possible in text mode... it's just a pain in the
arse.  I know of two ways.  The first is to use an alternate
character set (the EGA can have 2 on screen at once, the VGA can
have 4).  You use one character set as normal text, and use the
other as a pseudo-graphics window.  Put the text you need to
scroll in the window and move (copy) it a pixel at a time.  The
second way is to use the 8253 timer to time the scanline.  When
the scanline gets to the portion of the screen you want, turn off
v-retrace, set v-retrace on the next scan line, and set the
horizontal pel pan to the value you need for your smooth pan.
When the card gets to the line that the v-retrace would occur, it
resets the pan but doesn't retrace because you turned it off.
After this, reset the registers you changed back to their default
values so the card builds the screen correctly.  This is done on
EVERY screen build.  Needless to say, the pseudo-graphics window
version is easier so that's the one I used to program the example
that follows.
}

Program SmoothTextScrollExample1;

{==============================================

       Smooth Scroll In Text Mode Example
           Programmed by David Dahl
                   12/21/93
   This program and source are PUBLIC DOMAIN

 ----------------------------------------------

   This example uses a second font to scroll
   the text.  The font definition is changed
   to make the text scroll.  This program
   requires VGA.

 ==============================================}

Uses  CRT;

Type  FontDefType = Array[0..255, 0..31] of Byte;

Var   ScrollText : String;

      FontDef    : FontDefType;

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

Procedure WriteScrollTextCharacters(Row : Byte);
Var Counter : Word;
Begin
     { Set Fonts 0 & 1 }
     ASM
        MOV BL, 4
        MOV AX, $1103
        INT $10
     END;

     { Write Characters }
     For Counter := 0 to 79 do
     Begin
          { Set Characters }

          MEM[$B800:(80*2)*Row+(Counter*2)]   := Counter;
          { Set Attribute To Secondary Font }
          MEM[$B800:(80*2)*Row+(Counter*2)+1] :=
             MEM[$B800:(80*2)*Row+(Counter*2)+1] OR 8;

     End;

End;

Procedure FlushKeyBoardBuffer;
Var Key : Char;
Begin
     While KeyPressed do
           Key := ReadKey;
End;

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

Procedure MakeFontDefTable;
Var  CounterX,
     CounterY  : Word;
Begin
     SetAccessToFontMemory;

     For CounterY := 0 to 255 do
         For CounterX := 0 to 31 do
             FontDef[CounterY, CounterX] :=
                 MEM[$B800:(CounterY * 32)+CounterX];

     SetAccessToTextMemory;
End;

Procedure ClearSecondFontMemory;
Var Counter : Word;
Begin
     SetAccessToFontMemory;

     For Counter := 0 to 32 * 256 do
         MEM[$B800:$4000 + Counter] := 0;

     SetAccessToTextMemory;
End;

Procedure ScrollMessage;
Const CharCol  : Integer = 8;
      Counter  : Byte = 1;
      COUNTERY : Byte = 0;
      PWRTbl   : Array [0..7] of Byte = (1,2,4,8,16,32,64,128);
Begin
     SetAccessToFontMemory;

     ASM
        { Wait For Retrace }
        MOV DX, $3DA
        @RT:
         IN   AL, DX
         TEST AL, 8
        JZ @RT

        { Scroll Text One Pixel To The Left }
        MOV AX, $B800 + ($4000 / 16)
        MOV ES, AX
        MOV CX, 32
        @Row:
         MOV DI, (79 * 32) - 1
         ADD DI, CX
         SHL byte ptr ES:[DI], 1
         PUSHF
         SUB DI, 32
         POPF
         PUSH CX
         MOV CX, 79
         @Chrs:
          RCL byte ptr ES:[DI], 1
          PUSHF
          SUB DI, 32
          POPF
         Loop @Chrs
         POP CX
        Loop @Row
     END;

     If CharCol < 0
     Then

     Begin
          CharCol := 7;
          Inc(Counter);
     End
     Else
         Dec(CharCol);

     If Counter > Length(ScrollText)
     Then
         Counter := 1;

     { Write New Column Of Pixels }
     For CounterY := 0 to 31 do
     MEM[$B800:$4000 + (79 * 32) + CounterY] :=
         MEM[$B800:$4000 + (79 * 32) + CounterY] OR
          ((FontDef[Ord(ScrollText[Counter]), CounterY] AND PwrTbl[CharCol])
            SHR CharCol);

     SetAccessToTextMemory;
End;

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

Begin
     TextMode (C80);
     TurnCursorOff;
     SetCharWidthTo8;
     MakeFontDefTable;
     ClearSecondFontMemory;
     TextColor(Red);
     ClrScr;

     ScrollText := 'This program is one example of how a smooth '+
                   'scroll can be done in text mode.            ';

     WriteScrollTextCharacters(10);

     TextColor(Blue);
     GoToXY (26,10);
     Write  ('Text Mode Smooth Scroll Example');
     GoToXY (34,11);
     Write  ('By David Dahl');

     FlushKeyBoardBuffer;

     Repeat
           ScrollMessage;
     Until Keypressed;

     FlushKeyboardBuffer;

     TextMode (C80);
     TurnCursorOn;
End.

