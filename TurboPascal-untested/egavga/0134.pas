{
> 640/480/16 mode... Yes I know how to put a pixel with the
> What I want is Line, Bitmap procedure...

The first is mine, the second a bit.
}

procedure FillBox(X1,Y1,X2,Y2:word; Color:byte); assembler;
{ Fill (X1,Y1)-(X2,Y1) with Color, VGA only, 640 lines, 16 color mode, PD }
asm
 cld
 mov dx,3ceh
 mov ah,Color
 mov al,0
 out dx,ax
 mov ax,0305h
 out dx,ax
 mov ax,0a000h
 mov es,ax
 mov ax,Y1
 mov si,Y2
 sub si,ax
 jz @NoLines
 {$ifopt G+}shl ax,6{$else}mov cl,6;shl ax,cl{$endif}
 mov di,ax
 {$ifopt G+}shr ax,2{$else}shr ax,1; shr ax,1{$endif}
 add di,ax
 mov ax,X1
 mov cl,al
 {$ifdef G+}shr ax,3{$else}shr ax,1; shr ax,1; shr ax,1{$endif}
 mov bx,X2
 mov ch,bl
 {$ifdef G+}shr bx,3{$else}shr bx,1; shr bx,1; shr bx,1{$endif}
 sub bx,ax
 push bp
 mov bp,bx
 add di,ax
 and cx,707h
 mov bx,0ffffh
 shr bl,cl
 mov cl,ch
 xor cl,7
 inc cx
 shl bh,cl
 or bp,bp
 jnz @NoDub
 and bl,bh
 jz @NoLines2
@NoDub:
 mov al,8
@PutLines:
 cli
 mov al,es:[di]
 mov es:[di],bl
 sti
 inc di
 mov cx,bp
 dec cx
 js @NoPBL
 jz @NoPB
 mov al,0ffh
 rep stosb
@NoPB:
 cli
 mov al,es:[di]
 mov es:[di],bh
 sti
 inc di
@NoPBL:
 sub di,bp
 add di,80-1
 dec si
 jnz @PutLines
@NoLines2:
 pop bp
@NoLines:
 mov ax,0005h
 out dx,ax
end;

procedure PixelAddrHGC; assembler;
asm
 mov cl,bl
 {$ifopt G+}shr bx,3{$else}shr bx,1;shr bx,1;shr bx,1{$endif}
 {$ifopt G+}shl ax,6{$else}mov ch,cl; mov cl,6; shl ax,cl; mov cl,ch;{$endif}
 add bx,ax
 {$ifopt G+}shr ax,2{$else}shr ax,1; shr ax,1;{$endif}
 add bx,ax
 mov ax,0a000h
 mov es,ax
 and cl,7
 xor cl,7
 mov ah,1
end;

procedure Line(X1,Y1,X2,Y2:word; Color:byte); assembler;
{ Draw a line from (X1,Y1)-(X2,Y2) in Color, VGA only, 640 lines, 16 colors }
{ Originally from a HGC line routine in a book, converted to VGA by me }
const
 ByteOffsetShift=3;
var
 Incr1,Incr2:word;
 Routine:word;
asm
        cld
        mov si,80
        mov dx,3ceh
        mov ah,Color
        xor al,al
        out dx,ax
        mov ax,0305h
        out dx,ax
        mov cx,X2
        sub cx,X1
        jz @VertLineHGC    { Jump if X1=X2, VertLine }
        jns @Li01          { Jump if X2>X1, no swap }
        neg cx
        mov bx,X2
        xchg bx,X1
        mov X2,bx
        mov bx,Y2
        xchg bx,Y1
        mov Y2,bx
@Li01:  mov bx,Y2
        sub bx,Y1
        jnz @Li02          { Jump if Y1<>Y2, no HorizLine }
        jmp @HorizLineHGC
@Li02:  jns @Li03          { Jump if Y2 > Y1, no swap }
        neg bx
        neg si
@Li03:  mov routine,offset @LoSlopeLineHGC
        cmp bx,cx
        jle @Li04
        mov routine,offset @HiSlopeLineHGC
        xchg bx,cx
@Li04:  shl bx,1
        mov incr1,bx
        sub bx,cx
        mov di,bx
        sub bx,cx
        mov incr2,bx
        push cx
        mov ax,Y1
        mov bx,X1
        call PixelAddrHGC
        mov al,1
        shl ax,cl
        mov dx,ax
        not dh
        pop cx
        inc cx
        jmp routine          { Var containing LoSlope/HiSlope }

@VertLineHGC: mov ax,Y1
        mov bx,Y2
        mov cx,bx
        sub cx,ax
        jge @Li31
        neg cx
        mov ax,bx
@Li31:  inc cx
        mov bx,X1
        push cx
        call PixelAddrHGC
        mov al,1
        shl ax,cl
        not ah
        pop cx
@Li32:  mov ah,es:[bx]
        mov es:[bx],al
        add bx,si
        loop @Li32
        jmp @Liexit

@HorizLineHGC:
        mov ax,Y1
        mov bx,X1
        call PixelAddrHGC
        mov di,bx
        mov dh,ah
        not dh
        mov dl,0ffh
        shl dh,cl
        not dh
        mov cx,X2
        and cl,7
        xor cl,7
        shl dl,cl
        mov ax,X2
        mov bx,X1
        mov cl,ByteOffsetShift
        shr ax,cl
        shr bx,cl
        mov cx,ax
        sub cx,bx
        mov ax,0ffffh
        or dh,dh
        js @Li43
        or cx,cx
        jnz @Li42
        and dl,dh
        jmp @Li44
@Li42:  mov ah,al
        and ah,dh
        mov bl,es:[di]
        mov es:[di],ah
        inc di
        dec cx
@Li43:  or cx,cx
        jz @Li44
@InLoop: mov bl,es:[di]
        stosb
        loop @InLoop
      {  if mode = NO_OP replace 'or cx,cx'-'loop @InLoop:' with 'rep stosb'}
@Li44:  and al,dl
        mov dl,es:[di]
        mov es:[di],al
        jmp @Liexit

@LoSlopeLineHGC:
@Li10:  mov ah,es:[bx]
        xor ah,ah
@Li11:  or ah,dl
        ror dl,1
        ror dh,1
        jnc @Li14
        or di,di
        jns @Li12
        add di,incr1
        loop @Li11
        mov es:[bx],ah
        jmp @Liexit
@Li12:  add di,incr2
        mov es:[bx],ah
        add bx,si
        loop @Li10
        jmp @Liexit
@Li14:  mov es:[bx],ah
        inc bx
        or di,di
        jns @Li15
        add di,incr1
        loop @Li10
        jmp @Liexit
@Li15:  add di,incr2
        add bx,si
        loop @Li10
        jmp @Liexit

@HiSlopeLineHGC:
@Li21:  mov al,es:[bx]
        mov es:[bx],dl
        add bx,si
        or di,di
        jns @Li23
        add di,incr1
        loop @Li21
        jmp @Liexit
@Li23:  add di,incr2
        ror dl,1
        ror dh,1
        cmc
        adc bx,0
        loop @Li21
@Liexit:
 mov dx,3ceh
 mov ax,5
 out dx,ax
end;
