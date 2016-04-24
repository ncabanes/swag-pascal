(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0072.PAS
  Description: Asm access to Keyboard
  Author: IAN LIN
  Date: 02-03-94  16:08
*)

{
From: IAN LIN
Subj: keyboard buffer
---------------------------------------------------------------------------
 TH> How do you write TO the keyboard buffer.

These are all procedures. You could easily rewrite them to be functions or
write functions that call these and use them.

High byte is scan code, low byte is character.
}

Procedure putkey(key:word);
 assembler; {PUTKEY}
 asm; mov ah,5; mov cx,key; int 16h;
end;


{To find out what ones belong to each key (E is for enhanced; the other will
filter enhanced keys): }

Procedure egetkey(Var key:word);
Var tmp:word;
Begin
 asm; mov ah,10h; int 16h; mov tmp,ax; end;
 key:=tmp;
end;

Procedure getkey(Var key:word);
Var tmp:word;
Begin
 asm; xor ah,ah; int 16h; mov tmp,ax; end;
 key:=tmp;
end;

