(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0066.PAS
  Description: VGA Text Mode Demo
  Author: KAI ROHRBACHER
  Date: 11-02-93  10:35
*)

{
KAI ROHRBACHER

>> VGA Text mode (which is just an all-points-not-addressable mode,
>> whereas the Graphics modes we're all familiar With are called all-
>> points-addressable. The point is that whether all the points are
>> addressable or not is irrevelant, but rather the "points" are
>> there period.)

No.  The  width  of  a  normal  256  color  Graphics mode counts twice
compared  to the pixel frequency of a 16 color mode (Text or Graphic):
a  320  pixel  resolution in 256 colors needs the same clock rate as a
640 pixel resolution in 16 color mode.

>> Anyway, the VGA Text mode consists of 80 Characters wide
>> each which are 9 points wide. Do you see where I'm going...the VGA
>> ISSSSS capable of 720 pixels wide.
> I wouldn't doubt it since we've seen 640x480x16 on a regular VGA.
> 720 isn't far from 640.

That's  why  it  is  so  easy  to  trick  the  VGA into 360x400x256 or
360x480x256 modes: 80 Text columns * 9 pixels = 720 pixels. 720/2=360.
Here's  a  small Program, demonstrating some Graphics mode; it's taken
from a German computer magazine, I just ported it from "C" to TP.
Note  that  For  the  same reason, I doubt that the claimed resolution
640x400x256  will  run  on  a  standard  VGA:  it  would require a dot
frequency of 1280 pixels in a 16 color mode!
}

Program vgademo;

Uses
  Dos, Crt;

Const
  maxPar = 23;

Type
  parameter = Array [0..maxPar] of Byte;

Const
 CrtRegVal320x240 : parameter { Static }  =
   (95,79,80,130,84,128,13,62,0,65,0,0,0,0,0,0,234,172,223,40,0,231,6,227);
 CrtRegVal320x400 : parameter { Static }  =
   (95,79,80,130,84,128,191,31,0,64,0,0,0,0,0,0,156,142,143,40,0,150,185,227);
 CrtRegVal360x480 : parameter { Static }  =
   (107,89,90,142,94,138,13,62,0,64,0,0,0,0,0,0,234,172,223,45,0,231,6,227);
 CrtRegVal640x400 : parameter { Static }  =
   (95,79,80,130,84,128,191,31,0,64,0,0,0,0,0,0,156,142,143,40,0,150,185,163);

 actualMode :Byte = 0;

 R640x400 = 4;
 R360x480 = 3;
 R320x400 = 2;
 R320x240 = 1;    { die moeglichen Aufloesungen }


Var
  ch       : Char;
  VideoRam,
  zb4,           {ein 1/4 der Bytes je Grafikzeile}
  max_X,
  max_Y    : Word;
  regs     : Registers;

Function ReadMode : Byte;
begin
  regs.ah := $f;
  intr($10, regs);
  ReadMode := regs.al;
end;


Procedure OldMode(OldMod : Byte);
begin
  regs.ah := 0;
  regs.al := OldMod;
  intr($10, regs);
end;


Procedure Mode(Resolution : Word);
Var
  Read_1,
  RegNumber : Word;
begin
 regs.ax := $0012;
 intr($10, regs);
 regs.ax := $0013;
 intr($10, regs);
 portw[$3c4] := $0604;
 port[$3d4]  := $11;
 Read_1      := port[$03d5] And $7f;
 port[$03d5] := Read_1;

 Case Resolution Of
   R320x240 :
   begin
     actualMode   := R320x240;
     portw[$03c4] := $0100;
     port[$03c2]  := $e3;
     portw[$03c4] := $0300;
     For RegNumber := 0 to maxPar DO
       portw[$03d4] := CrtRegVal320x240[RegNumber] SHL 8 + RegNumber;
     zb4   := 80;
     max_X := 319;
     max_Y := 239;
   end;

   R320x400 :
   begin
     actualMode := R320x400;
     For RegNumber := 0 to maxPar DO
       portw[$03d4] := CrtRegVal320x400[RegNumber] SHL 8 + RegNumber;
     zb4   := 80;
     max_X := 319;
     max_Y := 399;
   end;

   R360x480 :
   begin
     actualMode := R360x480;
     portw[$03c4] := $0100;
     port[$03c2]  := $e7;
     portw[$03c4] := $0300;
     For RegNumber := 0 to maxPar DO
       portw[$03d4] := CrtRegVal360x480[RegNumber] SHL 8 + RegNumber;
     zb4   := 90;
     max_X := 359;
     max_Y := 479;
   end;

   R640x400 :
   begin
     actualMode   := R640x400;
     {hier!}
     portw[$03c4] := $0100;
     port[$03c2]  := $e7;
     portw[$03c4] := $0300;
     For RegNumber := 0 to maxPar DO
       portw[$03d4] := CrtRegVal640x400[RegNumber] SHL 8 + RegNumber;
     zb4   := 160;
     max_X := 639;
     max_Y := 399;
   end
 end;

 VideoRam := $a000;
end;


Procedure Paint(Resolution, Side : Word);
begin
  Case Resolution Of
    R320x240 : Case Side Of
                 1  : VideoRam := $a000;
                 2  : VideoRam := $a4b0;
                 3  : VideoRam := $a960;
                 else VideoRam := $a000;
               end;
    R320x400 : Case Side Of
                 1  : VideoRam := $a000;
                 2  : VideoRam := $a800;
                 else VideoRam := $a000;
               end;
    R360x480,
    R640x400 : VideoRam := $a000;
    else
      VideoRam := $a000;
  end;
end;


Procedure Show(Resolution, Side : Word);
Var
  Start : Word;
begin
  Case Resolution Of
    R320x240 :
    Case Side Of
      1 : Start := 0;
      2 : Start := $4b;
      3 : Start := $96;
      else { Default } Start := 0;
    end;

    R320x400:
    Case Side Of
      1 : Start := 0;
      2 : Start := $80;
      else { Default } Start := 0;
    end;

    R360x480,
    R640x400 : Start := 0;

    else { Default } Start := 0;
  end;
  portw[$03d4] := Start SHL 8 + $0c;
end;


Procedure SetPoint(x, y, Color : Word);
Var
  Offset : Word;
begin
{ if actualMode=R640x400
  then Offset:=(y*zb4)+ (x shr 1 and $FE)
  else}
  Offset := (y * zb4) + (x Shr 2);
  portw[$03c4] := (1 Shl ((x And 3) + 8)) + 2;
  mem[VideoRam : Offset] := Color;
end;


Function GetPoint(x, y : Word) : Word;
Var
  Offset : Word;
begin
{ if actualMode=R640x400
  then Offset:=(y*zb4)+ (x shr 1 and $FE)
  else}
  Offset := (y * zb4) + (x Shr 2);
  portw[$03ce] := (x And 3) SHL 8 + 4;
  GetPoint := mem[VideoRam : Offset];
end;

{ Demo-HauptProgramm }

Procedure main;
Var
  x,
  y,
  c,
  OldMod : Word;

begin
  OldMod := ReadMode; { speichert alten Videomodus in Oldmod }
  Writeln('VGASTAR');
  Writeln('320x240 (3 Seiten), 320x400 (2 Seiten ) 360x480 oder');
  Writeln('640x400 Pixel in 256 Farben auf Standard-VGA mit 256K');
  Writeln('1991 Ingo Spitczok von Brisinski, c''t 12/91');
  Writeln(' Modus 1: 320 x 240 Pixel mit 3 Seiten');
  Write('Bitte Return-Taste druecken');
  ch := ReadKey;
  Mode(R320x240);
  Show(R320x240, 1);
  Paint(R320x240, 1);
  x := 0;
  While (x <= max_X) Do
  begin
    y := 0;
    While (y <= max_Y) Do
    begin
      { male in 256 Farben }
      SetPoint(x, y, ((x + y) And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  Show(R320x240, 2);
  Paint(R320x240, 2);
  x := 100;
  While (x < 201) Do
  begin
    y := 100;
    While (y < 201) Do
    begin
      { Quadrat 100x100 Pixel }
      SetPoint(x, y, ((x + y) And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  Paint(R320x240, 3);
  c := 0;
  While (c <= max_Y) Do
  begin
    SetPoint(c, c, 10);
    c := Succ(c)
  end;

  ch := ReadKey;
  Show(R320x240, 3);
  ch := ReadKey;
  Show(R320x240, 1);
  ch := ReadKey;
  OldMode(OldMod);
  Writeln(' Modus 2: 320 x 400 Pixel, 2 Seiten');
  ch := ReadKey;
  Mode(R320x400);
  Show(R320x400, 1);
  Paint(R320x400, 1);
  x := 0;

  While (x <= max_X) Do
  begin
    y := 0;
    While (y < 200) Do
    begin
      SetPoint(x, y, ((x + y) And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  x := 0;
  While (x < 320) Do
  begin
    y := 200;
    While (y < 400) Do
    begin
      SetPoint(x, y, 22);
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  Paint(R320x400, 2);
  x := 80;
  While (x < 220) Do
  begin
    y := 0;
    While (y <= max_Y) Do
    begin
      SetPoint(x, y, ((x + y) And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  ch := ReadKey;
  Show(R320x400, 2);
  ch := ReadKey;
  Show(R320x400, 3);
  Paint(R320x400, 1);
  x := 100;

  While (x < 200) Do
  begin
    y := 0;
    While (y < 50) Do
    begin
      c := GetPoint(x, y);
      { Lies die Farbe }
      SetPoint(x, y + 250, c);
      { Male die gelesene Farbe } ;
      y := Succ(y)
    end;
    x := Succ(x)
  end { For };

  ch := ReadKey;
  OldMode(OldMod);
  Writeln(' Modus 3: 360 x 400 Pixel, 1 Seite');
  ch := ReadKey;
  Mode(R360x480);
  x := 0;

  While (x < 320) Do
  begin
    y := 0;
    While (y < 200) Do
    begin
      SetPoint(x, y, (x And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  x := 0;
  While (x <= max_X) Do
  begin
    y := 200;
    While (y <= max_Y) Do
    begin
      SetPoint(x, y, y And 255);
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  x := 320;
  While (x <= max_X) Do
  begin
    y := 0;
    While (y  <=  max_Y) Do
    begin
      SetPoint(x, y, 25);
      y  :=  Succ(y)
    end;
    x  :=  Succ(x)
  end;

  x  :=  0;
  While (x <= max_X) Do
  begin
    y := 400;
    While (y <= max_Y) Do
    begin
      SetPoint(x, y, 26);
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  ch := ReadKey;
  OldMode(OldMod);
  Writeln(' Modus 4: 640 x 400 Pixel, 1 Seite');
  ch := ReadKey;
  Mode(R640x400);
  x := 0;

  While (x <= max_X) Do
  begin
    y := 0;
    While (y <= max_Y) Do
    begin
      { male in 256 Farben };
      SetPoint(x, y, ((x+y) And 255));
      y := Succ(y)
    end;
    x := Succ(x)
  end;

  x := 0;
  While (x < 400) Do
  begin
    y := x;
    While (y < 400) Do
    begin
      c := GetPoint(x, y);
      SetPoint(x, y, 255-c);
      { aendere Farbe};
      y := Succ(y)
    end;
    x := Succ(x)
  end;
  ch := ReadKey;
  OldMode(OldMod);
end;

Procedure SetPix(x, y, Color : Word);
Var
  Offset : Word;
begin
  if actualMode = R640x400 then
    Offset := (y * zb4) + (x shr 1 and $FE)
  else
    Offset := (y * zb4) + (x Shr 2);
  portw[$03c4] := (1 Shl ((x And 3) + 8)) + 2;
  mem[VideoRam : Offset] := Color;
end;


Function GetPix(x, y : Word) : Word;
Var
  Offset : Word;
begin
{ if actualMode=R640x400
  then Offset := (y*zb4)+ (x shr 1 and $FE)
  else}
  Offset := (y * zb4) + (x Shr 2);
  portw[$03ce] := (x And 3) SHL 8 + 4;
  GetPix := mem[VideoRam : Offset];
end;

begin
  main;
end.

