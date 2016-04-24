(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0198.PAS
  Description: Fast Sierpinski Triangle
  Author: JEFF MOLOFEE
  Date: 05-26-95  23:03
*)

{
I'm not to sure what the rule is for posting code on here but I figured
a few of the new programmer, maybe even some of the older ones would
enjoy this little program I whipped up.  (finally got my screen 12
putpixel working... grrrrr).  Annoying when every odd color rotates the
bits and doesn't carry. :)  Anyone have a smaller routine :)
}

var
  k:byte;
  j:word;
  oddeven:array[1..639] of Boolean;
  gasket :array[1..639] of Boolean;

function keypressed : boolean; assembler;
asm
 mov ah,$b
 int $21
 and al,$fe
end;

procedure put(x,y:word; c:byte); assembler;
asm
 mov dx,$3c4
 mov al,2
 out dx,al
 add dx,2
 mov al,[c]
 out dx,al
 mov bx,80
 mov es,sega000
 mov ax,[y]
 mul bx
 mov di,[x]
 shr di,3
 add di,ax
 mov dl,[es:di]
 mov ch,byte(x)
 and ch,7
 mov cl,7
 sub cl,ch
 mov ch,1
 shl ch,cl
 or dl,ch
 mov [es:di],dl
end;

begin
  asm mov ax,$12; int $10; end;
  for j:=1 to 639 do gasket[j]:=false;
  gasket[319]:=true;
  put(319,100,10);
  for k:=1 to 255 do begin
    for j:=1 to 639 do begin
      oddeven[j]:=gasket[j-1] xor gasket[j+1];
      if oddeven[j]=true then put(j,100+k,5);
      end;
    move(oddeven,gasket,639);
  end;
  repeat
  until keypressed;
  asm mov ax,$3; int $10; end;
  writeln('"Gasket" from low-res to HI-RES by Nitro & SeKs...');
for j:=1 to 2000 do begin mem[$b800:1+j*2]:=random(7)+9; end;
end.

