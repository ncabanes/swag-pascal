(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0025.PAS
  Description: Handling Numbers in ASM
  Author: SEAN PALMER
  Date: 08-27-93  20:03
*)

{ SEAN PALMER

I've been playing around with the AAM instruction and came up with some
things you guys might find useful...

Strings as function results are WIERD with the inline Assembler. 8)
}

function div10(b : byte) : byte; assembler;
asm
  mov al, b
  aam
  mov al, ah
end;

function mod10(b : byte) : byte; assembler;
asm
  mov al, b
  aam
end;

type
  str2 = string[2];
  str8 = string[8];

function toStr2(b : byte) : str2; assembler;
asm {only call with b=0~99}
  les  di, @RESULT
  cld
  mov  al, 2
  stosb
  mov  al, b
  aam
  xchg ah, al
  add  ax, $3030
  stosw
end;

{makes date string in MM/DD/YY format from m,d,y}
function toDateStr(m,d,y:byte):str8;assembler;asm {only call with m,d,y=0~99}
  les  di, @RESULT
  cld
  mov  al, 8
  stosb
  mov  al, m
  aam
  xchg ah, al
  add  ax, $3030
  stosw
  mov  al, '/'
  stosb
  mov  al, d
  aam
  xchg ah, al
  add  ax, $3030
  stosw
  mov  al, '/'
  stosb
  mov  al, y
  aam
  xchg ah, al
  add  ax, $3030
  stosw
end;



