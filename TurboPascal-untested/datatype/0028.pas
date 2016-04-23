
{set of char = array [1..32] of byte where each bit=1 if char is in set}

function aepos(const str:string; chs:charset; xst:byte):byte; assembler;
asm
        push ds
        lds si,str
        les di,chs
@1:
        mov bl,xst {xst is a copy of byte value , we can use it as i}
        xor bh,bh
        mov al,[si+bx] {str[i]}
        mov ah,1
        mov dx,32
        call @BitMask {Input: al=char; Output: al=char mask, bx=chs offset}
        test al,es:[di+bx] {str[i] in chs ?}
        jnz @2 {yes}
        mov al,xst {i}
        cmp al,[si] {i>length(str) ?}
        ja @2 {yes}
        inc xst {i}
        jmp @1
@2:
        mov al,xst
        pop ds
        jmp @exit

@BitMask:  {used ZBitMask from BP7 RTL ("seth.asm")}
        mov ch,al
        mov cl,3
        shr ch,cl
        sub ch,dh
        jc @3
        cmp ch,dl
        jae @3
        mov bl,ch
        xor bh,bh
        and al,7
        mov cl,al
        mov al,ah
        rol al,cl
        retn  {!}
@3:
        cwd
        xchg dx,ax
        xor bx,bx
        retn  {!}
@exit:
end;
