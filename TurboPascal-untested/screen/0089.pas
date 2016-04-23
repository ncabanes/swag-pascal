{
Here are some uncommented routines for you all to use and abuse.. most
are either assembler or inline, except for box and writecentre.. box has
much inline assembler, but uses gotoxy for compatibility.  Most of these
procedures require CRT to be used.  SWAG people: Feel free to include
these snippets.

Note that all assume a vga system with video memory at 0B800h..
}

{Draw a box from (x1,y1) to (x2,y2) in current text attributes.  If FILL
 is true, then the box will be filled in.  If SHADOW is true, then the
 box will get a shadow (shadows just set the attribute around the bottom
 left edge of the box to dark gray..}
procedure Box(x1,y1,x2,y2:byte; fill,shadow:boolean);
var
  x,y: word;
begin
  gotoxy(x1,y1);
  write(#218);
  for x := x1+1 to x2-1 do write(#196);
  write(#191);
  for y := y1+1 to y2-1 do begin
    gotoxy(x1,y);
    write(#179);
    asm
      cmp  [fill],1
      jne  @@nofill
      mov  cl,x2
      mov  bl,x1
      sub  cl,bl
      xor  ch,ch
      mov  ah,textattr
      mov  al,20h
      mov  bx,0b800h
      mov  es,bx
      mov  di,y
      shl  di,2
      add  di,y
      shl  di,5
      sub  di,160
      mov  bl,x1
      xor  bh,bh
      add  di,bx
      add  di,bx
      rep  stosw
    @@NoFill:
    end;
    gotoxy(x2,y);
    write(#179);
  end;
  gotoxy(x1,y2);
  write(#192);
  for x := x1+1 to x2-1 do write(#196);
  write(#217);
  asm
    cmp  [shadow],1
    jne  @@noshadow
    mov  di,word ptr x1
    inc  di
    add  di,di
    mov  bx,word ptr y2
    mov  ax,bx
    shl  bx,5
    shl  ax,7
    add  di,ax
    mov  cx,word ptr x2
    sub  cx,word ptr x1
    inc  cx
    mov  ax,0b800h
    mov  es,ax
  @@ShadowLoop:
    mov  ax,[es:di]
    mov  ah,7h
    mov  [es:di],ax
    dec  cx
    jnz  @@ShadowLoop
    mov  di,word ptr x1
    add  di,di
    mov  bx,word ptr y1
    mov  ax,bx
    shl  bx,5
    shl  ax,7
    add  di,bx
    add  di,ax
    mov  cx,word ptr y2
    sub  cx,word ptr y1
  @@VertShadowLoop:
    mov ax,es:[di]
    mov ah,7h
    stosw
    mov ax,es:[di]
    mov ah,7h
    stosw
    add di,156
    dec cx
    jnz @@VertShadowLoop
  @@NoShadow:
  end;
end;

{CursOn and CursOff turn the cursor on and off}
procedure CursOn;
inline(
  $B4/$03/     {mov  ah,03h}
  $B7/$00/     {mov  bh,00h}
  $CD/$10/     {int  10h}
  $B4/$01/     {mov  ah,01h}
  $80/$E5/$DF/ {and  ch,0DFh}
  $CD/$10      {int  10h}
);

procedure cursoff;
inline(
  $B4/$03/     {mov  ah,03h}
  $B7/$00/     {mov  bl,0}
  $CD/$10/     {int  10h}
  $B4/$01/     {mov  ah,01h}
  $80/$CD/$20/ {or   ch,20h}
  $CD/$10      {int  10h}
);

{WriteCenter centres a string on a specific Y row}
procedure WriteCenter(s: string; y:byte);
begin
  gotoxy((80-length(s)) shr 1,y);
  write(s);
end;

{This procedure writes a highlighted string to x,y.  It uses the current
 text attribute to determine the colours to use.  By default, it is the
 low intensity version of the colour.  In the string, everything enclosed
 in ~ characters will be drawn in the high intensity version of the colour.
 eg 'You ~must~ be very ~patient~.'  The words must and patient would be
 highlighted}
procedure WriteHi(x,y:byte; s: string); assembler;
asm
  mov  bl,y
  xor  bh,bh
  mov  ax,bx
  shl  ax,2
  add  ax,bx
  shl  ax,5
  sub  ax,160
  mov  bl,x
  shl  bx,1
  add  ax,bx
  mov  di,ax
  mov  ax,0b800h
  mov  es,ax
  mov  ah,TextAttr
  and  ah,0f7h
  push ds
  lds  si,[s]
  mov  cl,[si]
  inc  si
@@WriteLoop:
  lodsb
  cmp  al,'~'
  jne  @@WriteChar
  xor  ah,08h
  lodsb
  dec  cl
  jz   @@Done
@@WriteChar:
  stosw
  dec  cl
  jnz  @@WriteLoop
@@Done:
  pop  ds
end;

{Indicator provides a fast percent indicator bar, of any length.. an
 example use is: Indicator(1,10,25,50) to draw an indicator bar 10
 characters wide starting at (1,25), half full.  The characters used
 are a dot and a box (. and X)..Note that they are high ascii characters
 and may not successfully transmit through FidoNet.  You can change them
 at the indicated positions}
procedure Indicator(x1,x2,y,percent:byte); assembler;
asm
  mov  bl,y
  xor  bh,bh
  mov  ax,bx
  shl  ax,2
  add  ax,bx
  shl  ax,5
  sub  ax,160
  mov  bl,x1
  shl  bx,1
  add  ax,bx
  mov  di,ax
  mov  ax,0b800h
  mov  es,ax
  mov  al,x2
  mov  bl,x1
  sub  al,bl
  xor  ah,ah
  mov  dl,al
  mov  bl,percent
  mul  bl
  mov  bl,100
  div  bl
  mov  cl,al
  mov  bl,al
  mov  ah,TextAttr
  mov  al,254        {Filled character}
  xor  ch,ch
  rep  stosw
  mov  al,249        {background character}
  sub  dl,bl
  mov  cl,dl
  rep  stosw
end;

{Toggle the video to gray scale instead of colour and back.  VGA ONLY!!}
procedure Gray(state : boolean); assembler;
asm
  mov  al,[state]
  xor  al,1
  mov  cl,al
  mov  bl,33h
  mov  ah,12h
  int  10h
  mov  ah,0fh
  int  10h
  mov  ah,00
  int  10h
end;

{State determines if Blink(false) or Bright Backgrounds(true) should be
 used when TextColor is given a parameter of ??+Blink}
procedure BriBack(state : boolean); assembler;
asm
  mov  bl,[state]
  xor  bl,1
  mov  ax,1003h
  int  10h
end;

