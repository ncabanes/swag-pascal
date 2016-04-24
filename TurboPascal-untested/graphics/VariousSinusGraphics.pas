(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0219.PAS
  Description: Various SINUS Graphics
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

{$g+}  { see end of document for more .. }
uses
  crt,gru;  { GRU in GRAPHICS.SWG }
const
  add1=1;
  add2=-1;
  add3=-1;
var
  ptab,ctab:array[0..199] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  frame:=0;
  for i:=0 to 255 do begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+160;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var x,y:word;
begin
  t1:=timer;
  repeat
    move(ctab,ptab,sizeof(ctab));
    for i:=0 to 199 do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      hline2(0,ctab[i],i,work,ctab[i]-59);
      hline2(ctab[i],320,i,work,not (ctab[i]-15));
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.

{---------------------------  SIN2 -------------------- }

{$g+}
uses
  crt,gru;
const
  add1=1;
  add2=-1;
  add3=-1;
var
  ptab,ctab:array[0..319] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  frame:=0;
  for i:=0 to 255 do
  begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+109;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var x,y:word;
begin
  t1:=timer;
  repeat
    move(ctab,ptab,sizeof(ctab));
    for i:=0 to 319 do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      vline2(i,0,ctab[i],work,ctab[i]);
      vline2(i,ctab[i],200,work,not (ctab[i]+40));
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln('SiNUS iNTRO ][ CODED BY Z00NE/MARCHERSOFT');
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.

{ ------------------ SIN3 ---------------------- }

{$g+}
uses
  crt,gru;
const
  add1=1;
  add2=-1;
  add3=-1;
var
  ptab,ctab:array[0..319] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  frame:=0;
  for i:=0 to 255 do begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+109;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var x,y:word;
begin
  t1:=timer;
  repeat
    move(ctab,ptab,sizeof(ctab));
    for i:=0 to 319 do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      vline2(i,0,ctab[i],work,ctab[i]);
      vline2(i,ctab[i],200,work,not (ctab[i]+40));
      smooth1(i-1,ctab[i]-1,work);
      smooth1(i-1,ctab[i],work);
      smooth1(i-1,ctab[i]-1,work);
      smooth1(i+1,ctab[i]+1,work);
      smooth1(i+1,ctab[i],work);
      smooth1(i,ctab[i]+1,work);
      smooth1(i-1,ctab[i]+1,work);
      smooth1(i+1,ctab[i]-1,work);
      smooth1(i,ctab[i],work);
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln('SiNUS iNTRO ]I[ CODED BY Z00NE/MARCHERSOFT');
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.

{ ------------------------  SIN 4 -------------------- }
{$g+,r-,x-,o-,s-,q-,d-,l-,y-,a+,e-,n-,p-,t-,v-,y-}
uses
  crt,gru;
const
  add1=1;
  add2=-1;
  add3=-1;
  sofs=75;
  samp=75;
  slen=255;
  sprpic:array[0..15,0..15]of byte=(
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
    (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
    (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
    (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
    (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
    (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
    (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
    (1,1,1,1,2,2,3,4,4,3,2,2,1,1,1,1),
    (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
    (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
    (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
    (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
    (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0),
    (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
    (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));
type
  sinarray=array[0..slen]of word;
var
  stab:sinarray; { Used to move shade bob. }
  ptab,ctab:array[0..319] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  for i:=0 to slen do stab[i]:=round(sin(i*4*pi/slen)*samp)+sofs;
  for i:=0 to 255 do
  begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+109;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var
  c,x,y:word;
  i,j:byte;
begin
  t1:=timer;
  i:=0;
  j:=25;
  c:=0;
  clear386(work,0);
  repeat
    if(c>4)then
    begin
      c:=0;
      smooth(work);
      line2(160,100,x,y,work,i);
    end;
    x:=2*stab[i];
    y:=stab[j];
    inc(i);
    inc(j);
    drawsprite(x,y,work,16,16,0,sprpic);
    line2(0,0,319,0,work,0);
    line2(0,0,0,199,work,0);
    line2(0,199,319,199,work,0);
    line2(319,199,319,0,work,0);
    flip386(work,vidseg);
    inc(c);
  until(keypressed);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln('SiNUS iNTRO iV CODED BY Z00NE/MARCHERSOFT');
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.

{ ----------------------------  SIN 5 ---------------------- }
{$g+}
uses
  crt,gru;
const
  add1=1;
  add2=-1;
  add3=-1;
var
  ptab,ctab:array[0..319] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  frame:=0;
  for i:=0 to 255 do
  begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+109;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var x,y:word;
begin
  t1:=timer;
  repeat
    move(ctab,ptab,sizeof(ctab));
    for i:=0 to 319 do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      vline2(i,0,200,work,ctab[i]);
      vline2(i,ctab[i]-5,ctab[i]+5,work,not(ctab[i]+40));
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln('SiNUS iNTRO V CODED BY Z00NE/MARCHERSOFT');
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.
{ ---------------------  SIN 6   --------------------- }


{$g+,d-,l-,y-,n-,e-,r-,s-,q-,t-,v-,x-}
uses gru;
const
  add1=1;
  add2=-1;
  add3=-1;
var
  ptab,ctab:array[0..199] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

function readkey:char; assembler;
asm
  xor ah,ah
  int 16h
end;

function keypressed:boolean; assembler;
asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz @1
  inc ax
  @1:
end;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure init;
begin
  virtup;
  frame:=0;
  for i:=0 to 255 do begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+160;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure waves;
var x,y:word;
begin
  t1:=timer;
  repeat
    move(ctab,ptab,sizeof(ctab));
    for i:=0 to 44 do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      hline2(0,ctab[i],i,work,ctab[i]-59);
      hline2(ctab[i],320,i,work,not (ctab[i]-15));
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    for i:=0 to 2 do
      smooth2(work,320*44);
    flip386(work,vidseg);
    inc(frame);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
end;

procedure main;
begin
  init;
  setmode($13);
  scanlines(8);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  waves;
  setmode($03);
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.

