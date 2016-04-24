(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0037.PAS
  Description: Quick PutImage
  Author: NICK ONOUFRIOU
  Date: 11-02-93  05:54
*)

{
NICK ONOUFRIOU

I'm writing a small game that requires a transparent putimage Function. I
normally use the BGI, but in this Case I need a little bit more speed. This
partial Program shows what I have already. What I want to know is there is
simple method of masking color 0 so it won't be displayed.
}
Program PutMan;

Uses
  Dos, Crt;

Const
(* Turbo Pascal, Width= 11 Height= 23 Colors= 256 *)

  Man : Array [1..259] of Byte = (
          $0A,$00,$16,$00,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$00,$00,
          $00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$00,$00,
          $00,$00,$00,$02,$2C,$2C,$2C,$2C,$2C,$02,$00,$00,
          $00,$00,$2C,$10,$10,$2C,$10,$10,$2C,$00,$00,$00,
          $00,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$00,$00,$00,$00,
          $00,$2C,$0C,$0C,$0C,$2C,$00,$00,$00,$00,$00,$00,
          $00,$2C,$2C,$2C,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$0F,$00,$00,$00,$00,$00,$00,$0F,$00,$00,$0F,
          $0F,$0F,$00,$00,$00,$00,$00,$0F,$00,$0D,$0D,$0D,
          $0D,$0D,$00,$00,$00,$00,$0F,$0D,$0D,$0D,$0D,$0D,
          $0D,$0D,$00,$00,$00,$0F,$1F,$1F,$1F,$1F,$1F,$1F,
          $1F,$0F,$00,$00,$00,$1F,$1F,$1F,$1F,$1F,$1F,$1F,
          $0F,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$1F,$00,$0F,
          $00,$00,$00,$00,$00,$0D,$0D,$0D,$00,$00,$0F,$00,
          $00,$00,$00,$0D,$0D,$0D,$0D,$0D,$00,$00,$00,$00,
          $00,$00,$0D,$0D,$0D,$0D,$0D,$00,$00,$00,$00,$00,
          $00,$0D,$0D,$00,$0D,$0D,$00,$00,$00,$00,$00,$00,
          $0D,$0D,$00,$0D,$0D,$00,$00,$00,$00,$00,$00,$07,
          $07,$00,$07,$07,$00,$00,$00,$00,$00,$00,$07,$07,
          $00,$07,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$00,$00,$00,$00,$00,$00);

Type
  _screenRec = Array [0..199, 0..319] of Byte;

Var
  _mcgaScreen  : _screenRec Absolute $A000:0000;


Procedure SetMode(mode : Integer);
Var
  regs : Registers;
begin
  regs.ah := 0;
  regs.al := mode;
  intr($10, regs);
end;

Procedure ClearPage(color : Integer);
begin
  FillChar(_mcgaScreen, 64000, color);
end;

Procedure PutImg(x, y : Integer; Var Img);
Type
  AList = Array[1..$FFFF] of Byte;
Var
  APtr      : ^AList;
  J, Width,
  Height,
  Counter   : Word;
begin
  Aptr    := @Img;
  Width   := (Aptr^[2] SHL 8) + Aptr^[1] + 1;
  Height  := (Aptr^[4] SHL 8) + Aptr^[3] + 1;
  Counter := 5;
  For j := y to (y + height - 1) do
  begin
    Move(Aptr^[Counter], _mcgaScreen[j, x], Width);
    Inc(Counter, Width);
  end;
end;

begin
  SetMode(19);
  ClearPage(Blue);
  PutImg(150, 80, Ptr(seg(man), ofs(man))^);
  readln;
  SetMode(3);
end.

