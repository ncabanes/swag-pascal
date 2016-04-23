{
┤ You mean there is a way to have just a PART of the screen scroll with
┤ registers?!?!?

All this routines is importet from Myown ASM-lib. And works fine i
Turbo Pascal. v7

Use this routine to "scroll" the screen :-))
My English is not good enough to explain Exactly that it does!
}

Procedure ScreenPos(Plass:word); assembler;
asm
    mov bx,plass
    mov dx,3d4h
    mov al,0ch
    mov ah,bh
    out dx,ax
    mov al,0dh
    mov ah,bl
    out dx,ax
end;


{
Thos routine will tell you there the "screen" should start Writing the
screen one more time...
It's just called a Split, screen Routine...:)
}

procedure Split_screen(Linje:word); assember;
label crt_ok, Vga_split;
asm
        mov     dx,3d4h
crt_ok:
        mov     al,18h
        out     dx,al
        inc     dx
 
        MOV     AX,linje                
        out     dx,al
        dec     dx
VGA_split:
        mov     al,7
        out     dx,al
        inc     dx
        in      al,dx
        mov     bl,AH
        and     bl,1
        mov     cl,4
        shl     bl,cl
        and     al,not 10h
        or      al,bl
        out     dx,al
        dec     dx
        mov     al,9
        out     dx,al
        inc     dx
        in      al,dx
        and     al,not 40h
        out     dx,al
end;


{ This routine will wait for the vertical Retrace! }

Procedure WaitBorder; assembler;
label wb1,wb2;
asm
        MOV DX,3dah
wb1:    in al,dx
        test al,8
        jnz wb1
wb2:    in al,dx
        test al,8
        jz wb2
end;

{
This was all!

Everytime you change some om the Split_Screens, and ScreenPos, Do wait
for the Vertical Retrace, if you don't want a flicking screen! :-)

And remember by using these registers in Text-modus, will show you
"two" pages, and might give you some errors.

The best place to use these routines is if you find a VGA, MODEX-
library!
But I will work half the way it should in standard VGA, 320x200. Mode.
But I know you will get it work :-))
}
