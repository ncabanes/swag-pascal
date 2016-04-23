{
SEAN PALMER

Well, I got a wild hair up my butt and decided to convert that
bitmap scaler I posted into an inline assembler procedure (mostly)
It's now quite a bit faster...

by Sean Palmer
public domain
}

{bitmaps are limited to 256x256 (duh)}

type
  fixed = record
    case boolean of
      true  : (w : longint);
      false : (f, i : word);
    end;

const
  bmp : array [0..3, 0..3] of byte =
    ((0, 1, 2, 3),
     (1, 2, 3, 4),
     (2, 3, 4, 5),
     (3, 4, 5, 6));
var
  bmp2 : array [0..63, 0..63] of byte;
  i, j : integer;

procedure scaleBitmap(var bitmap; x, y : byte; x1, y1, x2, y2 : word);
var
  s, w, h    : word;  {xSkip,width,height}
  sx, sy, cy : fixed; {xinc, yinc, ySrcPos}
begin
  w    := x2 - x1 + 1;
  h    := y2 - y1 + 1;
  sx.w := x * $10000 div w;
  sy.w := y * $10000 div h;
  s    := 320-w;
  cy.w := 0;
  asm
    push ds
    mov  ds, word ptr bitmap+2;
    mov  ax, $A000
    mov  es, ax  {setup screen seg}
    cld
    mov  ax, 320
    mul  y1
    add  ax, x1
    mov  di, ax {calc screen adr}
   @L2:
    mov  ax, cy.i
    mul  x
    mov  bx, ax
    add  bx, word ptr bitmap {offset}
    mov  cx, w
    mov  si, 0     {fraction of src adr (bx.si)}
    mov  dx, sx.f
   @L:
    mov  al, [bx]
    stosb
    add  si, dx
    adc  bx, sx.i    {if carry or sx.i<>0, new source pixel}
    loop @L
    add  di, s     {skip to next screen row}
    mov  ax, sy.f
    mov  bx, sy.i
    add  cy.f, ax
    adc  cy.i, bx
    dec  word ptr h
    jnz  @L2
    pop  ds
  end;
end;

begin
  for i := 0 to 63 do   {init bmp2}
    for j := 0 to 63 do
      bmp2[j, i] := j + (i xor $19) + 32;
  asm
    mov ax, $13
    int $10
  end;   {init vga mode 13h}
  for i := 2 to 99 do                 {test bmp}
    scaleBitMap(bmp, 4, 4, 0, 0, i * 2 - 1, i * 2 - 1);
  for i := 99 downto 2 do
    scaleBitMap(bmp, 4, 4, 0, 0, i * 2 - 1, 197);
  for i := 1 to 66 do                 {test bmp2}
    scaleBitMap(bmp2, 64, 64, 0, 0, i * 2 - 1, i * 3 - 1);
  for i := 66 downto 1 do
    scaleBitMap(bmp2, 64, 64, 0, 0, i * 2 - 1, i * 2 - 1 + 66);
  asm
    mov ax, $3
    int $10
  end;      {restore text mode}
end.
