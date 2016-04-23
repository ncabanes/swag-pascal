unit VVGA;
{$F+,O+}
interface

type
  VColor = record
    R,G,B: byte;
  end;

procedure SetVGAMode;
procedure SetTxtMode;
procedure SetOneColor(C,R,G,B: Byte);
procedure SetColors(CFirst: Word; Count: Word; var ColTabl);
procedure GetColors(CFirst: Word; Count: Word; var ColTabl);
procedure SmoothDecreaseColors(CFirst: Word; Count: Word);
procedure SmoothSetColors(CFirst: Word; Count: Word;var Palette);
procedure KillColors(CFirst: Word; Count: Word);

var
  VGAPresent : Boolean;

implementation

procedure SetVGAMode; assembler;
asm
  mov AX,0013H
  int 10H
end;

procedure SetTxtMode; assembler;
asm
  mov AX,0003H
  int 10H
end;

procedure SetOneColor(C,R,G,B: Byte); assembler;
asm
  mov AX, 1017H
  mov BL, C
  xor BH, BH
  mov DH, R
  mov CH, G
  mov CL, B
  int 10h
end;

procedure SetColors(CFirst: Word; Count: Word; var ColTabl);
begin
  asm
    cli
    push ds
    push es
    xor ax, ax
    mov es, ax
    mov dx, es:[463h]
    add dx, 6
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
@@WaitOff:
    in al, dx
    nop
    nop
    test al, 08h
    jnz @@WaitOff
@@WaitOn:
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
    mov dx, 3C8h
    mov ax, CFirst
    out dx, al
    nop
    nop
    lds si, ColTabl
    mov ax, Count
    mov cx, 3
    mul cx
    mov cx, ax
    mov dx, 3C9h
    cld
@@ReadReg:
    lodsb
    out dx, al
    nop
    nop
    loop @@ReadReg
    pop es
    pop ds
    sti
  end;
end;

procedure KillColors(CFirst: Word; Count: Word);
begin
  asm
    cli
    push ds
    push es
    xor ax, ax
    mov es, ax
    mov dx, es:[463h]
    add dx, 6
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
@@WaitOff:
    in al, dx
    nop
    nop
    test al, 08h
    jnz @@WaitOff
@@WaitOn:
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
    mov dx, 3C8h
    mov ax, CFirst
    out dx, al
    nop
    nop
    mov ax, Count
    mov cx, 3
    mul cx
    mov cx, ax
    mov dx, 3C9h
    cld
    mov al, 0
@@ReadReg:
    out dx, al
    nop
    nop
    loop @@ReadReg
    pop es
    pop ds
    sti
  end;
end;

procedure GetColors(CFirst: Word; Count: Word; var ColTabl);
begin
  asm
    cli
    push ds
    push es
    xor ax, ax
    mov es, ax
    mov dx, es:[463h]
    add dx, 6
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
@@WaitOff:
    in al, dx
    nop
    nop
    test al, 08h
    jnz @@WaitOff
@@WaitOn:
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
    mov dx, 3C7h
    mov ax, CFirst
    out dx, al
    nop
    nop
    les di, ColTabl
    mov ax, Count
    mov cx, 3
    mul cx
    mov cx, ax
    mov dx, 3C9h
    cld
@@ReadReg:
    in al, dx
    stosb
    nop
    nop
    loop @@ReadReg
    pop es
    pop ds
    sti
  end;
end;

procedure SmoothDecreaseColors(CFirst: Word; Count: Word);
var
  ColTabl: array[0..255] of VColor;
  NPort  : Word;
  PTable : Pointer;
begin
  GetColors(0,256, ColTabl);
  PTable := Addr(ColTabl);
  asm
    cli
    push ds
    push es
    xor ax, ax
    mov es, ax
    mov dx, es:[463h]
    add dx, 6
    mov NPort, dx
    pop es
    mov cx, 63
    mov bl, 1
@@NextStep:
    cmp bl, 0
    je @@End
    dec bl
    push cx
    mov dx, NPort
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
@@WaitOff:
    in al, dx
    nop
    nop
    test al, 08h
    jnz @@WaitOff
@@WaitOn:
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
    mov dx, 3C8h
    mov ax, CFirst
    out dx, al
    nop
    nop
    lds si, PTable
    mov cx, 3
    mov ax, Count
    mul cx
    mov cx, ax
    mov dx, 3C9h
    cld
@@WriteReg:
    cmp ds:[si].Byte, 0
    je @@NotDec
    dec ds:[si].Byte
    mov bl, 1
@@NotDec:
    lodsb
    out dx, al
    loop @@WriteReg
    pop cx
    loop @@NextStep
@@End:
    pop ds
    sti
  end;
end;

procedure SmoothSetColors(CFirst, Count: Word; var Palette);
var
  ColTabl: array[0..255] of VColor;
  NPort  : Word;
  PTable : Pointer;
begin
   GetColors(CFirst,Count, ColTabl);
  PTable := Addr(ColTabl);
  asm
    cli
    push ds
    push es
    xor ax, ax
    mov es, ax
    mov dx, es:[463h]
    add dx, 6
    mov NPort, dx
    pop es
    mov cx, 63
    mov bl, 1
@@NextStep:
    cmp bl, 0
    je @@End
    dec bl
    push cx
    mov dx, NPort
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
@@WaitOff:
    in al, dx
    nop
    nop
    test al, 08h
    jnz @@WaitOff
@@WaitOn:
    in al, dx
    nop
    nop
    test al, 08h
    jz @@WaitOn
    mov dx, 3C8h
    mov ax, CFirst
    out dx, al
    nop
    nop
    lds si, PTable
    les di, Palette
    mov cx, 3
    mov ax, Count
    mul cx
    mov cx, ax
    mov dx, 3C9h
    cld
@@WriteReg:
    mov al, es:[di].Byte
    cmp ds:[si].Byte, al
    je @@NotChange
    jb @@Increase
    dec ds:[si].Byte
    jmp @@IsChanged
@@Increase:
    inc ds:[si].Byte
@@IsChanged:
    mov bl, 1
@@NotChange:
    inc di
    lodsb
    out dx, al
    loop @@WriteReg
    pop cx
    loop @@NextStep
@@End:
    pop ds
    sti
  end;
end;

begin
  {$IFNDEF DPMI}
  asm
    mov ax, 1200h
    mov bl, 32h
    int 10h
    cmp al, 12h
    je @@VGA
    mov al, 0
    jmp @@ThatsAll
@@VGA:
    mov al, 1
@@ThatsAll:
    mov VGAPresent, al
  end;
  {$ENDIF}
end.
