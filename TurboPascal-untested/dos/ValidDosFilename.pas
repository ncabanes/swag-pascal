(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0084.PAS
  Description: Valid DOS Filename
  Author: ANDREW EIGUS
  Date: 11-26-94  05:08
*)

{
> What are the valid characters for a filename in DOS?

Better to say which are invalid, or even more good to post a routine that
checks filename for bad characters, eh? :)
}

Function ValidFileName(FileName : string) : boolean; assembler;
const BadChars : PChar = ' /,;^+[]"=*?|<>';  { these are BAD onez }
Asm
  mov dl,True
  push ds
  lds si,FileName
  cld
  lodsb
  xor cx,cx
  mov cl,al
  jcxz @@4
@@1:
  lodsb
  push ds
  push cx
  mov cx,15
  lds di,BadChars
@@2:
  scasb
  jnz @@3 { if not bad char then exec loop }
  pop cx  { restore CX }
  pop ds  { restore DS }
  dec dl  { dl=False }
  jmp @@4
@@3:
  loop @@3
  pop cx  { restore CX }
  pop ds  { restore DS }
  loop @@1
@@4:
  pop ds
  mov al,dl { result 0/1 (False/True) in AL }
End; { ValidFileName }

