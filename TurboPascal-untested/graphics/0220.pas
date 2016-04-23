{$g+,x-,o-,q-,r-,s-,d-,l-,y-,a+,n-,e-,p-,t-,v-,y-}
uses gru;
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
  ctab:array[0..319] of byte;
  stab1,stab2,stab3:array[0..255] of byte;
  i,i1,i2,i3:word;
  workp:pointer;
  work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;
  pal1,pal2:paltype;

function keypressed:boolean; assembler;
asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz @1
  inc ax
  @1:
end;

function readkey:char; assembler;
asm
  xor ah,ah
  int 16h
end;

procedure virtup;
begin
  getmem(workp,64000);
  work:=seg(workp^);
  clear386(work,0);
end;

procedure virtdn;
begin
  work:=0;
  freemem(workp,64000);
end;

procedure calcsinus;
begin
  for i:=0 to slen do stab[i]:=round(sin(i*4*pi/slen)*samp)+sofs;
  for i:=0 to 255 do begin
    stab1[i]:=round(sin(i*2*pi/255)*50)+109;
    stab2[i]:=round(cos(i*4*pi/255)*25);
    stab3[i]:=round(sin(i*4*pi/255)*25);
  end;
  fillchar(ctab,sizeof(ctab),0);
  i1:=0; i2:=25; i3:=100;
end;

procedure init;
begin
  virtup;
  calcsinus;
  frame:=0;
end;

procedure volplot(x,y,where:word;c:byte);
begin
  plot2(x,y,where,c);
  plot2(x+1,y,where,c+1);
  plot2(x,y+1,where,c+2);
  plot2(x+1,y+1,where,c+3);
end;

procedure volsmoth(x,y,where:word);
begin
  smooth1(x,y,where);
  smooth1(x+1,y,where);
  smooth1(x,y+1,where);
  smooth1(x+1,y+1,where);
end;

function abort:boolean;
begin
  abort:=(keypressed)and(readkey=#27);
end;

procedure waves;
var
  x,y,s,e,loops:word;
  done,dir:boolean;
begin
  s:=159;
  e:=161;
  done:=false;
  repeat
    clear386(work,0);
    for i:=s to e do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      volplot(i,ctab[i],work,ctab[i]);
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
    if(frame mod 3)=0 then
    begin
      if(s>1)then dec(s);
      if(e<318)then inc(e);
    end;
    inc(frame);
    if(s<=1)and(e>=318)then done:=true;
  until(done)or(abort);
  done:=false;
  s:=0;
  repeat
    clear386(work,0);
    done:=true;
    for i:=0 to 319 do
    begin
      if(ctab[i]>0)then done:=false;
      plot2(i,ctab[i],work,ctab[i]);
      smooth1(i-1,ctab[i]-1,work);
      smooth1(i-1,ctab[i],work);
      smooth1(i-1,ctab[i]-1,work);
      smooth1(i+1,ctab[i]+1,work);
      smooth1(i+1,ctab[i],work);
      smooth1(i,ctab[i]+1,work);
      smooth1(i-1,ctab[i]+1,work);
      smooth1(i+1,ctab[i]-1,work);
      smooth1(i,ctab[i],work);
      if(ctab[i]>0)then dec(ctab[i]);
    end;
    inc(frame);
    flip386(work,vidseg);
  until(done)or(abort);
  done:=false;
  s:=159; e:=161;
  repeat
    clear386(work,0);
    for i:=s to e do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      vline2(i,0,ctab[i],work,ctab[i]);
      vline2(i,ctab[i],199,work,not(ctab[i]+40));
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
    flip386(work,vidseg);
    if(frame mod 3)=0 then
    begin
      if(s>1)then dec(s);
      if(e<318)then inc(e);
    end;
    inc(frame);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    if(s<=1)and(e>=318)then done:=true;
  until(done)or(abort);
  done:=false;
  s:=99; e:=101;
  repeat
    clear386(work,0);
    for i:=s to e do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      hline2(0,ctab[i]+99,i,work,ctab[i]);
      hline2(ctab[i]+99,319,i,work,not(ctab[i]+40));
    end;
    for i:=0 to 319 do
    begin
      smooth1(i,s,work);
      smooth1(i,e,work);
      smooth1(i,s+1,work);
      smooth1(i,e-1,work);
    end;
    flip386(work,vidseg);
    if(frame mod 3)=0 then
    begin
      if(s>1)then dec(s);
      if(e<198)then inc(e);
    end;
    inc(frame);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    if(s<=1)and(e>=198)then done:=true;
  until(done)or(abort);
  done:=false;
  loops:=0;
  i:=0;
  repeat
    smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(i);
    done:=(i>=299);
  until(done)or(abort);
  done:=false;
  dir:=true;
  i:=0;
  clear386(work,0);
  repeat
    ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
    volplot(i,ctab[i]-5,work,ctab[i]);
    if(dir)then inc(i)else dec(i);
    if(i>=318)or(i<=0)then dir:=not(dir);
    smooth(work);
    flip386(work,vidseg);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    done:=(loops>=990);
    inc(frame);
    inc(loops);
  until(done)or(abort);
  done:=false;
  dir:=true;
  i:=0;
  loops:=0;
  repeat
    ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
    line2(0,0,i,ctab[i],work,ctab[i]);
    smooth(work);
    if(dir)then inc(i)else dec(i);
    if(i>=318)or(i<=0)then dir:=not(dir);
    flip386(work,vidseg);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    done:=(loops>=960);
    inc(frame);
    inc(loops);
  until(done)or(abort);
  done:=false;
  i:=0;
  repeat
    smooth(work);
    flip386(work,vidseg);
    inc(frame);
    done:=(i>=230);
    inc(i);
  until(done)or(abort);
end;

procedure bobs;
var
  loop,cnt:longint;
  x,y,x2,y2,x3,y3:integer;
  i,j,i2,j2,i3,j3:byte;
  dir,done:boolean;
begin
  getvgapal(pal1);
  for i:=1 to 255 do
  begin
    with pal2[i]do
    begin
      r:=(i shl 2)+25;
      g:=(i shl 1)-1;
      b:=i;
    end;
  end;
  f2black(pal1);
  clear386(work,0);
  i:=0;
  j:=25;
  for cnt:=0 to 199 do
  begin
    x:=2*stab[i];
    y:=stab[j];
    inc(i);
    inc(j);
    drawsprite(x,y,work,16,16,0,sprpic);
  end;
  flip386(work,vidseg);
  ffblack(pal2);
  i:=0;
  j:=25;
  dir:=false;
  done:=false;
  loop:=0;
  repeat
    x:=2*stab[i];
    y:=stab[j];
    inc(i);
    inc(j);
    drawsprite(x,y,work,16,16,0,sprpic);
    dir:=not(dir);
    if(dir)then smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=500);
  until(abort)or(done);
  { End of the first comet bob. }
  i:=0;   j:=25;
  i2:=50; j2:=70;
  dir:=false;
  done:=false;
  loop:=0;
  clear386(work,0);
  repeat
    x:=2*stab[i];   y:=stab[j];
    x2:=2*stab[i2]; y2:=stab[j2];
    inc(i);  inc(j);
    inc(i2); inc(j2);
    drawsprite(x,y,work,16,16,0,sprpic);
    drawsprite(x2,y2,work,16,16,0,sprpic);
    dir:=not(dir);
    if(dir)then smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=500);
  until(abort)or(done);
  { end of the second comet bob }
  i:=0;   j:=25;
  i2:=50; j2:=60;
  i3:=50; j3:=0;
  dir:=false;
  done:=false;
  loop:=0;
  clear386(work,0);
  repeat
    x:=2*stab[i];   y:=stab[j];
    x2:=2*stab[i2]; y2:=stab[j2];
    x3:=2*stab[i3]; y3:=stab[j3];
    inc(i);  inc(j);
    inc(i2); dec(j2);
    dec(i3); inc(j3);
    drawsprite(x,y,work,16,16,0,sprpic);
    drawsprite(x2,y2,work,16,16,0,sprpic);
    drawsprite(x3,y3,work,16,16,0,sprpic);
    dir:=not(dir);
    if(dir)then smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=500);
  until(abort)or(done);
  { end of the third comet bob. This one have THREE bobs! }
  i:=0;   j:=25;
  dir:=false;
  done:=false;
  loop:=0;
  clear386(work,0);
  repeat
    x:=2*stab[i];   y:=stab[j];
    inc(i);  inc(j);
    line2(0,0,x+8,y+8,work,2);
    line2(319,0,x+8,y+8,work,4);
    line2(0,199,x+8,y+8,work,2);
    line2(319,199,x+8,y+8,work,4);
    drawsprite(x,y,work,16,16,0,sprpic);
    dir:=not(dir);
    if(dir)then smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=800);
  until(abort)or(done);
  { End of the tracking fire bob. }
  getvgapal(pal1);
  f2black(pal1);
  { Fade to black }
end;

procedure bobwaves;
{
  This is gonna be a SHORT "chapter"!
  And it's not going to cover ONLY sinus-bobs.
}
const
  maxtrail:word=3;
var
  c,x,y,x2,y2,x3,y3:integer;
  loop,cnt:longint;
  dir,done:boolean;
  i,j:byte;

begin
  for i:=1 to 255 do
  begin
    with pal1[i]do
    begin
      r:=i*3;
      g:=i*3;
      b:=i*3;
    end;
  end;
  clear386(work,0);
  clear386(vidseg,0);
  setvgapal(pal1);
  done:=false;
  loop:=0;
  repeat
    clear386(work,0);
    for i:=0 to (184 shr 1)do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      x:=ctab[i]+90;
      y:=(i);
      drawsprite(x,y shl 1,work,16,16,0,sprpic);
    end;
    for i:=0 to (303 shr 1) do
    begin
      ctab[i]:=stab1[(i+i1) mod 255]+stab2[(i+i2) mod 255]+stab3[(i+i3) mod 255];
      x:=i;
      y:=ctab[i];
      drawsprite(x shl 1,y,work,16,16,0,sprpic);
    end;
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=1000);
  until(done)or(abort);
  { End of the first double-sinus-bob. }
  clear386(work,0);
  clear386(vidseg,0);
  done:=false;
  loop:=0;
  repeat
    clear386(work,0);
    for c:=0 to 319 do
      ctab[c]:=stab1[(c+i1) mod 255]+stab2[(c+i2) mod 255]+stab3[(c+i3) mod 255];
    line2(0,ctab[0],319,ctab[319],work,10);
    line2(ctab[0]+30,0,ctab[199],199,work,10);
    drawsprite(ctab[160],ctab[99],work,16,16,0,sprpic);
    drawsprite(ctab[99],ctab[160],work,16,16,0,sprpic);
    drawsprite(ctab[1],ctab[200],work,16,16,0,sprpic);
    drawsprite(ctab[200],ctab[1],work,16,16,0,sprpic);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=2000);
  until(done)or(abort);
  { End of the first sinus-line bob show. }
  clear386(work,0);
  clear386(vidseg,0);
  done:=false;
  loop:=0;
  repeat
    for c:=0 to 319 do
      ctab[c]:=stab1[(c+i1) mod 255]+stab2[(c+i2) mod 255]+stab3[(c+i3) mod 255];
    line2(0,ctab[0],319,ctab[319],work,10);
    line2(ctab[0]+30,0,ctab[199],199,work,10);
    drawsprite(ctab[160],ctab[99],work,16,16,0,sprpic);
    drawsprite(ctab[99],ctab[160],work,16,16,0,sprpic);
    drawsprite(ctab[1],ctab[200],work,16,16,0,sprpic);
    drawsprite(ctab[200],ctab[1],work,16,16,0,sprpic);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    smooth(work);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=1000);
  until(done)or(abort);
  { End of the smoothed sinus-line bob show. }
  getvgapal(pal1);
  for i:=1 to 255 do
  begin
    with pal2[i]do
    begin
      r:=(i shl 2)+25;
      g:=(i shl 1)-1;
      b:=i;
    end;
  end;
  fadefrompaltopal(pal1,pal2);
  done:=false;
  loop:=0;
  repeat
    for c:=0 to 319 do
      ctab[c]:=stab1[(c+i1) mod 255]+stab2[(c+i2) mod 255]+stab3[(c+i3) mod 255];
    line2(0,ctab[0],319,ctab[319],work,5);
    line2(ctab[0]+30,0,ctab[199],199,work,5);
    drawsprite(ctab[160],ctab[99],work,16,16,0,sprpic);
    drawsprite(ctab[99],ctab[160],work,16,16,0,sprpic);
    drawsprite(ctab[1],ctab[200],work,16,16,0,sprpic);
    drawsprite(ctab[200],ctab[1],work,16,16,0,sprpic);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    smooth(work);
    line2(0,199,319,199,work,0);
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=1000);
  until(done)or(abort);
  { End of the smoothed sinus-line bob with fire colors show. }
  done:=false;
  loop:=0;
  cnt:=0;
  getvgapal(pal1);
  for i:=1 to 255 do
  begin
    with pal2[i]do
    begin
      r:=i;
      g:=sqr(i);
      b:=(i shl 2)+25;
    end;
  end;
  fadefrompaltopal(pal1,pal2);
  clear386(work,0);
  clear386(vidseg,0);
  repeat
    for c:=0 to 319 do
      ctab[c]:=stab1[(c+i1) mod 255]+stab2[(c+i2) mod 255]+stab3[(c+i3) mod 255];
    line2(0,ctab[0],319,ctab[319],work,(i mod 3)+5);
    line2(ctab[0]+30,0,ctab[199],199,work,(i mod 3)+4);
    line2(0,199,319,199,work,0);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    inc(cnt);
    if(cnt>=maxtrail)then
    begin
      smooth(work);
      cnt:=0;
    end;
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=1500);
  until(done)or(abort);
  { End of the traily line. }
  i:=0;
  j:=25;
  c:=0;
  loop:=0;
  done:=false;
  clear386(work,0);
  repeat
    if(c>4)then
    begin
      c:=0;
      smooth(work);
      line2(160,100,x,y,work,8);
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
    done:=(loop>1500);
    inc(c);
    inc(loop);
  until(done)or(abort);
  { Okay, maybe not exactly a bob-line, but it still rock! ;-) }
  clear386(work,0);
  clear386(vidseg,0);
  done:=false;
  dir:=false;
  loop:=0;
  repeat
    clear386(work,0);
    for c:=0 to 319 do
      ctab[c]:=stab1[(c+i1) mod 255]+stab2[(c+i2) mod 255]+stab3[(c+i3) mod 255];
    line2(0,ctab[0],319,ctab[319],work,3);
    line2(ctab[0]+30,0,ctab[199],199,work,3);
    line2(0,ctab[319],319,ctab[0],work,30);
    line2(ctab[199],0,ctab[0],199,work,30);
    line2(0,ctab[160],319,ctab[99],work,50);
    line2(ctab[99],0,ctab[160],199,work,50);
    drawsprite(ctab[160],ctab[99],work,16,16,0,sprpic);
    drawsprite(ctab[99],ctab[160],work,16,16,0,sprpic);
    drawsprite(ctab[1],ctab[200],work,16,16,0,sprpic);
    drawsprite(ctab[200],ctab[1],work,16,16,0,sprpic);
    drawsprite(ctab[100],ctab[10],work,16,16,0,sprpic);
    drawsprite(ctab[10],ctab[199],work,16,16,0,sprpic);
    drawsprite(ctab[300],ctab[50],work,16,16,0,sprpic);
    drawsprite(ctab[50],ctab[100],work,16,16,0,sprpic);
    i1:=(i1+add1) mod 255; i2:=(i2+add2) mod 255; i3:=(i3+add3) mod 255;
    flip386(work,vidseg);
    inc(frame);
    inc(loop);
    done:=(loop>=2300);
  until(done)or(abort);
  { End of retarded crosses with EIGHT bobs show. }
end;

procedure main;
begin
  init;
  setmode($13);
  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);
  t1:=timer;
  waves;
  bobs;
  bobwaves;
  t2:=(timer-t1);
  setmode($03);
  writeln('SiNUS "DEMO". Whatever. Coded by Sune Marcher');
  writeln('You saw ',frame,' of the demos frames.');
  writeln('It took ',(t2/18.2):0:1,' seconds.');
  writeln('  (',((t2/18.2)/60):0:1,' minutes).');
  writeln(round((frame*18.2)/t2),' fps.');
  virtdn;
end;

begin
  main;
end.