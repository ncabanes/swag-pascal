(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0243.PAS
  Description: Re: 256 Colours
  Author: ZIV KATZIR
  Date: 09-04-95  10:44
*)


{
Here is a unit for using a 640*400*256 color mode. The color mapping is exactly
the same as in the normal mode 13h, anyway procedures for setting the palette
are also included (in assembly).
The basic idea of working in this graphic mode is that for segments (pages) of
VGA screen are addressed through the one segment ($a0000..$affff). This can be
done by setting some of the vga ports.
Btw this mode can also be used for generating four 320*200 screens and
scrolling through them freely.

I recommend reading the asm parts  with some kind of document about the vga
so u will be able to see which port do what.
Ziv.
------------------------------ Cut Here --------------------------------------
}
unit chained4;

interface

uses crt,dos;

type
    dotptr=^dot;
    dot=record
              x,y:integer;
    end;
    color=record
                red,green,blue:byte;
    end;
    point=record
                x,y:integer;
                color:byte;
    end;
var
   xsize:integer;
procedure init(mode:byte);
procedure init_chained;
procedure clear_chained;
procedure pixel(x,y:word; color:byte);
procedure line(x0,y0,x1,y1,color:integer);
procedure box(x1,y1,x2,y2,col:integer);
procedure draw_poly(start_point:dotptr; num,col:integer);
procedure circle(xcenter,ycenter,rad,color:integer);
procedure setpall(segm,off:word);
procedure getpall(segm,off:word);


implementation

procedure init(mode:byte); assembler;
asm
   sti
   mov ah,0
   mov al,mode
   int $10
end;
procedure init_chained; assembler;
asm
   mov   ax,5ch         { Set normal mode 13H }
   int   10h

   mov   dx,3CEh          { Memory division }
   mov   al,5             { Disable bit 4 of }
   out   dx,al            { graphic mode register }
   inc   dx               { in graphics controller }
   in    al,dx
   and   al,11111011b
   out   dx,al
   dec   dx

   mov   al,6             { And change bit 1 }
   out   dx,al            { in the miscellaneous }
   inc   dx               { register }
   in    al,dx
   and   al,11111101b
   out   dx,al


   mov   dx,3C4h          { Modify memory mode register in }
   mov   al,4             { sequencer controlller so no further }
   out   dx,al            { address division follows in }
   inc   dx               { bitplanes, and set the bitplane }
   in    al,dx            { currently in the }
   and   al,11110111b     { bit mask register }
   or    al,4
   out   dx,al


   mov   dx,3D4h          { Set double word mode using bit 6 }
   mov   al,14h           { in underline register of }
   out   dx,al            { CRT controller }
   inc   dx
   in    al,dx
   and   al,10111111b
   out   dx,al
   dec   dx


   mov   al,17h           { Using bit 6 in mode control reg. }
   out   dx,al            { of CRT controller, change }
   inc   dx               { from word mode to byte mode }
   in    al,dx
   or    al,01000000b
   out   dx,al
end;

procedure clear_chained; assembler;
asm
   mov dx,03c4h      { clear all 256k of video memory                        }
   mov ax,020fh
   out dx,ax
   mov ax,0a000h
   mov es,ax
   xor di,di
   xor ax,ax            { zero all planes                                    }
   mov cx,32768
   cld
   rep stosw
end;
procedure pixel(x,y:word; color:byte); assembler;
asm
   mov ax,y
   xor bx,bx
   mov bx,xsize
   shl bx,1
   mul bx
   mov bx,ax
   mov ax,x
   mov cx,ax
   shr ax,2
   add bx,ax
   and cl,00000011b
   mov dx,03c4h
   mov al,2
   out dx,al
   inc dx
   mov al,1
   shl al,cl
   out dx,al
   mov ax,0a000h
   mov es,ax
   mov al,color
   mov es:[bx],al
end;
procedure line(x0,y0,x1,y1,color:integer);
var
   px,py,x,y,dx,dy,d,ince,temp,incne:integer;
   op,xminus,yminus:boolean;
begin
     pixel(x0,y0,color);
     dy:=y0-y1;
     dx:=x1-x0;
     xminus:=dx<0;
     yminus:=dy<0;
     dx:=abs(dx);
     dy:=abs(dy);
     op:=dx<dy;
     if op then
     begin
          temp:=dy;
          dy:=dx;
          dx:=temp;
     end;
     d:=2*dy-dx;
     ince:=2*dy;
     incne:=2*(dy-dx);
     x:=0;
     y:=0;
     while x<dx do
     begin
          if d<=0 then
          begin
               d:=d+ince;
               x:=x+1;
          end else
          begin
               d:=d+incne;
               x:=x+1;
               y:=y+1;
          end;
          px:=x;
          py:=y;
          if op then
          begin
               temp:=px;
               px:=py;
               py:=temp;
          end;
          if xminus then px:=x0-px else px:=x0+px;
          if yminus then py:=y0+py else py:=y0-py;
          pixel(px,py,color);
     end;
end;

procedure box(x1,y1,x2,y2,col:integer);
begin
     line(x1,y1,x2,y1,col);
     line(x1,y2,x2,y2,col);
     line(x1,y1,x1,y2,col);
     line(x2,y1,x2,y2,col);
end;
procedure draw_poly(start_point:dotptr; num,col:integer);
var
   count:integer;
   first,next:dotptr;
begin
     first:=start_point;
     for count:=1 to num -1 do
     begin
          next:=ptr(seg(first^),ofs(first^)+4);
          line(first^.x,first^.y,next^.x,next^.y,col);
          first:=next;
     end;
     line(next^.x,next^.y,start_point^.x,start_point^.y,col);
end;
procedure circlepoints(xcenter,ycenter,x,y,color:integer);
var
   count:integer;
begin
     pixel(xcenter+x,ycenter+y,color);
     pixel(xcenter+y,ycenter+x,color);
     pixel(xcenter+y,ycenter-x,color);
     pixel(xcenter+x,ycenter-y,color);
     pixel(xcenter-x,ycenter-y,color);
     pixel(xcenter-y,ycenter-x,color);
     pixel(xcenter-y,ycenter+x,color);
     pixel(xcenter-x,ycenter+y,color);
end;
procedure circle(xcenter,ycenter,rad,color:integer);
var
   x,y:integer;
   d:real;
begin
     x:=0;
     y:=rad;
     d:=5/4-rad div 2;
     circlepoints(xcenter,ycenter,x,y,color);
     while x<=y do
     begin
          if d<0 then
          begin
               d:=d+2*x+3;
               x:=x+1;
          end else
          begin
               d:=d+2*(x-y)+5;
               x:=x+1;
               y:=y-1;
          end;
          circlepoints(xcenter,ycenter,x,y,color);
     end;
end;

procedure setpall(segm,off:word);
begin
     asm
        push ds
        push di
        push ax
        push cx
        push dx
        mov ds,segm
        mov di,off
        mov cx,768
        mov dx,3c8h
        xor al,al
        out dx,al
        mov dx,3c9h
        @xx:
           mov al,ds:[di]
           out dx,al
           inc di
        loop @xx
        pop dx
        pop cx
        pop ax
        pop di
        pop ds
     end;
end;

procedure getpall(segm,off:word);
begin
     asm
        push ds
        push di
        push ax
        push cx
        push dx
        mov ds,segm
        mov di,off
        mov cx,768
        mov dx,3c7h
        xor al,al
        out dx,al
        mov dx,3c9h
        @xx:
           in al,dx
           mov ds:[di],al
           inc di
        loop @xx
        pop dx
        pop cx
        pop ax
        pop di
        pop ds
     end;
end;
begin
     xsize:=80;
end.

