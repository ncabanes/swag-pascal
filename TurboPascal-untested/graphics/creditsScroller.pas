(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0156.PAS
  Description: credits scroller
  Author: BAS VAN GAALEN
  Date: 11-26-94  05:02
*)

{
Here's an example of one of the possibilities mode-q offers. Of course the same
can be done in any other mode, too... Well, just check it out. To Jens and the
other carefull ones: keep being carefull (read the text).

>--- cut here
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
        mem[vseg:$fe00+i*8+(256-8*length(txt[txtidx])) div 2+j]:=32+txtidx+slidx+j;    moveup;
    slidx:=(1+slidx) mod 8;
    if slidx=0 then txtidx:=(1+txtidx) mod lines;
  until keypressed;
  inittxt;
end.

{ UNIT NEEDED BY SCROLLER !! }

{ Original by Robert Schmidt in C, converted to Pas by Bas van Gaalen,
  fido: 2:285/213.8, email: bas.van.gaalen@schotman.nl, Holland, Aug. '94, PD }

unit umodeq;

interface

const
  vidseg:word=$a000;

procedure setpal(col,r,g,b : byte);
procedure initvga; { not public }
procedure inittxt;
procedure openregs; { not public }
procedure closeregs; { not public }
procedure setmodeq;

implementation

type
  twrec=record reg:word; func,data:byte; end;
  twarr=array[0..22] of twrec;

const
  tweak:twarr=(
    (reg:$03d4; func:$00; data:$5f), { hor. total }
    (reg:$03d4; func:$01; data:$3f), { hor. display enable end }
    (reg:$03d4; func:$02; data:$40), { blank start }
    (reg:$03d4; func:$03; data:$82), { blank end }
    (reg:$03d4; func:$04; data:$4e), { retrace start }
    (reg:$03d4; func:$05; data:$9a), { retrace end }
    (reg:$03d4; func:$06; data:$23), { vertical total }
    (reg:$03d4; func:$07; data:$b2), { overflow register }
    (reg:$03d4; func:$08; data:$00), { preset row scan }
    (reg:$03d4; func:$09; data:$61), { max scan line/char heigth }
    (reg:$03d4; func:$10; data:$0a), { ver. retrace start }
    (reg:$03d4; func:$11; data:$ac), { ver. retrace end }
    (reg:$03d4; func:$12; data:$ff), { ver. display enable end }
    (reg:$03d4; func:$13; data:$20), { offset/logical width }
    (reg:$03d4; func:$14; data:$40), { underlinde location }
    (reg:$03d4; func:$15; data:$07), { ver. blank start }
    (reg:$03d4; func:$16; data:$17), { ver. blank end }
    (reg:$03d4; func:$17; data:$a3), { mode control }
    (reg:$03c4; func:$01; data:$01), { clock mode register }
    (reg:$03c4; func:$04; data:$0e), { memory mode register }
    (reg:$03ce; func:$05; data:$40), { mode register }
    (reg:$03ce; func:$06; data:$05), { misc. register }
    (reg:$03c0; func:$10; data:$41)  { mode control }
  );

procedure setpal(col,r,g,b : byte); assembler; asm
  mov dx,03c8h; mov al,col; out dx,al; inc dx; mov al,r; out dx,al
  mov al,g; out dx,al; mov al,b; out dx,al; end;

procedure initvga; assembler; asm mov ax,13h; int 10h; end;
procedure inittxt; assembler; asm mov ax,3; int 10h; end;

procedure openregs; assembler; asm
  mov dx,03d4h; mov al,11h; out dx,al; inc dx; in al,dx; and al,7fh
  mov ah,al; mov al,11h; dec dx; out dx,ax; end;

procedure closeregs; assembler; asm
  mov dx,03d4h; mov al,11h; out dx,al; inc dx; in al,dx; or al,80h
  mov ah,al; mov al,11h; dec dx; out dx,ax; end;

procedure setmodeq;
var i:byte;
begin
  initvga;
  openregs;
  for i:=0 to 22 do
    with tweak[i] do begin
      if reg<>$03c0 then port[reg]:=func else port[reg]:=func+32;
      port[reg+1]:=data;
    end;
  closeregs;
end;

{var x,y:byte;
begin
  setmodeq;
  for x:=0 to 255 do setpal(x,x div 4,x div 5,x div 6);
  for x:=0 to 255 do for y:=0 to 255 do mem[vidseg:y*256+x]:=(x+y) mod 255;
  readln;
  inittxt;}
end.


