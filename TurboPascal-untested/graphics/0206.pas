{
 ABA> No, it won't work, the procedure you have written, will hardly work on
 ABA> it's own in standard VGA, because you do not tell the routine, in which
 ABA> segment your screen memory is.

 No, i wasnt sure if it would work in SVGA mode! My friend said it should so
 i put it in just in case! Now that Putpixel Procedure was the wrong one
 anyway, so it wouldnt work because i left out a few things. Mainly because
 that was my first ASM Putpixel Procedure and i didnt try to hard on it.

 Here is my current Putpixel pixel procedure that is for Standard VGA mode!
 }
 Procedure Putpixel(x,y : integer; COL : byte);
 BEGIN
    ASM
        Push    es
        mov     ax, $a000
        mov     es, ax
        Xor     di, di
        mov     ax, [x]
        mov     bx, 320
        mul     bx
        add     ax, [y]
        mov     di, ax
        mov     ah, [col]
        mov     es:[di], ah
        pop     es
    end
end;
