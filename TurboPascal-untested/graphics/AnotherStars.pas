(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0031.PAS
  Description: Another STARS
  Author: BAS VAN GALLEN
  Date: 10-28-93  11:39
*)

{===========================================================================
 BBS: Canada Remote Systems
Date: 10-17-93 (23:26)
From: BAS VAN GAALEN
Subj: Stars?

{$N+}

program _Rotation;

uses
  crt,dos;

const
  NofPoints = 75;
  Speed = 5;
  Xc : real = 0;
  Yc : real = 0;
  Zc : real = 150;
  SinTab : array[0..255] of integer = (
    0,2,5,7,10,12,15,17,20,22,24,27,29,31,34,36,38,41,43,45,47,49,52,54,
    56,58,60,62,64,66,67,69,71,73,74,76,78,79,81,82,83,85,86,87,88,90,91,
    92,93,93,94,95,96,97,97,98,98,99,99,99,100,100,100,100,100,100,100,
    100,99,99,99,98,98,97,97,96,95,95,94,93,92,91,90,89,88,87,85,84,83,
    81,80,78,77,75,73,72,70,68,66,65,63,61,59,57,55,53,51,48,46,44,42,40,
    37,35,33,30,28,26,23,21,18,16,14,11,9,6,4,1,-1,-4,-6,-9,-11,-14,-16,
    -18,-21,-23,-26,-28,-30,-33,-35,-37,-40,-42,-44,-46,-48,-51,-53,-55,
    -57,-59,-61,-63,-65,-66,-68,-70,-72,-73,-75,-77,-78,-80,-81,-83,-84,
    -85,-87,-88,-89,-90,-91,-92,-93,-94,-95,-95,-96,-97,-97,-98,-98,-99,
    -99,-99,-100,-100,-100,-100,-100,-100,-100,-100,-99,-99,-99,-98,-98,
    -97,-97,-96,-95,-94,-93,-93,-92,-91,-90,-88,-87,-86,-85,-83,-82,-81,
    -79,-78,-76,-74,-73,-71,-69,-67,-66,-64,-62,-60,-58,-56,-54,-52,-49,
    -47,-45,-43,-41,-38,-36,-34,-31,-29,-27,-24,-22,-20,-17,-15,-12,-10,
    -7,-5,-2,0);

type
  PointRec = record
               X,Y,Z : integer;
             end;
  PointPos = array[0..NofPoints] of PointRec;

var
  Point : PointPos;

{----------------------------------------------------------------------------}

procedure SetGraphics(Mode : byte); assembler;
asm mov AH,0; mov AL,Mode; int 10h; end;

{----------------------------------------------------------------------------}

procedure Init;

var
  I : byte;

begin
  randomize;
  for I := 0 to NofPoints do begin
    Point[I].X := random(250)-125;
    Point[I].Y := random(250)-125;
    Point[I].Z := random(250)-125;
  end;
end;

{----------------------------------------------------------------------------}

procedure DoRotation;

const
  Xstep = 1;
  Ystep = 1;
  Zstep = -2;

var
  Xp,Yp : array[0..NofPoints] of word;
  X,Y,Z,X1,Y1,Z1 : real;
  PhiX,PhiY,PhiZ : byte;
  I,Color : byte;

function Sinus(Idx : byte) : real;

begin
  Sinus := SinTab[Idx]/100;
end;

function Cosinus(Idx : byte) : real;

begin
  Cosinus := SinTab[(Idx+192) mod 255]/100;
end;

begin
  PhiX := 0; PhiY := 0; PhiZ := 0;
  repeat
    while (port[$3da] and 8) <> 8 do;
    while (port[$3da] and 8) = 8 do;
    for I := 0 to NofPoints do begin

      if (Xp[I]+160 < 320) and (Yp[I]+100 < 200) then
        mem[$a000:(Yp[I]+100)*320+Xp[I]+160] := 0;

      X1 := Cosinus(PhiY)*Point[I].X-Sinus(PhiY)*Point[I].Z;
      Z1 := Sinus(PhiY)*Point[I].X+Cosinus(PhiY)*Point[I].Z;
      X := Cosinus(PhiZ)*X1+Sinus(PhiZ)*Point[I].Y;
      Y1 := Cosinus(PhiZ)*Point[I].Y-Sinus(PhiZ)*X1;
      Z := Cosinus(PhiX)*Z1-Sinus(PhiX)*Y1;
      Y := Sinus(PhiX)*Z1+Cosinus(PhiX)*Y1;

      Xp[I] := round((Xc*Z-X*Zc)/(Z-Zc));
      Yp[I] := round((Yc*Z-Y*Zc)/(Z-Zc));
      if (Xp[I]+160 < 320) and (Yp[I]+100 < 200) then begin
        Color := 31+round(Z/7);
        if Color > 31 then Color := 31
        else if Color < 16 then Color := 16;
        mem[$a000:(Yp[I]+100)*320+Xp[I]+160] := Color;
      end;

      inc(Point[I].Z,Speed); if Point[I].Z > 125 then Point[I].Z := -125;
    end;
    inc(PhiX,Xstep);
    inc(PhiY,Ystep);
    inc(PhiZ,Zstep);
  until keypressed;
end;

{----------------------------------------------------------------------------}

begin
  SetGraphics($13);
  Init;
  DoRotation;
  textmode(lastmode);
end.


