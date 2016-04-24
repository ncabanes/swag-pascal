(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0190.PAS
  Description: Rotating Screen Spiral
  Author: MARIO VAN DEN ANCKER
  Date: 09-04-95  10:57
*)

{
Mario van den Ancker,
Amsterdam, The Netherlands.
E-mail: mario@astro.uva.nl
WWW: http://www.astro.uva.nl/mario/

-----8<---------8<---------8<---------8<---------8<---------8<---------8<-----
}
Program Spiral;

{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}

{ Spiral.pas - by Mario van den Ancker
                  E-Mail: mario@astro.uva.nl
                  WWW: http://www.astro.uva.nl/mario/
  Program to display a rotating spiral on the screen in 320x200x256 MCGA
  mode using colour-cycling. Please be patient. Generating the spiral image
  takes a little while. Requires TP 6.0 or higher. Donated to the public
  domain. }

Uses Crt;


type
  RGB = Array[1..3] of Byte;
  TPalette = Array[0..255] of RGB;

const
  MaxX = 319;            { Dimensions of MCGA screen. }
  MaxY = 199;
  MidX = MaxX div 2;
  MidY = MaxY div 2;

  Palette: TPalette = (
     (0, 0, 0), (0, 0, 63), (3, 0, 60), (7, 0, 56), 
     (10, 0, 53), (13, 0, 50), (15, 0, 48), (17, 1, 46), 
     (19, 1, 44), (20, 1, 43), (21, 1, 42), (23, 1, 40), 
     (24, 1, 39), (25, 1, 38), (26, 1, 37), (27, 2, 36), 
     (28, 2, 35), (29, 2, 34), (30, 2, 33), (31, 2, 32), 
     (32, 2, 31), (33, 3, 30), (34, 3, 29), (34, 3, 29), 
     (35, 3, 28), (35, 3, 28), (36, 3, 27), (37, 4, 26), 
     (37, 4, 26), (38, 4, 25), (38, 4, 25), (39, 4, 24), 
     (40, 5, 23), (40, 5, 23), (41, 5, 22), (41, 5, 22), 
     (41, 5, 22), (42, 6, 21), (42, 6, 21), (43, 6, 20), 
     (43, 6, 20), (43, 6, 20), (44, 7, 19), (44, 7, 19), 
     (45, 7, 18), (45, 8, 18), (45, 8, 18), (46, 8, 17), 
     (46, 8, 17), (47, 9, 16), (47, 9, 16), (47, 9, 16), 
     (47, 9, 16), (48, 10, 15), (48, 10, 15), (48, 10, 15), 
     (49, 11, 14), (49, 11, 14), (49, 11, 14), (50, 12, 13), 
     (50, 12, 13), (50, 13, 13), (50, 13, 13), (51, 13, 12),
     (51, 14, 12), (51, 14, 12), (51, 14, 12), (52, 15, 11), 
     (52, 15, 11), (52, 15, 11), (53, 16, 10), (53, 16, 10), 
     (53, 17, 10), (53, 17, 10), (54, 18, 9), (54, 18, 9), 
     (54, 19, 9), (54, 19, 9), (54, 20, 9), (55, 20, 8), 
     (55, 21, 8), (55, 21, 8), (55, 22, 8), (56, 22, 7), 
     (56, 23, 7), (56, 23, 7), (56, 24, 7), (56, 24, 7), 
     (57, 25, 6), (57, 26, 6), (57, 26, 6), (57, 27, 6), 
     (57, 28, 6), (57, 28, 6), (58, 29, 5), (58, 30, 5), 
     (58, 30, 5), (58, 31, 5), (59, 32, 4), (59, 33, 4), 
     (59, 33, 4), (59, 34, 4), (59, 35, 4), (59, 36, 4), 
     (59, 37, 4), (60, 38, 3), (60, 38, 3), (60, 39, 3), 
     (60, 40, 3), (60, 41, 3), (60, 42, 3), (61, 43, 2), 
     (61, 44, 2), (61, 45, 2), (61, 46, 2), (61, 47, 2), 
     (61, 48, 2), (61, 49, 2), (62, 50, 1), (62, 51, 1), 
     (62, 52, 1), (62, 54, 1), (62, 55, 1), (62, 56, 1), 
     (63, 57, 0), (63, 59, 0), (63, 60, 0), (63, 61, 0), 
     (63, 63, 0), (63, 61, 0), (63, 60, 0), (63, 59, 0), 
     (63, 57, 0), (62, 56, 1), (62, 55, 1), (62, 54, 1), 
     (62, 52, 1), (62, 51, 1), (62, 50, 1), (61, 49, 2), 
     (61, 48, 2), (61, 47, 2), (61, 46, 2), (61, 45, 2),
     (61, 44, 2), (61, 43, 2), (60, 42, 3), (60, 41, 3), 
     (60, 40, 3), (60, 39, 3), (60, 38, 3), (60, 38, 3), 
     (59, 37, 4), (59, 36, 4), (59, 35, 4), (59, 34, 4), 
     (59, 33, 4), (59, 33, 4), (59, 32, 4), (58, 31, 5), 
     (58, 30, 5), (58, 30, 5), (58, 29, 5), (57, 28, 6), 
     (57, 28, 6), (57, 27, 6), (57, 26, 6), (57, 26, 6), 
     (57, 25, 6), (56, 24, 7), (56, 24, 7), (56, 23, 7), 
     (56, 23, 7), (56, 22, 7), (55, 22, 8), (55, 21, 8), 
     (55, 21, 8), (55, 20, 8), (54, 20, 9), (54, 19, 9), 
     (54, 19, 9), (54, 18, 9), (54, 18, 9), (53, 17, 10), 
     (53, 17, 10), (53, 16, 10), (53, 16, 10), (52, 15, 11), 
     (52, 15, 11), (52, 15, 11), (51, 14, 12), (51, 14, 12), 
     (51, 14, 12), (51, 13, 12), (50, 13, 13), (50, 13, 13), 
     (50, 12, 13), (50, 12, 13), (49, 11, 14), (49, 11, 14), 
     (49, 11, 14), (48, 10, 15), (48, 10, 15), (48, 10, 15), 
     (47, 9, 16), (47, 9, 16), (47, 9, 16), (47, 9, 16), 
     (46, 8, 17), (46, 8, 17), (45, 8, 18), (45, 8, 18), 
     (45, 7, 18), (44, 7, 19), (44, 7, 19), (43, 6, 20), 
     (43, 6, 20), (43, 6, 20), (42, 6, 21), (42, 6, 21), 
     (41, 5, 22), (41, 5, 22), (41, 5, 22), (40, 5, 23),
     (40, 5, 23), (39, 4, 24), (38, 4, 25), (38, 4, 25), 
     (37, 4, 26), (37, 4, 26), (36, 3, 27), (35, 3, 28), 
     (35, 3, 28), (34, 3, 29), (34, 3, 29), (33, 3, 30), 
     (32, 2, 31), (31, 2, 32), (30, 2, 33), (29, 2, 34), 
     (28, 2, 35), (27, 2, 36), (26, 1, 37), (25, 1, 38), 
     (24, 1, 39), (23, 1, 40), (21, 1, 42), (20, 1, 43), 
     (19, 1, 44), (17, 1, 46), (15, 0, 48), (13, 0, 50), 
     (10, 0, 53), (7, 0, 56), (3, 0, 60), (0, 0, 63));

var
  MyPal, InitPal: TPalette;
  TimesRun: LongInt;
  i, j: Integer;
  Time: Longint Absolute $0000:$046c;
  StartTime, EndTime: Longint;


{ Waits for VGA's vertical retrace. }
procedure WaitVRetrace; Assembler;
Asm
  mov  dx, 3DAh
@@1:
  in   al, dx
  and  al, 08h
  jnz  @@1
@@2:
  in   al, dx
  and  al, 08h
  jz   @@2
end;

{ Sets a complete palette. }
procedure SetPal(var Palet: TPalette); Assembler;
Asm
  call  WaitVRetrace
  push  ds
  lds   si, Palet
  mov   dx, 3c8h
  mov   al, 0
  out   dx, al
  inc   dx
  mov   cx, 768
  rep   outsb
  pop   ds
end;

{ Flips the screen to 320x200x256 MCGA mode and puts all palette colours to
  black. }
procedure SetMCGAMode;
var
  Palet: TPalette;
begin
  Asm
    mov  ax, 0013h
    int  10h
  end;

  FillChar(Palet, 768, 0);   { Put all palette colors to black. }
  SetPal(Palet);
end;

{ Flips screen back to text mode. }
procedure SetTextMode; Assembler;
Asm
  mov ax, $0003
  int 10h
end;

{ PutPixel in MCGA mode. }
procedure PutPixel(x, y: Word; Color: Byte); Assembler;
Asm
  mov  ax, y
  mov  bx, x
  xchg ah, al
  add  bx, ax
  shr  ax, 2
  add  bx, ax
  mov  ax, $A000
  mov  es, ax
  mov  al, Color
  mov  es:[bx], al
end;

{ Cycles all colours in both Palettes. }
procedure CyclePalettes;
var
  ColMin: RGB;
  i, j, k: Byte;
begin
  ColMin := MyPal[1];
  for i := 1 to 254 do MyPal[i] := MyPal[i+1];
  MyPal[255] := ColMin;
  ColMin := InitPal[1];
  for i := 1 to 254 do InitPal[i] := InitPal[i+1];
  InitPal[255] := ColMin;
  SetPal(MyPal);
end;

{ Draws a spiral on the screen. }
procedure DrawSpiral(Phi0: Double; Colour: Byte);
var
  x, y, i: Integer;
  Phase1, Phase2: Double;
begin
  Phase1 := Phi0;
  Phase2 := 0;
  for i := 0 to 1850 do
  begin
    x := MidX + round(Phase2*sin(Phase1));
    y := MidY + round(Phase2*cos(Phase1)/1.2);  { Divide by 1.2 to correct for non-square pixels. }
    if (x >= 0) and (x <= MaxX) and (y >= 0) and (y <= MaxY) then PutPixel(x, y, Colour);
    Phase1 := Phase1 + 0.0035*Pi;
    Phase2 := Phase2 + 0.035*Pi;
  end;
end;


begin
  SetMCGAMode;
  MyPal := Palette;
  InitPal := Palette;

  StartTime := Time;
  for i := 0 to 255 do                { Draw spirals in 255 different colours. }
    DrawSpiral(i*2*Pi/255, i);
  EndTime := Time;

  TimesRun := 0;
  Repeat
    if (TimesRun < 256) then          { Start with turning colours up. }
    begin
      for i := 0 to 255 do
        for j := 1 to 3 do
          MyPal[i,j] := round(InitPal[i,j]*TimesRun/255);
    end;
    if (TimesRun > 3000-256) then    { And end with turning colours down. }
    begin
      for i := 0 to 255 do
        for j := 1 to 3 do
          MyPal[i,j] := round(InitPal[i,j]*(3000-TimesRun)/255);
    end;
    CyclePalettes;
    Inc(TimesRun);
  Until KeyPressed or (TimesRun > 3000);
  SetTextMode;
  WriteLn('Time required to generate image: ', (EndTime-StartTime)/18.0:2:2, ' seconds.');
end.

