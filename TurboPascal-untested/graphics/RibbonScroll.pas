(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0092.PAS
  Description: Ribbon scroll..
  Author: GLEN JEH
  Date: 05-25-94  08:22
*)


{Ribbon scroller...programmed by Glen Jeh in Turbo Pascal 7.0, 4/24/94
 Use freely}

{$R+}
program RibbonScroll;  {this is IT}
uses Crt, Dos;

     { I turned on range checking to slow it down :) }

const
  YLocation = 100;  {position on the screen...}
  Constant = 8;     {mess with this to use different parts of the curve}
  Radius = 30;      {this is how big of a curve you want}
  Width  = 10;      {wrong name..this is actually the waviness of the curve}
  Spacing = 4;      {this is how fat the chars will be..or something}
  Height = 1.5;     {this is how tall each character will be}
  DispStr : string = 'Adjust the above constants <WRAP>...   ';

  Rows   = 8; {don't change this}

{testing}
type
  CharType = array[1..8] of Byte;
  PathType = array[1..320 div Spacing] of
    record
      Pos : Word; {position in memory}
      On  : Boolean; {on or off?}
    end;
             {this keeps track of the Y-Pos of the dot at X}
var
  CharSet : array[0..255] of CharType absolute $F000:$FA6E;
  PathArray : array[1..Rows] of PathType;
  I,
  I2,
  DispLine : Integer;

function GetNext(Row : Integer) : Boolean;
var
  CharNum,
  ColumnNum : Integer;
begin
  CharNum := DispLine div 8 + 1;
  ColumnNum := DispLine mod 8 + 1;
  GetNext := CharSet[Ord(DispStr[CharNum])][Row] shr (8 - ColumnNum) and 1 = 1;
end;


function F(X:Real): Real;
begin
  F := (Sin ((X + Constant) / Width) * Radius + YLocation)
end;


procedure Mode(B : Byte);
var
  Regs : Registers;
begin
  Regs.ah := 0;
  Regs.al := B;
  Intr($10,Regs);
end;

procedure BuildPath;
begin
  for I := 1 to Rows do
    for I2 := 1 to 320 div Spacing do
      begin
        PathArray[I][I2].Pos := Round(F(I2+Height*I));
          {compute Y location first}

        PathArray[I][I2].Pos :=
          (PathArray[I][I2].Pos - 1) * 320 + (I2 * Spacing) - 1;
          {compute memory location}
      end
end;


begin
  Mode($13);
  BuildPath;
  DispLine := 1;
  repeat
    repeat until (Port[$3DA] and $08) <> 0;
    for I := 1 to 8 do
      begin
        for I2 := 1 to (320 div Spacing) - 1 do
          PathArray[I][I2].On := PathArray[I][I2 + 1].On;
        PathArray[I][320 div Spacing].On := GetNext(I);
        for I2 := 1 to 320 div Spacing do
          if PathArray[I][I2].On then
            Mem[$A000:PathArray[I][I2].Pos] := I2 mod (100 - 50) + 50
          else
            Mem[$A000:PathArray[I][I2].Pos] := 0;
      end;
    Inc(DispLine);
    if DispLine = 8 * Length(DispStr) then
      DispLine := 1;
  until KeyPressed;
  Mode($3);
end.

