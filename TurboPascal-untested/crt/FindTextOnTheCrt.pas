(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0037.PAS
  Description: Find text on the CRT
  Author: MIKE PHILLIPS
  Date: 05-31-96  09:16
*)

function getchr (x,y : byte) : char; assembler;
asm
  mov ah, 3;
  xor bh, bh;
  int 10h;
  push dx;
  mov ah, 2;
  mov dl, x;
  mov dh, y;
  dec dl;    {Coordinates are 1 based in TP -- 0 based in asm}
  dec dh;
  int 10h
  mov ah, 8;
  int 10h;
  mov ah, 2;
  pop dx;
  int 10h;
end;

This gets a character from the screen without ultimately affecting
cursor positon (it is saved and restored).  It can also be used as:
getchr (wherex, wherey);
to get the character at the current cursor location.

Mike Phillips
INTERNET:  phil4086@utdallas.edu

