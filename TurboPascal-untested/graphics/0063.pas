{
>Try converting it to use pointers instead of accessing the array with
>indexes, and use a pointer to video memory for direct plots
>instead of using the putPixel routine. Also it's quicker to
>check against 0 for the background than to check against
>255.

> I found a copy of "The Visible Computer: 8088" in my bookshelves and
> tried rewriting my assembly routines.  Here's what I finally got:

> procedure MaskPut(x,y: word; p: pointer); assembler;
> var
> XX,YY: byte;
> asm
> LES SI,p
> MOV [XX],0
> MOV [YY],0
> MOV CX,256
> XOR DX,DX
> CLD
> @Loopit:SEGES LODSB
> MOV DL,AL
> PUSH ES
> PUSH SI
> CMP DL,255
> JZ @Done
> MOV AX,0A000h
> MOV ES,AX
> MOV AX,320
> MOV BX,[Y]
> ADD BL,[YY]
> PUSH DX
> MUL BX
> POP DX
> MOV BX,[X]
> ADD BL,[XX]
> ADD AX,BX
> MOV SI,AX
> MOV ES:[SI],DL
> @Done:  INC [XX]
> CMP [XX],16
> JNZ @Okay
> MOV [XX],0
> INC [YY]
> @Okay:  POP SI
> POP ES
> LOOP @Loopit
> end;

> It works fine.  I didn't notice much of a difference in speed though.
> I tested it and I can plot about 1103 sprites/second in ASM and 828
> sprites/sec. with my original TP code.  Please keep in mind I'm not
> much of an assembly programmer. Can anyone help me optimize this code
> (into 286 would be good too). Thanx for your help!

I'll try. I notice you're using memory variables for loop counters in that
code. Also seem to be reloading the segment registers each time through the
loop, and general sundry pushes, pops, and such which are unnecesary. I don't
have time to rewrite your code from scratch today but I'll post my transparent
bitmap routine for Mode 13 for you to use/learn from. K?

this is untested, I was fixing it up after I found it my optimization gets
better over time, and it's been a while since I've worked on this Mode 13h
stuff.
}

{$G+}

procedure drawSprite(x, y : integer; w, h : byte; sprite : pointer); assembler;
asm
 push ds
 lds si,[sprite]
 mov ax,$A000
 mov es,ax
 cld
 mov ax,[y]     {y * 320}
 shl ax,6
 mov di,ax
 shl ax,2
 add di,ax
 add ax,[x]     {+ x}
 mov bh,[h]
 mov cx,320     {dif between rows}
 sub cl,[w]
 sbb ch,0
@L:
 mov bl,[w]
@L2:
 lodsb
 or al,al       {test for 0. For 255 you'd use inc al here instead}
                {heck dx and ah are free, you could store the
                  comparison value in one of those}
 jnz @S
                {for 255 you'd also need a dec al here}
 mov [es:di],al
@S:
 inc di
 dec bl
 jnz @L2
 add di,cx
 dec bh
 jnz @L
 pop ds
 end;

{
And I'll bet you notice a difference in speed with this puppy. 8)

If you could guarantee that the width would be an even number you could
optimize it to use word moves, otherwise it wouldn't be worth it.
}
