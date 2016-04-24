(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0017.PAS
  Description: Optimized line drawing
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{1)  An efficient/optimised line-drawing routine (in Pascal
or Asm) based on (or better than) the Bres. Line algorithm.
}

{$R-,S-}

Uses
  Crt, Dos;

Procedure PutPixel(X, Y : Word; Color : Byte);
begin
  Mem[$A000:Y*320+X] := Color
end;

Procedure Switch(Var First, Second : Integer);
{ Exchange the values of First and second }
Var
  Temp : Integer;
begin
  Temp := First;
  First := Second;
  Second := Temp;
end; { Switch }

Procedure Line(X1, Y1, X2, Y2, Color : Integer);
{ Uses Bressenham's algorithm For drawing a line }
Var
  LgDelta, ShDelta, LgStep, ShStep, Cycle, PointAddr : Integer;

begin
  LgDelta := X2 - X1;
  ShDelta := Y2 - Y1;
  if LgDelta < 0 then
    begin
      LgDelta := -LgDelta;
      LgStep := -1;
    end
  else
    LgStep := 1;
  if ShDelta < 0 then
    begin
      ShDelta := -ShDelta;
      ShStep := -1;
    end
  else
    ShStep := 1;
  if LgDelta > ShDelta then
    begin
      Cycle := LgDelta shr 1; { LgDelta / 2 }
      While X1 <> X2 do
      begin
        Mem[$A000:Y1*320+X1] := Color; { PutPixel(X1, Y1, Color); }
        Inc(X1, LgStep);
        Inc(Cycle, ShDelta);
        if Cycle > LgDelta then
        begin
          Inc(Y1, ShStep);
          Dec(Cycle, LgDelta);
        end;
      end;
    end
  else
    begin
      Cycle := ShDelta shr 1; { ShDelta / 2 }
      Switch(LgDelta, ShDelta);
      Switch(LgStep, ShStep);
      While Y1 <> Y2 do
      begin
        Mem[$A000:Y1*320+X1] := Color; { PutPixel(X1, Y1, Color); }
        Inc(Y1, LgStep);
        Inc(Cycle, ShDelta);
        if Cycle > LgDelta then
        begin
          Inc(X1, ShStep);
          Dec(Cycle, LgDelta);
        end;
      end;
    end;
end; { Line }

Procedure SetMode(Mode : Byte);
{ Interrupt $10, sub-Function 0 - Set video mode }
Var
  Regs : Registers;
begin
  With Regs do
  begin
    AH := 0;
    AL := Mode;
  end;
  Intr($10, Regs);
end; { SetMode }

Var
  x,y,d:Word;
  r:Real;

begin   { example }
  SetMode($13);  { 320x200 256 color mode For VGA and MCGA cards }
  For d := 0 to 360 * 10 do
  begin
     r := (d * PI) * 0.1 / 180;
     x := round(sin(r * 5) * 90) + 160;
     y := round(cos(r) * 90) + 100;
     line(160,100,x,y,x div 4);
  end;
  Repeat Until port[$60] = 1;    { hit esc to end }

  SetMode($03) { Text mode }
end.

