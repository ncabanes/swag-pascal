(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0122.PAS
  Description: smooth text scroll
  Author: BAS VAN GAALEN
  Date: 08-24-94  13:57
*)

{
Here's a demo for a REAL smooth textscroll. Reset lines to something usefull,
cut the sideborders, place some readable text, and your scroller is ready! ;-)

}
program smoothtextscroll;
{ by Bas van Gaalen and Sven van Heel, Holland, PD }
uses crt;
const vidseg:word=$b800; lines=23;
var ofs:byte;

procedure vertrace; assembler; asm
  mov dx,03dah; @vert1: in al,dx; test al,8; jnz @vert1
  @vert2: in al,dx; test al,8; jz @vert2; end;

procedure setaddress(ad:word); assembler; asm
  mov dx,3d4h; mov al,0ch; mov ah,[byte(ad)+1]; out dx,ax
  mov al,0dh; mov ah,[byte(ad)]; out dx,ax; end;

procedure setsmooth(smt:byte); assembler; asm
  mov dx,03c0h; mov al,13h+32; out dx,al; inc dx; in al,dx
  and al,11110000b; mov ah,smt; or al,ah; dec dx; out dx,al; end;

procedure setup(ad:word); assembler;
asm
  mov dx,3d4h
  mov al,18h
  mov ah,[byte(ad)]
  out dx,ax
  mov al,7
  out dx,al
  inc dx
  in al,dx
  dec dx
  mov ah,[byte(ad)+1]
  and ah,00000001b
  shl ah,4
  and al,11101111b
  or al,ah
  mov ah,al
  mov al,7
  out dx,ax

  mov al,9
  out dx,al
  inc dx
  in al,dx
  dec dx
  mov ah,[byte(ad)+1]
  and ah,00000010b
  shl ah,5
  and al,10111111b
  or al,ah
  mov ah,al
  mov al,9
  out dx,ax

  mov dx,03c0h
  mov al,10h+32
  out dx,al
  inc dx
  in al,dx
  and al,11011111b
  or al,00100000b
  dec dx
  out dx,al
end;

var x,y,i:word; cx:byte;
begin
  setup(lines*16);
  setaddress((25-lines)*80);
  gotoxy(1,1);
  writeln('Hey, a smooth textscroll...');
  x:=0; cx:=0;
  randomize;
  repeat
    vertrace;
    setsmooth(x); ofs:=ofs mod 4;
    x:=(1+x) mod 9; if x=0 then begin
      for y:=0 to lines-1 do begin
        move(mem[$b800:160*(25-lines+y)+4],mem[$b800:160*(25-lines+y)+2],158);
        mem[$b800:(25-lines+y)*160+158]:=random(26)+32;
      end;
    end;
  until keypressed;
  textmode(lastmode);
end.

