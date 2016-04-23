{$G+}  { Enable 286 Instructions }
Unit Palette;

{ Programmed By David Dahl }

(* PUBLIC DOMAIN *)

Interface

  Type PaletteRec  = Record
                           Red,
                           Green,
                           Blue  : Byte;
                     End;
       PaletteType = Array[0..255] of PaletteRec;
       PalettePtr  = ^PaletteType;

  Procedure SetPalette        (Var PalBuf : PaletteType);
  Procedure GetPalette        (Var PalBuf : PaletteType);

  Procedure BlackPalette;
  Procedure FadeInFromBlack   (Var Palin : PaletteType);
  Procedure FadeInFromBlackQ  (Var Palin     : PaletteType;
                                   Intensity : Word);
  Procedure FadeOutToBlack    (Var Palin : PaletteType);
  Procedure FadeFromPalToPal  (Var OldPal, NewPal : PaletteType);
  Procedure FadeFromPalToPalQ (Var OldPal, NewPal : PaletteType;
                                   Color          : Word);


  Var BlackP  : PaletteType;
      WhiteP  : PaletteType;

      TempPal : PaletteType;

Implementation

{-[ Set Value Of All DAC Registers ]--------------------------------------}
Procedure SetPalette (Var PalBuf : PaletteType); Assembler;
Asm
    PUSH DS

    XOR AX, AX       { Palette Start = 0 }
    MOV CX, 0300h / 2
    LDS SI, PalBuf   { Load DS:SI With Address Of PalBuf (For OUTSB) }

    MOV DX, 03C8h    { Tell VGA Card What DAC Color To Start With }
    OUT DX, AL

    INC DX           { Set DX To Equal DAC Data Port }
    MOV BX, DX
    CLD

    { Wait For V-sync }
    MOV DX, 03DAh
    @VSYNC0:
      IN   AL, DX
      TEST AL, 8
    JZ @VSYNC0

    MOV DX, BX
    REP
       OUTSB

    MOV BX, DX

    { Wait For V-sync }
    MOV DX, 03DAh
    @VSYNC1:
      IN   AL, DX
      TEST AL, 8
    JZ @VSYNC1

    MOV DX, BX
    MOV CX, 0300h / 2
    REP
       OUTSB

    POP DS
End;

{-[ Get Value Of All DAC Registers ]--------------------------------------}
Procedure GetPalette (Var PalBuf : PaletteType); Assembler;
Asm
    PUSH DS

    XOR AX, AX       { Palette Start = 0 }
    MOV CX, 0300h
    LES DI, PalBuf   { Load ES:DI With Address Of PalBuf (For INSB) }

    MOV DX, 03C7h    { Tell VGA Card What DAC Color To Start With }
    OUT DX, AL

    INC DX           { Set DX To Equal DAC Data Port }
    INC DX
    CLD

    REP
       INSB

    POP DS
End;


Procedure BlackPalette;
Begin
     SetPalette (BlackP);
End;

Procedure FadeInFromBlack (Var Palin : PaletteType);
Var DAC,
    Intensity : Word;
Begin
     For Intensity := 0 to 32 do
     Begin
       For DAC := 0 to 255 do
       Begin
          TempPal[DAC].Red   := (Palin[DAC].Red   * Intensity) DIV 32;
          TempPal[DAC].Green := (Palin[DAC].Green * Intensity) DIV 32;
          TempPal[DAC].Blue  := (Palin[DAC].Blue  * Intensity) DIV 32;
       End;

       SetPalette (TempPal);
     End;
End;

Procedure FadeInFromBlackQ (Var Palin     : PaletteType;
                                Intensity : Word);
Const DAC : Word = 0;
Begin
     For DAC := 0 to 255 do
     Begin
          TempPal[DAC].Red   := (Palin[DAC].Red   * Intensity) DIV 32;
          TempPal[DAC].Green := (Palin[DAC].Green * Intensity) DIV 32;
          TempPal[DAC].Blue  := (Palin[DAC].Blue  * Intensity) DIV 32;
     End;

     SetPalette (TempPal);
End;

Procedure FadeOutToBlack (Var Palin : PaletteType);
Var DAC,
    Intensity : Word;
Begin
     For Intensity := 32 downto 0 do
     Begin
       For DAC := 0 to 255 do
       Begin
          TempPal[DAC].Red   := (Palin[DAC].Red   * Intensity) DIV 32;
          TempPal[DAC].Green := (Palin[DAC].Green * Intensity) DIV 32;
          TempPal[DAC].Blue  := (Palin[DAC].Blue  * Intensity) DIV 32;
       End;

       SetPalette (TempPal);
     End;
End;


Procedure FadeFromPalToPal (Var OldPal, NewPal : PaletteType);
Var DAC,
    Color : Word;
Begin
     For Color := 32 downto 0 do
     Begin
       For DAC := 0 to 255 do
       Begin
          TempPal[DAC].Red   := ((OldPal[DAC].Red   * Color) DIV 32) +
                                ((NewPal[DAC].Red   * (32 - Color)) DIV 32);
          TempPal[DAC].Green := ((OldPal[DAC].Green * Color) DIV 32) +
                                ((NewPal[DAC].Green * (32 - Color)) DIV 32);
          TempPal[DAC].Blue  := ((OldPal[DAC].Blue  * Color) DIV 32) +
                                ((NewPal[DAC].Blue  * (32 - Color)) DIV 32);
       End;

       SetPalette (TempPal);
     End;
End;

Procedure FadeFromPalToPalQ (Var OldPal, NewPal : PaletteType;
                                 Color          : Word);
Const DAC : Word = 0;
Begin
     For DAC := 0 to 255 do
     Begin
          TempPal[DAC].Red   := ((OldPal[DAC].Red   * (32 - Color)) DIV 32)+
                                ((NewPal[DAC].Red   * Color) DIV 32);
          TempPal[DAC].Green := ((OldPal[DAC].Green * (32 - Color)) DIV 32)+
                                ((NewPal[DAC].Green * Color) DIV 32);
          TempPal[DAC].Blue  := ((OldPal[DAC].Blue  * (32 - Color)) DIV 32)+
                                ((NewPal[DAC].Blue  * Color) DIV 32);
     End;

     SetPalette (TempPal);
End;

Var Counter : Word;
Begin
     For Counter := 0 to 255 do
     Begin
          BlackP[Counter].Red   := 0;
          BlackP[Counter].Green := 0;
          BlackP[Counter].Blue  := 0;
     End;

     For Counter := 0 to 255 do
     Begin
          WhiteP[Counter].Red   := 63;
          WhiteP[Counter].Green := 63;
          WhiteP[Counter].Blue  := 63;
     End;
End.

