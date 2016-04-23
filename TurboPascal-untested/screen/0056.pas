{
> I have always addressed $B800 as the screen segment for
> direct video writes in text.... Err, umm, does anyone have
> the code to detect whether it is $B000 or $B800 (for
> Herc.'s and the like)...

I know you didn't ask for this, but...

If you're on a EGA or better, this code should FORCE the screen segment to be
at whereever you want even if it's a mono mode!

BEGIN QUOTE OF CONVERSATION WITH 'NEON PROPHET' WHOEVER THAT IS

>>Not sure what you mean here. Do you mean to use A000:0 for
>>both text & graphics if you know it's an e/vga card?
>
>Yes, I mean I want to write to a text screen by accessing memory at
>$A000:0 on an EGA+

that's easy..

Send a 6 to port 3CEh
then in / out with port 3CFh  (you gotta do this latching). Bitmaped :
        bit  0        Graphics mode = 1
                      Textmode      = 0
        bit  1        Chain Odd Maps To Even Maps  (who knows.. :(  )
        bits 2 - 3    memory map / size
                      00   A000    128k  <-dangerous
                      01   A000    64K   <-ok
                      10   B000    32k
                      11   B800    32k
        bits 4 - 7    Unused

a quick note being that I haven't tested using A000 for text.  But I suppose
using   mov ax, 3 / int 10h and then switching this register would work. Never
set the first one if you are using QEMM.  You *WILL* lock up the machine
because it uses some of that space for memory addressing.

Example code :
        mov        dx, 3CEH
        mov        al, 06h
        out        dx, al
        inc        dx
        in         al, dx
        and        al, 00001100b
        shr        al, 1
        shr        al, 1
now, the current state of memory should be in AL.

Hope this helps.

END QUOTE

and so do I. Haven't had a chance to try it yet.

But this should set up B800 even on a mono system (please let me know if it
works)
}
procedure initB800SegText;begin
 asm mov ax,3; int 10h; end;
 port[$3CE]:=2 or (3 shl 2);
 if port[$3CF]=0 then;   {read to latch}
 end;

procedure initA000SegText;begin
 asm mov ax,3; int 10h; end;
 port[$3CE]:=2 or (1 shl 2);
 if port[$3CF]=0 then;   {read to latch}
 end;

{ this should report the current segment being used. }

function segAddr:word;
const table:array[0..3]of word=($A000,$A000,$B000,$B800); begin
 segAddr:=table[(port[$3CF]shr 2)and 3];
 end;

{
I don't believe any of these will work on a MDA or CGA, especially not the one
for A000. I don't think they have that register...
}
