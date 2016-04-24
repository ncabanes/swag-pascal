(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0087.PAS
  Description: Font Banks
  Author: CHRIS PRIEDE
  Date: 01-27-94  12:12
*)

{
>have a vga that I want to use the above mentioned interrupt with. The
>problem is that I can't seem to get the interrupt to do its thing. The
>program seems to go through it with no effect at all. My question is how
>do I get the results?

The following procedures may help you. VGA has 8 font banks
(0..7). Load your font using LoadFont, then activate that bank with
SelectFont. Selecting two different font banks will let you display
two fonts simultaneously -- intensity bit selects secondary font (you
loose high intensity colors).
}
procedure SelectFont(Prim, Sec: byte);
var Tmp: byte;
begin
  Tmp := (Prim and $3) or (Prim shl 2 and $10)
  or (Sec shl 2 and $C) or (Sec shl 3 and $20);
  asm
        mov     bl, Tmp
        mov     ax, $1103
        int     $10
  end;
  if (Prim and $7) = (Sec and $7) then
    Tmp := $F
  else
    Tmp := $7;
  asm
        mov     bh, Tmp
        mov     bl, $12
        mov     ax, $1000
        int     $10
  end;
end;


procedure LoadFont(var Buf; Bank, Height: byte; First, Last: char); assembler;
asm
        mov     dl, First
        xor     dh, dh
        mov     cl, Last
        sub     cl, dl
        mov     ch, dh
        inc     cx
        mov     bl, Bank
        mov     bh, Height
        les     bp, Buf
        mov     ax, $1100
        int     $10
end;

var Buf: array [1..4096] of byte;

begin
  { Load 256 8x16 characters in buffer }
  LoadFont(Buf, 0, 16, #0, #255);
  SelectFont(0, 0);
end.



