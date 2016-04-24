(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0252.PAS
  Description: Split Screen VGA
  Author: MARIO VAN DEN ANCKER
  Date: 09-04-95  10:57
*)

{
Mario van den Ancker,
Amsterdam, The Netherlands.
E-mail: mario@astro.uva.nl
WWW: http://www.astro.uva.nl/mario/

----8<---------8<---------8<---------8<---------8<---------8<---------8<----
}
Program SplitScreen;

{ SplitScrn.pas - by Mario van den Ancker
                  E-Mail: mario@astro.uva.nl
                  WWW: http://www.astro.uva.nl/mario/
  Program to demonstrate how to split the screen using the VGA hardware
  in 320x240x256 ModeX. Requires TP 6.0 or higher. Donated to the public
  domain. }

Uses Crt;

type
  RGB = Array[1..3] of Byte;
  TPalette = Array[0..255] of RGB;

const
  MaxX = 319;       { dimensions of screen. }
  MaxY = 239;

  SEGA000: Word = $A000;

  Palette: TPalette = (
        (0, 0, 0), (0, 0, 63), (1, 0, 62), (3, 0, 60), 
        (5, 0, 58), (7, 0, 56), (9, 0, 54), (10, 0, 53), 
        (11, 0, 52), (13, 0, 50), (14, 0, 49), (15, 0, 48), 
        (16, 0, 47), (17, 1, 46), (18, 1, 45), (19, 1, 44), 
        (19, 1, 44), (20, 1, 43), (21, 1, 42), (21, 1, 42), 
        (22, 1, 41), (23, 1, 40), (23, 1, 40), (24, 1, 39), 
        (25, 1, 38), (25, 1, 38), (26, 1, 37), (26, 1, 37), 
        (27, 1, 36), (27, 2, 36), (28, 2, 35), (28, 2, 35), 
        (29, 2, 34), (29, 2, 34), (30, 2, 33), (30, 2, 33), 
        (31, 2, 32), (31, 2, 32), (32, 2, 31), (32, 2, 31), 
        (32, 3, 31), (33, 3, 30), (33, 3, 30), (34, 3, 29), 
        (34, 3, 29), (34, 3, 29), (35, 3, 28), (35, 3, 28), 
        (35, 3, 28), (35, 3, 28), (36, 3, 27), (36, 3, 27), 
        (37, 4, 26), (37, 4, 26), (37, 4, 26), (37, 4, 26), 
        (38, 4, 25), (38, 4, 25), (38, 4, 25), (38, 4, 25), 
        (39, 4, 24), (39, 4, 24), (39, 4, 24), (40, 5, 23), 
        (40, 5, 23), (40, 5, 23), (40, 5, 23), (41, 5, 22), 
        (41, 5, 22), (41, 5, 22), (41, 5, 22), (41, 5, 22), 
        (42, 5, 21), (42, 6, 21), (42, 6, 21), (42, 6, 21), 
        (43, 6, 20), (43, 6, 20), (43, 6, 20), (43, 6, 20), 
        (43, 6, 20), (43, 6, 20), (44, 7, 19), (44, 7, 19), 
        (44, 7, 19), (44, 7, 19), (44, 7, 19), (45, 7, 18), 
        (45, 7, 18), (45, 8, 18), (45, 8, 18), (45, 8, 18), 
        (45, 8, 18), (46, 8, 17), (46, 8, 17), (46, 8, 17), 
        (46, 9, 17), (47, 9, 16), (47, 9, 16), (47, 9, 16), 
        (47, 9, 16), (47, 9, 16), (47, 9, 16), (47, 9, 16), 
        (48, 10, 15), (48, 10, 15), (48, 10, 15), (48, 10, 15), 
        (48, 10, 15), (48, 10, 15), (48, 11, 15), (49, 11, 14), 
        (49, 11, 14), (49, 11, 14), (49, 11, 14), (49, 11, 14), 
        (50, 11, 13), (50, 12, 13), (50, 12, 13), (50, 12, 13), 
        (50, 12, 13), (50, 13, 13), (50, 13, 13), (50, 13, 13), 
        (51, 13, 12), (51, 13, 12), (51, 13, 12), (51, 14, 12), 
        (51, 14, 12), (51, 14, 12), (51, 14, 12), (51, 14, 12), 
        (52, 15, 11), (52, 15, 11), (52, 15, 11), (52, 15, 11), 
        (52, 15, 11), (52, 15, 11), (53, 16, 10), (53, 16, 10), 
        (53, 16, 10), (53, 16, 10), (53, 17, 10), (53, 17, 10), 
        (53, 17, 10), (53, 17, 10), (53, 18, 10), (54, 18, 9), 
        (54, 18, 9), (54, 18, 9), (54, 19, 9), (54, 19, 9), 
        (54, 19, 9), (54, 19, 9), (54, 19, 9), (54, 20, 9), 
        (54, 20, 9), (55, 20, 8), (55, 20, 8), (55, 21, 8), 
        (55, 21, 8), (55, 21, 8), (55, 21, 8), (55, 22, 8), 
        (56, 22, 7), (56, 22, 7), (56, 22, 7), (56, 23, 7), 
        (56, 23, 7), (56, 23, 7), (56, 24, 7), (56, 24, 7), 
        (56, 24, 7), (56, 24, 7), (56, 25, 7), (57, 25, 6), 
        (57, 25, 6), (57, 26, 6), (57, 26, 6), (57, 26, 6), 
        (57, 27, 6), (57, 27, 6), (57, 27, 6), (57, 28, 6), 
        (57, 28, 6), (57, 28, 6), (58, 29, 5), (58, 29, 5), 
        (58, 29, 5), (58, 30, 5), (58, 30, 5), (58, 30, 5), 
        (58, 31, 5), (58, 31, 5), (58, 32, 5), (59, 32, 4), 
        (59, 32, 4), (59, 33, 4), (59, 33, 4), (59, 33, 4), 
        (59, 34, 4), (59, 34, 4), (59, 35, 4), (59, 35, 4), 
        (59, 35, 4), (59, 36, 4), (59, 36, 4), (59, 37, 4), 
        (60, 37, 3), (60, 38, 3), (60, 38, 3), (60, 38, 3), 
        (60, 39, 3), (60, 39, 3), (60, 40, 3), (60, 40, 3), 
        (60, 41, 3), (60, 41, 3), (60, 42, 3), (60, 42, 3), 
        (60, 42, 3), (61, 43, 2), (61, 43, 2), (61, 44, 2), 
        (61, 44, 2), (61, 45, 2), (61, 45, 2), (61, 46, 2), 
        (61, 46, 2), (61, 47, 2), (61, 47, 2), (61, 48, 2), 
        (61, 49, 2), (61, 49, 2), (61, 50, 2), (62, 50, 1), 
        (62, 51, 1), (62, 51, 1), (62, 52, 1), (62, 52, 1), 
        (62, 53, 1), (62, 54, 1), (62, 54, 1), (62, 55, 1), 
        (62, 55, 1), (62, 56, 1), (63, 57, 0), (63, 57, 0), 
        (63, 58, 0), (63, 59, 0), (63, 59, 0), (63, 60, 0), 
        (63, 61, 0), (63, 61, 0), (63, 62, 0), (63, 63, 0));

var
  x, y: Integer;
  i: Byte;


{ Waits for VGA's vertical retrace. }
procedure WaitVRetrace; Assembler;
Asm
  mov  dx, 3dah
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

{ Initializes 320x240x256 ModeX. Virtual screen is 320x800x256. }
procedure SetModeX; Assembler;
Asm
  { First get in MCGA mode. }
  mov    ax, 13h
  int    10h

  { Unchain. }
  cli
  mov    dx, 3c4h
  mov    ax, 0604h
  out    dx, ax
  mov    ax, 0f02h
  out    dx, ax

  { Clear complete VGA memory. }
  mov    ax, 0f02h           { Select all bitplanes. }
  out    dx, ax
  mov    es, SEGA000
  xor    di, di              { Clear di }
  xor    ax, ax              { Clear ax }
  mov    cx, 7fffh
  cld
  rep    stosw               { Clear garbage off the screen. }

  { Now setup 320x240x256 ModeX. }
  mov    dx, 03c2h
  mov    al, 0e3h
  out    dx, al
  mov    dx, 03d4h
  mov    ax, 02c11h
  out    dx, ax
  mov    ax, 0d06h
  out    dx, ax
  mov    ax, 3e07h
  out    dx, ax
  mov    ax, 0ea10h
  out    dx, ax
  mov    ax, 0ac11h
  out    dx, ax
  mov    ax, 0df12h
  out    dx, ax
  mov    ax, 0e715h
  out    dx, ax
  mov    ax, 0616h
  out    dx, ax
  sti
end;

{ Flips screen back to text mode. }
procedure SetTextMode; Assembler;
asm
  mov ax, 0003h
  int 10h
end;


{ Moves offset of screen to (x, y). }
procedure ScreenOffset(x, y: Word); Assembler;
Asm
  cli
  mov    ax, y
  mov    bx, ax
  shl    bx, 6
  shl    ax, 4
  add    bx, ax              { bx = y*80 }
  mov    ax, x
  add    bx, ax              { bx = y*80 + x }
  mov    ah, bh
  mov    al, 0ch

  mov    dx, 3d4h
  out    dx, ax

  mov    ah, bl
  mov    al, 0dh
  out    dx, ax
  sti
end;

{ Splits the screen. The offset of this split screen in VGA memory is always
  0. The split screen can be hidden by setting it to a line > MaxY. }
procedure SetSplitscreen(Line: Word); Assembler;
Asm
  mov    bx, Line
  shl    bx, 1
  dec    bx

  cli
  mov    dx, 3d4h            { CRTC base address }
  mov    ah, bl
  mov    al, 18h             { CRTC line compare reg. index  }
  out    dx, ax
  mov    ah, bh
  and    ah, 1
  shl    ah, 4
  mov    al, 07h             { CRTC overflow register index }
  out    dx, al
  inc    dx
  in     al, dx
  and    al, not 10h
  or     al, ah
  out    dx, al
  dec    dx
  mov    ah, bh
  and    ah, 2
  ror    ah, 3
  mov    al, 09h             { CRTC maximum scan line register index }
  out    dx, al
  inc    dx
  in     al, dx
  and    al, not 40h
  or     al, ah
  out    dx, al
  sti
end;

{ Puts a pixel on the screen in ModeX. x should be between 0 and 319. y 
  should be between 0 and 799. Whether or not the pixel is visible on the 
  screen is determined by what part of the VGA memory we are displaying, as 
  can be set by ScreenOffset and SplitScreen. }
procedure PutPixel(x, y: Word; Color: Byte); Assembler;
Asm
  mov    ax, y
  mov    bx, ax
  shl    bx, 4
  shl    ax, 6
  add    bx, ax              { bx = y*80 }
  mov    ax, x
  mov    cl, al
  and    cl, 03h
  shr    ax, 2
  add    bx, ax
  mov    ah, 1
  shl    ah, cl
  mov    dx, 3c4h            { Sequencer Register    }
  mov    al, 2               { Map Mask Index        }
  out    dx, ax

  mov    es, SEGA000
  mov    al, Color
  mov    es:[bx], al
end;

{ Simple 'n slow rectangle drawing routine. }
procedure Rect(x1, y1, x2, y2: Word; Color: Byte);
var
  i: Integer;
begin
  for i := x1 to x2 do
  begin
    PutPixel(i, y1, Color);
    PutPixel(i, y2, Color);
  end;
  for i := y1 to y2 do
  begin
    PutPixel(x1, i, Color);
    PutPixel(x2, i, Color);
  end;
end;

{ Puts a character on the screen using the VGA ROM font. }
procedure PutChar(x, y: Word; Color: Byte; ch: Char);
var
  i, j: Byte;
  pre: Word;
begin
  pre := $FA6E + (Ord(ch) shl 3);
  for i := 0 to 7 do
    for j := 0 to 7 do
      if (((Mem[$F000:pre+i] shl j) and 128) <> 0) then
        PutPixel(x+j, y+i, Color);
end;

{ Puts a string on the screen using the VGA ROM font. }
procedure PutString(x, y: Word; Color: Byte; Str: String);
var
  i: Byte;
begin
  for i := 1 to length(Str) do
    PutChar(x + ((i-1) shl 3), y, Color, Str[i]);
end;


begin
  { Initialize display and palette. }
  SetModeX;
  SetPal(Palette);

  { Set virtual screen to start at line 64 and put simple background
    pattern on screen. }
  ScreenOffset(0, 64);
  for x := 0 to MaxX do
    for y := 0 to MaxY do
    begin
      i := x xor y;
      if (i = 0) then i := 1;    { Using colour 0 (black) looks ugly... }
      PutPixel(x, y+64, i);
    end;

  { We're gonna use lines 0-63 in VGA memory for our split screen.
    Let's write a background pattern and some text to that region. }
  for i := 0 to 31 do
    Rect(i, i, MaxX-i, 63-i, i shl 2);
  PutString(24, 23, 255, 'Split Screen in 320x240x256 ModeX!');
  PutString(52, 35, 255, 'Press any key to continue...');

  { Now scroll the split screen on the display.... }
  for y := 0 to 63 do
  begin
    SetSplitScreen(MaxY-y);
    WaitVRetrace;
  end;

  Repeat Until KeyPressed;

  { And scroll the split screen off the display... }
  for y := 63 downto 0 do
  begin
    SetSplitScreen(MaxY-y);
    WaitVRetrace;
  end;

  { Finito: back to Text mode! }
  SetTextMode;
end.

