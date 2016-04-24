(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0214.PAS
  Description: Fire Code VI
  Author: JERE SANISALO
  Date: 05-26-95  23:22
*)

{
This one more fire code from ME... Check this out and comment me... I'd
like to get comments for this (and I might be able to help someone, if
he/she can't get fire code done correctly)...

}
const wavespd = 6;

var ftable : array [1..30,1..60] of byte;
    ycal : array [1..60] of real;
    x,y,i,j : word;

begin
asm mov ax,013h; int 010h; end;
for i:=1 to 15 do
    begin
    port[$3c8]:=i;
    port[$3c9]:=i*4;
    port[$3c9]:=i*4;
    port[$3c9]:=0;
    end;
for i:=1 to 31 do
    begin
    port[$3c8]:=15+i;
    port[$3c9]:=63;
    port[$3c9]:=63-i*2;
    port[$3c9]:=0;
    end;
for i:=1 to 63 do
    begin
    port[$3c9]:=63;
    port[$3c9]:=0;
    port[$3c9]:=0;
    end;
for i:=1 to 30 do
    for j:=1 to 60 do
        ftable[i,j]:=0;
for i:=1 to 60 do
    ycal[i]:=sin(i*pi/30);
j:=1;
repeat
asm mov dx,03dah; @v1: in al,dx; test al,8; je @v1; @v2: in al,dx; test al,8;
jne @v2; end;
for x:=10 to 20 do
    if random(100)<50 then ftable[x,60]:=200 else ftable[x,60]:=0;
for y:=1 to 58 do
    for x:=2 to 28 do
        begin
        ftable[x,y]:=(ftable[x-1,y]+ftable[x,y]+ftable[x+1,y]+ftable[x-1,y+1]
        +ftable[x+1,y+1]+ftable[x-1,y+2]+ftable[x,y+2]+ftable[x+1,y+2]) shr 3;
        end;
inc(j); if j>59 then j:=j-59;
for y:=1 to 59 do
    for x:=1 to 30 do
        begin
        mem[$a000:100+x+y*320]:=ftable[x,y];
        i:=y+j;
        if i>59 then i:=i-59;
        mem[$a000:(100+x+round(ycal[i]*((60-y) div wavespd)))+
                  (117-(y*1 div 3)-(40))*320]:=ftable[x,y];
        end;
until port[$60]=1;
asm mov ax,03h; int 010h; end;
end.

