(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0024.PAS
  Description: FAST GoToXY (BASM)
  Author: MARCIN BORKOWSKI
  Date: 08-24-94  13:40
*)


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
