{
 JS> I'm looking for some sort of function to return that:
 JS> SOMEFILE.TXT = SOM*.TX?

I've written that once. Sorry for the lack of comments.

--------------
{ Unit with universal wildcard search function, Arne de Bruijn, 1994, PD }
unit find4dos;

interface
function FindName(SearchStr,NameStr:string):boolean;
implementation
function FindName(SearchStr,NameStr:string):boolean; assembler;
{
 Compare SearchStr with NameStr, and allow wildcards in SearchStr.
 The following wildcards are allowed:
 *ABC*        matches everything which contains ABC
 [A-C]*       matches everything that starts with either A,B or C
 [ADEF-JW-Z]  matches A,D,E,F,G,H,I,J,W,V,X,Y or Z
 ABC?         matches ABC, ABC1, ABC2, ABCA, ABCB etc.
 ABC[?]       matches ABC1, ABC2, ABCA, ABCB etc. (but not ABC)
 ABC*         matches everything starting with ABC
 (for using with DOS filenames like DOS (and 4DOS), you must split the
  filename in the extention and the filename, and compare them seperately)
}

var
 LastW:word;
asm
 cld
 push ds
 lds si,SearchStr
 les di,NameStr
 xor ah,ah
 lodsb
 mov cx,ax
 mov al,es:[di]
 inc di
 mov bx,ax
 or cx,cx
 jnz @ChkChr
 or bx,bx
 jz @ChrAOk
 jmp @ChrNOk
 xor dh,dh
@ChkChr:
 lodsb
 cmp al,'*'
 jne @ChkQues
 dec cx
 jz @ChrAOk
 mov dh,1
 mov LastW,cx
 jmp @ChkChr
@ChkQues:
 cmp al,'?'
 jnz @NormChr
 inc di
 or bx,bx
 je @ChrOk
 dec bx
 jmp @ChrOk
@NormChr:
 or bx,bx
 je @ChrNOk
{From here to @No4DosChr is used for [0-9]/[?]/[!0-9] 4DOS wildcards...}
 cmp al,'['
 jne @No4DosChr
 cmp word ptr [si],']?'
 je @SkipRange
 mov ah,byte ptr es:[di]
 xor dl,dl
 cmp byte ptr [si],'!'
 jnz @ChkRange
 inc si
 dec cx
 jz @ChrNOk
 inc dx
@ChkRange:
 lodsb
 dec cx
 jz @ChrNOk
 cmp al,']'
 je @NChrNOk
 cmp ah,al
 je @NChrOk
 cmp byte ptr [si],'-'
 jne @ChkRange
 inc si
 dec cx
 jz @ChrNOk
 cmp ah,al
 jae @ChkR2
 inc si              {Throw a-Z < away}
 dec cx
 jz @ChrNOk
 jmp @ChkRange
@ChkR2:
 lodsb
 dec cx
 jz @ChrNOk
 cmp ah,al
 ja @ChkRange        {= jbe @NChrOk; jmp @ChkRange}
@NChrOk:
 or dl,dl
 jnz @ChrNOk
 inc dx
@NChrNOk:
 or dl,dl
 jz @ChrNOk
@NNChrOk:
 cmp al,']'
 je @NNNChrOk
@SkipRange:
 lodsb
 cmp al,']'
 loopne @SkipRange
 jne @ChrNOk
@NNNChrOk:
 dec bx
 inc di
 jmp @ChrOk
@No4DosChr:
 cmp es:[di],al
 jne @ChrNOk
 inc di
 dec bx
@ChrOk:
 xor dh,dh
 dec cx
 jnz @ChkChr        { Can't use loop, distance >128 bytes }
 or bx,bx
 jnz @ChrNOk
@ChrAOk:
 mov al,1
 jmp @EndR
@ChrNOk:
 or dh,dh
 jz @IChrNOk
 jcxz @IChrNOk
 or bx,bx
 jz @IChrNOk
 inc di
 dec bx
 jz @IChrNOk
 mov ax,[LastW]
 sub ax,cx
 add cx,ax
 sub si,ax
 dec si
 jmp @ChkChr
@IChrNOk:
 mov al,0
@EndR:
 pop ds
end;

end.
