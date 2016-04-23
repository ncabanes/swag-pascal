unit x3dunit2;

{ mode-x 3D unit - xhlin-procedure by Sean Palmer }
{ Optimized by Luis Mezquita Raya                 }

{$g+}

interface

const vidseg:word=$a000;
      divd:word=128;
      dist:word=200;
      minx:word=0;
      maxx:word=319;
      border:boolean=false;

var   ctab:array[byte] of integer;
      stab:array[byte] of integer;
      address:word;
      triangles:boolean;

Procedure setborder(col:byte);
Procedure setpal(c,r,g,b:byte);
Procedure retrace;
Procedure setmodex;
Procedure setaddress(ad:word);
Procedure cls;
Procedure polygon(x1,y1,x2,y2,x3,y3,x4,y4:integer; c:byte);
Function  cosinus(i:byte):integer;
Function  sinus(i:byte):integer;

implementation

var   xpos:array[0..199,0..1] of integer;

Procedure setborder(col:byte); assembler;
asm
        xor ch,ch
        mov cl,border
        jcxz @out
        mov dx,3dah
        in al,dx
        mov dx,3c0h
        mov al,11h+32
        out dx,al
        mov al,col
        out dx,al
@out:
end;

Procedure setpal(c,r,g,b:byte); assembler;
asm
        mov dx,3c8h
        mov al,[c]
        out dx,al
        inc dx
        mov al,[r]
        out dx,al
        mov al,[g]
        out dx,al
        mov al,[b]
        out dx,al
end;

Procedure retrace; assembler;
asm
        mov dx,3dah;
@vert1: in al,dx
        test al,8
        jz @vert1
@vert2: in al,dx
        test al,8
        jnz @vert2
end;

Procedure setmodex; assembler;
asm
        mov ax,13h
        int 10h
        mov dx,3c4h
        mov ax,0604h
        out dx,ax
        mov ax,0f02h
        out dx,ax
        mov cx,320*200
        mov es,vidseg
        xor ax,ax
        mov di,ax
        rep stosw
        mov dx,3d4h
        mov ax,0014h
        out dx,ax
        mov ax,0e317h
        out dx,ax
end;

Procedure setaddress(ad:word); assembler;
asm
        mov dx,3d4h
        mov al,0ch
        mov ah,[byte(ad)+1]
        out dx,ax
        mov al,0dh
        mov ah,[byte(ad)]
        out dx,ax
end;

Procedure cls; assembler;
asm
        mov es,vidseg
        mov di,address
        mov cx,8000
        mov dx,3c4h
        mov ax,0f02h
        out dx,ax
        xor ax,ax
        rep stosw
end;

{$f-}

Procedure polygon(x1,y1,x2,y2,x3,y3,x4,y4:integer; c:byte); assembler;
var mny,mxy,y,m,mult,divi,top,s,
    stb,px1,py1,px2,py2:integer;
    dir:byte;
asm                                     { Procedure Polygon }
        mov ax,y1                       { Determine lowest & highest points }
        mov cx,ax
        mov bx,y2

        cmp ax,bx                       { if mny>y2 ==> mny:=y2 }
        jl @p2
        mov ax,bx

@p2:    cmp cx,bx                       { if mxy<y2 ==> mxy:=y2 }
        jg @p3
        mov cx,bx

@p3:    mov bx,y3
        cmp ax,bx                       { if mny>y3 ==> mny:=y3 }
        jl @p3M
        mov ax,bx

@p3M:   cmp cx,bx                       { if mxy<y3 ==> mxy:=y3 }
        jg @p4
        mov cx,bx

@p4:    mov bx,y4
        cmp ax,bx                       { if mny>y4 ==> mny:=y4 }
        jl @p4M
        mov ax,bx

@p4M:   cmp cx,bx                       { if mxy<y4 ==> mxy:=y4 }
        jg @vert
        mov cx,bx

@vert:  cmp ax,0                        { Vertical range checking }
        jge @minin                      { if mny<0 ==> mny:=0 }
        xor ax,ax
@minin: cmp cx,200                      { if mxy>199 ==> mxy:=199 }
        jl @maxin
        mov cx,199
@maxin: cmp cx,0                        { if mxy<0 ==> Exit }
        jl @pexit
        cmp ax,199                      { if mny>199 ==> Exit }
        jg @pexit

        mov mny,ax                      { ax=mny=lowest point }
        mov mxy,cx                      { cx=mxy=highest point }

        push x1                         { RangeChk(x1,y1,x2,y2) }
        push y1
        push x2
        push y2
        call @Range

        push x2                         { RangeChk(x2,y2,x3,y3) }
        push y2
        push x3
        push y3
        call @Range

        push x3                         { RangeChk(x3,y3,x4,y4) }
        push y3
        cmp Triangles,0
        jz @Poly4
        push x1
        push y1
        jmp @Last

@Poly4: push x4
        push y4
        call @Range

        push x4                         { RangeChk(x4,y4,x1,y1) }
        push y4
        push x1
        push y1
@Last:  call @Range

        mov ax,mny                      { Show a poly }
        mov di,ax                       { y:=mny }
        shl di,2
        lea bx,xpos
        add di,bx                       { di points to xpos[y,0] }
@Show:  mov y,ax                        { repeat ... }
        mov cx,[di]
        mov dx,[di+2]
        mov px1,cx
        mov px2,dx
        push ax
        push di
        call @xhlin                     { xhlin(px1,px2,y,c) }
        pop di
        pop ax
        add di,4                        { Next xpos }
        inc ax                          { inc(y) }
        cmp ax,mxy                      { ... until y>mxy; }
        jle @Show
        jmp @pexit

{ RangeChk }

@Range: pop di                          { Get return IP }
        pop py2                         { Get params }
        pop px2
        pop py1
        pop px1
        push di                         { Save return IP }

        mov ax,py1                      { dir:=byte(y1<y2) }
        cmp ax,py2
        mov ax,1
        jl @Rdwn
        dec al
@Rdwn:  mov dir,al

        shl al,1
        push ax
        shl al,2
        sub ax,4
        mov stb,ax                      { stb:=8*dir-4 }
        pop ax
        dec ax                          { s:=2*dir-1 }
        mov s,ax                        { Check directions (-1= down, 1=up) }

        test AH,10000000b               { Calculate constants }
        mov dx,0
        jz @Rposi
        dec dx
@Rposi: mov bx,px2
        sub bx,px1
        imul bx
        mov mult,ax                     { mult:=s*(x2-x1) }
        mov ax,py2
        mov bx,py1
        mov cx,ax
        sub ax,bx
        mov divi,ax                     { divi:=y2-y1 }

        cmp bx,cx                       { ¿y1=y2? }

        pushf                           { Calculate pointer to xpos[y,dir] }
        mov y,bx                        { y:=y1 }
        mov di,bx
        shl di,2
        lea bx,xpos
        add di,bx
        mov cl,dir
        mov ch,0
        shl cl,1
        add di,cx                       { di points to xpos[y,dir] }
        popf

        je @Requ                        { if y1=y2 ==> @Requ }

        mov m,0                         { m:=0 }
        mov ax,py2
        add ax,s
        mov top,ax                      { top:=y2+s }

@RLoop: mov ax,y                        { repeat ... }
        cmp ax,mny                      { if y<mny ==> @RNext }
        jl @RNext
        cmp ax,mxy                      { if y>mxy ==> @RNext }
        jg @RNext

        mov ax,m                        { Calculate int(m/divi)+x1 }
        test AH,10000000b
        mov dx,0
        jz @RLpos
        dec dx
@RLpos: mov bx,divi
        idiv bx
        add ax,px1
        call @HR                        { HorRangeChk(m div divi+x1) }

@RNext: mov ax,mult
        add m,ax                        { inc(m,mult) }
        add di,stb                      { Next xpos }
        mov ax,y                        { inc(y,s) }
        add ax,s
        mov y,ax
        cmp ax,top
        jne @RLoop                      { ... until y=top }
        jmp @Rexit

@Requ:  mov ax,y
        cmp ax,mny                      { if y<mny ==> Exit }
        jl @Rexit
        cmp ax,mxy                      { if y>mxy ==> Exit }
        jg @Rexit
        mov ax,px1
        call @HR                        { HorRangeChk(px1) }
@Rexit: jmp @exit

{ HorRangeChk }

@HR:    mov bx,minx                     { bx:=minx }
        cmp ax,bx
        jl @HRsav
        mov bx,maxx                     { bx:=maxx }
        cmp ax,bx
        jg @HRsav
        mov bx,ax
@HRsav: mov [di],bx                     { xpos[y,dir]:=bx }
        jmp @exit
{ xhlin }

@xhlin: mov es,vidseg
        cld
        mov ax,80
        mul y
        mov di,ax                       { base of scan line }
        add di,address

        mov bx,px1                      { px1 = x begin coord }
        mov dx,px2                      { px2 = x end coord }
        cmp bx,dx
        jb @skip
        xchg bx,dx                      { switch coords if px1>px2 }

@skip:  mov cl,bl
        shr bx,2
        mov ch,dl
        shr dx,2
        and cx,$0303
        sub dx,bx                       { width in Bytes }
        add di,bx                       { offset into video buffer }
        mov ax,$ff02
        shl ah,cl
        and ah,1111b                    { left edge mask }
        mov cl,ch
        mov bh,$f1
        rol bh,cl
        and bh,1111b                    { right edge mask }
        mov cx,dx
        or cx,cx
        jnz @left
        and ah,bh                       { combine left & right bitmasks }

@left:  mov dx,$03c4
        out dx,ax
        inc dx
        mov al,c
        stosb
        jcxz @exit
        dec cx
        jcxz @right
        mov al,1111b
        out dx,al                       { skipped if cx=0,1 }
        mov al,c
        repz stosb                      { fill middle Bytes }

@right: mov al,bh
        out dx,al                       { skipped if cx=0 }
        mov al,c
        stosb

@exit:  pop ax
        push cs
        push ax
        ret
@pexit:
end;

{$f+}

Function cosinus(i:byte):integer;
begin
 cosinus:=ctab[i];
end;

Function sinus(i:byte):integer;
begin
 sinus:=stab[i];
end;

Procedure Initialize;
var i:byte;
begin
 triangles:=False;
 for i:=0 to 255 do ctab[i]:=round(-cos(i*pi/128)*divd);
 for i:=0 to 255 do stab[i]:=round(sin(i*pi/128)*divd);
end;

begin
 Initialize;
end.
