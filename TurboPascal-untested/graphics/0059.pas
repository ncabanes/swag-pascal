{$G+} { Enable 286 Instructions }
{$N+} { Enable Math Coprocessor - Delete This Line If You Don't Have One }
Program FractalPlasma;

{ Programmed By David Dahl }

(* PUBLIC DOMAIN *)

Uses
  CRT,
  Palette;

Const
  Rug = 0.2;

Type
  VGAPtr  = ^VGAType;
  VGAType = Array [0..199, 0..319] of Byte;

Var
  Screen    : VGAPtr;

  PlasmaMap : VGAPtr;
  PlasmaPal : PaletteType;

Procedure GeneratePlasma(P : VGAPtr);
{                                                                 }
{ This procedure uses an algorithm to generate a fractal surface. }
{                                                                 }
{ Algorithm from page 359 of _Computer_Graphics:_the_Principles_  }
{ _Behind_the_Art_And_Science_ by Pokorny and Gerald.             }
{                                                                 }
  Procedure FractPlasma(il, jl, ih, jh : Integer);
  Var
    im, jm : Integer;
  Begin
    im := (il + ih + 1) DIV 2;
    jm := (jl + jh + 1) DIV 2;

    If jm < jh then
    Begin
      If P^[il,jm] = 0 Then
        P^[il,jm] := Trunc(((P^[il,jl] + P^[il,jh]) / 2) +
                              Random*Rug*(jh-jl));
      If il < ih Then
        P^[ih,jm] := Trunc(((P^[ih,jl] + P^[ih,jh]) / 2) +
                              Random*Rug*(jh-jl));
    End;

    If im < ih then
    Begin
      If P^[im,jl] = 0 Then
        P^[im,jl] := Trunc(((P^[il,jl] + P^[ih,jl]) / 2) +
                              Random*Rug*(ih-il));
      If jl < jh Then
        P^[im,jh] := Trunc(((P^[il,jh] + P^[ih,jh]) / 2) +
                              Random*Rug*(jh-jl));
    End;

    If (im < ih) AND (jm < jh) Then
      P^[im,jm] := Trunc(((P^[il,jl] + P^[ih,jl] +
                           P^[il,jh] + P^[ih, jh]) / 4) +
                           Random*Rug*(ABS(ih-il)+abs(jh-jl)));
    If (im < ih) OR (jm < jh) Then
    Begin
      FractPlasma(il, jl, im, jm);
      FractPlasma(il, jm, im, jh);
      FractPlasma(im, jl, ih, jm);
      FractPlasma(im, jm, ih, jh);
    End;
  End;

Begin
  FractPlasma(0, 0, 199, 319);
End;

Procedure InitVGA13h; Assembler;
Asm
  MOV AX, $0013
  INT $10
End;

Procedure CalculatePalette(Var PalOut : PaletteType);
Var
  RA, GA, BA : Integer;
  RF, GF, BF : Integer;
  RS, GS, BS : Integer;
  Counter    : Word;
Begin
  RA := 16 + Random(32-16);
  GA := 16 + Random(32-16);
  BA := 16 + Random(32-16);

  RF := 2 + Random(5);
  GF := 2 + Random(5);
  BF := 2 + Random(5);

  RS := Random(64);
  GS := Random(64);
  BS := Random(64);


  For Counter := 0 to 255 do
  With PalOut[Counter] do
  Begin
    Red   := 32 + Round(RA * Sin((RS + Counter * RF) * Pi / 128));
    Green := 32 + Round(GA * Sin((GS + Counter * GF) * Pi / 128));
    Blue  := 32 + Round(BA * Sin((BS + Counter * BF) * Pi / 128));
  End;
End;

Procedure RotatePalette(Var PalIn : PaletteType);
Var
  TRGB : PaletteRec;
Begin
  TRGB := PalIn[0];
  Move (PalIn[1], PalIn[0], 255 * 3);
  PalIn[255] := TRGB;
End;

Var
  Int : Integer;
  Key : Char;
Begin
  DirectVideo := False;
  Randomize;

  InitVGA13h;

  Screen := Ptr($A000,$0000);
  New(PlasmaMap);

  { Initialize Workspace }
  FillChar(PlasmaMap^, 320 * 200 , 0);

  { Calculate Smooth Random Colors }
  CalculatePalette(PlasmaPal);

  GotoXY(12, 12);
  Writeln('Generating Plasma');
  GotoXY(14, 14);
  Writeln('Please Wait...');

  GeneratePlasma(PlasmaMap);

  { Set All Colors to Black }
  BlackPalette;
  { Copy Fractal To Screen }
  Screen^ := PlasmaMap^;

  { Rotate Palette And Fade It In Slowly }
  For Int := 1 to 32 do
  Begin
    RotatePalette(PlasmaPal);
    FadeInFromBlackQ(PlasmaPal, Int);
  End;

  { Rotate Full Intensity Palette And Wait For KeyPress }
  Repeat
    RotatePalette(PlasmaPal);
    SetPalette(PlasmaPal);
  Until KeyPressed;

  { Rotate Palette and Fade It Out Slowly }
  For Int := 31 downto 0 do
  Begin
    RotatePalette(PlasmaPal);
    FadeInFromBlackQ(PlasmaPal, Int);
  End;

  Dispose(PlasmaMap);

  TextMode(C80);

  { Flush Keyboard Buffer }
  While KeyPressed do
    Key := ReadKey;
End.
