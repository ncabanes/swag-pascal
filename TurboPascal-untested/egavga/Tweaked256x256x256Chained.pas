(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0175.PAS
  Description: Tweaked 256x256x256 Chained
  Author: BAS VAN GAALEN
  Date: 11-26-94  04:59
*)

{
Here's something funny to play with. I got it from Tweak by Robert Schmidt of
Ztiff Zox Softwear (just quoting here...), which I FTP'ed. It was written in
C, and rather buggy (as ever with C). Anyway, he called it mode-q, because of
the 3 times 256: cubed. I even documented it a bit. You can alter the
horizontal position by playing with reg $3d4, func $4 for instance. None of
those blew my monitor up, so I guess it won't do any harm on yours. But don't
start complaining if it does: use at your own risk! <btw: as far as I know
it's not possible to harm the VGA-monitor. If you have a EGA or worse, you
better not run this>
}
program tweak256x256chained;
{ Original by Robert Schmidt in C, converted to Pas by Bas van Gaalen,
  fido: 2:285/213.8, email: bas.van.gaalen@schotman.nl, Holland, Aug. '94, PD }
const
  vidseg:word=$a000;

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

var x,y:byte;
begin
  setmodeq;
  for x:=0 to 255 do setpal(x,x div 4,x div 5,x div 6);
  for x:=0 to 255 do for y:=0 to 255 do mem[vidseg:y*256+x]:=(x+y) mod 255;
  readln;
  inittxt;
end.

{ Just imagine the possibilities... No words needed, no muls needed... }


