(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0120.PAS
  Description: FAST Delete String Procedure
  Author: DAVOR DUNDOVIC
  Date: 11-24-95  08:26
*)

{
 I am offering you my DelStr procedure. It's written in assembler
 (BASM), behaves just like standard Delete procedure only a LOT
 faster. I hope you'll find it interesting (and good) enough to
 include it in STRINGS.SWG.
}

 procedure DelStr(var S : string; Const Index, Count : byte); assembler;
 asm
    push ds
    mov cl,Count
    or cl,cl
    jz @Exit
    lds ax,S
    les ax,S
    mov bx,ax
    push ax
    mov al,Index
    xor ah,ah
    xor ch,ch
    add ax,cx
    dec ax
    mov cl,byte ptr [bx]
    cmp ax,cx
    pop ax
    ja @Exit
    je @To_End
    mov cl,Index
    xor ch,ch
    add ax,cx
    mov di,ax
    mov cl,Count
    xor ch,ch
    add ax,cx
    mov si,ax
    mov cl,byte ptr [bx]
    sub cl,Count
    xor ch,ch
    or cx,cx
    jz @Empty
    cld
    rep movsb
    mov cl,byte ptr [bx]
    sub cl,Count
 @Empty:
    mov byte ptr [bx],cl
    jmp @Exit
 @To_End:
    mov cl,Index
    dec cl
    mov byte ptr [bx],cl
 @Exit:
    pop ds
 end;

