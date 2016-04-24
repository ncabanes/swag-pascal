(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0027.PAS
  Description: Dealing with SETS in basm
  Author: ARNE DE BRUIJN
  Date: 02-28-95  09:59
*)

{
A set is just an array of bits, each possible element in the set has a bit in
the array. If the element is in the set, the bit is set, otherwise clear.
If you know that (and asm :), you know how to access a set in BASM.

 BvG> How would the following routine look in assembler?

}

type charset=set of char;

function epos(str:string; ch:charset; xst:byte):byte;
var i:byte;
begin
  i:=xst;
  while (not (str[i] in ch)) and (i<=length(str)) do inc(i);
  epos:=i;
end;

function eposasm(str:string; ch:charset; xst:byte):byte; assembler;
{ Same result as pascal version, except for xst=0: }
{ this one returns 0, pascal version returns same as xst=1, }
{ or 0 if chr(length(Str)) exists in ch }
asm
 cld
 push ds
 lds si,Str
 lodsb
 xor ah,ah
 mov bx,ax
 mov al,xst
 dec ax            { assumes xst>0 }
 add si,ax
 sub bx,ax
 jle @NotFnd       { jump if xst > length(str) }
 les dx,&ch        { ch is a reserved word, so use the identifier operator }
@LoopStr:
 lodsb
 mov di,dx
 mov cl,al
 and cl,7
 shr ax,1
 shr ax,1
 shr ax,1
 mov di,ax
 add di,dx
 mov al,1
 shl al,cl
 test es:[di],al
 jnz @Fnd
 dec bx
 jnz @LoopStr
 jmp @NotFnd
@Fnd:
 dec si                { SI already incremented by lodsb, not wanted }
@NotFnd:
 mov ax,si
 sub ax,word ptr [Str] { The offset of Str }
 pop ds
end;

