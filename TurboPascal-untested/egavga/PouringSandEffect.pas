(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0224.PAS
  Description: Pouring Sand Effect
  Author: MARCIN BORKOWSKI
  Date: 05-26-95  23:27
*)

{
{ Pouring sand simulator - by Marcin Borkowski 2:480/25.
  VGA and patience required. Program simulates sand poured
  from some height on a flat surface. There are different
  grain densities and different grain colors - denser grains
  are darker. I saw something similar this year during winter
  vacation done from tho pieces of glass, water and sand - this
  program tries to simulate physical effects taking place in
  a real system. Denser grains falls faster and they form flatter
  slopes. ESC ends simulation. }

const
  maxgrains = 199;

type
  data   = (x,y,c);

var
  sand   : array[0..maxgrains,x..c]of integer;
  bottom : array[0..639,0..1]of integer;
  grains,source : integer;

procedure movedown(i : integer);
var
  moved : boolean;
  j : integer;

  procedure totheleft;
  var
    j : integer;
  begin
    for j:=1 to sand[i,c] do
      if (sand[i,y]>bottom[sand[i,x]-j,0]+1) and (sand[i,x]>8) then
      begin
        dec(sand[i,x],j);
        sand[i,y]:=bottom[sand[i,x],0]+1;
        moved:=true;
        EXIT
      end;
  end;

  procedure totheright;
  var
    j : integer;
  begin
    for j:=1 to sand[i,c] do
      if (sand[i,y]>bottom[sand[i,x]+j,0]+1) and (sand[i,x]<632)  then
      begin
        inc(sand[i,x],j);
        sand[i,y]:=bottom[sand[i,x],0]+1;  {}
        moved:=true;
        EXIT
      end;
  end;

begin
  moved:=false;
  if random(2)<>0 then
  begin
    totheleft;
    if not moved then totheright;
  end
  else
  begin
    totheright;
    if not moved then totheleft;
  end;
  if moved then movedown(i)
end;

procedure pour;
var
  i : integer;
  addr : word;
  dummy : byte;
  px,py,pc : integer;
begin
  for i:=0 to grains do
  begin
    dec(sand[i,y],sand[i,c]);
    if sand[i,y] shr 4<=bottom[sand[i,x],0] then
    begin
      sand[i,y]:=bottom[sand[i,x],0]+1;
      movedown(i);
      px:=sand[i,x];
      py:=sand[i,y];
      pc:=sand[i,c];
      bottom[px,0]:=py;
      bottom[px,1]:=pc;
      Port[$3CE]:=08;
      Port[$3CF]:=$80 shr (px and 7);   { Bit Mask }
      addr:=80*(480-py)+px shr 3;
      dummy:=mem[$A000:addr];           { load latches }
      mem[$A000:addr]:=Lo(17-pc shl 1); { PutPixel - write mode #2 }
      move(sand[grains],sand[i],6);
      dec(grains);
    end;
  end;
  while grains<maxgrains do
  begin
    inc(grains);
    sand[grains,x]:=source;
    sand[grains,y]:=16*400;
    sand[grains,c]:=1+random(8);
  end;
end;

procedure colors16;
var
  i : integer;
begin
  Port[$3C8]:=0;
  for i:=0 to 15 do
  begin
    Port[$3C9]:=3+4*i;
    Port[$3C9]:=3+4*i;
    Port[$3C9]:=3+4*i;
    port[$3C0]:=i;
    port[$3C0]:=i;
  end;
  port[$3C0]:=$30;
end;

begin
  asm mov ax,12h; int 10h end;
  randomize;
  colors16;
  Port[$3C4]:=02;  Port[$3C5]:=$0F;
  Port[$3CE]:=05;  Port[$3CF]:=(Port[$3CF] and $FD) or 2;
  fillchar(sand,sizeof(sand),#0);
  fillchar(bottom,sizeof(bottom),#0);
  grains:=0;
  source:=30+random(600);
  sand[grains,x]:=source;
  sand[grains,y]:=16*400;
  sand[grains,c]:=1;
  repeat
    pour;
    if random(10000)>9997 then source:=30+random(600)
  until port[$60]=1;
  asm mov ax,03h; int 10h end;
end.

