{
DVE>> What I want to do is to make it point to the next byte in memory,
DVE>> sort of "apointer:=[byte ptr] apointer + 1"
DVE>> Apointer:=ptr(seg(apointer^),Ofs(apointer^) + 1);

AGB> That won't work if the pointer is equal to 0FFFFh (Segment must be
AGB> adjusted!). A shorter (and faster?) method of coding this (wrong) way :
AGB> Inc(LongInt(APointer));

Oeps, this doesn't work either, especially in the case $ffff ! (unwanted
paragraph increase and in protected mode a RunTime Error 216 "General
protection fault")

For non segm. overrides this should work fine: Aptr:=pchar(Aptr)+1;
and if youre planning segments overrides than you should use this:
}

function GetDosPtr(Point:Pointer;Offs:Longint):pointer;
assembler;{offs in [$0..$fffff}
asm
        mov     dx,point.word[2]
        mov     cx,offs.word[2]
        mov     bx,offs.word[0]
        add     bx,point.word[0]
        adc     cx,0
        mov     ax,bx
        and     ax,0fh
        shr     cx,1;rcr bx,1
        shr     cx,1;rcr bx,1
        shr     cx,1;rcr bx,1
        shr     cx,1;rcr bx,1
        add     dx,bx
end;

{And for protected mode: }

function GetPtr(BASE:Pointer;Offs:Longint):Pbyte;
assembler;
asm
        MOV     AX,word ptr [OFFS+2]
        MOV     BX,word ptr [OFFS+0]
        ADD     BX,word ptr [BASE+0]
        ADC     AX,0
        MUL     SelectorInc
        ADD     AX,word ptr [BASE+2]
        MOV     DX,AX
        MOV     AX,BX
end;
