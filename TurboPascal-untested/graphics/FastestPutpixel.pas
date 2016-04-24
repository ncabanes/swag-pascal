(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0134.PAS
  Description: Fastest Putpixel?
  Author: KIMMO K K FREDRIKSSON
  Date: 08-25-94  09:07
*)

(*
From: kfredrik@cc.Helsinki.FI (Kimmo K K Fredriksson)

:  > This routine, from off the net somewhere, is a little faster
:  > than simply writing to MEM (it replaces the multiply by a
:  > shift).
: Wilbert van Leijen and I once wrote a similar thing like this as an InLine
: macro, which turned out to be the true fastest code (ok, never say...)

: Procedure PutPixel18(c: Byte; x,y: Integer);
: Inline(
:   $B8/$00/$A0/      {  mov   AX,$A000   }
:   $8E/$C0/          {  mov   ES,AX      }
:   $5B/              {  pop   BX         }
:   $88/$DC/          {  mov   AH,BL      }
:   $5F/              {  pop   DI         }
:   $01/$C7/          {  add   DI,AX      }
:  {$IFOPT G+}
:   $C1/$E8/$02/      {  shr   AX,2       }
:  {$ELSE}
:   $D1/$E8/          {  shr   AX,1       }
:   $D1/$E8/          {  shr   AX,1       }
:  {$ENDIF}
:   $01/$C7/          {  add   DI,AX      }
:   $58/              {  pop   AX         }
:   $AA);             {  stosb            }

: I'd be real interested in seeing a PutPixel (remember: one pixel only, not a
: line, that's another story) that is faster than this one...

This is fast indeed, but the last instruction should be replaced at
least in 486 and Pentium CPUs with instruction mov es:[di],al, which
is faster than stosb (and you may also want to re-arrange them).

Also, the shift and add sequence could be replaced by table look-up,
but that wouldn't be so elegant, only faster. So if you wanna stick
with arithmetic address calculation, you could use 32-bit instructions,
something like this:

 mov es,[SegA000]
 pop di
 pop bx
 pop ax
 shl di,6
 lea edi,[edi*4+edi]
 mov es:[edi+ebx],al
 
If I use 32-bit instructions, I usually zero data registers in the
initialization part of my program, so I can use those registers
in the situations like above without the need to every time zero
the high bits.

You may also use fs or gs register instead of es, because you may
always keep it pointing to video RAM, instead of loading it every
time you do PutPixel.

This may go beyond the topic, but what the heck: usually I try to
use the offset of the screen mem as the parameter of these kind of
procedures, because it removes the need of address calculation:
*)
PROCEDURE PutPixel( offset : Word; c : Byte );
  INLINE(
 pop ax
 pop di
 mov fs,[di],al
);
(*
It is still very easy to use the offset instead of the (x,y)
position, if you want the next x-pix, add one to offset, if
you want the next y-pix, add 320 to offset.

Sorry, but I was too lazy to calc the hex values :-(

And never say that you have the absolutely fastest code ;-)
*)

