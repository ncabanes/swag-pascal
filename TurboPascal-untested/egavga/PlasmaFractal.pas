(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0065.PAS
  Description: PLASMA Fractal
  Author: SWAG SUPPORT TEAM
  Date: 11-02-93  10:32
*)

{
>Do you have Pascal code For generating this PLAsmA fractal? if so,
>then I'd like to snarf a copy of it, if'n you don't mind... Or (if it's
>not too large) could you post it as a message? Thanx in advance!
}

Program PlAsma;

Uses
  Crt, Dos;

Const
  f = 2.0;
  EndProgram  : Boolean = False;
  DelayFactor : Byte    = 20;

Type
  ColorValue  = Record
    Rvalue,
    Gvalue,
    Bvalue : Byte;
  end;

  PaletteType = Array [0..255] of ColorValue;

Var
  ch    : Char;
  i     : Integer;
  image : File;
  ok    : Boolean;
  p     : paletteType;

Procedure SetVGApalette(Var tp : PaletteType);
Var
  regs : Registers;
begin
  With regs do
  begin
    AX := $1012;
    BX := 0;
    CX := 256;
    ES := Seg(tp);
    DX := Ofs(tp);
  end;
  Intr($10, regs);
end;

Procedure PutPixel(x, y : Integer; c : Byte);
begin
  mem[$a000 : Word(320 * y + x)] := c;
end;

Function GetPixel(x, y : Integer) : Byte;
begin
  GetPixel := mem[$a000 : Word(320 * y + x)];
end;

Procedure adjust(xa, ya, x, y, xb, yb : Integer);
Var
  d, v : Integer;
begin
  if GetPixel(x, y) <> 0 then
    Exit;
  d := abs(xa - xb) + abs(ya - yb);
  v := trunc((GetPixel(xa, ya) + GetPixel(xb, yb)) / 2 +
       (random - 0.5) * d * F);
  if v < 1 then
    v := 1;
  if v >= 193 then
    v := 192;
  putpixel(x, y, v);
end;

Procedure subDivide(x1, y1, x2, y2 : Integer);
Var
  x, y : Integer;
  v    : Real;
begin
  if KeyPressed then
    Exit;
  if (x2 - x1 < 2) and (y2 - y1 < 2) then
    Exit;
  x := (x1 + x2) div 2;
  y := (y1 + y2) div 2;
  adjust(x1, y1, x, y1, x2, y1);
  adjust(x2, y1, x2, y, x2, y2);
  adjust(x1, y2, x, y2, x2, y2);
  adjust(x1, y1, x1, y, x1, y2);
  if GetPixel(x, y) = 0 then
  begin
    v := (GetPixel(x1, y1) + GetPixel(x2, y1) + GetPixel(x2, y2) +
          getPixel(x1, y2)) / 4;
    putpixel(x, y, Trunc(v));
  end;

  SubDivide(x1, y1, x, y);
  subDivide(x, y1, x2, y);
  subDivide(x, y, x2, y2);
  subDivide(x1, y, x, y2);
end;

Procedure rotatePalette(Var p : PaletteType; n1, n2, d : Integer);
Var
  q : PaletteType;
begin
  q := p;
  For i := n1 to n2 do
    p[i] :=q[n1 + (i + d) mod (n2 - n1 + 1)];
  SetVGApalette(p);
end;

begin
  Inline($b8/$13/0/$cd/$10);
  With P[0] do
  begin
    Rvalue := 32;
    Gvalue := 32;
    Bvalue := 32;
  end;
  For i := 0 to 63 do
  begin
    With p[i + 1] do
    begin
      Rvalue := 63-i; { 63 - i }
      Gvalue := 63-i; { 63 - i }
      Bvalue := i+63;    { 0 }
    end;
    With p[i + 65] do
    begin
      Rvalue := 0;    { 0 }
      Gvalue := i+63;    { i }
      Bvalue := 63-i;    { 0 }
    end;
    With p[i + 129] do
    begin
      Rvalue := i;    { 0 }
      Gvalue := i;    { 0 }
      Bvalue := 63 - i; { 63 - i }
    end;
  end;
  Inline($b8/$13/0/$cd/$10);

  SetVGApalette(p);
  Assign(image, 'PLASMA.IMG');
  {$i-}
  Reset(image, 1);
  {$I+}
  ok := (ioResult = 0);
  if not ok or (ParamCount <> 0) then
  begin
    Randomize;
    putpixel(0, 0, 1 + Random(192));
    putpixel(319, 0, 1 + Random(192));
    putpixel(319, 199, 1 + Random(192));
    putpixel(0, 199, 1 + Random(192));
    SubDivide(0, 0, 319, 199);
    ReWrite(image, 1);
    BlockWrite(image, mem[$a000:0], $FA00);
  end
  else
    BlockRead(image, mem[$a000:0], $FA00);

  Close(image);
  Repeat
    rotatePalette(p, 1, 192, + 1);
    Delay(DelayFactor);
    If KeyPressed then
    Case ReadKey of
      #0 : Case ReadKey of
             #80 : If DelayFactor < 255 then
                     Inc(DelayFactor);
             #72 : If DelayFactor > 0 then
                     Dec(DelayFactor);
           end;
      #113,#81 {Q,q} : EndProgram := True;
    end;
  Until EndProgram;

  TextMode(lastmode);
end.

