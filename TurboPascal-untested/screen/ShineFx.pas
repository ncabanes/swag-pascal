(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0088.PAS
  Description: Shine FX
  Author: CHRISTOPHER CHANDRA
  Date: 05-26-95  23:28
*)

{
 Here is something that you can play with ...

 Shine FX - by Christopher J. C.
 inspired by lotsa product out there that use this kind of FX

 This code is public domain.  Do whatever you want with it.

 A credit line for me would be nice  ;^p
}

uses crt;

const MaxRow=25;MaxColumn=80;

var Buffer:array[1..MaxRow] of byte;
    XTable:array[1..MaxRow] of shortint;

procedure Init_XTable;
var cnt:byte;
begin for cnt:=0 to MaxRow-1 do XTable[cnt+1]:=-cnt; end;

procedure Shine(sx,sy,ex,ey:integer;c:byte);
var x,y:integer;
    num,cnt:word;
begin
 cnt:=0;
 for x:=sx to ex+ey-sy do
 begin
  for y:=sy to ey do
   if (XTable[y-sy+1]+x > sx-1) and (XTable[y-sy+1]+x < ex+1) then
   begin
    num:=(y-1)*160+(XTable[y-sy+1]+(x-1))*2+1;
    Buffer[y]:=mem[$b800:num];                    {save background attr.}
    mem[$b800:num]:=c+Buffer[y] and 240;          {highlight the spot}
   end;
  asm                                             {retrace}
   mov dx,3dah;
   @r1: in al,dx; test al,8; jnz @r1
   @r2: in al,dx; test al,8; jz @r2
  end;
 for y:=sy to ey do
  if (XTable[y-sy+1]+x > sx-1) and (XTable[y-sy+1]+x < ex+1) then
  begin                                           {restore background attr.}
   mem[$b800:(y-1)*160+(XTable[y-sy+1]+(x-1))*2+1]:=Buffer[y];
  end;
 end;
end;

procedure ShowImage;

var cnt:word;
begin
 textbackground(0);window(25,7,55,18);clrscr;inc(windmax);
 for cnt:=1 to 7 do
 begin
  gotoxy(1,cnt+1);textcolor(11);write('█');
  gotoxy(31,cnt+4);textcolor(9);write('█');
 end;
 textcolor(11);
 gotoxy(1,1);write('▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄');
 textcolor(3);write('▄');
 gotoxy(1,12);write('▀');
 textcolor(9);write('▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀');
 textbackground(3);gotoxy(1,9);textcolor(11);write('▓');
 gotoxy(1,10);write('▒');gotoxy(1,11);write('░');
 gotoxy(31,4);textcolor(9);write('▓');
 gotoxy(31,3);write('▒');gotoxy(31,2);write('░');
 window(26,8,54,17);clrscr;
 textcolor(11);gotoxy(9,2);write('Shine FX Test');
 textcolor(8);gotoxy(6,3);write('─═════════════════─');
 textcolor(12);gotoxy(12,4);write('Code by');
 textcolor(1);gotoxy(7,5);write('Christopher J. C.');
 textcolor(8);gotoxy(6,6);write('─═════════════════─');
 textcolor(11);gotoxy(3,7);write('Add a little shine to the');
 gotoxy(5,8);write('usually boring screen');
 textcolor(12);gotoxy(12,9);write('Enjoy!!');
 window(1,1,80,25);
end;

begin
 Init_XTable;
 ShowImage;
 Shine(25,7,55,18,15);
 repeat until keypressed;
end.

