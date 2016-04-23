uses crt,dos;
type
pal       = array[0..255,0..2] of byte;
var
tgaheader : array[1..18] of byte;
tgapal    : pal;
tgatype,storage,bpp: byte;
fil       : file;
i         : byte;
xsize,ysize : word;
begin
clrscr;
assign(fil,'inf\vlagold.tga');
reset(fil,1);
seek(fil,2);
blockreaD(fil,tgatype,1);
seek(fil,12);
blockread(fil,xsize,2);
blockread(fil,ysize,2);
seek(fil,16);
blockread(fil,bpp,1);
blockread(fil,storage,1);
writeln;
writeln('═══════════════ TARGA Information ═══════════════');
writeln;
writeln('═══════════════ Misc. Information ═══════════════');
case tgatype of
3 :writeln('Type           : 8-bit grayscale uncompressed (3)');
2 :writeln('Type           : 24-bit true color uncompressed (2)');
1 :writeln('Type           : 8-bit with palette (1)');
else writeln('Type           : Unknown (',tgatype,')');
end;
case storage of
32 : writeln('Storing method : Top-down');
0  : writeln('Storing method : Bottom-up');
else writeln('Storing method : unknown (',storage,')');
end;
writeln;
writeln('═══════════════ Color Information ═══════════════');
writeln('BPP    : ',bpp);
writeln('Colors : ',256*(bpp div 8));
writeln;
writeln('═══════════════  Size Information ═══════════════');
writeln('X-Size : ',xsize);
writeln('Y-Size : ',ysize);
readln;
clrscr;
asm
mov ax,$13
int 10h
end;
if tgatype<3 then begin
                  blockread(fil,tgapal,sizeof(tgapal));
                  port[$3c8]:=0;
                  for i:=0 to 255 do begin
                  port[$3c9]:=tgapal[i,2] shr 2;
                  port[$3c9]:=tgapal[i,1] shr 2;
                  port[$3c9]:=tgapal[i,0] shr 2;
                  end;
                  end;
for i:=0 to ysize-1 do
blockread(fil,mem[$A000:320*i],xsize);
sound(200);
delay(20);
nosound;
repeat until keypressed; while keypressed do readkey;
asm mov ax,3; int 10h; end;
close(fil);
end.