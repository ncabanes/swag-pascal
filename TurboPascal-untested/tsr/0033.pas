(*

Date : Dec 27 '94, 13:49
From : Arne de.Bruijn                                        2:281/705.8
To   : Bert Kremer
Subj : Math Error

*)

{ No divide by zero, Arne de Bruijn, 1994, PD }
{ Works not for longints, they've a check inside the runtime lib, }
{ and not for floating point math }
uses Dos;
procedure NewInt0(Flags, CS, IP, AX, BX,
  CX, DX, SI, DI, DS, ES, BP: Word); interrupt; assembler;
const
 InsLen:array[0..3] of byte=(2,3,4,2);
asm
 les di,dword ptr [IP]  { Get address of instruction }
 xor ax,ax              { Test for 808x }
 push ax
 popf
 pushf
 pop ax
 and ax,0f000h
 cmp ax,0f000h
 je @Fixed              { Jump if it's a 808x, no update needed }
 mov bl,[es:di+1]       { Get address mode byte }
 and bx,0c7h
 cmp bl,6
 jne @NoImm
 add IP,4
 jmp @Fixed
@NoImm:
 mov cl,6
 shr bx,cl
 mov bl,byte ptr [InsLen+bx]
 add IP,bx
@Fixed:
 { Change result to 0 }
 mov &AX,0
 cmp byte ptr [es:di],0f7h  {Change DX only if word operand }
 jne @NoWord
 mov &DX,0
@NoWord:
end;


var
 W:word;
 L:longint;
 R:real;
begin
 { No need to save Int 0, already done in RTL }
 SetIntVec(0,@NewInt0);
 W:=0;
 WriteLn(1 div W);  { Displays 0 }
 L:=0;
 WriteLn(1 div L);  { Runtime error 200 .... }
 R:=0.0;
 WriteLn(1.0/R);    { Runtime error 200 .... }
end.
