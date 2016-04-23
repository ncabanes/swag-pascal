{
JOHN BECK

> question me is that when I'm using the BIOS block palette
> to create a fade in/out, it makes the screen flicker, which
> is quite disturbing.  What Info I need is how the VGA port
> works on setting up the RGB palette.  Thanks.
}

Type
  colorType  = Record
    rvalue,
    gvalue,
    bvalue : Byte;
  end;

  paletteType = Array [0..255] of colorType;

Procedure setpal(Var tp : paletteType);
Var
  palseg,
  palofs : Word;

Label wait1 {,wait2};

begin
  palseg := seg(tp);
  palofs := ofs(tp);
  Asm
    mov  dx, $3DA

   wait1:
    in   al, dx
    test al, $08
    jz   wait1

 { wait2:
    in   al,dx
    test al,$08
    jnz  wait2 }

    mov ax, 1012h
    xor bx, bx
    mov cx, 256
    mov es, palseg
    mov dx, palofs
    int 10h
  end;
end;

Procedure readpal(Var tp : paletteType);
Var
  palseg,
  palofs : Word;
begin
  palseg := seg(tp);
  palofs := ofs(tp);
  Asm
    mov ax, 1017h
    xor bx, bx
    mov cx, 256
    mov es, palseg
    mov dx, palofs
    int 10h
  end;
end;

{
   I cheat a little bit in the way that the screen flickering is handled,
but I find that this way is faster For many animations+palette manipulations /
second While still eliminating screen flickering.  Normally there would be
two tests for retrace, a 'jz' and a 'jnz', instead this only performs the
'jz' test. if your monitor still flickers, uncomment the other code.
}
