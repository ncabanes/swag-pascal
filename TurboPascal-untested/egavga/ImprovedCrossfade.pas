(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0183.PAS
  Description: Improved Cross-Fade
  Author: BAS VAN GAALEN
  Date: 11-26-94  04:59
*)

{
David Proper posted a cross-fade routine here, some days ago. This is an update
on that one. It now fades all texts. Quite a pain to figure this out, realy.
Put it in the SWAG if you want, Kerry - Done!.
}
program xfade;
{ made by Bas van Gaalen, Holland, PD,
  fido 2:285/213.8, internet bas.van.gaalen@schotman.nl }
uses crt;
const
  vseg=$a000; fseg=$f000; fofs=$fa6e; lines=13;
  creds:array[0..lines-1] of string[20]=(
    {.........|.........|}
    'This cross-fade',
    'routine was made by',
    'Bas van Gaalen',
    'Code and idea',
    'inspired by',
    'David Proper',
    'This routine was',
    'enhanced a bit',
    'in comparison with',
    'David''s one...',
    'cu later',
    'alligator!',
    '');

procedure setpal(c,r,g,b:byte); assembler; asm
  mov dx,3c8h; mov al,[c]; out dx,al; inc dx; mov al,[r]
  out dx,al; mov al,[g]; out dx,al; mov al,[b]; out dx,al; end;

procedure retrace; assembler; asm
  mov dx,3dah; @vert1: in al,dx; test al,8; jz @vert1
  @vert2: in al,dx; test al,8; jnz @vert2; end;

procedure cleartxt(col,new:byte);
var x,y,vofs:word;
begin
  for x:=0 to 319 do for y:=100 to 107 do begin
    vofs:=y*320+x;
    if mem[vseg:vofs]=col then mem[vseg:vofs]:=0
    else if mem[vseg:vofs]<>0 then mem[vseg:vofs]:=new;
  end;
end;

procedure writetxt(col,cur:byte; txt:string);
var x,y,vofs:word; i,j,k:byte;
begin
  x:=(320-8*length(txt)) div 2; y:=100;
  for i:=1 to length(txt) do for j:=0 to 7 do for k:=0 to 7 do
    if ((mem[fseg:fofs+ord(txt[i])*8+j] shl k) and 128) <> 0 then begin
      vofs:=(y+j)*320+(i*8)+x+k;
      if mem[vseg:vofs]=cur then mem[vseg:vofs]:=col+cur else
mem[vseg:vofs]:=col;    end;
end;

var txtidx,curcol,i:byte;
begin
  asm mov ax,13h; int 10h; end;
  setpal(1,0,0,0); setpal(2,0,0,0); setpal(3,63 div 2,63,63 div 2);
  curcol:=1; txtidx:=0;
  repeat
    cleartxt(curcol,3-curcol);
    writetxt(curcol,3-curcol,creds[txtidx]);
    for i:=0 to 63 do begin
      retrace;
      setpal(curcol,i div 2,i,i div 2);
      setpal(3-curcol,(63-i) div 2,63-i,(63-i) div 2);
    end;
    delay(500);
    curcol:=1+(curcol mod 2);
    txtidx:=(1+txtidx) mod lines;
  until keypressed;
  textmode(lastmode);
end.

