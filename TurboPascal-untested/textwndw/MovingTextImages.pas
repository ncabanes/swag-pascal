(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0008.PAS
  Description: Moving Text Images
  Author: SEAN PALMER
  Date: 08-27-93  22:02
*)

{
SEAN PALMER

>I was looking threw a Turbo C++ manual and noted some
>Procedures that deal With the Text screen, such as
>Get/PutTextImage. I was wondering if anyone has created one
>for Pascal to move/save Text images around the screen like
>in C++.

Copies a rectangular section from one video buffer (any size) to another
}

Procedure moveScr(Var srcBuf; srcX, srcY, width, height, srcBufW,
                      srcBufH : Word; Var dstBuf; dstX, dstY, dstBufW,
                      dstBufH : Word); Assembler;
Asm
  cld
  push ds
  lds  si, srcBuf    {calc src adr}
  mov  ax, srcBufW
  mul  srcY
  add  ax, srcX
  shl  ax, 1
  add  si, ax
  les  di, dstBuf    {calc dst adr}
  mov  ax, dstBufW
  mul  dstY
  add  ax, dstX
  shl  ax, 1
  add  di, ax
  mov  dx, height    {num lines}
  mov  ax, SrcBufW   {calc ofs between src lines}
  sub  ax, width
  shl  ax, 1
  mov  bx, dstBufW   {calc ofs between dst lines}
  sub  bx, width
  shl  bx, 1
 @L:
  mov  cx, width
  rep  movsw
  add  si, ax
  add  di, bx
  dec  dx
  jnz  @L
  pop  ds
end;

Var
  s : Array [0..24,0..79,0..1] of Char Absolute $B800 : 0;
  d : Array [0..11,0..39,0..1] of Char;
  i : Integer;

begin
  For i := 1 to 25 * 10 do
    Write('(--)(--)');
  moveScr(s,0,0,40,12,80,25,d,0,0,40,12); {copy 40x12 block to buf}
  readln;
  moveScr(d,0,0,38,10,40,12,s,5,5,80,25); {copy part back to screen}
  readln;
end.


