(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0110.PAS
  Description: MS-DOS Contry-Specific Upper Case
  Author: HORST KRAEMER
  Date: 05-26-95  23:21
*)

{
> I did, as I said "I couldn't get anything to work". No functions that
> I called returned the expected results, or maybe I wasn't doing something
> correctly, in any case it would be easier if someone was to post
> information on how I do something like this:

There is an easy way to convert strings using the national conversion tables
using DOS function $6521 (4.0 up). I'm using these two implementations:

  MS-DOS function $6521
  Version 4.0 up
  Converts string at address DS:DX
  of length CX
}

procedure cap(var s:string);
{ converts string S to uppercase
  procedure version
}
assembler;
asm
  push ds
  lds  si,s
  mov  cl,[si]
  xor  ch,ch
  jcxz @Exit
  lea  dx,[si+1]
  mov  ax,$6521
  int  21h
@Exit:
  pop ds
end;

function fcap(s:string):string;
(* TP 7.0
function fcap(const s:string):string;
*)
{ converts string S to uppercase
  function version
}
assembler;
asm
  push ds
  lds  si,s
  cld
  lodsb
  mov  cl,al
  xor  ch,ch
  jcxz @Exit
  les  di,@Result
  stosb
  mov  dx,di
  push cx
  rep  movsb
  push es
  pop  ds
  pop  cx
  mov  ax,$6521
  int  21h
@Exit:
  pop ds
end;

