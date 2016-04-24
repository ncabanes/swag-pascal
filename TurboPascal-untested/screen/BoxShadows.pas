(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0037.PAS
  Description: Box Shadows
  Author: KIMBA DOUGHTY
  Date: 11-02-93  05:02
*)

{
KIMBA DOUGHTY

> could someone tell me how to do a shadow Window.. you know the Type that
> has a Window then a shadow of what is under the Window in color 8 or dark
> gray... Either in Inline assembly or Straight Pascal...
}

Unit shadow;

Interface

Uses
  Crt, Dos;

Procedure WriteXY(X, Y : Integer; S : String);
Function  GetCharXY(X, Y : Integer) : Char;
Procedure SHADE(PX, PY, QX, QY : Integer);
Procedure BOX(PX, PY, QX, QY : Integer);
Procedure SHADOWBOX(PX, PY, QX, QY : Integer; fg, bg : Byte);

Implementation

Procedure menubox(x1, y1, x2, y2 : Integer; fg, bg : Byte);
Var
  count : Integer;
begin
  TextColor(fg);
  TextBackGround(bg);
  Writexy(x1 + 1, y1, '╔');

  For count := x1 + 2 to x2 - 2 do
    Writexy(count, y1, '═');

  Writexy(x2 - 1, y1, '╗');
  For count := y1 + 1 to y2 - 1 do
    Writexy(x1 + 1, count, '║');

  Writexy(x1 + 1, y2, '╚');
  For count := y1 + 1 to y2 - 1 do
    Writexy(x2 - 1, count, '║');

  Writexy(x2 - 1, y2, '╝');
  For count := x1 + 2 to x2 - 2 do
    Writexy(count, y2, '═');
end;

Procedure WriteXY(X, Y : Integer; S : String);
Var
  SX, SY : Integer ;
begin
  SX := WhereX;
  SY := WhereY;
  GotoXY(X, Y);
  Write(S);
  GotoXY(SX, SY);
end;

Function GetCharXY(X, Y : Integer) : Char;
Var
  Regs : Registers;
  SX, SY : Integer;
begin
  SX := WhereX;
  SY := WhereY;
  GotoXY(X, Y);
  Regs.AH := $08;
  Regs.BH := $00;
  Intr($10, Regs);
  GetCharXY := Char(Regs.AL);
  GotoXY(SX, SY);
end;

Procedure SHADE(PX, PY, QX, QY : Integer);
Var
  X, Y : Integer;
begin
  TextColor(8);
  TextBackGround(black);
  For Y := PY to QY Do
  For X := PX to QX Do
    WriteXY(X, Y, GetCharXY(X, Y));
end;

Procedure BOX(PX, PY, QX, QY : Integer);
begin
  Window(PX, PY, QX, QY);
  ClrScr;
end;

Procedure SHADOWBOX(PX, PY, QX, QY: Integer; fg, bg : Byte);
begin
  TextColor(fg);
  TextBackGround(bg);
  BOX(PX, PY, QX, QY);
  Window(1, 1, 80, 25);
  SHADE(PX + 2, QY + 1, QX + 2, QY + 1);
  SHADE(QX + 2, PY + 1, QX + 2, QY + 1);
  SHADE(QX + 1, PY + 1, QX + 1, QY + 1);
  MENUBOX(PX, PY, QX, QY, fg, bg);
end;

end.


