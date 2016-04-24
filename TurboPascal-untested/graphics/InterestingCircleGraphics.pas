(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0215.PAS
  Description: Interesting Circle Graphics
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

{$n+,e-,g+,x+,r-,q-,s-,a+}
                          { NOTE See the end of document for more .. }

uses crt,gru;
             {NOTE : GRU can be found in GRAPHICS.SWG }

var
  x,y,work:word;
  workp:pointer;
  p1,p2:paltype;

procedure plot3(x,y:word;c:byte);
begin
  plot2((160+x),(100+y),work,c);
end;

function abort:boolean;
begin
  {$b-}
  abort:=false;
  abort:=(keypressed)and(readkey=#27);
end;

begin
  getmem(workp,64000); work:=seg(workp^);
  setmode($13);
  for x:=1 to 255 do
    setpal(x,(x shl 2)+25,(x shl 1)-1,x);
  clear386(work,0);
  repeat
    y:=0;
    repeat
      for x:=0 to 360 do
      begin
        plot3(round(cos(x)*y),round(sin(x)*y),round((y shl 1)+(sqrt(x))));
      end;
      line2(0,199,319,199,work,0);
      smooth(work);
      flip386(work,vidseg);
      inc(y);
    until(y>90)or(keypressed);
  until(abort);
  readkey;
  setmode($03);
end.

{ ----------------------  CIRCLE2 ----------------------- }

{$n+,e-,g+,x+,r-,q-,s-,a+}
uses crt,gru;

var
  ctab,stab:array[0..360]of real;
  x,y,work:word;
  workp:pointer;
  p1,p2:paltype;

procedure plot3(x,y:word;c:byte);
begin
  plot2((160+x),(100+y),work,c);
end;

function abort:boolean;
begin
  {$b-}
  abort:=false;
  abort:=(keypressed)and(readkey=#27);
end;

begin
  for x:=0 to 360 do
  begin
    stab[x]:=(sin(x)*1);
    ctab[x]:=(cos(x)*1);
  end;
  getmem(workp,64000); work:=seg(workp^);
  setmode($13);
  for x:=1 to 255 do
    setpal(x,(x shl 2)+25,(x shl 1)-1,x);
  clear386(work,0);
  repeat
    y:=0;
    repeat
      for x:=0 to 360 do
      begin
        plot3(round(ctab[x]*y),round(stab[x]*y),round((y shl 1)+(sqrt(x))));
      end;
      line2(0,199,319,199,work,0);
      smooth(work);
      flip386(work,vidseg);
      inc(y);
    until(y>90)or(keypressed);
  until(abort);
  setmode($03);
end.

{------------------------------------  CIRCLE3  ------------------- }

{$n+,e-,g+,x+,r-,q-,s-,a+}
uses crt,gru;

var
  scrofs:array[0..199]of word; { Holding screen offsets. }
  ctab,stab:array[0..360]of real;
  x,y,c,work:word;
  workp:pointer;
  p1,p2:paltype;

procedure pload2(const x,y,where:word;const c:byte); assembler;
asm
  cmp clipon,0
  je @@sc
  mov ax,[x]
  cmp ax,cx1
  jb @@exit
  cmp ax,cx2
  ja @@exit
  mov ax,[y]
  cmp ax,cy1
  jb @@exit
  cmp ax,cy2
  ja @@exit
  @@sc: { SkipCheck :-) }
  mov ax,where
  mov es,ax
  mov bx,[y]
  shl bx,1
  mov di,word ptr[scrofs+bx]
  add di,[x]
  mov al,[c]
  add es:[di],al
@@exit:
end;

procedure plot3(x,y:word;c:byte);
var
  c1,c2:byte;
begin
  for c1:=0 to 3 do
    for c2:=0 to 3 do
    begin
{      plot2((160+x)+c1,(100+y)+c2,work,c);}
      pload2((160+x),(100+y),work,c);
    end;
end;

function abort:boolean;
begin
  {$b-}
  abort:=false;
  abort:=(keypressed)and(readkey=#27);
end;

begin
  randomize;
  for x:=0 to 360 do
  begin
    stab[x]:=(sin(x)*1);
    ctab[x]:=(cos(x)*1);
  end;
  for x:=0 to 199 do scrofs[x]:=x*320;
  getmem(workp,64000); work:=seg(workp^);
  setmode($13);
  for x:=1 to 255 do
    setpal(x,(x shl 2)+25,(x shl 1)-1,x);
  clear386(work,0);
  c:=0;
  repeat
    y:=0;
    repeat
      for x:=0 to 360 do
      begin
        plot3(round(ctab[x]*y),round(stab[x]*y),round((y shl 1)+(sqrt(x))));
      end;
      line2(0,199,319,199,work,0);
      inc(c);
      if(c>4)then
      begin
        c:=0;
        smooth(work);
      end;
      flip386(work,vidseg);
      inc(y);
    until(y>90)or(keypressed);
  until(abort);
  setmode($03);
end.
