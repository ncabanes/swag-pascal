{
Here's an example of one of the possibilities mode-q offers. Of course the same
can be done in any other mode, too... Well, just check it out. To Jens and the
other carefull ones: keep being carefull (read the text).
}
{$define cpu386}

program creditscroll;
{ Made by Bas van Gaalen, Holland, PD }
uses
  crt,umodeq;
const
  vseg:word=$a000; fseg=$f000; fofs=$fa6e; lines=45;
  txt:array[0..lines-1] of string[30]=(
   {.........|.........|.........|}
    'This is a credits-scroll',
    'in mode-q: 256x256x256.',
    'That''s a chained mode, with',
    'a lineair addressing sceme.',
    'The graphics-screen is',
    'initialized in the unit',
    'umodeq. It''s enclosed in the',
    'next message (I hope).','','',
    'and so the credits go to','','',
    '...Bas van Gaalen...','','',
    'Btw: this is quite lame:',
    'not even a hardware-scroll!',
    'But it''s just to show the',
    'nice overscan-mode...','',
    'Uuuhm, can someone supply',
    'some shit, to fill up this',
    'text?','',
    'Oyeah, before I forget,',
    'mode-q is a tweaked mode,',
    'and it plays a bit with the',
    'VGA-registers!',
    'So again: I won''t take any',
    'responsebilty for this code!',
    'It works fine on my ET-4000.','','','',
    'Gayle, place this in the SWAG',
    'if you like...','','','','','','','','');

procedure retrace; assembler; asm
  mov dx,3dah; @vert1: in al,dx; test al,8; jz @vert1
  @vert2: in al,dx; test al,8; jnz @vert2; end;

procedure moveup; assembler; asm
  push ds; mov es,vseg; mov ds,vseg; xor di,di; mov si,0100h
  {$ifdef cpu386} mov cx,255*256/4; db $66; rep movsw
  {$else} mov cx,255*256/2; rep movsw {$endif} pop ds; end;

var i,j,slidx,txtidx:byte;
begin
  setmodeq;
  txtidx:=0; slidx:=0;
  repeat
    retrace;
    for i:=1 to length(txt[txtidx]) do for j:=0 to 7 do
      if ((mem[fseg:fofs+ord(txt[txtidx][i])*8+slidx] shl j) and 128)<>0 then
        mem[vseg:$fe00+i*8+(256-8*length(txt[txtidx])) div
2+j]:=32+txtidx+slidx+j;    moveup;
    slidx:=(1+slidx) mod 8;
    if slidx=0 then txtidx:=(1+txtidx) mod lines;
  until keypressed;
  inittxt;
end.
