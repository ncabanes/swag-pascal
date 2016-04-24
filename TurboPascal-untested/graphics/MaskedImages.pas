(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0054.PAS
  Description: Masked Images
  Author: TIM JENSEN
  Date: 01-27-94  12:13
*)

{
>Try converting it to use pointers instead of accessing the array with
>indexes, and use a pointer to video memory for direct plots
>instead of using the putPixel routine. Also it's quicker to
>check against 0 for the background than to check against 255.

I found a copy of "The Visible Computer: 8088" in my bookshelves and
tried rewriting my assembly routines.  Here's what I finally got:
}

procedure MaskPut(x,y: word; p: pointer); assembler;
var
 XX,YY: byte;
asm
        LES SI,p
        MOV [XX],0
        MOV [YY],0
        MOV CX,256
        XOR DX,DX
        CLD
@Loopit:SEGES LODSB
        MOV DL,AL
        PUSH ES
        PUSH SI
        CMP DL,255
        JZ @Done
        MOV AX,0A000h
        MOV ES,AX
        MOV AX,320
        MOV BX,[Y]
        ADD BL,[YY]
        PUSH DX
        MUL BX
        POP DX
        MOV BX,[X]
        ADD BL,[XX]
        ADD AX,BX
        MOV SI,AX
        MOV ES:[SI],DL
@Done:  INC [XX]
        CMP [XX],16
        JNZ @Okay
        MOV [XX],0
        INC [YY]
@Okay:  POP SI
        POP ES
        LOOP @Loopit
end;

{
It works fine.  I didn't notice much of a difference in speed though.  I
tested it and I can plot about 1103 sprites/second in ASM and 828
sprites/sec. with my original TP code.  Please keep in mind I'm not much
of an assembly programmer. Can anyone help me optimize this code (into
286 would be good too). Thanx for your help!
}

