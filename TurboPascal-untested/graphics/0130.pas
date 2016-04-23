{here are some assembler routines for the 320x200x256 mode.}

uses
 crt;

PROCEDURE InitVGA; ASSEMBLER;
asm
   mov  ax, 13h
   int  10h
end;

PROCEDURE InitTEXT; ASSEMBLER;
asm
   mov  ax, 03h
   int  10h
end;

PROCEDURE PlotPixel1(X, Y: Word; Color: Byte); ASSEMBLER;
asm
   push es
   push di
   mov  ax, Y
   mov  bx, ax
   shl  ax, 8
   shl  bx, 6
   add  ax, bx
   add  ax, X
   mov  di, ax
   mov  ax, $A000
   mov  es, ax
   mov  al, Color
   mov  es:[di], al
   pop  di
   pop  es
end;

PROCEDURE PlotPixel2(X, Y : word; Color : byte);
begin
 if (X<320) then if (Y<200) then mem[$A000: Y*320+X] := color;
end;


PROCEDURE SetColor (ColorNo, Red, Green, Blue : byte);
begin
     PORT[$3C8] := ColorNo;
     PORT[$3C9] := Red;
     PORT[$3C9] := Green;
     PORT[$3C9] := Blue;
end;


var
 LoopX : word;
 LoopY, R, G, B, i : byte;
 Ky : char;

Begin
 Randomize;
 InitVGA;
 for LoopY := 0 to 199 do
 begin
  for LoopX := 0 to 319 do
   PlotPixel1(LoopX, LoopY, random(255)+1);
 end;
 B := 0;
 repeat
  G := random(63);
  for R := 0 to 63 do
  begin
   Setcolor(random(255)+1, R, G, B);
   inc(G, 1);
   if G=64 then G := 0;
  end;
  for G := 63 downto 0 do
  R := random(63);
  begin
   Setcolor(random(255)+1, R, G, B);
   dec(R, 1);
   if R=0 then R := 63;
  end;
  inc(B, random(10)-5);
  if B>63 then B := random(63);
 until keypressed;
 Ky := readkey;
 InitTEXT;
end.


