(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0114.PAS
  Description: MODE-X Routines
  Author: GARTH KRUMINS
  Date: 08-24-94  13:46
*)

{
 JW> What is mode-x or ($13) or whatever in graphics.  I like to write
     Mode-x is just your 320x200x256 VGA graphics mode.

It's pretty similar to using pascal's graph unit, except you don't!  You have
to get all the procedures and functions set-up yourself.
}

PROCEDURE InitVGA; ASSEMBLER;  {Puts you in 320x200x256 VGA}
asm 
   mov  ax, 13h 
   int  10h 
end; 
 
PROCEDURE InitTEXT; ASSEMBLER; {Puts you back in 80x25 text mode} 
asm 
   mov  ax, 03h 
   int  10h 
end; 

PROCEDURE SetColor (ColorNo, Red, Green, Blue : byte); 
begin     {Changes the pallete data for a particular colour} 
     PORT[$3C8] := ColorNo; 
     PORT[$3C9] := Red; 
     PORT[$3C9] := Green; 
     PORT[$3C9] := Blue; 
end; 
 
PROCEDURE MovCursor (X,Y : byte);  {Moves the cursor to (X,Y)} 
begin 
  asm 
  MOV   ah, 02h 
  XOR   bx, bx 
  MOV   dh, Y 
  MOV   dl, X 
  INT   10h 
  end; 
end; 
 
FUNCTION ReadCursorX: byte; assembler;  {Get X position of cursor}
asm 
  MOV   ah, 03h 
  XOR   bx, bx 
  INT   10h 
  MOV   al, dl 
end; 
 
FUNCTION ReadCursorY: byte; assembler;  {Get Y position of cursor} 
asm 
  MOV   ah, 03h 
  XOR   bx, bx 
  INT   10h 
  MOV   al, dh 
end; 
 
PROCEDURE PutText (TextData : string; Color : byte);  {Write a string} 
var      {It's not the fastest way to do it, but it does the job} 
 z, ASCdata, CursorX, CursorY : byte; 
begin 
 CursorX := ReadCursorX;
 CursorY := ReadCursorY; 
 for z := 1 to Length(TextData) do 
 begin 
  ASCdata := Ord(TextData[z]); 
  asm 
  MOV   ah, 0Ah 
  MOV   al, ASCdata 
  XOR   bx, bx 
  MOV   bl, Color 
  MOV   cx, 1 
  INT   10h 
  end; 
  inc(CursorX); 
  if CursorX=40 then begin CursorX:=0; inc(CursorY); end; 
  MovCursor(CursorX,CursorY); 
 end; 
end; 
 
PROCEDURE PlotPixel(X, Y: Word; Color: Byte); ASSEMBLER; {Plots a pixel} 
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

