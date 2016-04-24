(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0164.PAS
  Description: Percentage Bar
  Author: BRAD ZAVITSKY
  Date: 11-22-95  13:29
*)

{
Here is my percentage bar unit, that (??Steve Rogers?? I can't quite remember
now--sorry ) suggested I try a whiles back (I just got around to it).  It has
been debugged for all of a hour.
{**

PBar   Percentage Bar Unit   copr.1995 Brad Zavitsky

All Rights Reserved
Commercial use not allowed
Use at your own risk

Formulae-
  Percentage    => Round(cur/max);
  PBar progress => Round((cur/max) * #spaces);

ReDraw-
  If set to true, the whole percentage bar is redrawn each time.
  If false, it will continue were last left off

**}

unit PBar;

interface

type
  BarObj = object
    ReDraw : Boolean;
    Spaces : Integer;
    Old,
    Max    : Longint;
    Ch     : Char;
    X,
    Y,
    Color  : Byte;
    procedure UpDate(Cur: Longint);
    procedure Init(_Spaces: Integer; _Max: Longint; _Ch: Char; _X, _Y,
                   _Color: Byte; _ReDraw: Boolean);
  end;

implementation

var
  VS: word;

function VidSeg: Word;
var
  VidM: ^Byte;
begin
  {$iFDEF VER70}
  VidM := Ptr(Seg0040,$0049);
  if VidM^ = 7 then VidSeg := SegB000 else VidSeg := SegB800;
  {$ELSE}
  VidM := Ptr($0040,$0049);
  if VidM^ = 7 then VidSeg := $B000 else VidSeg := $B800;
  {$ENDiF}
end;

procedure WriteChar(Ch: char; x, y, attr: byte);
var
  where: Word;
[Abegin
  Where := 160*(Y-1)+2*(X-1);
  Mem[VS:Where] := Ord(Ch);
  Mem[VS:Where+1] := Attr;
end;

procedure BarObj.Init(_Spaces: Integer; _Max: Longint; _Ch: Char; _X, _Y,
                      _Color: Byte; _ReDraw: Boolean);
begin
  Old := 0;
  Spaces := _Spaces;
  X := _X;
  Y := _Y;
  Color := _Color;
  Ch := _Ch;
  Max := _Max;
  ReDraw := _ReDraw;
end;

procedure BarObj.UpDate(Cur: Longint);
var
  Temp,
  OldPos,
  SpacePos: Integer;
begin
  SpacePos := Round((Cur/Max) * Spaces);
  if ReDraw then
  begin
    for Temp := 0 to SpacePos-1 do WriteChar(Ch, X+Temp, Y, Color);
  end else
  begin
    Dec(SpacePos, Old);
    for Temp := 0 to SpacePos-1 do WriteChar(Ch, X+Temp+Old, Y, Color);
    Inc(Old, SpacePos);
  end;
end;

begin
  VS := VidSeg;
end.

