(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0216.PAS
  Description: Interesting Flaming Lines Graphic
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

uses crt,gru;

var
  workp:pointer; work:word;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;
  i:word;
  ox,oy:word;

procedure lineto(x,y,where:word;c:byte);
begin
  if(x=ox)and(y=oy)then exit;
  line2(ox,oy,x,y,where,c);
  ox:=x;
  oy:=y;
end;

begin
  ox:=160; oy:=100;
  getmem(workp,64000); work:=seg(workp^);
  randomize;
  setmode($13);
  clear386(vidseg,0);
  clear386(work,0);
  frame:=0;
{  for i:=1 to 199 do setpal(i,i div 4,20+i div 5,10+i div 6);}
{  for i:=1 to 199 do setpal(i,10+i div 4,5+i div 6,i div 7);}
  for i:=1 to 32 do
  begin
    setpal(i,(i shl 1)-1,0,0);
    setpal(i+32,63,(i shl 1)-1,0);
    setpal(i+64,63,63,(i shl 1)-1);
    setpal(i+96,63,63,63);
  end;
  t1:=timer;
  repeat
    inc(frame);
    lineto(succ(random(319)),succ(random(199)),work,succ(random(250)));
    line2(0,199,319,199,work,0);
    smooth(work);
    flip386(work,vidseg);
  until(keypressed)and(readkey=#27);
  t2:=(timer-t1);
  for t1:=0 to 110 do
  begin
    smooth(work);
    flip386(work,vidseg);
  end;
  setmode($03);
  writeln(round((frame*18.2)/t2),' fps.');
end.
