(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0001.PAS
  Description: Proportional Fade
  Author: REYNIR STEFANSSON
  Date: 05-28-93  13:39
*)

{
REYNIR STEFANSSON

     Here is yet another fade-in routine. This one does a proportional fade
of all colours.
}

Program FadeDemo;

Uses
  Crt;

Const
  PelAddrRgR  = $3C7;
  PelAddrRgW  = $3C8;
  PelDataReg  = $3C9;

Type
  rgb = Record
    r, g, b : Byte;
  end;

Var
  i   : Integer;
  ch  : Char;
  col : Array[0..63] of rgb;

Procedure GetCol(C : Byte; Var R, G, B : Byte);
begin
  Port[PelAddrRgR] := C;
  R := Port[PelDataReg];
  G := Port[PelDataReg];
  B := Port[PelDataReg];
end;

Procedure SetCol(C, R, G, B : Byte);
begin
  Port[PelAddrRgW] := C;
  Port[PelDataReg] := R;
  Port[PelDataReg] := G;
  Port[PelDataReg] := B;
end;

Procedure SetInten(b : Byte);
Var
  i  : Integer;
  fr,
  fg,
  fb : Byte;
begin
  For i := 0 to 63 DO
  begin
    fr := col[i].r * b div 63;
    fg := col[i].g * b div 63;
    fb := col[i].b * b div 63;
    SetCol(i, fr, fg, fb);
  end;
end;

begin
  TextMode(LastMode);
  For i := 0 to 63 DO
    GetCol(i, col[i].r, col[i].g, col[i].b);
  For i := 1 to 15 DO
  begin
    TextAttr := i;
    WriteLn('Foreground colour = ', i : 2);
  end;
  ch := ReadKey;
  For i := 63 DOWNTO 0 DO
  begin
    SetInten(i);
    Delay(20);
  end;
  GotoXY(1, 1);
  For i := 15 DOWNTO 1 DO
  begin
    TextAttr := i;
    WriteLn('Foreground colour = ', i : 2);
  end;

  For i := 0 to 63 DO
  begin
    SetInten(i);
    Delay(20);
  end;
  ch := ReadKey;
  TextMode(LastMode);
end.

