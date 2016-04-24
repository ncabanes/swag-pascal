(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0142.PAS
  Description: General Useful Routines
  Author: WILLIAM BARATH
  Date: 05-26-95  23:07
*)

Unit Goodies; {Collection of things I wish were in the System Unit}

Interface
Type Fixed= Record F:Word;W:Integer;end;

Var r,r2,r3:Word;

Function Greater(a,b:Integer):Integer;
Function Lesser(a,b:Integer):Integer;
Function Perturb:Word;  {Peturbation algorhythm (C) 1982 BarathSoft}
Function QRandWord:word;
Function QRand(n:Word):word;
Function SQRoot(N:LongInt):Word;
Function SGN(n:Integer):Integer;

Implementation

Function Greater(a,b:Integer):Integer;assembler;
asm
  Mov  ax,a
  Mov  bx,b
  Cmp  ax,bx
  Jnc  @done
  Xchg ax,bx
@Done:
end;
Function Lesser(a,b:Integer):Integer;assembler;
asm
  Mov  ax,a
  Mov  bx,b
  Cmp  ax,bx
  Jc   @done
  Xchg ax,bx
@Done:
end;

Function Perturb:Word;assembler;  {Peturbation algorhythm (C) 1982 
BarathSoft}
{Delta 2904 yields 65534 length pseudorandom sequence}
asm Mov ax,r; Xor ax,$a5a5; add ax,ax; adc ax,2904; Mov r,ax; end;
Function QRandWord:word;assembler;
asm Call Perturb; Add ax,r2;Mov r2,ax;Xor ax,r3;Mov r3,ax;end;
Function QRand(n:Word):word;assembler;
asm Call QRandWord; Mul n; Mov ax,dx; end;
Function SQRoot(N:LongInt):Word;Assembler;
asm
  Mov si,-1
  Mov cx,n+2.word
  Test ch,$80
  JNZ @Error
  Mov bx,n.word
  Mov di,32768
  Xor si,si
@DoSqrt:
  Mov ax,si
  Or  ax,di
  Mul ax
  Cmp dx,cx
  Ja  @NoSet
  Jnz @Set
  Cmp ax,bx
  Ja  @Noset
@Set:
  Or  si,di
@Noset:
  Shr di,1
  Jnz @DoSqrt
@Error:
  Mov ax,si
end;
Function SGN(n:Integer):Integer;assembler;
asm
  Xor ax,ax
  Cmp n,ax
  Js  @neg
  Inc ax
  Jmp @end
@neg:
  Dec ax
@end:
end;
end.

