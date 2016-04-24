(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0111.PAS
  Description: Set Border (BASM)
  Author: BAS VAN GAALEN
  Date: 08-24-94  13:26
*)

{ EM> Does anyone happen to know how to change the border color?}

const border:boolean=true;
procedure setborder(col:byte); assembler;
asm
  xor ch,ch
  mov cl,border
  jcxz @out
  mov dx,3dah
  in al,dx
  mov dx,3c0h
  mov al,11h+32
  out dx,al
  mov al,col
  out dx,al
 @out:
end;

BEGIN
SetBorder(1);  { make it blue }
Readln;
SetBorder(0);  { back to black }
END.
