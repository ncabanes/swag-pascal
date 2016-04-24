(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0011.PAS
  Description: FAST Upper/Justify String
  Author: CHRIS PRIEDE
  Date: 05-28-93  13:58
*)

{
> For some routins you may have.. Stuff like converting a String to
> upperCase, padding a String, and things like that..  Mainly stuff to do
> With Strings, as that seems to be my problem..  if you could, please
> document your source so i can see how it is done.


1)The Good Old String UpCase Routine. I'm sure there are at least
  several thousand Programmers, who have independently come up With code
  exactly like this:
}

Procedure StrUpr(Var S: String); Assembler;
Asm
  push    ds              { Save DS on stack }
  lds     si, S           { Load DS:SI With Pointer to S }
  cld                     { Clear direction flag - String instr. Forward
  lodsb                   { Load first Byte of S (String length Byte) }
  sub     ah, ah          { Clear high Byte of AX }
  mov     cx, ax          { Move AX in CX }
  jcxz    @Done           { Length = 0, done }
  mov     ax, ds          { Set ES to the value in DS through AX }
  mov     es, ax          { (can't move between two segment Registers) }
  mov     di, si          { DI and SI now point to the first Char. }
@UpCase:
  lodsb                   { Load Character }
  cmp     al, 'a'
  jb      @notLower       { below 'a' -- store as is }
  cmp     al, 'z'
  ja      @notLower       { above 'z' -- store as is }
  sub     al, ('a' - 'A') { convert Character in AL to upper Case }
@notLower:
  stosb                   { Store upCased Character in String }
  loop    @UpCase         { Decrement CX, jump if not zero }
@Done:
  pop     ds              { Restore DS from stack }
end;

{
2)Right justify routine. if Length(S) < Width then S will be
  padded With spaces on the left.
}

Procedure RightJustify(Var S: String; Width: Byte); Assembler;
Asm
   push    ds              { Save DS }
   lds     si, S           { Load Pointer to String }
   mov     al, [si]        { Move length Byte  in AL }
   mov     ah, Width       { Move Width in AH }
   sub     ah, al          { Subtract }
   jbe     @Done           { if Length(S) >= Width then Done... }
   push    si              { Save SI on stack }
   mov     cl, al
   sub     ch, ch          { CX = length of the String }
   add     si, cx          { SI points to the last Character }
   mov     dx, ds
   mov     es, dx          { ES = DS }
   mov     di, si          { DI = SI }
   mov     dl, ah
   sub     dh, dh          { DX = number of spaces to padd }
   add     di, dx          { DI points to the new end of the String }
   std                     { String ops backward }
   rep     movsb           { Copy String to the new location }
   pop     si              { SI points to S }
   mov     di, si          { DI points to S }
   add     al, ah          { AL = new length Byte }
   cld                     { String ops Forward }
   stosb                   { Store new length Byte }
   mov     al, ' '
   mov     cx, dx          { CX = number of spaces }
   rep     stosb           { store spaces }
@Done:
   pop     ds              { Restore DS }
end;

{
        I wrote both examples specifically For posting in this
conference (my regular code is For external Assembler and nowhere Nearly
as well commented). Both Functions appear to work as advertised and
should be very fast.
}


