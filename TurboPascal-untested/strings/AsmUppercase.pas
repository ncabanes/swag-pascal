(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0061.PAS
  Description: ASM Uppercase
  Author: ERIK HJELME
  Date: 10-28-93  11:40
*)

{===========================================================================
Date: 10-02-93 (16:28)
From: ERIK HJELME
Subj: Upcase/Locase string or Char
---------------------------------------------------------------------------

BF> Does anybody know if DOS' multi-country support will
BF> spit out a character uppercase/lowercase conversion table ?

Yes, function $6502 will let you see the conversion tables.

You can also use two conversion interrupts in your own programmes, the
function isn't supported by older versions of DOS, but I don't know wich : }

function upcase(c:char):char; { will replace TP's built-in upcase }
asm mov dl,c
 mov ax,$6520
 int $21
 mov al,dl           { function result in AL                 }
 end;

procedure upstr(var s);  { this will convert any TP string       }
asm push ds
 lds dx,s            { address of the s[0] character         }

 mov bx,dx
 mov ch,0
 mov cl,[bx]         { length of string in CX                }

 inc dx              { characters to convert in DS:DX        }
 mov ax,$6521
 int $21
 pop ds
 end;

