{
MIKE BURNS

> does someone have a circle routine for the 320x200x256 mode. I need one
> using the assembler...  (FAST) ( or isn't that possible) I doesn't need to
> be very perfect, if it has the shape of a circle, I'm satisfied.
}

PROCEDURE SWAP(VAR A, B : Integer);
Var
  X : Integer;
Begin
  X := A;
  A := B;
  B := X;
End;

Var
  SCR : Array [0..199, 0..319] of Byte Absolute $A000 : $0000;

PROCEDURE Circle(X, Y, Radius : Word; Color: Byte);
VAR
  a, af, b, bf,
  target, r2   : Integer;
Begin
  Target := 0;
  A  := Radius;
  B  := 0;
  R2 := Sqr(Radius);

  While a >= B DO
  Begin
    b:= Round(Sqrt(R2 - Sqr(A)));
    Swap(Target, B);
    While B < Target Do
    Begin
      Af := (120 * a) Div 100;
      Bf := (120 * b) Div 100;
      SCR[x + af, y + b] := color;
      SCR[x + bf, y + a] := color;
      SCR[x - af, y + b] := color;
      SCR[x - bf, y + a] := color;
      SCR[x - af, y - b] := color;
      SCR[x - bf, y - a] := color;
      SCR[x + af, y - b] := color;
      SCR[x + bf, y - a] := color;
      B := B + 1;
    End;
    A := A - 1;
  End;
End;

begin
  Asm
    Mov ax, $13
    Int $10;
  end;

  Circle(50, 50, 40, $32);
  Readln;

  Asm
    Mov ax, $03
    Int $10;
  end;
end.





