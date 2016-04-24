(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0107.PAS
  Description: Fading Unit
  Author: FLORIAN ANSORGE
  Date: 05-26-94  06:15
*)

UNIT FadeUnit;        { This unit does some fading (I hope!) }
                      { The SetCol procedure lets you change individual}
                      { palette entries , for an easier way, try }
                      { the TP setrgbpalette procedure...}
                      { Regards Florian Ansorge :-) }
INTERFACE

Procedure InitCol; {gets the current palette and saves it}

Procedure FadeOUT(Duration:Byte);   { lowers/increases the brightness,}
Procedure FadeIN(Duration:Byte);    { duration determines the time it takes}

Procedure SetBrightness(Brightness :Byte);
                                    {sets the brightness to brightness / 63 }
IMPLEMENTATION

USES Crt, Dos;

CONST     PelIdxR  = $3c7; {Port to read}
          PelIdxW  = $3c8; {Port to write}
          PelData  = $3c9; {Dataport}
          Maxreg   = 255;  {Set to 63 for textmode}
          MaxInten = 63;

VAR col : ARRAY[0..MaxReg] of RECORD
                                r, g, b : Byte
                              END;

PROCEDURE GetCol(ColNr :Byte; var r, g, b :Byte);
BEGIN
  Port[PelIdxR] := ColNr;
  r := Port[PelData];
  g := Port[PelData];
  b := Port[PelData];;
END;

PROCEDURE SetCol(ColNr, r, g, b :Byte); {Change just one colour}
BEGIN
  Port[PelIdxW] := ColNr;
  Port[PelData] := r;
  Port[PelData] := g;
  Port[PelData] := b;
END;

PROCEDURE InitCol; {save initial palette}

VAR i :Byte;

BEGIN
  FOR i := 0 to MaxReg DO
    GetCol(i,col[i].r,col[i].g,col[i].b);
END;

PROCEDURE SetBrightness(Brightness :Byte);

VAR i          :Byte;
    fr, fg, fb :Byte;

BEGIN
  FOR i := 0 to MaxReg DO
  BEGIN
    fr := col[i].r * Brightness DIV MaxInten;
    fg := col[i].g * Brightness DIV MaxInten;
    fb := col[i].b * Brightness DIV MaxInten;
    SetCol(i,fr,fg,fb);
  END;
END;

PROCEDURE FadeOUT(Duration :Byte);

VAR i :Byte;

BEGIN
  FOR i := MaxInten downto 0 DO
  BEGIN
    SetBrightness(i);
    Delay(Duration);
  END;
END;

PROCEDURE FadeIN(Duration :Byte);

VAR i :Byte;

BEGIN
  FOR i := 0 to MaxInten DO
  BEGIN
    SetBrightness(i);
    Delay(Duration);
  END;
END;

BEGIN
END.

