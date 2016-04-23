{
    VGAXDEMO -- VGA ModeX graphics demo.  Mode setup, pixel plotting.
}

{$G+}
program vgaxdemo;
uses crt;

{--------------------------------------------------------------------}

var
    color_buf:byte;

{--------------------------------------------------------------------}

procedure setmode(mode:integer); assembler;
asm
    mov ax,mode;
    xor ah,ah;
    int 10h;
end;

{--------------------------------------------------------------------}

procedure cls; assembler;
asm
    mov ax,0A000h;      { ES = video memory }
    mov es,ax;

    mov dx,03C4h;       { Select all planes }
    mov ax,0F02h;
    out dx,ax;

    xor di,di;          { Set up for clear }
    xor ax,ax;
    mov cx,9600

    rep stosw;          { Clear the screen }
end;

{--------------------------------------------------------------------}

procedure setmodex;
const
    xdata : array[1..10] of Word = (
        $0011, $0B06, $3E07, $EA10, $8C11,
        $DF12, $0014, $E715, $0416, $E317);
var
    i:integer;
begin
    setmode($13);               { Set mode 13h 320x200x256 }

    port[$03C2] := port[$03CC] or $C0;
    portw[$03C4] := $0604;      { Set ModeX 320x240x256 }
    for i := 1 to 10 do begin
        portw[$03D4] := xdata[I];
    end;

    cls;
end;

{--------------------------------------------------------------------}

procedure putpixel(x, y, color:integer); assembler;
asm
    mov ax,0A000h;          { ES = video memory }
    mov es,ax;
    mov cx,x;               { CX = X }

    mov dx,03C4h;           { Set the memory plane }
    mov ax,1102h;
    rol ah,cl;
    out dx,ax;

    imul di,y,80;           { DI = offset in video memory }
    shr cx,2;
    add di,cx;
    mov ax,color;           { Set the pixel }
    stosb;
end;

{--------------------------------------------------------------------}

function getpixel(x, y:integer):integer; assembler;
asm
    mov ax,0A000h;          { ES = video memory }
    mov es,ax;
    mov cx,x;               { CX = X }

    mov dx,03CEh;           { Set the memory plane }
    mov al,4;
    mov ah,cl;
    and ah,3;
    out dx,ax;

    imul di,y,80;           { DI = offset in video memory }
    shr cx,2;
    add di,cx;
    mov al,es:[di];         { Read the pixel }
    or al,es:[di];          { Buggy video card fix }
    xor ah,ah;
end;

{--------------------------------------------------------------------}

procedure line(x1, y1, x2, y2, color:integer); assembler;
asm
    push bp;                { Save BP }
    mov ax,0A000h;          { ES = video memory }
    mov es,ax;

    mov ax,color;           { Set up color buffer }
    mov color_buf,al;

    mov ax,x1;              { Get parameters }
    mov bx,y1;
    mov cx,x2;
    mov dx,y2;

    mov si,cx;              { Get X distance }
    sub si,ax;
    jge @l_skip1;
    neg si;                 { X distance must be positive }
    xchg ax,cx;
    xchg bx,dx;

@l_skip1:
    mov di,dx;              { Get Y distance }
    sub di,bx;
    jge @l_skip2;
    neg di;

@l_skip2:
    cmp si,di;              { Y-major? }
    jle @l_ymajor;

    sub cx,ax;              { CX = distance }
    sub dx,bx;              { DX = Y increment }
    sar dx,16;
    add dx,dx;
    inc dx;

    xchg cx,dx;             { Rotate registers }

    mov bp,si;              { BP = X distance }
    shr si,1;               { SI = error term }
    sub si,di;
    neg si;

    imul bx,bx,80;          { BX = offset in video memory }
    ror ax,2;
    add bl,al;
    adc bh,0;
    shr ax,14;
    push cx;                { Save CX }
    mov ah,11h;             { AH = plane }
    mov cl,al;
    rol ah,cl;
    pop cx;                 { Restore CX }

    imul cx,cx,80;          { CX = Y increment }
    mov al,ah;              { AL = plane value }

@l_xloop:
    or ah,al;               { OR in plane }
    cmp si,1;               { Check error value }
    jl @l_xstr;             { ZF clear if taken }

    push dx;                { Save registers }
    push ax;
    mov dx,03C4h;           { Set bit planes }
    mov al,2;
    out dx,ax;
    pop ax;                 { Restore registers }
    pop dx;

    mov ah,color_buf;       { AH = color }
    mov es:[bx],ah;         { Write pixels }

    add bx,cx;              { Next line }
    sub si,bp;
    xor ah,ah;              { Clear buffer, set ZF }

@l_xstr:
    rol al,1;               { Next plane }
    jnc @l_x2;              { New byte? }
    jz @l_x1;               { Buffer empty? }

    push dx;                { Save DX }
    mov dx,03C4h;           { Set bit planes }
    mov al,2;
    out dx,ax;
    pop dx;                 { Restore DX }

    mov al,color_buf;       { AL = color }
    mov es:[bx],al;         { Write pixels }
    mov ax,11h;             { Clear buffer }
@l_x1:
    inc bx;                 { Next byte }

@l_x2:
    add si,di;
    dec dx;                 { Loop back }
    jnl @l_xloop;

    mov dx,03C4h;           { Set bit planes }
    mov al,2;
    out dx,ax;
    mov al,color_buf;       { Write last pixels }
    mov es:[bx],al;
    jmp @l_done;            { Return }

@l_ymajor:
    xchg cx,dx;             { Switch X2, Y2 }
    mov dx,di;              { DX = distance }
    sub cx,bx;              { CX = Y increment }
    sar cx,16;
    add cx,cx;
    inc cx;

    mov bp,si;              { BP = X distance }
    mov si,di;              { SI = error term }
    shr si,1;
    sub si,bp;
    neg si;

    imul bx,bx,80;          { BX = offset in video memory }
    ror ax,2;
    add bl,al;
    adc bh,0;
    shr ax,14;
    push cx;                { Save CX }
    xchg cx,ax;             { AH = plane value }
    mov ah,11h;
    rol ah,cl;
    pop cx;                 { Restore CX }

    push dx;                { Save DX }
    mov al,2;               { Set first plane }
    mov dx,03C4h;
    out dx,ax;
    pop dx;                 { Restore DX }

    imul cx,cx,80;          { CX = Y increment }

@l_yloop:
    mov al,color_buf;       { AL = color }
    mov es:[bx],al;         { Set the pixel }
    test si,si;             { Check error value }
    jle @l_ystr;

    rol ah,1;               { Move in X direction }
    adc bx,0;

    push dx;                { Save DX }
    mov al,2;               { Set new plane }
    mov dx,03C4h;
    out dx,ax;
    pop dx;                 { Restore DX }
    sub si,di;              { Adjust error term }

@l_ystr:
    add bx,cx;              { Go straight }
    add si,bp;
    dec dx;                 { Loop back }
    jnl @l_yloop;

@l_done:
    pop bp;                 { Restore BP }
end;

{--------------------------------------------------------------------}

var
    i:integer;
begin
    setmodex;

    while not keypressed do begin
        for i := 1 to 200 do
            putpixel(random(320), random(240), random(256));
    end;

    while keypressed do readkey;
    cls;

    while not keypressed do begin
        for i := 1 to 20 do
            line(random(320), random(240),
                 random(320), random(240), random(256));
    end;

    while keypressed do readkey;
    cls;

    setmode($03);
end.

