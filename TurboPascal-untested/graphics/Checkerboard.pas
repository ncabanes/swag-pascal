(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0082.PAS
  Description: CheckerBoard
  Author: DAVID DAHL
  Date: 02-09-94  11:50
*)


Program CheckerBoard;

{=============================================

             CheckerBoard Example
           Programmed by David Dahl
                  01/06/94
   This program and source are PUBLIC DOMAIN

 ---------------------------------------------

   This program is an example of how to make
   a moving 3D checkerboard pattern on the
   screen like many demos do.

   This program requires VGA.

 =============================================}

Uses CRT;

Const TileMaxX = 10;  { Horiz Size Of Tile }
      TileMaxY = 10;  { Vert Size Of Tile }

      ViewerDist = 400;  { Distance Of Viewer From Screen }

Type TileArray = Array [0..TileMaxX-1, 0..TileMaxY-1] of Byte;

     PaletteRec  = Record
                         Red,
                         Green,
                         Blue  : Byte;
                   End;
     PaletteType = Array[0..255] of PaletteRec;


Var Tile    : TileArray;
    TilePal : PaletteType;

Procedure GoMode13; Assembler;
ASM
   MOV AX, $0013
   INT $10
End;

{-[ Set Value Of All DAC Registers ]--------------------------------------}
Procedure SetPalette (Var PalBuf : PaletteType); Assembler;
Asm
    PUSH DS

    XOR AX, AX
    MOV CX, 0300h / 2
    LDS SI, PalBuf

    MOV DX, 03C8h
    OUT DX, AL

    INC DX
    MOV BX, DX
    CLD

    MOV DX, 03DAh
    @VSYNC0:
      IN   AL, DX
      TEST AL, 8
    JZ @VSYNC0

    MOV DX, BX
    rep
       OUTSB

    MOV BX, DX
    MOV CX, 0300h / 2


    MOV DX, 03DAh
    @VSYNC1:
      IN   AL, DX
      TEST AL, 8
    JZ @VSYNC1

    MOV DX, BX
    REP
       OUTSB

    POP DS
End;
{-[ Get Value Of All DAC Registers ]--------------------------------------}
Procedure GetPalette (Var PalBuf : PaletteType); Assembler;
Asm
    PUSH DS

    XOR AX, AX
    MOV CX, 0300h
    LES DI, PalBuf

    MOV DX, 03C7h
    OUT DX, AL
    INC DX

    REP
       INSB

    POP DS
End;
{-[ Only Set DAC Regs 1 Through (TileMaxX * TileMaxY) ]-------------------}
Procedure SetTileColors (Var PalBuf : PaletteType); Assembler;
ASM
   PUSH DS

   MOV CX, TileMaxX * TileMaxY * 3
   MOV AX, 1
   LDS SI, PalBuf
   INC SI
   INC SI
   INC SI
   MOV DX, 03C8h
   OUT DX, AL
   INC DX
   MOV BX, DX

   MOV DX, 03DAh
   @VSYNC0:
     IN   AL, DX
     TEST AL, 8
   JZ @VSYNC0

   MOV DX, BX
   REP
      OUTSB

   POP DS
End;
{-[ Define The Bitmap Of The Tile ]---------------------------------------}
Procedure DefineTile;
Var CounterX,
    CounterY  : Word;
Begin
     For CounterY := 0 to TileMaxY-1 do
         For CounterX := 0 to TileMaxX-1 do
             Tile[CounterX, CounterY] := 1 + CounterX +
                                         (CounterY * TileMaxX);
End;
{-[ Define The Colors Of The Tile ]---------------------------------------}
Procedure DefinePalette;
Var PalXCounter : Byte;
    PalYCounter : Byte;
    PalSize     : Byte;
Begin
     GetPalette (TilePal);

     PalSize := (TileMaxX * TileMaxY);

     For PalYCounter := 1 to PalSize do
     With TilePal[PalYCounter] do
     Begin
          Red   := 0;
          Green := 0;
          Blue  := 63;
     End;

     For PalYCounter := 0 to ((TileMaxY - 1) DIV 2) do
         For PalXCounter := 0 to ((TileMaxX - 1) DIV 2) do
         Begin
              With TilePal[1 + PalXCounter + (PalYCounter*TileMaxX)] do
              Begin
                   Red   := 63;
                   Green := 63;
                   Blue  := 63;
              End;

              With TilePal[1 + (TileMaxX DIV 2) +
                               PalXCounter +
                               ((TileMaxY DIV 2) * TileMaxX) +
                               (PalYCounter*TileMaxX)] do
              Begin
                   Red   := 63;
                   Green := 63;
                   Blue  := 63;
              End;
         End;

End;
{-[ Display Tiles On Screen ]---------------------------------------------}
Procedure DisplayCheckerBoard;
Var CounterX,
    CounterY  : Integer;

    X,
    Y,
    Z         : LongInt;
Begin
     For CounterY := 110 to 199 do
     Begin
          Z := -1600 + (CounterY * 16) + ViewerDist;

          If Z = 0 THEN Z :=1;

          For CounterX := 0 to 319 do
          Begin

               X := 159 + (longInt(CounterX - 159 ) * ViewerDist) DIV Z;

               Y := (LongInt(CounterY + 100) * ViewerDist) DIV Z;

               MEM[$A000:CounterX + (CounterY * 320)] :=
                   Tile[X MOD TileMaxX, Y MOD TileMaxY]
          End;
     End;

End;
{-[ Rotate The Palette Of The Board To Give Illusion Of Movement Over It ]-}
Procedure MoveForwardOverBoard;
Type  TempPalType = Array[1..TileMaxX] of PaletteRec;
Var   TempPal     : TempPalType;
      CounterX,
      CounterY    : Word;
Begin
     For CounterX := 1 to TileMaxX do
         TempPal[CounterX] := TilePal[CounterX];

     For CounterY := 0 to (TileMaxY-1) do
         For CounterX := 0 to (TileMaxX-1) do
             TilePal[1 + CounterX + (CounterY * TileMaxX)] :=
                    TilePal[1 + CounterX + ((CounterY+1) * TileMaxX)];

     For CounterX := 1 to TileMaxX do
         TilePal[CounterX + ((TileMaxY-1) * TileMaxX)] :=
                TempPal[CounterX];
End;
{-[ Flush the Keyboard Buffer ]--------------------------------------------}
Procedure FlushKeyboard;
Var Key : Char;
Begin
     While KeyPressed do
           Key := ReadKey;
End;

{=[ Main Program ]=========================================================}
Begin

     GoMode13;
     DefineTile;
     DefinePalette;

     SetPalette(TilePal);

     DisplayCheckerboard;

     FlushKeyboard;

     Repeat
           MoveForwardOverBoard;
           SetTileColors(TilePal);
     Until KeyPressed;

     FlushKeyboard;

     TextMode(C80);
End.

