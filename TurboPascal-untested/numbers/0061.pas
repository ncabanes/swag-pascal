  From: Ryan Thompson                                Read: Yes    Replied: No

{ I have an Integer to hex in pascal with ASM: }

Function HexOf(I : Longint) : String; Assembler;
  Asm
    jmp   @1                         { Skip table }
  @0:
    db    '0123456789ABCDEF'
  @1:
    cld                              { Clear direction flag }
    les   di,@Result                 { ES:DI = Function return data }
    mov   ax,$0008                   { Set String size }
    stosb                            { in the output, }
    mov   cx,4                       { Loop 4x for four bytes }
    mov   si,3
  @2:
    mov   al,byte [I+si]             { Load AL with next byte }
    dec   si
    push  si                         { SAVE index register! }
    mov   bl,al                      { Load DL... }
    mov   dl,bl                      { and BL, }
    and   bx,$00F0                   { prepare and ... }
    {$IFOPT G+}
    shr   bx,4
    {$ELSE}
    shr   bx,1                       { convert BL to high nybble only, }
    shr   bx,1
    shr   bx,1                       { 8088-compatible }
    shr   bx,1
    {$ENDIF}
    and   dx,$000F                   { and DL to low nybble only. }
    mov   si,bx                      { move high nybble into index, }
    mov   al,byte [cs:@0+si]         { read Character for that nybble, }
    stosb                            { Write high nybble }
    mov   si,dx                      { move low nybble into index, }
    mov   al,byte [cs:@0+si]         { read Character for that nybble, }
    stosb                            { Write low nybble }
    pop   si                         { RESTORE index register! }
    loop  @2                         { Dec CX; Loop if CX <> 0 }
  End;

{
  It's not wonderfully written code, but it does work.  Spits out an 8-digit
hex string from a longint.  You could either delete the unneeded parts of the
string or make a version that doesn't do all four bytes.
}
