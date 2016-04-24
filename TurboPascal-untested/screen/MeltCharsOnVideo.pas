(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0024.PAS
  Description: MELT Chars on Video
  Author: BERNIE PALLEK
  Date: 08-17-93  08:45
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 07-14-93 (10:28)             Number: 30550
From: BERNIE PALLEK                Refer#: NONE
  To: DENNIS HO                     Recvd: NO
Subj: NEATO VIDEO TRICKS             Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
DH>     Could anyone possibly tell me how I could make the
DH> characters on the screen change the the next letter until
DH> they are Z then they disappear?  Sort of a melting effect.
DH> I realize that this would probably have to be done in ASM
DH> but I would just like the source to incorperate into one of
DH> my programs.

Hi, Dennis.  Just a suggestion: it would probably look better if they
decremented down to a space character (and it would be easier to
program), but here's an example:
*)

PROGRAM MeltTheCharactersInVideoMemory;

{ untested, by Bernie Pallek, 1993 }
{ best used in 80x25 mode, or you may have problems :') }

{ I don't think the program needs a USES clause }

CONST
     vidSeg : Word = $B800;  { use $B000 for mono monitors }

VAR
   max : Byte;
   w1,
   w2  : Word;

BEGIN
     { the below part finds the max. number of iterations req'd by
       the melting loop }
     max := 0;
     FOR w1 := 0 TO 1999 DO IF (Mem[vidSeg : w1 * 2] > max) THEN
         max := Mem[vidSeg : w1 * 2];
     { I know, I know, bad indenting style :') }
     FOR w1 := 1 TO max DO { could be from *0* TO max }
         { by using w1 * 2, we skip the colour attributes }
         FOR w2 := 0 TO 1999 DO IF (Mem[vidSeg : w2 * 2] > 32) THEN
             Mem[vidSeg : w2 * 2] := Mem[vidSeg : w2 * 2] - 1;
END.

Oh, you want me to *explain* it.  I see.  Well, text video memory is set
up like this: 4000 bytes starting at $B800 (for colour, $B000 for mono).
The first byte ($B800 : 0) rep's the ASCII code of the char at 1, 1
(screen pos.), and the next byte ($B800 : 1) rep's the colour attribute
of the char at 1, 1.  Then comes the ASCII code for the next character,
and then the colour for it.  This keeps going, and when you reach memory
position $B800 : 160 (that 160 is decimal, not hex), it wraps to the
next line on your screen.  This goes on until you reach $B800 : 3999,
which is the lower-right char's colour attribute.
The beginning part just finds how many times the characters will have
to be updated before they are all space characters.
BTW, sorry for not making them turn to Zs; it was easier to do it with
spaces, and you may modify the program as you wish.

Have fun, TTYL.

Bernie.
___
 * SLMR 2.0 * ... I wouldn't be caught dead with a necrophiliac!

--- Maximus 2.01wb
 * Origin: * idiot savant * +1 416 935 6628 * (1:247/128)

