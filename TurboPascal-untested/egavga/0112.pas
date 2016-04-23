Program CopperExampleNo2;
{$G+} { Enable 286 Instructions }

{                                }
{       Copper Example #2        }
{    Programmed by David Dahl    }
{                                }
{ THIS EXAMPLE RUNS IN TEXT MODE }
{                                }
{     This is PUBLIC DOMAIN      }
{                                }


{ This Example Works FLAWLESSLY On My ET4000AX Based VGA Card.    }
{ On My Friend's Trident, However, The Three Sinus Bars Have Snow }
{ Covering Their Leftmost Sides For About An Inch.  This Is Due   }
{ To The Double VGA DAC Set Required To Display Both The Sinus    }
{ Bars And The Smooth Color Transitions Of The Large Text.        }

Uses CRT;

Const MaxRaster = 399;

      Status1   = $3DA;
      DACWrite  = $3C8;
      DACData   = $3C9;

Type  CopperRec   = Record
                          Color : Byte;
                          Red   : Byte;
                          Green : Byte;
                          Blue  : Byte;
                    End;

      CopperArray = Array [0..MaxRaster] of CopperRec;

      BarArray    = Array [0..19] of CopperRec;

Var   CopperList : CopperArray;

      Bar        : Array[0..2] of BarArray;
      BarPos     : Array[0..2] of Integer;

      SinTab     : Array[0..255] of Integer;

{-[ Build Sine Lookup Table ]----------------------------------------------}
Procedure MakeSinTab;
Var Counter : Integer;
Begin
     For Counter := 0 to 255 do
         SinTab[Counter] := 115 + Round(90 * Sin(Counter * PI / 128));
End;
{-[ Build Colors For Sinus Bars ]------------------------------------------}
Procedure MakeBars;
Var Counter : Integer;
Begin
     { Clear Colors }
     FillChar (Bar, SizeOf(Bar), 0);

     For Counter := 0 to 9 do
     Begin
          Bar[0][Counter].Red   := Trunc(Counter * (63 / 9));
          Bar[1][Counter].Green := Trunc(Counter * (63 / 9));
          Bar[2][Counter].Blue  := Trunc(Counter * (63 / 9));
          If Odd(Counter)
          Then
          Begin
               Bar[0][Counter].Green := Trunc(Counter * (63 / 9));
               Bar[1][Counter].Red   := Trunc(Counter * (63 / 9));
               Bar[1][Counter].Blue  := Trunc(Counter * (63 / 9));
               Bar[2][Counter].Green := Trunc(Counter * (63 / 9));
          End;
     End;
     For Counter := 10 to 19 do
     Begin
          Bar[0][Counter].Red   := Trunc((19-Counter) * (63 / 9));
          Bar[1][Counter].Green := Trunc((19-Counter) * (63 / 9));
          Bar[2][Counter].Blue  := Trunc((19-Counter) * (63 / 9));
          If Odd(Counter)
          Then
          Begin
               Bar[0][Counter].Green := Trunc((19-Counter) * (63 / 9));
               Bar[1][Counter].Red   := Trunc((19-Counter) * (63 / 9));
               Bar[1][Counter].Blue  := Trunc((19-Counter) * (63 / 9));
               Bar[2][Counter].Green := Trunc((19-Counter) * (63 / 9));
          End;
     End;
End;
{-[ Make COPPER List ]-----------------------------------------------------}
Procedure MakeCopperList;
Var Counter1 : Integer;
    Counter2 : Integer;
Begin
     { Clear List }
     FillChar (CopperList, SizeOf(CopperList), 0);

     { Make Transition From White To Yellow For }
     { Color 1 On Scanlines 10 Through 250      }
     For Counter1 := 10 to 250 do
     With CopperList[Counter1] do
     Begin
          Color := 1;
          Red   := 63;
          Green := 63;
          Blue  := Round((250 - Counter1) * (63 / 200));
     End;

     { Make Transition From Black To Dark Blue For }
     { Color 0 On Scanlines 254 Through 274        }
     For Counter1 := 254 to 254 + 20 do
     With CopperList[Counter1] do
     Begin
          Color := 0;
          Red   := 0;
          Green := 0;
          Blue  := Counter1 - 254;
     End;
     { Make Dark Blue Background (Color 0) For   }
     { Scanlines 275 Through 287 Except Scanline }
     { 280 Which Is Yellow                       }
     For Counter1 := 275 to 287 do
     With CopperList[Counter1] do
     Begin
          Color := 0;
          Red   := 0;
          Green := 0;
          If Counter1 = 280
          Then
          Begin
               Red   := 45;
               Green := 45;
          End
          Else
              Blue := 20;
     End;
     { Make Dark Blue Background (Color 0) For   }
     { Scanlines 336 Through 394 Except Scanline }
     { 343 Which Is Yellow                       }
     For Counter1 := 336 to 349 do
     With CopperList[Counter1] do
     Begin
          Color := 0;
          Red   := 0;
          Green := 0;
          If Counter1 = 343
          Then
          Begin
               Red   := 45;
               Green := 45;
          End
          Else
              Blue := 20;
     End;
     { Make Transition From Dark Blue To Black }
     { For Background From Scanline 350 to 370 }
     For Counter1 := 350 to 350 + 20 do
     With CopperList[Counter1] do
     Begin
          Color := 0;
          Red   := 0;
          Green := 0;
          Blue  := (350 + 20 - Counter1);
     End;

     { Color Text Lines 18, 19, and 20 For Text Color 1 }
     { As Red -> Yellow (L18), Purple -> White (L20)    }
     For Counter1  := 18 to 20 do
       For Counter2 := 0 to 15 do
       With CopperList[Counter2 + (Counter1 * 16)] do
       Begin
            Color := 1;
            Red   := 63;
            Green := Trunc(Counter2 * (63 / 15));
            Blue  := ((Counter1 - 18) * 31) AND 63;
       End;
End;
{-[ Center And Write A String As Solid Chars And Spaces ]------------------}
Procedure WSol (StringIn : String);
Var Counter : Integer;
Begin
     For Counter := 1 to (40 - (Length(StringIn) DIV 2)) do
         Write(#32);

     For Counter := 1 to Length(StringIn) do
       If StringIn[Counter] <> #32
       Then
           Write (#219)
       Else
           Write (#32);

     Writeln;
End;
{-[ Put Text On Screen ]---------------------------------------------------}
Procedure SetUpScreen;
Begin
     ClrScr;

     GotoXY (1,5);
     TextColor (1);
     WSol('  ####     ####    ######    ######    ########  ######  ');
     WSol(' ##  ##   ##  ##   ##   ##   ##   ##   ##        ##   ## ');
     WSol('##       ##    ##  ##    ##  ##    ##  ##        ##    ##');
     WSol('##       ##    ##  ##    ##  ##    ##  #####     ##    ##');
     WSol('##       ##    ##  ##   ##   ##   ##   ##        ##   ## ');
     WSol('##       ##    ##  ######    ######    ##        ######  ');
     WSol(' ##  ##   ##  ##   ##        ##        ##        ##   ## ');
     WSol('  ####     ####    ##        ##        ########  ##    ##');
     GotoXY(21, 19);
     Writeln('Textmode COPPER Example #2 by David Dahl');
     GotoXY(27, 21);
     Writeln('This Program is Public Domain');
End;
{-[ Update COPPER ]--------------------------------------------------------}
Procedure UpdateCopper;
Var Raster     : Word;
    DrawBar    : Integer;
    BarNum     : Integer;
    BarCounter : Integer;
Begin
     Raster := 1;

     DrawBar := -1;
     BarNum  := 0;

     Inc(BarPos[0],1);
     Inc(BarPos[1],1);
     Inc(BarPos[2],1);

     { Sorry For All The Assembly Here, But Plain Vanilla Pascal  }
     { Just Isn't Fast Enough To Properly Display BOTH Sinus Bars }
     { And The Color Transitions For The Large Text.              }
     ASM
        PUSH DS
        MOV AX, SEG @Data
        MOV DS, AX
        CLI

        { Wait For End Of Vertical Retrace }
        MOV DX, Status1
        @NotVert:
          IN  AL, DX
          AND AL, 8
        JNZ @NotVert
        @IsVert:
          IN  AL, DX
          AND AL, 8
        JZ @IsVert


        @DrawAllBarsLoop:
          {--- Check For Bars ---}
          MOV CX, 3
          @BarRasterCompare:

            { Calculate Location of Bar (Start Line Placed In AX) }
            MOV BX, CX
            DEC BX
            SHL BX, 1
            MOV BX, word(BarPos[BX])
            AND BX, 255
            SHL BX, 1
            MOV AX, word(SinTab[BX])

            { Check If A Bar Is On Current Raster }
            CMP AX, Raster
            JNS @BarNotDisplayed
            MOV BX, AX
            ADD AX, 20
            CMP Raster, AX
            JNS @BarNotDisplayed

            { Bar Is On Raster So Mark It }
            SUB BX, Raster
            XOR AX, AX
            SUB AX, BX

            MOV word(DrawBar), AX
            MOV word(BarNum), CX
            DEC word(BarNum)

            @BarNotDisplayed:
            @DoneChecking:
          LOOP @BarRasterCompare

          {--- Draw Bars ---}
          MOV  BX, DrawBar
          OR   BX, BX
          JL   @NoDrawBar

          { Build Index To Bar Color Table }
          SHL BX, 2

          MOV AX, word(BarNum)
          MOV CX, AX
          SHL AX, 6
          SHL CX, 4
          ADD AX, CX
          ADD BX, AX

          { Set Up Next Scan Line Color }
          MOV DX, DACWRITE
          XOR AX, AX
          OUT DX, AL

          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(Bar[BX])
          OUT DX, AL
          INC BX
          MOV AL, Byte(Bar[BX])
          OUT DX, AL

          { Wait For End of Horiz Retrace }
          MOV DX, Status1
          @NotHoriz1:
            IN  AL, DX
            AND AL, 1
          JNZ @NotHoriz1
          @IsHoriz1:
            IN  AL, DX
            AND AL, 1
          JZ @IsHoriz1

          { Send Last Byte Of DAC Reg So Color Is Updated }
          MOV DX, DACDATA
          INC BX
          MOV AL, byte(Bar[BX])
          OUT DX, AL

          { Update Color From Copper Table }
          MOV DX, DACWRITE
          MOV BX, Raster
          SHL BX, 2
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          JMP @Done

          @NoDrawBar:
          { Update Color }
          MOV DX, DACWRITE
          MOV BX, Raster
          SHL BX, 2
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          { Wait For End of Horiz Retrace }
          MOV DX, Status1
          @NotHoriz2:
            IN  AL, DX
            AND AL, 1
          JNZ @NotHoriz2
          @IsHoriz2:
            IN  AL, DX
            AND AL, 1
          JZ @IsHoriz2

          { Update Last }
          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          @Done:

          INC Word(Raster)

       { If Raster <= 250 Then Loop }
       CMP Word(Raster), 250
       JLE @DrawAllBarsLoop

       {--- Color Background And Text At Bottom of Screen ---}
       @TextColorLoop:
          MOV DX, DACWRITE
          MOV BX, Raster
          SHL BX, 2
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          MOV DX, Status1
          @NotHoriz3:
            IN  AL, DX
            AND AL, 1
          JNZ @NotHoriz3
          @IsHoriz3:
            IN  AL, DX
            AND AL, 1
          JZ @IsHoriz3

          MOV DX, DACDATA
          INC BX
          MOV AL, Byte(CopperList[BX])
          OUT DX, AL

          INC Word(Raster)
       CMP Word(Raster), MaxRaster
       JLE @TextColorLoop
       STI
       POP DS
     END;
End;
{=[ Main Program ]=========================================================}
Var Key : Char;
Begin
     TextMode (C80);
     MakeSinTab;
     MakeCopperList;
     MakeBars;
     SetUpScreen;
     BarPos[0] := 30;
     BarPos[1] := 15;
     BarPos[2] :=  0;
     Repeat
           UpdateCopper;
     Until Keypressed;
     While Keypressed do
           Key := ReadKey;
     TextMode (C80);
End.

