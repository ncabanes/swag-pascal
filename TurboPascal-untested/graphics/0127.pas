{
Howdy all!

By request here's the stars-routine, the final update. ;-)
Limits: cpu-speed and conv.-memory. No others...

}
program _stars;
{ Done by Sven van Heel and Bas van Gaalen, Holland, PD }
uses crt;
const
  f=6; nofstars=100; vidseg:word=$a000;
  bitmask:array[0..1,0..4,0..4] of byte=(
    ((0,0,1,0,0),(0,0,3,0,0),(1,3,6,3,1),(0,0,3,0,0),(0,0,1,0,0)),
    ((0,0,6,0,0),(0,0,3,0,0),(6,3,1,3,6),(0,0,3,0,0),(0,0,6,0,0)));
type starstruc=record
  xp,yp:word; phase,col:byte; dur:shortint; active:boolean; end;
var stars:array[1..nofstars] of starstruc;

procedure setpal(col,r,g,b : byte); assembler; asm
  mov dx,03c8h; mov al,col; out dx,al; inc dx; mov al,r
  out dx,al; mov al,g; out dx,al; mov al,b; out dx,al; end;

procedure retrace; assembler; asm
  mov dx,3dah; @vert1: in al,dx; test al,8; jz @vert1
  @vert2: in al,dx; test al,8; jnz @vert2; end;

var i,x,y:word;
begin
  asm mov ax,13h; int 10h; end;
  for i:=1 to 10 do begin
    setpal(i,f*i,0,0); setpal(21-i,f*i,0,0); setpal(20+i,0,0,0);
    setpal(30+i,0,f*i,0); setpal(51-i,0,f*i,0); setpal(50+i,0,0,0);
    setpal(60+i,0,0,f*i); setpal(81-i,0,0,f*i); setpal(80+i,0,0,0);
    setpal(90+i,f*i,f*i,0); setpal(111-i,f*i,f*i,0); setpal(110+i,0,0,0);
    setpal(120+i,0,f*i,f*i); setpal(141-i,0,f*i,f*i); setpal(140+i,0,0,0);
    setpal(150+i,f*i,f*i,f*i); setpal(171-i,f*i,f*i,f*i); setpal(170+i,0,0,0);
  end;
  randomize;
  for i:=1 to nofstars do with stars[i] do begin
    xp:=0; yp:=0; col:=0; phase:=0;
    dur:=random(20);
    active:=false;
  end;
  repeat
    retrace; retrace;
    {setpal(0,0,0,30);}
    for i:=1 to nofstars do with stars[i] do begin
      dec(dur);
      if (not active) and (dur<0) then begin
        active:=true; phase:=0; col:=30*random(6);
        xp:=random(315); yp:=random(195);
      end;
    end;
    for i:=1 to nofstars do with stars[i] do
      if active then begin
        for x:=0 to 4 do for y:=0 to 4 do
          if bitmask[byte(phase>10),x,y]>0 then
            mem[vidseg:(yp+y)*320+xp+x]:=bitmask[byte(phase>10),x,y]+col+phase;
        inc(phase);
        if phase=20 then begin active:=false; dur:=random(20); end;
      end;
    setpal(0,0,0,0);
  until keypressed;
  textmode(lastmode);
end.
