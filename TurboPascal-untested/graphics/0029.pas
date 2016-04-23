{$A-,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S-,V-,X+} {TP 6.0 & 286 required!}
Unit x320x240;

{
 Sean Palmer, 1993
 released to the Public Domain
 in tweaked modes, each latch/bit plane contains the entire 8-bit pixel.
 the sequencer map mask determines which plane (pixel) to update, and, when
 reading, the read map select reg determines which plane (pixel) to read.
 almost exactly opposite from regular vga 16-color modes which is why I never
 could get my routines to work For BOTH modes. 8)

  # = source screen pixel
  Normal 16-color         Tweaked 256-color

      Bit Mask                Bit Mask
      76543210                33333333
 Map  76543210           Map  22222222
 Mask 76543210           Mask 11111111
      76543210                00000000

  Functional equivalents
      Bit Mask        =       Seq Map Mask
      Seq Map Mask    =       Bit Mask
}


Interface

Var
  color : Byte;

Const
 xRes    = 320;
 yRes    = 240;   {displayed screen size}
 xMax    = xRes - 1;
 yMax    = yRes - 1;
 xMid    = xMax div 2;
 yMid    = yMax div 2;
 vxRes   = 512;
 vyRes   = $40000 div vxRes; {virtual screen size}
 nColors = 256;
 tsx : Byte = 8;
 tsy : Byte = 8;  {tile size}


Procedure plot(x, y : Integer);
Function  scrn(x, y : Integer) : Byte;

Procedure hLin(x, x2, y : Integer);
Procedure vLin(x, y, y2 : Integer);
Procedure rect(x, y, x2, y2 : Integer);
Procedure pane(x, y, x2, y2 : Integer);

Procedure line(x, y, x2, y2 : Integer);
Procedure oval(xc, yc, a, b : Integer);
Procedure disk(xc, yc, a, b : Integer);
Procedure fill(x, y : Integer);

Procedure putTile(x, y : Integer; p : Pointer);
Procedure overTile(x, y : Integer; p : Pointer);
Procedure putChar(x, y : Integer; p : Word);

Procedure setColor(color, r, g, b : Byte);
{rgb vals are from 0-63}
Function  getColor(color : Byte) : LongInt;
{returns $00rrggbb format}
Procedure setPalette(color : Byte; num : Word; Var rgb);
{rgb is list of 3-Byte rgb vals}
Procedure getPalette(color : Byte; num : Word; Var rgb);

Procedure clearGraph;
Procedure setWriteMode(f : Byte);
Procedure waitRetrace;
Procedure setWindow(x, y : Integer);

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Implementation

Const
  vSeg     = $A000;        {video segment}
  vxBytes  = vxRes div 4;  {Bytes per virtual scan line}
  seqPort  = $3C4;   {Sequencer}
  gcPort   = $3CE;    {Graphics Controller}
  attrPort = $3C0;   {attribute Controller}

  tableReadIndex    = $3C7;
  tableWriteIndex   = $3C8;
  tableDataRegister = $3C9;

  CrtcRegLen   = 10;
  CrtcRegTable : Array [1..CrtcRegLen] of Word =
    ($0D06, $3E07, $4109, $EA10, $AC11, $DF12, $0014, $E715, $0616, $E317);



Var
  CrtcPort   : Word;  {Crt controller}
  oldMode    : Byte;
  ExitSave   : Pointer;
  input1Port : Word;  {Crtc Input Status Reg #1=CrtcPort+6}
  fillVal    : Byte;

Type
 tRGB = Record
   r, g, b : Byte;
 end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Procedure clearGraph; Assembler;
Asm
  mov ax, vSeg
  mov es, ax
  mov dx, seqPort
  mov ax, $0F02
  out dx, ax {enable whole map mask}
  xor di, di
  mov cx, $8000 {screen size in Words}
  cld
  mov al, color
  mov ah, al
  repz stosw {clear screen}
end;

Procedure setWriteMode(f : Byte); Assembler;
Asm {copy/and/or/xor modes}
  mov ah, f
  shl ah, 3
  mov al, 3
  mov dx, gcPort
  out dx, ax {Function select reg}
end;

Procedure waitRetrace; Assembler;
Asm
  mov  dx, CrtcPort
  add  dx, 6 {find Crt status reg (input port #1)}
 @L1:
  in   al, dx
  test al, 8
  jnz  @L1;  {wait For no v retrace}
 @L2:
  in   al, dx
  test al, 8
  jz   @L2 {wait For v retrace}
 end;


{
 Since a virtual screen can be larger than the actual screen, scrolling is
 possible.  This routine sets the upper left corner of the screen to the
 specified pixel. Make sure 0 <= x <= vxRes - xRes, 0 <= y <= vyRes - yRes
}
Procedure setWindow(x, y : Integer); Assembler;
Asm
  mov  ax, vxBytes
  mul  y
  mov  bx, x
  mov  cl, bl
  shr  bx, 2
  add  bx, ax     {bx=Ofs of upper left corner}
  mov  dx, input1Port
 @L:
  in   al, dx
  test al, 8
  jnz  @L  {wait For no v retrace}
  sub  dx, 6  {CrtC port}
  mov  al, $D
  mov  ah, bl
  cli {these values are sampled at start of retrace}
  out  dx, ax  {lo Byte of display start addr}
  dec  al
  mov  ah, bh
  out  dx, ax    {hi Byte}
  sti
  add  dx, 6
 @L2:
  in   al, dx
  test al, 8
  jz   @L2  {wait For v retrace}
  {this also resets Attrib flip/flop}
  mov  dx, attrPort
  mov  al, $33
  out  dx, al   {Select Pixel Pan Register}
  and  cl, 3
  mov  al, cl
  shl  al, 1
  out  dx, al   {Shift is For 256 Color Mode}
end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Procedure plot(x, y : Integer); Assembler;
Asm
  mov   ax, vSeg
  mov   es, ax
  mov   di, x
  mov   cx, di
  shr   di, 2
  mov   ax, vxBytes
  mul   y
  add   di, ax
  mov   ax, $0102
  and   cl, 3
  shl   ah, cl
  mov   dx, seqPort
  out   dx, ax {set bit mask}
  mov   al, color
  stosb
end;

Function scrn(x, y : Integer) : Byte; Assembler;
Asm
  mov ax, vSeg
  mov es, ax
  mov di, x
  mov cx, di
  shr di, 2
  mov ax, vxBytes
  mul y
  add di, ax
  and cl, 3
  mov ah, cl
  mov al, 4
  mov dx, gcPort
  out dx, ax      {Read Map Select register}
  mov al, es:[di]  {get the whole plane}
end;

Procedure hLin(x, x2, y : Integer); Assembler;
Asm
  mov   ax, vSeg
  mov   es, ax
  cld
  mov   ax, vxBytes
  mul   y
  mov   di, ax {base of scan line}
  mov   bx, x
  mov   cl, bl
  shr   bx, 2
  mov   dx, x2
  mov   ch, dl
  shr   dx, 2
  and   cx, $0303
  sub   dx, bx     {width in Bytes}
  add   di, bx     {offset into video buffer}
  mov   ax, $FF02
  shl   ah, cl
  and   ah, $0F {left edge mask}
  mov   cl, ch
  mov   bh, $F1
  rol   bh, cl
  and   bh, $0F {right edge mask}
  mov   cx, dx
  or    cx, cx
  jnz   @LEFT
  and   ah, bh                  {combine left & right bitmasks}
 @LEFT:
  mov   dx, seqPort
  out   dx, ax
  inc   dx
  mov   al, color
  stosb
  jcxz  @EXIT
  dec   cx
  jcxz  @RIGHT
  mov   al, $0F
  out   dx, al     {skipped if cx=0,1}
  mov   al, color
  repz  stosb   {fill middle Bytes}
 @RIGHT:
  mov   al, bh
  out   dx, al       {skipped if cx=0}
  mov   al, color
  stosb
 @EXIT:
end;

Procedure vLin(x, y, y2 : Integer); Assembler;
Asm
  mov ax, vSeg
  mov es, ax
  cld
  mov di, x
  mov cx, di
  shr di, 2
  mov ax, vxBytes
  mul y
  add di, ax
  mov ax, $102
  and cl, 3
  shl ah, cl
  mov dx, seqPort
  out dx, ax
  mov cx, y2
  sub cx, y
  inc cx
  mov al, color
 @DOLINE:
  mov bl, es:[di]
  stosb
  add di, vxBytes-1
  loop @DOLINE
end;

Procedure rect(x, y, x2, y2 : Integer);
Var
  i : Word;
begin
  hlin(x, pred(x2), y);
  hlin(succ(x), x2, y2);
  vlin(x, succ(y), y2);
  vlin(x2, y, pred(y2));
end;

Procedure pane(x, y, x2, y2 : Integer);
Var
  i : Word;
begin
  For i := y2 downto y do
    hlin(x, x2, i);
end;

Procedure line(x, y, x2, y2:Integer);
Var
  d, dx, dy,
  ai, bi, xi, yi : Integer;
begin
  if(x < x2) then
  begin
    xi := 1;
    dx := x2 - x;
  end
  else
  begin
    xi := -1;
    dx := x - x2;
  end;
  if (y < y2) then
  begin
    yi := 1;
    dy := y2 - y;
  end
  else
  begin
    yi := -1;
    dy := y - y2;
  end;
  plot(x, y);
  if dx > dy then
  begin
    ai := (dy - dx) * 2;
    bi := dy * 2;
    d  := bi - dx;
    Repeat
      if (d >= 0) then
      begin
        inc(y, yi);
        inc(d, ai);
      end
      else
        inc(d, bi);
      inc(x, xi);
      plot(x, y);
    Until (x = x2);
  end
  else
  begin
    ai := (dx - dy) * 2;
    bi := dx * 2;
    d  := bi - dy;
    Repeat
      if (d >= 0) then
      begin
        inc(x, xi);
        inc(d, ai);
      end
      else
        inc(d, bi);
      inc(y, yi);
      plot(x, y);
    Until (y = y2);
  end;
end;

Procedure oval(xc, yc, a, b : Integer);
Var
  x, y      : Integer;
  aa, aa2,
  bb, bb2,
  d, dx, dy : LongInt;
begin
  x := 0;
  y := b;
  aa := LongInt(a) * a;
  aa2 := 2 * aa;
  bb := LongInt(b) * b;
  bb2 := 2 * bb;
  d := bb - aa * b + aa div 4;
  dx := 0;
  dy := aa2 * b;
  plot(xc, yc - y);
  plot(xc, yc + y);
  plot(xc - a, yc);
  plot(xc + a, yc);
  While (dx < dy) do
  begin
    if(d > 0) then
    begin
      dec(y);
      dec(dy, aa2);
      dec(d, dy);
    end;
    inc(x);
    inc(dx, bb2);
    inc(d, bb + dx);
    plot(xc + x, yc + y);
    plot(xc - x, yc + y);
    plot(xc + x, yc - y);
    plot(xc - x, yc - y);
  end;

  inc(d, (3 * (aa - bb) div 2 - (dx + dy)) div 2);

  While (y > 0) do
  begin
    if (d < 0) then
    begin
      inc(x);
      inc(dx, bb2);
      inc(d, bb + dx);
    end;
    dec(y);
    dec(dy, aa2);
    inc(d, aa - dy);
    plot(xc + x, yc + y);
    plot(xc - x, yc + y);
    plot(xc + x, yc - y);
    plot(xc - x, yc - y);
  end;
end;

Procedure disk(xc, yc, a, b:Integer);
Var
  x, y      : Integer;
  aa, aa2,
  bb, bb2,
  d, dx, dy : LongInt;
begin
  x   := 0;
  y   := b;
  aa  := LongInt(a) * a;
  aa2 := 2 * aa;
  bb  := LongInt(b) * b;
  bb2 := 2 * bb;
  d   := bb - aa * b + aa div 4;
  dx  := 0;
  dy  := aa2 * b;

  vLin(xc, yc - y, yc + y);

  While (dx < dy) do
  begin
    if (d > 0) then
    begin
      dec(y);
      dec(dy, aa2);
      dec(d, dy);
    end;
    inc(x);
    inc(dx, bb2);
    inc(d, bb + dx);
    vLin(xc - x, yc - y, yc + y);
    vLin(xc + x, yc - y, yc + y);
  end;

  inc(d, (3 * (aa - bb) div 2 - (dx + dy)) div 2);

  While (y >= 0) do
  begin
    if (d < 0) then
    begin
      inc(x);
      inc(dx, bb2);
      inc(d, bb + dx);
      vLin(xc - x, yc - y, yc + y);
      vLin(xc + x, yc - y, yc + y);
    end;
    dec(y);
    dec(dy, aa2);
    inc(d, aa - dy);
  end;
end;

{This routine only called by fill}
Function lineFill(x, y, d, prevXL, prevXR : Integer) : Integer;
Var
  xl, xr, i : Integer;
Label
  _1, _2, _3;
begin
  xl := x;
  xr := x;

  Repeat
    dec(xl);
  Until (scrn(xl, y) <> fillVal) or (xl < 0);

  inc(xl);

  Repeat
    inc(xr);
  Until (scrn(xr, y) <> fillVal) or (xr > xMax);

  dec(xr);
  hLin(xl, xr, y);
  inc(y, d);

  if Word(y) <= yMax then
  For x := xl to xr do
    if (scrn(x, y) = fillVal) then
    begin
      x := lineFill(x, y, d, xl, xr);
      if Word(x) > xr then
        Goto _1;
    end;

  _1 :

  dec(y, d + d);
  Asm
    neg d;
  end;
  if Word(y) <= yMax then
  begin
  For x := xl to prevXL do
    if (scrn(x, y) = fillVal) then
    begin
      i := lineFill(x, y, d, xl, xr);
      if Word(x) > prevXL then
        Goto _2;
    end;

    _2 :

    for x := prevXR to xr do
      if (scrn(x, y) = fillVal) then
      begin
        i := lineFill(x, y, d, xl, xr);
        if Word(x) > xr then
          Goto _3;
      end;

      _3 :

      end;

  lineFill := xr;
end;

Procedure fill(x, y : Integer);
begin
  fillVal := scrn(x, y);
  if fillVal <> color then
    lineFill(x, y, 1, x, x);
end;


{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Procedure putTile(x, y : Integer; p : Pointer); Assembler;
Asm
  push  ds
  lds   si, p
  mov   ax, vSeg
  mov   es, ax
  mov   di, x
  mov   cx, di
  shr   di, 2
  mov   ax, vxBytes
  mul   y
  add   di, ax
  mov   ax, $102
  and   cl, 3
  shl   ah, cl      {make bit mask}
  mov   dx, seqPort
  mov   bh, tsy
 @DOLINE:
  mov   cl, tsx
  xor   ch, ch
  push  ax
  push  di    {save starting bit mask}
 @LOOP:
  {mov al, 2}
  out   dx, ax
  shl   ah, 1       {give it some time to respond}
  mov   bl, es:[di]
  movsb
  dec   di
  test  ah, $10
  jz    @SAMEByte
  mov   ah, 1
  inc   di
 @SAMEByte:
  loop  @LOOP
  pop   di
  add   di, vxBytes
  pop   ax {start of next line}
  dec   bh
  jnz   @DOLINE
  pop   ds
end;

Procedure overTile(x, y : Integer; p : Pointer); Assembler;
Asm
  push  ds
  lds   si, p
  mov   ax, vSeg
  mov   es, ax
  mov   di, x
  mov   cx, di
  shr   di, 2
  mov   ax, vxBytes
  mul   y
  add   di, ax
  mov   ax, $102
  and   cl, 3
  shl   ah, cl      {make bit mask}
  mov   bh, tsy
  mov   dx, seqPort
 @DOLINE:
  mov   ch, tsx
  push  ax
  push  di    {save starting bit mask}
 @LOOP:
  mov   al, 2
  mov   dx, seqPort
  out   dx, ax
  shl   ah, 1
  xchg  ah, cl
  mov   al, 4
  mov   dl, gcPort and $FF
  out   dx, ax
  xchg  ah, cl
  inc   cl
  and   cl, 3
  lodsb
  or    al, al
  jz    @SKIP
  mov   bl, es:[di]
  cmp   bl, $C0
  jae   @SKIP
  stosb
  dec   di
 @SKIP:
  test  ah, $10
  jz    @SAMEByte
  mov   ah, 1
  inc   di
 @SAMEByte:
  dec   ch
  jnz   @LOOP
  pop   di
  add   di, vxBytes
  pop   ax {start of next line}
  dec   bh
  jnz   @DOLINE
  pop   ds
end;

{won't handle Chars wider than 1 Byte}
Procedure putChar(x, y : Integer; p : Word); Assembler;
Asm
  mov   si, p  {offset of Char in DS}
  mov   ax, vSeg
  mov   es, ax
  mov   di, x
  mov   cx, di
  shr   di, 2
  mov   ax, vxBytes
  mul   y
  add   di, ax
  mov   ax, $0102
  and   cl, 3
  shl   ah, cl      {make bit mask}
  mov   dx, seqPort
  mov   cl, tsy
  xor   ch, ch
 @DOLINE:
  mov   bl, [si]
  inc   si
  push  ax
  push  di    {save starting bit mask}
 @LOOP:
  mov   al, 2
  out   dx, ax
  shl   ah, 1
  shl   bl, 1
  jnc   @SKIP
  mov   al, color
  mov   es:[di], al
 @SKIP:
  test  ah, $10
  jz    @SAMEByte
  mov   ah, 1
  inc   di
 @SAMEByte:
  or    bl, bl
  jnz   @LOOP
  pop   di
  add   di, vxBytes
  pop   ax {start of next line}
  loop  @DOLINE
end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Procedure setColor(color, r, g, b : Byte); Assembler;
Asm {set DAC color}
  mov  dx, tableWriteIndex
  mov  al, color
  out  dx, al
  inc  dx
  mov  al, r
  out  dx, al
  mov  al, g
  out  dx, al
  mov  al, b
  out  dx, al
end; {Write index now points to next color}

Function getColor(color : Byte) : LongInt; Assembler;
Asm {get DAC color}
  mov  dx, tableReadIndex
  mov  al, color
  out  dx, al
  add  dx, 2
  cld
  xor  bh, bh
  in   al, dx
  mov  bl, al
  in   al, dx
  mov  ah, al
  in   al, dx
  mov  dx, bx
end; {read index now points to next color}

Procedure setPalette(color : Byte; num : Word; Var rgb); Assembler;
Asm
  mov   cx, num
  jcxz  @X
  mov   ax, cx
  shl   cx, 1
  add   cx, ax {mul by 3}
  push  ds
  lds   si, rgb
  cld
  mov   dx, tableWriteIndex
  mov   al, color
  out   dx, al
  inc   dx
 @L:
  lodsb
  out   dx, al
  loop  @L
  pop   ds
 @X:
end;

Procedure getPalette(color : Byte; num : Word; Var rgb); Assembler;
Asm
  mov   cx, num
  jcxz  @X
  mov   ax, cx
  shl   cx, 1
  add   cx, ax {mul by 3}
  les   di, rgb
  cld
  mov   dx, tableReadIndex
  mov   al, color
  out   dx, al
  add   dx, 2
 @L:
  in    al, dx
  stosb
  loop  @L
 @X:
end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

Function vgaPresent : Boolean; Assembler;
Asm
  mov ah, $F
  int $10
  mov oldMode, al  { save old Gr mode}
  mov ax, $1A00
  int $10          { check For VGA}
  cmp al, $1A
  jne @ERR         { no VGA Bios}
  cmp bl, 7
  jb @ERR          { is VGA or better?}
  cmp bl, $FF
  jnz @OK
 @ERR:
  xor al, al
  jmp @EXIT
 @OK:
  mov al, 1
 @EXIT:
end;

Procedure Graphbegin;
Var
  p     : Array [0..255] of tRGB;
  i, j,
  k, l  : Byte;
begin
  Asm
    mov ax, $0013
    int $10
  end;   {set BIOS mode}

  l := 0;
  For i := 0 to 5 do
    For j := 0 to 5 do
      For k := 0 to 5 do
      With p[l] do
      begin
        r := (i * 63) div 5;
        g := (j * 63) div 5;
        b := (k * 63) div 5;
        inc(l);
      end;

  For i := 216 to 255 do
  With p[i] do
  begin
    l := ((i - 216) * 63) div 39;
    r := l;
    g := l;
    b := l;
  end;

  setpalette(0, 256, p);
  color := 0;

  Asm
   mov  dx, seqPort
   mov  ax, $0604
   out  dx, ax            { disable chain 4}
   mov  ax, $0100
   out  dx, ax            { synchronous reset asserted}
   dec  dx
   dec  dx
   mov  al, $E3
   out  dx, al            { misc output port at $3C2}
                          { use 25mHz dot clock,  480 lines}
   inc  dx
   inc  dx
   mov  ax, $0300
   out  dx, ax            { restart sequencer}
   mov  dx, CrtcPort
   mov  al, $11
   out  dx, al            { select cr11}
   inc  dx
   in   al, dx
   and  al, $7F
   out  dx, al
   dec  dx                { remove Write protect from cr0-cr7}
   mov  si, offset CrtcRegTable
   mov  cx, CrtcRegLen
   repz outsw             { set Crtc data}
   mov  ax, vxBytes
   shr  ax, 1             { Words per scan line}
   mov  ah, al
   mov  al, $13
   out  dx, ax            { set CrtC offset reg}
  end;

  clearGraph;
end;

Procedure Graphend; Far;
begin
  ExitProc := exitSave;
  Asm
    mov al, oldMode
    mov ah, 0
    int $10
  end;
end;

begin
  CrtcPort   := memw[$40 : $63];
  input1Port := CrtcPort + 6;
  if vgaPresent then
  begin
    ExitSave := exitProc;
    ExitProc := @Graphend;
    Graphbegin;
  end
  else
  begin
    Writeln(^G + 'VGA required.');
    halt(1);
  end;
end.
