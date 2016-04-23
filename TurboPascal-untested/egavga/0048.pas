{
KAI ROHRBACHER

> explain MODE X.

Well,  I don't care much about Mode X (which is 320x240x256), but use Mode Y
(=320x200x256)  --at least I think that this mode is called "Mode Y" (as far
as  I  know, the terms were introduced by a series of Michael Abrash in "Dr.
Dobb's  Journal" (?)). Nevertheless, things are identical With the exception
of initialising the VGA card! So here we go; note that the Asm code examples
were taken from my ANIVGA-toolkit: the PASCAL-equivalents when given are "on
the  fly"  Asm->PASCAL  translations  For  improved  clarity (I hope...); in
doubt, rely on the Asm part.

MODE Y in a nutshell
~~~~~~~~~~~~~~~~~~~~

Basically,  Mode  Y  works  like  this:  use  the BIOS to switch into normal
320x200x256  mode,  then reProgram the sequencer to unchain the 4 bitplanes.
This  results  in  a bitplaned VRAM layout very similiar to the EGA/VGA's 16
color modes:
}
Procedure InitGraph; Assembler;
Asm
  MOV AX,0013h
  INT 10h
  MOV DX,03C4h
  MOV AL,04
  OUT DX,AL
  INC DX
  in  AL,DX
  and AL,0F7h
  or  AL,04
  OUT DX,AL
  MOV DX,03C4h
  MOV AL,02
  OUT DX,AL
  INC DX
  MOV AL,0Fh
  OUT DX,AL
  MOV AX,0A000h
  MOV ES,AX
  SUB DI,DI
  MOV AX,DI
  MOV CX,8000h
  CLD
  REP STOSW

  MOV DX,CrtAddress
  MOV AL,14h
  OUT DX,AL
  INC DX
  in  AL,DX
  and AL,0BFh
  OUT DX,AL
  DEC DX
  MOV AL,17h
  OUT DX,AL
  INC DX
  in  AL,DX
  or  AL,40h
  OUT DX,AL
end;

{
CrtAddress  and  StatusReg  are the port addresses For the VGA ports needed;
they  are 3B4h and 3BAh on a monochrome display and 3D4h and 3DAh on a color
display, but can be determined at run-time, too:
}

Asm
  MOV DX,3CCh
  in AL,DX
  TEST AL,1
  MOV DX,3D4h
  JNZ @L1
  MOV DX,3B4h
 @L1:
  MOV CrtAddress,DX
  ADD DX,6
  MOV StatusReg,DX
end;

{
The  VRAM  layout  is  this:  underneath  each  memory  address in the range
$A000:0000..$A000:$FFFF,  there  are  4 Bytes, each representing one pixel's
color.
Whenever you Write to or read from such an address, an internal logic of the
VGA-card determines which one of those 4 pixels is accessed.
A  line  of  320  pixels (=320 Bytes) thus only takes 320/4=80 Bytes address
space,  but  to  address  a pixel, you need a) its VRAM address and b) which
bitplane it's on.
The  pixels  are arranged linearly: thus, the mapping from point coordinates
to memory addresses is done by (x,y) <-> mem[$A000: y*80+ (x div 4)] and the
bitplane is determined by (x mod 4).
(Note coordinates start With 0 and that "div 4" can be computed very fast by
"shr 2"; "mod 4" by "and 3").

So  you  computed the proper address and bitplane. If you want to _read_ the
pixel's color, you issue commands like this:
 portw[$3CE]:=(bitplane SHL 8)+4; color:=mem[$A000:y*80+(x shr 2)]
Or For better speed & control, do it in Asm:

 MOV AL,4
 MOV AH,bitplane
 MOV DX,3CEh
 CLI
 OUT DX,AX
 MOV AL,ES:[DI]
 STI

_Writing_  a pixel's color works similiar, but needs an additional step: the
mask is computed by 1 SHL bitplane (that is: 1/2/4/8 For mod4 values 0/1/2/3
respectively):
 portw[$3C4]:=(1 SHL bitplane+8)+2; mem[$A000:y*80+(x shr 2)]:=color
Or using Asm again:

 MOV CL,bitplane
 MOV AH,1
 SHL AH,CL
 MOV AL,2
 MOV DX,3C4h
 CLI
 OUT DX,AX
 STOSB
 STI

As  stated  above, one address represents 4 pixels, so 320x200 pixels occupy
16000  address  Bytes.  We  do  have  65536  (=$A000:0..$A000:$FFFF) though,
therefore  a  bit  more  than 4 pages are possible. It's up to you to define
your  pages,  0..15999=page  0,  16000..31999=page  1,  32000..47999=page 2,
48000..63999=page 3, 64000..65535=unused  is the most obvious layout.

Which  part  of  the VRAM is actually displayed can be Programmed by writing
the  offset  part of the starting address to the Crt-controller (the segment
part is implicitly set to $A000):

Asm
  MOV DX,CrtAddress
  MOV AL,$0D
  CLI
  OUT DX,AL
  INC DX
  MOV AL,low Byte of starting offset
  OUT DX,AL
  DEC DX
  MOV AL,$0C
  OUT DX,AL
  INC DX
  MOV AL,high Byte of starting offset
  OUT DX,AL
  STI
end;

N.B.: if you reProgram the display's starting address more often than "every
now  and  then",  you  better  synchronize  that  to the vertical retrace or
horizontal  enable  signal  of  your VGA card; otherwise, an annoying screen
flicker will become visible during switching!

For  example,  if  you do a "FOR i:=1 to 100 do SetAddress(i*80)", this will
result  in a blinding fast hardware scroll: With each iteration of the loop,
the  display will start 80 address Bytes (=320 pixels = 1 row) later, giving
the impression of the display scrolling upwards.

Note  that  Mode  X/Y  do  not differ in any other respect than their memory
layouts  from  all  the  other  bitplaned VGA modes: palette handling is the
same,  as  is usage of the VGA's Write modes! In (default) Write mode 0, you
can access the VRAM by Bytes, Words or dWords. Write mode 1 is handy to copy
the  contents  of  one  Graphic  page to another: you are restricted to Byte
accesses, but each one will transfer 4 Bytes at once.
For example, a sequence like the following...
portw[$3C4]:=$0f02; portw[$3CE]:=$4105;
move(mem[$a000:0000],mem[$a000:$3e80],16000);
portw[$3CE]:=$4005
...enables  all 4 planes, switches to Write mode 1, copies the (64000 Bytes)
contents  of  the  2nd Graphic page to the 1st one and then switches back to
Write mode 0 again.
}