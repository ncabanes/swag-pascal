
procedure GoToXY(x,y : word);
begin
  asm
    mov    ax,y
    mov    dh,al
    dec    dh
    mov    ax,x
    mov    dl,al
    dec    dl
    mov    ah,2
    xor    bh,bh
    int    10h
  end
end;

