
{
        I have only been programming for about 1.5 decades, but in order
to change fonts you have to know if you are in text mode or graphics
mode. If you are in graphics mode then there is a procedure you call. If
you are in text mode, then you will need to download an font editor from
a bbs (most of them say they are for the EGA because that is when it got
easy to download fonts to the video card in text mode). First you will
need to know how high you font is, on a VGA with 25 lines it is usally
16. Then you load the font into a buffer and you call this procedure I
made for you. Have fun
}

procedure load_textfont(high:word;buf:pointer);
begin
        asm
                mov ax,3
                int $10
                mov ax,$1110
                les dx,dword ptr [buf]
                mov bx,word ptr [high]
                xchg bh,bl
                push bp
                mov bp,dx
                xor dx,dx
                mov cx,$100
                int $10
        end;
end;

procedure load_normaltext;
begin
        asm
                mov ax,3
                int $10
                mov ax,$1114
                mov bl,0
                int $10
        end;
end;
