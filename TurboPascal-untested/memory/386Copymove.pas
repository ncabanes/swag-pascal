(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0062.PAS
  Description: 386 copy/move
  Author: ROBERT ROTHENBUR
  Date: 08-24-94  17:56
*)

{
I wrote some substitutes for Move and Copy in Turbo Pascal 7.0 that use
386-instructions (sort of).  Some initial tests showed 30-40% improve-
ment in speed.

I am posting these here for the public domain, and hance I make no
guarantees for how well they work.  If you find bugs or make any
optimizations, drop me a line...
}

(* XFUNC.PAS v0.01 by Robert Rothenburg Walking-Owl, June 1, 1994 *)
(* 32-bit "X-Functions" for Turbo Pascal 7.0                      *)

{$DEFINE USE386}

{ if you $UNDEF USE386, normal 8086 instructions will be used; this
  way the only change that needs to be made if you want to write '86
  and '386 versions is to recompile this unit with the appropriate
  define... }

unit XFunc;

interface

procedure XMove(var source, dest; size: word);
function XCopy(source: string; soffs, size: byte): string;

implementation

          { Works the same as Move(source,dest,size); }

procedure XMove(var source, dest; size: word); assembler;
asm
        push    ds
        push    es
        lds     si, source
        les     di, dest
        mov     cx, size
        cld
        shr     cx, 1
        jnc     @word1
        movsb
@word1:
{$IFDEF USE386}
        shr     cx, 1
        jnc     @word2
        movsw
@word2: db      0f3h, 066h, 0a5h  { rep movsd }
{$ELSE}
        rep     movsw
{$ENDIF}
        pop     es
        pop     ds
end;

     { works the same as Copy(str, index, len); }


function XCopy(source: string; soffs, size: byte): string; assembler;
asm
        push    ds
        push    es
        lds     si, source
        les     di, @result
        xor     ax, ax
        mov     bx, ax
        mov     cx, ax
        mov     bl, soffs
        mov     cl, size
        cld
        stosb
        lodsb
        cmp     ax, bx
        jb      @done
        add     si, bx
        dec     si
        sub     ax, bx
        cmp     ax, cx
        jnb     @docop
        xchg    ax, cx
        inc     cx
@docop: push    cx
        shr     cx, 1
        jnc     @word1
        movsb
@word1:
{$IFDEF USE386}
        shr     cx, 1
        jnc     @word2
        movsw
@word2: db      0f3h, 066h, 0a5h  { rep movsd }
{$ELSE}
        rep     movsw
{$ENDIF}
        pop     ax
        les     di, @result
        stosb
@done:
        pop     es
        pop     ds
end;

end.


