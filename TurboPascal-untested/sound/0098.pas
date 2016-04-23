{
 PV> i PLeaSe WaNT To KNoW HoW i CaN MoNiToR iNPuT SouRCeS LiKe
 PV> THe MiC, LiNe iN, CD iN PoRTS?

Here is a simple program I made, just for YOU:
}

uses crt;
{Maybe you must change the ports a bit, the second number isn't always 2}
const resetport = $226;
      datareadyport = $22E;
      readdataport = $22A;
      wbsport = $22C;
      writeport = $22C;

procedure wait;
begin
     delay(10);
end;

procedure writedsp(data : byte);assembler;
asm
   mov dx,wbsport
@loop:
   in al,dx
   test al,1 shl 7
   jnz @loop
   mov al,data
   out dx,al
end;

function readdsp : byte;assembler;
asm
   mov dx,datareadyport
@loop:
   in al,dx
   test al,1 shl 7
   jz @loop
   mov dx,readdataport
   in al,dx
end;

function readsound : byte;
begin
     writedsp($20);
     readsound := readdsp;
end;

procedure resetsb;assembler;
asm
   mov dx,resetport
   mov al,1
   out dx,al
   call wait
   mov dx,resetport
   xor al,al
   out dx,al
   mov dx,datareadyport
@loop:
   in al,dx
   test al,1 shl 7
   jz @loop
   mov dx,readdataport
   in al,dx
   call readsound
end;

var x : word;
    y : byte;
    oldy : array[0..319] of byte;

begin
   asm mov ax,13h;int 10h; end;
   resetsb;
   repeat
      mem[$A000:x+oldy[x]*320] := 0;
      y := 100+(readsound-127) div 2;
      mem[$A000:x+y*320] := 9;
      oldy[x] := y;
      x := (x+1) mod 320;
   until keypressed;
   asm mov ax,3h;int 10h; end;
end.
