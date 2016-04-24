(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0059.PAS
  Description: Fast Upper/Lower Case
  Author: LEE BARKER
  Date: 09-26-93  10:09
*)

(*
From: LEE BARKER
Subj: FAST Up/Low Case CORRECTION
*)

Uses CRT;

  function LoStr(const s:string):string; assembler;
  asm
    push ds
    lds  si,s
    les  di,@result
    lodsb            { load and store length of string }
    stosb
    xor  ch,ch
    mov  cl,al
    jcxz @empty      { FIX for null string }
  @LowerLoop:
    lodsb
    cmp  al,'A'
    jb   @cont
    cmp  al,'Z'
    ja   @cont
    add  al,' '
  @cont:
    stosb
    loop @LowerLoop
  @empty:
    pop  ds
  end;  { LoStr }

  function UpStr(const s:string):string; assembler;
  asm
    push ds
    lds  si,s
    les  di,@result
    lodsb            { load and store length of string }
    stosb
    xor  ch,ch
    mov  cl,al
    jcxz @empty      { FIX for null length string }
  @upperLoop:
    lodsb
    cmp  al,'a'
    jb   @cont
    cmp  al,'z'
    ja   @cont
    sub  al,' '
  @cont:
    stosb
    loop @UpperLoop
  @empty:
    pop  ds
  end;  { UpStr }

VAR S : String;

BEGIN
  ClrScr;
  WriteLn(LoStr('LEE BARKER'));
  WriteLn(UpStr('lee barker'));
  Readkey;
END.

