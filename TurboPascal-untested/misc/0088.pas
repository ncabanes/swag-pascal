
{$S-,R-}
UNIT MaxMinW;
(*
  The source code for the MaxMinW unit is released to the public domain.
  No rights are reserved.  Phil Nickell.  NSoft Co.
  This Turbo Pascal unit implements four highly optimized assembly
  language functions that provide MAX() and MIN() for unsigned words and
  signed integers
*)
INTERFACE
   function  MAXW  (a,b:word)    : Word;          { max word }
   function  MINW  (a,b:word)    : Word;          { min word }
   function  MAXI  (a,b:integer) : Integer;       { max integer }
   function  MINI  (a,b:integer) : Integer;       { min integer }

IMPLEMENTATION
function maxw(a,b:word):word; Assembler;
  Asm
        mov     ax, a       { first parm in ax }
        mov     dx, b       { second parm in dx }
        cmp     ax, dx      { compare parms }
        jae     @1          { return 1st parm }
        mov     ax, dx      { return 2nd parm }
  @1:
  End;

function minw(a,b:word):word; Assembler;
  Asm
        mov     ax, a       { first parm in ax }
        mov     dx, b       { second parm in dx }
        cmp     ax, dx      { compare parms }
        jbe     @1          { return 1st parm }
        mov     ax, dx      { return 2nd parm }
  @1:
  End;

function maxi(a,b:integer):integer; Assembler;
  Asm
        mov     ax, a       { first parm in ax }
        mov     dx, b       { second parm in dx }
        cmp     ax, dx      { compare parms }
        jge     @1          { return 1st parm }
        mov     ax, dx      { return 2nd parm }
  @1:
  End;

function mini(a,b:integer):integer; Assembler;
  Asm
        mov     ax, a       { first parm in ax }
        mov     dx, b       { second parm in dx }
        cmp     ax, dx      { compare parms }
        jle     @1          { return 1st parm }
        mov     ax, dx      { return 2nd parm }
  @1:
  End;

Begin {INITIALIZATION}
End.
