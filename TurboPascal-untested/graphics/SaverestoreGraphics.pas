(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0131.PAS
  Description: Save/Restore Graphics
  Author: RICH VERAA
  Date: 08-24-94  17:54
*)



Procedure GetImage (X1,Y1,X2,Y2:Integer;P:Pointer); assembler;
asm
    mov  bx,320
    push ds
    les  di,P

    mov  ax,0A000h
    mov  ds,ax
    mov  ax,Y1
    mov  dx,320
    mul  dx
    add  ax,X1
    mov  si,ax

    mov  ax,X2
    sub  ax,X1
    inc  ax
    mov  dx,ax
    stosw

    mov  ax,Y2
    sub  ax,Y1
    inc  ax
    stosw
    mov  cx,ax

  @@1:
    mov  cx,dx

    shr  cx,1
    cld
    rep  movsw

    test dx,1
    jz         @@2
    movsb
  @@2:
    add  si,bx
    sub  si,dx

    dec  ax
    jnz  @@1

    pop  ds
end;

Procedure PutImage (X1,Y1:Integer;P:Pointer); assembler;
asm
    mov  bx,320
    push ds
    lds  si,P

    mov  ax,0A000h
    mov  es,ax
    mov  ax,Y1
    mov  dx,320
    mul  dx
    add  ax,X1
    mov  di,ax

    lodsw
    mov  dx,ax

    lodsw

  @@1:
    mov  cx,dx

    shr  cx,1
    cld
    rep  movsw

    test dx,1
    jz         @@2
    movsb
  @@2:
    add  di,bx
    sub  di,dx

    dec  ax
    jnz  @@1

    pop  ds
end;

Procedure Init;
begin
  GetMem (Buf1,64000);
  GetMem(Buf2,64000);
end;

begin
  init;
  dographicstuff;

  GetImage( 0,0,319,199,Buf1);  {store page 1}

  domoregraphicstuff;

  GetImage( 0,0,319,199,Buf2);  {store page 2}

  PutImage (0,0, Buf1);  {restore page 1}

end.

