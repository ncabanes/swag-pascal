(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0089.PAS
  Description: Min/Max Longs in ASM
  Author: PHIL NICKELL
  Date: 02-03-94  16:15
*)


UNIT MaxMinL;
(*
  The source code MaxMinL unit is released to the public domain.  No
  rights are reserved.  Phil Nickell.  NSoft Co.
  This Turbo Pascal unit implements five highly optimized assembly
  language functions that provide MAX() and MIN() for unsigned longword
  and signed longintegers, and also a function for an unsigned longword
  compare.  The word functions treat the passed values as unsigned
  values.  The integer functions treat the passed values as signed
  values.  Turbo pascal does not have a LONGWORD data type, but the
  MAXLW() and MINLW() functions treat the passed longint types as
  unsigned words.  Maxlw returns $ffffffff as greater than 0.  Minlw
  returns 0 as less than $ffffffff.
*)
{$r-,S-}
INTERFACE
   FUNCTION  MAXLW (a,b:longint) : Longint;       { max longword }
   FUNCTION  MINLW (a,b:Longint) : Longint;       { min longword }
   FUNCTION  MAXLI (a,b:longint) : Longint;       { max longint }
   function  MINLI (a,b:Longint) : Longint;       { min longint }
   function  LWGT  (a,b:Longint) : Boolean;       { long > unsigned }

IMPLEMENTATION
function maxlw(a,b:longint):longint; Assembler; {long word}
  Asm
        les     ax, a            { load longint to es:ax }
        mov     dx, es           { load longint to dx:ax }
        cmp     dx, word ptr b+2 { cmp high words }
        ja      @2               { high word > }
        jb      @1               { high word < }
        cmp     ax, word ptr b   { comp low word }
        jae     @2               { low word >= }
  @1:   les     ax, b
        mov     dx, es           { load int to dx:ax }
  @2:
  End;

function minlw(a,b:longint):longint;  Assembler; { longword }
  Asm
        les     ax, a            { load longint to es:ax }
        mov     dx, es           { load longint to dx:ax }
        cmp     dx, word ptr b+2 { cmp high words }
        jb      @2               { high word < }
        ja      @1               { high word > }
        cmp     ax, word ptr b   { comp low word }
        jbe     @2               { low word >= }
  @1:   les     ax, b
        mov     dx, es           { load int to dx:ax }
  @2:
  End;

function maxli(a,b:longint):longint; Assembler;
  Asm
        les     ax, a            { load longint to es:ax }
        mov     dx, es           { load longint to dx:ax }
        cmp     dx, word ptr b+2 { cmp high words }
        jg      @2               { high word > }
        jl      @1               { high word < }
        cmp     ax, word ptr b   { comp low word }
        jae     @2               { low word >= }
  @1:   les     ax, b
        mov     dx, es           { load int to dx:ax }
  @2:
  End;

function minli(a,b:longint):longint; Assembler;
  Asm
        les     ax, a            { load longint to es:ax }
        mov     dx, es           { load longint to dx:ax }
        cmp     dx, word ptr b+2 { cmp high words }
        jl      @2               { high word < }
        jg      @1               { high word > }
        cmp     ax, word ptr b   { comp low word }
        jbe     @2               { low word >= }
  @1:   les     ax, b
        mov     dx, es           { load int to dx:ax }
  @2:
  End;

function lwgt(a,b:longint):boolean;  Assembler; {unsigned longword greater than
}
  Asm
        xor     cx, cx           { cx = 0 = false }
        les     ax, a            { load longint to es:ax }
        mov     dx, es           { load longint to dx:ax }
        cmp     dx, word ptr b+2 { cmp high words }
        jb      @2               { high word < }
        ja      @1               { high word > }
        cmp     ax, word ptr b   { comp low word }
        jbe     @2               { low word <= }
  @1:   inc     cx               { cx = 1 = true }
  @2:   mov     ax, cx           { load result to ax }
  End;

BEGIN {INITIALIZATION}
END.

