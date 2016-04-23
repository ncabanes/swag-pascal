{
SEAN PALMER

I'm using TP. Here are the fixed division routines I'm currently using
(they are, as you can see, quite specialized)

I had to abandon the original fixed division routines because I didn't
know how to translate the 386-specific instructions using DB. (MOVSX,
SHLD, etc)
}

type
  fixed = record
    f : word;
    i : integer;
  end;

  shortFixed = record
    f : byte;
    i : shortint;
  end;

{ this one divides a fixed by a fixed, result is fixed needs 386 }

function fixedDiv(d1, d2 : longint) : longint; assembler;
asm
  db $66; xor dx, dx
  mov cx, word ptr D1 + 2
  or cx, cx
  jns @S
  db $66; dec dx
 @S:
  mov dx, cx
  mov ax, word ptr D1
  db $66; shl ax, 16
  db $66; idiv word ptr d2
  db $66; mov dx, ax
  db $66; shr dx, 16
end;

{ this one divides a longint by a longint, result is fixed needs 386 }

function div2Fixed(d1, d2 : longint) : longint; assembler;
asm
  db $66; xor dx, dx
  db $66; mov ax, word ptr d1
  db $66; shl ax, 16
  jns @S;
  db $66; dec dx
 @S:
  db $66; idiv word ptr d2
  db $66; mov dx, ax
  db $66; shr dx, 16
end;

{ this one divides an integer by and integer, result is shortFixed }

function divfix(d1, d2 : integer) : integer; assembler;
asm
  mov al, byte
  ptr d1 + 1
  cbw
  mov dx, ax
  xor al, al
  mov ah, byte ptr d1
  idiv d2
end;


