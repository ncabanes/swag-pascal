Unit MyGraph;

Interface

Type
  ColorValue = Record
    Rvalue,
    Gvalue,
    Bvalue : Byte;
  end;

  PaleteType = Array [0..255] of ColorValue;

Procedure palette(tp : paleteType);
Procedure pset(x, y : Integer; c : Byte);
Function  Point(x, y : Integer) : Byte;
Procedure RotatePalette(Var p : PaleteType; n1, n2, d : Integer);
Procedure SetVga;

Implementation

Uses
  Crt, Dos;



Var
  n, x,
  y, c, i : Integer;
  ch      : Char;
  p       : PaleteType;
  image   : File;
  ok      : Boolean;

Procedure palette(tp : PaleteType);
Var
  regs : Registers;
begin { Procedure VGApalette }
  Regs.AX := $1012;
  Regs.BX := 0; { first register to set }
  Regs.CX := 256; { number of Registers to set }
  Regs.ES := Seg(tp);
  Regs.DX := Ofs(tp);
  Intr($10, regs);
end; { Procedure SetVGApalette }

Procedure Pset(x, y : Integer; c : Byte);
begin { Procedure PutPixel }
  mem[$A000 : Word(320 * y + x)] := c;
end; { Procedure PutPixel }

Function point(x, y : Integer) : Byte;
begin { Function GetPixel }
  Point := mem[$A000 : Word(320 * y + x)];
end; { Function GetPixel }

Procedure rotatePalette(Var p : PaleteType; n1, n2, d : Integer);
Var
  q : PaleteType;
begin { Procedure rotatePalette }
  q := p;
  For i := n1 to n2 do
    p[i] := q[n1 + (i + d) mod (n2 - n1 + 1)];
  palette(p);
end; { Procedure rotatePalette }

Procedure SetVga;
begin
  Inline($B8/$13/$00/$CD/$10);
end;

end.

