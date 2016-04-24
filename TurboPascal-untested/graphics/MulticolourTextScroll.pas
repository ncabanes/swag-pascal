(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0093.PAS
  Description: Multicolour Text Scroll
  Author: OSCAR WAHLBERT
  Date: 05-25-94  08:22
*)


program multicolourtextscroll;
uses crt;
const sseg : word = $b800; hi = 16; wideness = 1;
  txt : string = 'Multicoloured smooth text scroller!   ';
  maxcols = 17; cols : array[0..maxcols] of byte =
    (8, 8, 8, 7, 8, 7, 7, 15, 7, 15, 15, 15, 7, 15, 7, 7, 8, 7);
var idx : word; i, cur, line, bitpos : byte;
    ccol : byte; colw : byte; ch : char;

procedure retrace; assembler;
asm
  mov dx,3dah;
  @l1: in al,dx; test al,8; jnz @l1;
  @l2: in al,dx; test al,8; jz @l2;
end;

procedure movecharsleft(startingrow : word); assembler;
asm
  push  ds;
  mov   ax,$b800;
  mov   ds,ax;
  mov   di,2
  @@MoveByte:
    add   di,startingrow;
    mov   al,[ds:di];
    sub   di,2
    mov   [ds:di],al;
    sub   di,startingrow;
    add   di,4
    cmp   di,160
  jl      @@MoveByte;
  pop   ds
end;

procedure movecolsright(startingrow : word); assembler;
asm
  push  ds
  mov   ax,$b800
  mov   ds,ax
  mov   di,161
  @@MoveByte:
    add   di,startingrow
    sub   di,4
    mov   al,[ds:di]
    add   di,2
    mov   [ds:di],al
    sub   di,startingrow
    cmp   di,0001
  ja      @@MoveByte
  pop   ds
end;


begin
  textattr := 7; clrscr; ccol := 1; idx := 1; colw := 0;
  repeat
    inc(colw);
    retrace;
    mem[$b800:hi*160+158] := ord(txt[idx]);
    movecharsleft(hi*160);
    if (colw > 1) then begin
      colw := 0; inc(ccol);
      mem[$b800:hi*160+1] := cols[ccol mod (maxcols+1)];
      movecolsright(hi*160);
    end;
    if not keypressed then idx := 1 + idx mod length(txt);
  until keypressed;
  while keypressed do ch := readkey; textattr := 7; clrscr;
end.

The push/pop ds might be superfluous... I don't know if you need them or not...
I'm just starting assembly, you know.  :^)
It's kinda like the one you made, but it doesn't lock up on my computer -- you
can't check port[$60] on XTs.  :^)
And in this, the colours move one way, and the text, the other.  It's kinda
distracting when you're trying to read the scroll, but oh well...
C-YA.


