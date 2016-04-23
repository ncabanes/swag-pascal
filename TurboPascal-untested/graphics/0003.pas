
{Program to simulate travel through a star field - try a different MaxStar}
uses
  TpCrt, TpInline, Graph;    {OpInline used for HiWord only}
const
  MaxStar = 50;                        {num stars}
  MaxHistory = 3;                      {points per streak, = 2**n -1, note mask on line #59}
type
  T_HistoryPoint = record
                     hX, hY : Integer;
                   end;
  T_Star = record
             X, Y       : LongInt;           {star position}
             DX, DY     : LongInt;         {delta}
             DXPositive,
             DYPositive : Boolean;
             Speed      : Word;
             History    : array[0..MaxHistory] of T_HistoryPoint; {Position history}
             HistIndex  : Byte;
           end;
  T_StarArray = array[1..MaxStar] of T_Star;
var
  Gd,
  Gm,
  i,
  j       : Integer;

  Color   : Word;

  A       : T_StarArray;
  BoundX,
  BoundY,
  CenterX,

  CenterY : LongInt;

  Angle   : Real;

  Shift   : Byte;

BEGIN
  Gd := Detect;
  InitGraph(Gd, Gm, '\turbo\tp');
  if GraphResult <> grOk then
    Halt(1);
  Color := GetMaxColor;
  BoundX := GetMaxX * 65536;
  BoundY := GetMaxY * 65536;
  CenterX := GetMaxX * 32768;
  CenterY := GetMaxY * 32768;
  FillChar(A, SizeOf(A), $FF);
  Randomize;
  {Background}
  for i := 1 to 1500 do
    PutPixel(Random(GetMaxX), Random(GetMaxY), Color);
  {Stars}
  repeat
    for i := 1 to MaxStar do
      with A[i] do
        begin
          if (X < 0) or (X > BoundX) or (Y < 0) or (Y > BoundY) then
            begin
            {Position is off-screen, go back to center, new angle}
              Angle := 6.283185 * Random;
              Speed := Random(2000) + 1000;
              DX := Round(Speed * Sin(Angle));
              DY := Round(Speed * Cos(Angle));
              X := 300 * DX + CenterX;
              Y := 300 * DY + CenterY;
              DXPositive := DX > 0;
              DYPositive := DY > 0;
              DX := Abs(DX);
              DY := Abs(DY);
            {Erase all of old line segment}
              for j := 0 to MaxHistory do
                with History[j] do
                  PutPixel(hX, hY, 0);
            end
          else
            begin               {Plot point}
              Inc(HistIndex);                {Next slot in history}
              HistIndex := HistIndex and $03; { <-- change for new MaxHistory!}
              with History[HistIndex] do
                begin
                  PutPixel(hX, hY, 0);         {Erase inner dot of line segment}
                  hX := HiWord(X);
                  hY := HiWord(Y);
                  PutPixel(hX, hY, Color);     {New outer dot of line segment}
                end;
        {Next point}
              if DXPositive then
                Inc(X, DX)
              else
                Dec(X, DX); {Add delta}
              if DYPositive then
                Inc(Y, DY)
              else
                Dec(Y, DY);
              case Speed of
                1000..1300 : Shift := 9;
                1300..1600 : Shift := 8;
                1600..2100 : Shift := 7;
                2100..2700 : Shift := 6;
                2700..2900 : Shift := 5;
                2900..3000 : Shift := 4;
              end;
              Inc(DX, DX shr Shift);         {Increase delta to accelerate}
              Inc(DY, DY shr Shift);
            end;
        end;
  until KeyPressed;
  ReadLn;
  CloseGraph;
END.

