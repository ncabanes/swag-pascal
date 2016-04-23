
{ Do you think this function would work faster than the Pascal CLRSCR? }

PROGRAM CLEAR;

Uses CRT;

VAR
   Attrib : Byte;

BEGIN
   TextBackground(1);          { I fill the screen with blue to see }
   CLRSCR;                     { the asm code work.. :)             }
   Attrib := 15 + 0 * 16;
   asm
     mov ah, 09h
     mov al, 32
     mov bh, 00h
     mov bl, byte ptr Attrib
     mov cx, 2000
     Int 10h
   end;
END.
