(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0013.PAS
  Description: Mouse Cursor Editor
  Author: TORSTEN PINKERT
  Date: 01-27-94  12:15
*)

{
Now here's the source for the Mouse-Cursor-Editor

}
PROGRAM Mouse_Edit;
uses Crt;
type
 Masktype = array[1..16] of word;
var
 Cursor :  Array[1..2] of Masktype;
 screenmask,Cursormask : Array [1..16,1..16] of Char;
 x,y,oldx,oldy : Byte;
 Fenster : Boolean; {False=Links,True=Rechts}
 i,j : Byte;
 c : Char;
 wert : word;
  dest : text;
  s : string;

procedure Init;
begin
  TextMode (co40);
 ClrScr;
 for i:=1 to 16 do
  for j:=1 to 16 do
  begin
   Screenmask[i,j]:='*';
   GoToXY(i+2,j);
   Write (Screenmask[i,j]);
   CursorMask[i,j]:='.';
   GoToXY (i+22,j);
   Write (CursorMask[i,j]);
  end;
 x:=8; oldx:=8; y:=8; oldy:=8;
 Fenster := false;
 GotoXY(20,20); write('X=',x:3,'  Y=',y:3);
 GotoXY (x+2,y);
end;
procedure Changemask;
var
 t : byte;
begin
 t:=x; x:=oldx; oldx:=t;
 t:=y; y:=oldy; oldy:=t;
 fenster := fenster xor true;
 GotoXY(20,20); write('X=',x:3,'  Y=',y:3);
end;
begin
 init;
 repeat
  c:=readkey;
  if c=#9 then
   ChangeMask
  else if c=#32 then
   if fenster then begin
    if cursormask[x,y]='.' then
     cursormask[x,y]:='*'
    else
     cursormask[x,y]:='.';
    write(cursormask[x,y]);
    GotoXY(wherex-1,wherey);
   end else begin
    if screenmask[x,y]='.' then
     screenmask[x,y]:='*'
    else
     screenmask[x,y]:='.';
    write(screenmask[x,y]);
    GotoXY(wherex-1,wherey)
  end else if c=#0 then begin
   c:=readkey;
   case c of
    #72 : if y > 1 then
        dec(y);
    #80 : if y < 16 then
        inc(y);
    #77 : if x<16 then
        inc(x);
    #75 : if x > 1 then
        dec(x);
   end;
   GotoXY(20,20); write('X=',x:3,'  Y=',y:3);
  end;
  if fenster then
   GotoXY(x+22,y)
  else
   GotoXY(x+2,y);
 until c=#27;
 for i:=1 to 16 do begin
  wert:=0;
  for j:=1 to 16 do
   if screenmask[j,i]='*' then
    inc(wert,1 shl (16-j));
  Cursor[1,i]:=wert;
 end;
 for i:=1 to 16 do begin
  wert:=0;
  for j:=1 to 16 do
   if cursormask[j,i]='*' then
    inc(wert,1 shl (16-j));
  Cursor[2,i]:=wert;
 end;
  assign(dest,'pfeil.dat');
  rewrite(dest);
  writeln (dest,'const');
  write (dest,#7,'screenmask : masktype = (');
  for i:=1 to 16 do begin
   str(cursor[1,i],s);
   write(dest,s);
    if i<16 then
     write(dest,',');
  end;
  writeln(dest,');');
  write (dest,#7,'cursormask : masktype = (');
  for i:=1 to 16 do begin
   str(cursor[2,i],s);
   write(dest,s);
    if i<16 then
     write(dest,',');
  end;
  writeln(dest,');');
 close(dest);
end.

{
TORSTEN PINKERT

And now here's the program to test how Mouse-Edit works...
}
PROGRAM Mouse_Edit_Test;
uses graph;
type
 masktype = array[1..16] of word;

{$I Pfeil.dat}

var
 cursor : array[1..2] of masktype;
  gd,gm : integer;

procedure ShowMouse; assembler;
 asm
  mov ax,1
  int 33h
end; {ShowMouse}
procedure HideMouse; assembler;
 asm
  mov ax,2
  int 33h
end; {HideMouse}
procedure ChangeMousePointer (x,y:integer; zeiger:word); assembler;
asm
 mov ax,9
 mov bx,x
 mov bx,y
 mov dx,zeiger
 int 33h
end; {ChangeMousePointer}

begin
 gd:=VGA; gm := VGAHi;
 initgraph(gd,gm,'c:\bp\bgi');
  setfillstyle(solidfill,white);
  bar (200,200,400,400);
 cursor[1]:=screenmask; cursor[2]:=cursormask;
 SetBKColor(black);
 ShowMouse;
 ChangeMousePointer(8,8,ofs(cursor));
  readln;
  HideMouse;
  closegraph;
end.

