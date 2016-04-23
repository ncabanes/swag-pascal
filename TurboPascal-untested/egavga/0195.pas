{
  Drip revisited - Modifications by Christopher J. Chandra
  Originally coded by Tim Mattison.
  This version works much much faster than the last one.
  I dunno if it is maximally optimized or not.  Speed Demons?? *Grin* }

uses crt;                               {386s needed for clrcrt procs}

const SEGA000:Word=$a000;               {needed for TP v6.0 or older}

var yt:array[0..200] of word;
    timer:longint absolute $0040:$006c;
    tstart,tend:longint;
    xx,yy:word;

{You can use Drip and Drip2 interchangably?; both operates on the same
 speed.  The difference is in the calculation of the pixel position}

procedure Drip;assembler;
asm
   mov es,SEGA000
   mov dx,198                           {for dx:=198 downto 0 do}
@reloop1:
   xor si,si                            {for si:=0 to 319 do}
@reloop2:
   mov bx,dx;shl bx,1;mov di,word ptr[yt+bx];add di,si
   mov al,[ES:DI]                       {al:=getcolor(si,dx}
   mov bx,dx;inc bx;mov cx,200;sub cx,bx;
   shl bx,1;mov di,word ptr[yt+bx];add di,si
@again:                                 {for cx:=dx+1 to 200 do}
   mov [ES:DI],al;add di,320            {putpixel(si,cx,al}
   loop @again
  inc si;cmp si,320;jl @reloop2         {end}
  dec dx;jnz @reloop1;                  {end}
end;

procedure Drip2;assembler;
asm
   mov es,SEGA000
   mov dx,198                           {for dx:=198 downto 0 do}
@reloop11:
   xor si,si                            {for si:=0 to 319 do}
@reloop22:
   mov ax,dx;mov di,ax;shl ax,8;shl di,6;add di,ax;add di,si 
   mov bl,[ES:DI]                       {bl:=getcolor(si,dx}
   mov ax,dx;inc ax;mov cx,200;sub cx,ax
   mov di,ax;shl ax,8;shl di,6;add di,ax;add di,si
@again1:                                {for cx:=dx+1 to 200 do}
   mov [ES:DI],bl;add di,320            {putpixel(si,cx,bl}
   loop @again1
  inc si;cmp si,320;jl @reloop22        {end}
  dec dx;jnz @reloop11;                 {end}
end;

begin
 for xx:=0 to 200 do yt[xx]:=xx*320;    {prepare y table}
 asm mov ax,$13;int 10h                 {init 320x200x256c graphic mode}
  mov es,SEGA000;xor di,di;db $66;mov ax,$3232;dw $3232;mov cx,16000;db $66
  rep stosw end;                        {fill screen w/ some sort of blue}

 for xx:=0 to 255 do                    {set palette}
 begin
  port[$3c8]:=xx;
  port[$3c9]:=xx shr 3;port[$3c9]:=xx shr 2;port[$3c9]:=xx shr 1;
 end;

 for yy:=50 to 199-50 do                {you can replace this w/ whatever}
 for xx:=50 to 320-50 do                {thing that you want to drip}
  mem[$a000:yt[yy]+xx]:=yy and 255 + random(xx shr 2);

 tstart:=timer;                         {begin timer}
 drip2;                                 {apply dripping fx - drip/drip2}
 tend:=timer;                           {stop timer}

 asm mov es,SEGA000;xor di,di;db $66;mov ax,$0000;dw $0000;mov cx,16000;
  db $66;rep stosw                      {fill screen w/ black}
  xor ax,ax;int 16h end;                {get a keystroke}

 textmode(co80);                        {return to textmode 80x25 color}
 writeln(tend-tstart);                  {show time needed in microseconds}
end.

