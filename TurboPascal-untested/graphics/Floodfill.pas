(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0176.PAS
  Description: Floodfill
  Author: CHRISTOPHER CHANDRA
  Date: 05-26-95  23:05
*)


{
Does anybody know how to do gradient floodfilling?
or a fast floodfill routine?

Here is my floodfill routine, not optimized yet ('cause I am so lazy-grin)
If you feel you can optimize this (I am sure some of you can) and have time to
do so, could you post it back so I can get it from this echo (he he he)

Oh well, some of the procedures and functions in here are not included, like
VSwap - to swap 2 integer variable, GetPixel, PutPixel, I am sure you can
figure out how to create those routines.. now...
I am using link list for tracing, here is the type:
}
type ppixel=^pixel;
     pixel=record
            x,y:integer;
            last:pointer
           end;
{
and here is the routine...
}

procedure floodfill(x,y:integer;c:byte);

var dx,dy,ex,ey,f:integer;
    dc,fc:byte;
    up,down:boolean;
    dot:ppixel;

procedure pushdot(px,py:integer);

var pdot:ppixel;

begin
 new(pdot);
 pdot^.last:=dot;
 pdot^.x:=px;
 pdot^.y:=py;
 dot:=pdot
end;

procedure popdot(var px,py:integer);

var pdot:ppixel;

begin
 pdot:=dot^.last;
 px:=dot^.x;
 py:=dot^.y;
 dispose(dot);
 dot:=pdot
end;

procedure scanline(px1,px2,py:integer;c:byte);

var dpx:integer;

begin
 if px2<px1 then vswap(px1,px2);
 asm
  mov ax,vseg
  mov es,ax
  mov ax,py
  mov dx,320
  mul dx
  add ax,vofs
  mov di,ax
  add di,px1
  mov cx,px2
  sub cx,px1
  inc cx
  mov al,c
  repz stosb
 end
end;

begin
 dot:=nil;
 fc:=getpixel(x,y);
 pushdot(x,y);
 if c<>fc then
 repeat
   down:=on;up:=on;
   popdot(ex,ey);
   dx:=ex;dy:=ey;
   repeat
    if ((getpixel(dx,dy+1)=fc) and down and (dy+1<=199)) then
    begin
     pushdot(dx,dy+1);
     down:=off
    end;
    if ((getpixel(dx,dy-1)=fc) and up and (dy-1>=0)) then
    begin
     pushdot(dx,dy-1);
     up:=off
    end;
    if ((getpixel(dx,dy+1)<>fc) and (not down) and (dy+1<=199)) then down:=on;
    if ((getpixel(dx,dy-1)<>fc) and (not up) and (dy-1>=0)) then up:=on;
    dec(dx)
   until ((getpixel(dx,dy)<>fc) or (dx<0));
   scanline(ex,dx+1,dy,c);
   dx:=ex+1;dy:=ey;
   if getpixel(dx,dy)=fc then
   begin
    down:=on;up:=on;
    repeat
     if ((getpixel(dx,dy+1)=fc) and down and (dy+1<=199)) then
     begin
      pushdot(dx,dy+1);
      down:=off
     end;
     if ((getpixel(dx,dy-1)=fc) and up and (dy-1>=0)) then
     begin
      pushdot(dx,dy-1);
      up:=off
     end;
     if ((getpixel(dx,dy+1)<>fc) and (not down) and (dy+1<=199)) then down:=on;
     if ((getpixel(dx,dy-1)<>fc) and (not up) and (dy-1>=0)) then up:=on;
     inc(dx)
    until ((getpixel(dx,dy)<>fc) or (dx>319));
    scanline(ex,dx-1,dy,c)
   end
 until dot=nil;
end;
{

Phew... Is that messy or what, but hey, it works.  This floodfill doesn't need
a boundary value, it will just fill anything (of the same seed color) until it
encounter a different color (for boundary--any color)

I know somebody asked this b4, but I didn't pay too much attention b4, so, the
2nd question... how do you find the closest RGB value again?
}

