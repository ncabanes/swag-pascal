(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0007.PAS
  Description: Text Fonts in ASM
  Author: SEAN PALMER
  Date: 11-26-93  18:05
*)

{
From: SEAN PALMER
Subj: Text Fonts in ASM
}

Procedure SetAsciiChar(Charnum : Word; Var Data); Assembler;
ASM
   mov ah,11h
   mov al,10h
   mov bh,10h
   mov bl,0
   mov cx,1      {set 1 character only}
   mov dx,charnum     {what charnum to modify }
   mov bp,seg data   {seg of the char}
   mov es,bp
   mov bp,offset data  {ofs of the char}
   int 10h
End;

{
This has been reputed to work. Although I didn't write it (Salim Samhara
I think is who did) and if I did I would have changed it to load ax and
bx as one unit instead of ah and al, then bh and bl. With this though
you have to have the buffer in the data segment, not on the stack.

So here's how I would do it:
}

Procedure LoadFont (FileName : String);
Type
 FontType=Array [char] of Array [0..15] of Byte;
Var
 F    : File of FontType;
 Font : FontType;
Begin
 Assign (F, FileName);
 Reset (F);
 Read (F,Font);
 Close (F);
 Asm
  mov ax,$1100
  mov bx,$1000
  mov cx,$0100
  xor dx,dx
  mov es,seg Font
  mov bp,offset Font
  Int $10
  end;
 End;

