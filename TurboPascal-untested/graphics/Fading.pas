(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0040.PAS
  Description: Fading
  Author: KEVIN OTTO
  Date: 11-02-93  06:11
*)

{ KEVIN OTTO }

Unit Fade;

{ Change DelayAmt and Steps to change the speed of fading. }

Interface

Uses
  Dos, Crt;

Const
  Colors   = 64;
  DelayAmt = 15;
  Steps    = 24;

Type
  PalType = Array [0..Colors - 1] of Record
    R, G, B : Byte;
  end;

Var
  OrigPal : palType;

Procedure GetPal(Var OrigPal : PalType);
Procedure FadePal(OrigPal : PalType; FadeOut : Boolean);

Implementation

Procedure GetPal(Var OrigPal : PalType);
Var
  Reg : Registers;
begin
  With Reg do
  begin
    AX := $1017;
    BX := 0;
    CX := colors;
    ES := seg(OrigPal);
    DX := ofs(OrigPal);
    intr ($10, Reg);
  end;
end;

Procedure FadePal(OrigPal : PalType; FadeOut : Boolean);
Var
  Reg     : Registers;
  WorkPal : PalType;
  Fade    : Word;
  Pct     : Real;
  I       : Word;
begin
  With Reg do
  For Fade := 0 to Steps do
  begin
    Pct := Fade / Steps;
    if FadeOut then
      Pct := 1 - Pct;
    For I := 0 to Colors - 1 do
    With WorkPal[I] do
    begin
      R := round(OrigPal[I].R * Pct);
      G := round(OrigPal[I].G * Pct);
      B := round(OrigPal[I].B * Pct);
    end;
    AX := $1012;
    BX := 0;
    CX := Colors;
    ES := seg (WorkPal);
    DX := ofs (WorkPal);
    intr ($10, Reg);
    Delay (DelayAmt);
  end;
end;

end.

