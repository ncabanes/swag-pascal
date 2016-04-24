(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0127.PAS
  Description: Palette Fades/Transparent
  Author: DAVID DAHL
  Date: 08-24-94  17:53
*)

Program Transparent;
{                                       }
{   Example of How Transparency Works   }
{                                       }
{  Programmed by David Dahl @ 1:272/38  }
{                                       }
{     This program is PUBLIC DOMAIN     }
{                                       }
Uses CRT, Palette;

Type ImageArray = Array [0..15, 0..15] of Byte;

     LocationRec = Record
                         X : Integer;
                         Y : Integer;
                   End;

     VGABufferArray = Array[0..199, 0..319] of Byte;
     VGABufferPtr   = ^VGABufferArray;

Const BobTemplate : ImageArray =
              ((00,00,00,00,00,00,07,07,07,07,00,00,00,00,00,00),
               (00,00,00,00,07,07,04,04,04,04,06,05,00,00,00,00),
               (00,00,00,07,04,04,04,04,04,04,04,04,04,00,00,00),
               (00,00,07,04,04,04,04,04,04,04,04,04,04,03,00,00),
               (00,07,04,04,04,04,04,04,04,04,04,04,04,04,02,00),
               (00,07,04,04,04,04,04,04,04,04,04,04,04,04,01,00),
               (07,04,04,04,04,04,04,04,04,04,04,04,04,04,04,01),
               (07,04,04,04,04,04,04,04,04,04,04,04,04,04,04,01),
               (07,04,04,04,04,04,04,04,04,04,04,04,04,04,04,01),
               (07,04,04,04,04,04,04,04,04,04,04,04,04,04,04,01),
               (00,06,04,04,04,04,04,04,04,04,04,04,04,04,01,00),
               (00,06,04,04,04,04,04,04,04,04,04,04,04,04,01,00),
               (00,00,05,04,04,04,04,04,04,04,04,04,04,01,00,00),
               (00,00,00,04,04,04,04,04,04,04,04,04,01,00,00,00),
               (00,00,00,00,03,02,04,04,04,04,01,01,00,00,00,00),
               (00,00,00,00,00,00,01,01,01,01,00,00,00,00,00,00));

      MaxBob = 2; { 3 Bobs (0 .. 2) }

Var VGA        : VGABufferPtr;
    BackGround : VGABufferPtr;
    WorkPage   : VGABufferPtr;

    Pal : PaletteArray;

    BobImage    : Array[0..MaxBob] of ImageArray;
    BobLocation : Array[0..MaxBob] of LocationRec;

    Counter1 : Integer;
    Counter2 : Integer;

{-[ Set VGA Mode 13h (320 X 200 X 256 Chain 4) ]------------------------}
Procedure SetMode13h; Assembler;
ASM
   MOV AX, $13
   INT $10
End;
{-[ Put A 16 X 16 Image by ORing it With Background ]-------------------}
Procedure Put16X16ImageOR (Var Bob    : ImageArray;
                               X, Y   : Integer);
Var CounterX,
    CounterY  : Integer;
Begin
     For CounterY := 0 to 15 do
      For CounterX := 0 to 15 do
       WorkPage^[CounterY + Y, CounterX + X] :=
        WorkPage^[CounterY + Y, CounterX + X] OR Bob[CounterX, CounterY];
End;
{-[ Update Bob Positions ]----------------------------------------------}
Procedure UpdateBobs;
Var BobCounter : Integer;
Begin
     For BobCounter := 0 to MaxBob do
     Begin
          Inc (Counter1, 1);
          While (Counter1 >= 360) do
             Dec(Counter1, 360);

          If (Counter1 MOD 2) = 0
          Then
          Begin
               Inc(Counter2,1);
               While (Counter2 >= 360) do
                     Dec(Counter2, 360);
          End;

          BobLocation[BobCounter].X := 160 +
             Round(90 * -Sin((Counter1 + (BobCounter*Counter2))*PI/180));

          BobLocation[BobCounter].Y := 95 +
             Round(60 * Cos((Counter2 + (BobCounter*Counter1))*PI/180));

     End;
End;
{-[ Draw All Bobs To Work Buffer ]--------------------------------------}
Procedure DrawBobs;
Var BobCounter : Integer;
Begin
     For BobCounter := 0 to MaxBob do
         Put16X16ImageOR (BobImage[BobCounter],
            BobLocation[BobCounter].X, BobLocation[BobCounter].Y);
End;
{-[ Initialize Variables ]----------------------------------------------}
Procedure InitializeVariables;
Const Tbl : Array [0..MaxBob] of Byte = (8, 16, 32);
Var BobCounter : Integer;
    CX, CY     : Integer;
Begin
     { Make Individual Bobs From Template }
     For BobCounter := 0 to MaxBob do
     Begin
          BobImage[BobCounter] := BobTemplate;

          For CY := 0 to 15 do
              For CX := 0 to 15 do
                  If BobImage[BobCounter][CX,CY] <> 0
                  Then
                      BobImage[BobCounter][CX,CY] :=
                         BobImage[BobCounter][CX,CY] OR Tbl[BobCounter];
     End;

     Counter1 := 0;
     Counter2 := 0;
End;
{-[ Build Palette ]-----------------------------------------------------}
Procedure BuildPalette;
Var ColorCounter : Integer;
Begin
     { Initialize Palette Buffer To All Black }
     FillChar (Pal, SizeOf(Pal), 0);

     For ColorCounter := 0 to 7 do
     Begin
      { Make Red, Green, and Blue Bobs }
      Pal[ColorCounter OR 08].Red   := 21 + (ColorCounter * 6);
      Pal[ColorCounter OR 16].Green := 21 + (ColorCounter * 6);
      Pal[ColorCounter OR 32].Blue  := 21 + (ColorCounter * 6);

      { Make Colors Where Red and Green Bobs Overlap }
      Pal[ColorCounter OR 08 OR 16].Red   := 21 + (ColorCounter * 6);
      Pal[ColorCounter OR 08 OR 16].Green := 21 + (ColorCounter * 6);

      { Make Colors Where Red and Blue Bobs Overlap }
      Pal[ColorCounter OR 08 OR 32].Red  := 21 + (ColorCounter * 6);
      Pal[ColorCounter OR 08 OR 32].Blue := 21 + (ColorCounter * 6);

      { Make Colors Where Green and Blue Bobs Overlap }
      Pal[ColorCounter OR 16 OR 32].Green := 21 + (ColorCounter * 6);
      Pal[ColorCounter OR 16 OR 32].Blue  := 21 + (ColorCounter * 6);

      { Make Colors Where Red, Green and Blue Bobs Overlap }
      Pal[ColorCounter OR 08 OR 16 OR 32].Red   := 21+(ColorCounter * 6);
      Pal[ColorCounter OR 08 OR 16 OR 32].Green := 21+(ColorCounter * 6);
      Pal[ColorCounter OR 08 OR 16 OR 32].blue  := 21+(ColorCounter * 6);
     End;

     { Make Colors Where The Grey Square Overlaps The Bobs }
     For ColorCounter := 128 to 255 do
     Begin
      Pal[ColorCounter].Red   := (Pal[ColorCounter-128].Red   DIV 4)+14;
      Pal[ColorCounter].Green := (Pal[ColorCounter-128].Green DIV 4)+14;
      Pal[ColorCounter].Blue  := (Pal[ColorCounter-128].Blue  DIV 4)+14;
     End;
End;
{-[ Draw Grey Square In Background Buffer ]-----------------------------}
Procedure BuildBackground;
Var Y, X : Integer;
Begin
     FillChar (BackGround^, SizeOf(BackGround^), 0);

     For Y := 50 to 150 do
     For X := 100 to 220 do
         BackGround^[Y, X] := 128;

End;
{=[ Main Program ]======================================================}
Begin
     VGA := Ptr ($A000,$0000);
     New (WorkPage);
     New (BackGround);

     InitializeVariables;
     BuildPalette;
     BuildBackground;

     SetMode13h;
     SetPalette (Pal);

     Repeat
           UpdateBobs;               { Update Bob Positions }
           WorkPage^ := BackGround^; { Clear WorkPage With Static Image }
           DrawBobs;                 { Draw Bobs }

           { Wait For Retrace }
           Repeat Until ((Port[$3DA] AND 8) <> 0);

           VGA^ := WorkPage^;        { Display Page }
     Until KeyPressed;

     TextMode (C80);

     Dispose (BackGround);
     Dispose (WorkPage);
End.

{ PALETTE CODE FOLLOWS }

{
 TD> I've seen it done in many places, but I haven't seen any info on
 TD> how it's done:  What is the basic algorithm for fading from one
 TD> palette to another.

        Many people do palette fading incorrectly.  The correct
way to do it would be to set up a relation such as:

        Palette_Element     Calculated_Element
        ---------------  =  ------------------
         Max_Intensity      Current_Intensity

Where Palette_Element is a single element in our master DAC
table, Max_Intensity is the maximum allowable intensity level for
our scale, Current_Intensity is a number between 0 and
Max_Intensity which represents the level we want, and
Calculated_Element is the new value for the element of our DAC
table.  But since we want the Calculated_Element, we re-write it
as this equation:

        Calculated_Element = Palette_Element * Current_Intensity
                             -----------------------------------
                                         Max_Intensity

The above equation will allow us to fade a given palette set to
black or from black to a given palette set.  To fade out an entire
palette set, you would need to calculate the above for the red,
green, and blue components of each color in the 256 element DAC
table.
        Fading from one palette set to another palette set is
very similar.  What you must do is fade one palette set to black
while simultaneously fade from black to another palette set and
add the two values.  The equation for this is:

       CE = ((PE1 * (MI - CI)) + (PE2 * CI)) / MI

Where CE is the calculated element, PE1 and PE2 are corresponding
palette elements from palette 1 and 2, MI is the maximum
intensity in our scale, and CI is the current intensity we want
(num between 0 and MI). }

Unit Palette;
{ Programmed By David Dahl @ FidoNet 1:272/38 }
(* PUBLIC DOMAIN *)
Interface
  Type PaletteRec = Record
                          Red   : Byte;
                          Green : Byte;
                          Blue  : Byte;
                    End;
       PaletteArray = Array [0..255] of PaletteRec;

  Procedure SetPalette (Var PaletteIn : PaletteArray);
  Procedure FadeFromPaletteToBlack (Var PaletteIn : PaletteArray);
  Procedure FadeFromBlackToPalette (Var PaletteIn : PaletteArray);
  Procedure FadeFromPalette1ToPalette2 (Var Palette1 : PaletteArray;
                                        Var Palette2 : PaletteArray);
Implementation
Procedure SetPalette (Var PaletteIn : PaletteArray); Assembler;
Asm
   { Get Address of PaletteIn }
   LDS SI, PaletteIn
   CLD

   { Tell VGA To Start With First Palette Element }
   XOR AX, AX     
   MOV DX, $3C8
   OUT DX, AL

   { Wait For Retrace }
   MOV DX, $3DA
   @VRWait1:
     IN AL, DX
     AND AL, 8
   JZ @VRWait1
   
   { Set First Half Of Palette }
   MOV DX, $3C9
   MOV CX, 128 * 3
   @PALLOOP1:
     LODSB  { DON'T use "REP OUTSB" since some VGA cards can't handle it }
     OUT DX, AL
   LOOP @PALLOOP1

   { Wait For Retrace }
   PUSH DX
   MOV DX, $3DA
   @VRWait2:
     IN AL, DX
     AND AL, 8
   JZ @VRWait2
   POP DX

   { Set Last Half Of Palette }
   MOV CX, 128 * 3
   @PALLOOP2:
     LODSB
     OUT DX, AL
   LOOP @PALLOOP2
End;

Procedure FadeFromPaletteToBlack (Var PaletteIn : PaletteArray);
Var WorkPalette : PaletteArray;
    Counter     : Integer;
    Intensity   : Integer;
Begin
     For Intensity := 31 downto 0 do  
     Begin
       For Counter := 0 to 255 do
       Begin
          WorkPalette[Counter].Red   := 
                   (PaletteIn[Counter].Red   * Intensity) DIV 32;
          WorkPalette[Counter].Green := 
                   (PaletteIn[Counter].Green * Intensity) DIV 32;
          WorkPalette[Counter].Blue  := 
                   (PaletteIn[Counter].Blue  * Intensity) DIV 32;
       End;
       SetPalette (WorkPalette);
     End;
End;

Procedure FadeFromBlackToPalette (Var PaletteIn : PaletteArray);
Var WorkPalette : PaletteArray;
    Counter     : Integer;
    Intensity   : Integer;
Begin
     For Intensity := 1 to 32 do  
     Begin
       For Counter := 0 to 255 do
       Begin
          WorkPalette[Counter].Red   := 
                   (PaletteIn[Counter].Red   * Intensity) DIV 32;
          WorkPalette[Counter].Green := 
                   (PaletteIn[Counter].Green * Intensity) DIV 32;
          WorkPalette[Counter].Blue  := 
                   (PaletteIn[Counter].Blue  * Intensity) DIV 32;
       End;
       SetPalette (WorkPalette);
     End;
End;

Procedure FadeFromPalette1ToPalette2 (Var Palette1 : PaletteArray;
                                      Var Palette2 : PaletteArray);
Var WorkPalette : PaletteArray;
    Counter     : Integer;
    CrossFade   : Integer;
Begin
     For CrossFade := 0 to 32 do
     Begin
       For Counter := 0 to 255 do
       Begin
         WorkPalette[Counter].Red   :=
             ((Palette1[Counter].Red   * (32 - CrossFade)) + 
              (Palette2[Counter].Red   * CrossFade)) DIV 32;
         WorkPalette[Counter].Green :=
             ((Palette1[Counter].Green * (32 - CrossFade)) + 
              (Palette2[Counter].Green * CrossFade)) DIV 32;
         WorkPalette[Counter].Blue  :=
             ((Palette1[Counter].Blue  * (32 - CrossFade)) + 
              (Palette2[Counter].Blue  * CrossFade)) DIV 32;
       End;
       SetPalette (WorkPalette);
     End;
End;
End.

TUTORIAL !!

        Transparent objects are rather simple.  What you do is
set up your palette so pure colors are represented by powers of
two.  This way you can "mix" your colors by ORing the values
together.  For simplicity's sake, this example will use 3 colors:

        Bit  7 6 5 4 3 2 1 0
                       | | |
                       | | +----> Red
                       | +------> Green
                       +--------> Blue

So now you would set your palette up as follows:

    All single colors:

      2^0 = 1   --   Red
      2^1 = 2   --   Green
      2^2 = 4   --   Blue

    All possible 2 color mixes:

      2^0 OR 2^1 = 1 OR 2 = 3   --   Red + Green  = Yellow
      2^0 OR 2^2 = 1 OR 4 = 5   --   Red + Blue   = Magenta
      2^1 OR 2^2 = 2 OR 4 = 6   --   Green + Blue = Cyan

    All possible 3 color mixes:

      2^0 OR 2^1 OR 2^2 = 1 OR 2 OR 4 = 7  --  R + G + B = White

So our palette is set up as:

        0 - Black
        1 - Red
        2 - Green
        3 - Yellow
        4 - Blue
        5 - Magenta
        6 - Cyan
        7 - White

Now let's say we have a Red, Green, and a Blue square.  The
bitmap of the red square will be made up of bytes of the value 1,
the green square will be made up of the value 2, and the blue
square will be made up of the value 4 as so:

           Red             Green              Blue

         11111111         22222222          44444444
         11111111         22222222          44444444
         11111111         22222222          44444444
         11111111         22222222          44444444

To put the squares, you just have to OR put them to your frame
buffer.  If they overlap, they will automatically mix as so:

     The 3 overlaping bitmaps       The 3 overlaping bitmaps
     in frame buffer using an       in frame buffer showing
     OR'd image put:                what colors are where:

            11111111                      RRRRRRRR
            11111111                      RRRRRRRR
            111133332222                  RRRRYYYYGGGG
            155577776222                  RMMMWWWWCGGG
             44466666222                   BBBCCCCCGGG
             44466666222                   BBBCCCCCGGG
             44444444                      BBBBBBBB

The following example program uses this bit scheme:

        Bit  7 6 5 4 3 2 1 0
             |   | | | +-+-+---> Color Intensity (0:Least - 7:Full)
             |   | | +---------> Red
             |   | +-----------> Green
             |   +-------------> Blue
             +-----------------> Grey


David Dahl
