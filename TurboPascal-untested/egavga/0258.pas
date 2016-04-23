{
 JA> Does anyone know how to set the palette in 640x480x16 mode?  I am
 JA> working on a bmp reader for C/S class and it needs to be compatible
 JA> with the BGI drivers :(  Thanks.

I thnik this one will work :)))) }

uses Dos;

type paltype=array [0..255,0..2] of Byte;

var
  i,j:Integer;
  r,g,b,k:Byte;
  kuku,sv:paltype;
  palup:shortint;



procedure SetPalette (paletka:paltype);
var reg:registers;
begin
  reg.ax:=$1012;
  reg.bx:=0;
  reg.cx:=255;
  reg.es:=Seg(paletka);
  reg.dx:=Ofs(paletka);
  intr ($10,reg);
end;

procedure GetPalette (var paletka:paltype);
var reg:registers;
begin
  reg.ax:=$1017;
  reg.bx:=0;
  reg.cx:=255;
  reg.es:=Seg(paletka);
  reg.dx:=Ofs(paletka);
  intr ($10,reg);
end;

procedure setrgb(n:integer;r,g,b:byte);
begin
asm
  mov ax,1010h
  mov bx,n
  mov ch,g
  mov cl,b
  mov dh,r
  int 10h
end
end;

procedure getrgb(n:integer; var r,g,b:byte);
begin
asm
  mov ax,1015h
  mov bx,n
  int 10h
  les di,g
  mov [es:di],ch
  les di,b
  mov [es:di],cl
  les di,r
  mov [es:di],dh
end
end;
