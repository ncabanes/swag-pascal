(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0051.PAS
  Description: Ramdon Integer
  Author: ERIC LOWE
  Date: 08-24-94  13:53
*)


Function RandomInteger: Integer; Assembler;
asm
  mov ah,2ch
  int 21h     { Get a random seed from DOS's clock }
  imul 9821
  inc ax
  ror al,1
  rol ah,1    { Randomize the seed }
end;

