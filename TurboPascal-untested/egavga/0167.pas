
{
>    how ever i know that the ET3000 use diference ways to get your
> modes so this mite be your trouble..
no, it can't, cause the mode is actually set and works, but some single lines
(!) just don't work (and they change if I run the program twice or more) - so
this screen is 256 lines high, and for example lines 3, 180, 185 and 200 are
let's say gray - any idea why?  (the amount of lines and which lines seem to be
totally random)

(* Original code by Bas van Gaalen.         *)
(* Modified for no vertical overscan        *)
(* and converted to unit by Antonio Sanchez *)
}
unit umodeq;

interface
type
  twrec=record reg:word; func,data:byte; end;
  twarr=array[0..24] of twrec;

const
  vidseg:word=$a000;

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
    (reg:$03c0; func:$10; data:$41), { mode control }
    (reg:$3c2;  func:$0;  data:$e3), (* newly added *)
    (reg:$3c0;  func:$13; data:$0)); (* newly added *)

procedure setpal(col,r,g,b : byte);
procedure initvga;
procedure inittxt;
procedure openregs;
procedure closeregs;
procedure setmodeq;
procedure putpixel(x,y,c:byte);
procedure fillscreen;

implementation

procedure setpal(col,r,g,b : byte);assembler; asm
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
    dummy : byte;
begin
  initvga;
  openregs;
  for i:=0 to 24 do
    with tweak[i] do
    begin
      IF reg=$3c0
      then begin
            dummy:=port[$3da];     { reset read/write flip-flop }
            port[$3c0]:= func or $20; { ensure vga output is enabled }
            port[$3c0]:= data;
           end
      else if (reg=$3c2) or (reg=$3c3)
       then port[reg]:=data   {  directly to the port  }
      else begin
            port[reg]:=func;  {  index to port  }
            port[reg+1]:=data;{  value to port+1  }
           end;
    end;
  closeregs;
end;

procedure putpixel(x,y,c:byte); assembler;
asm
  mov es,vidseg
  mov bh,[y]
  mov bl,[x]
  mov al,[c]
  mov [es:bx],al
end;

procedure fillscreen; assembler;
asm
  mov es,vidseg
  xor cx,cx
 @loop:
  mov di,cx
  mov al,cl
  add al,ch
  mov [es:di],al
  inc cx
  jnz @loop
end;
end.

{
well, I have no simple example for that unit now, but for example just fill the
screen each line with a different color, and you'll see...  (BTW, works on a
ET4000 and on my new Cirrus Logic-based card...)
}
