(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0013.PAS
  Description: Joystick
  Author: CHRISTOPHER CHANDRA
  Date: 08-24-94  13:44
*)

{
Here is a little something that I made up.. It kinda works w/ a Gravis GamePad
(w/ 4 buttons)..
}
{Joystick Test - by Christopher J. Chandra - Freeware}

uses dos,crt;
var x,y,lx,ly,u,r,b,l:byte;
    z1,z2,z3,z4:byte;          {the buttons}

procedure joy_read(var x1,y1,b1,b2,b3,b4:byte);
var result:byte;
    r:registers;
begin
asm
 mov ax,$8400
 xor dx,dx
 int 15h                       {get the buttons}
 mov result,al
end;
 if result and 16 = 16 then b1:=0 else b1:=1;
 if result and 32 = 32 then b2:=0 else b2:=1;
 if result and 64 = 64 then b3:=0 else b3:=1;
 if result and 128=128 then b4:=0 else b4:=1;
 with r do
 begin
  ax:=$8400;
  dx:=$0001;                    {get the coordinate}
 end;
 intr($15,r);
 with r do
 begin
  x1:=ax;
  y1:=bx
 end
end;
 
procedure calibrate(var upp,lef,bot,rig:byte);
var m,m1:string;
begin
 m:='Center your Joystick';m1:='and press a button';
 gotoxy(40-length(m) div 2,12);write(m);
 gotoxy(40-length(m1) div 2,13);write(m1);
 repeat
  joy_read(x,y,z1,z2,z3,z4)
 until (z1<>0) or (z2<>0) or (z3<>0) or (z4<>0);
 lx:=x;ly:=y;
 clrscr;
 z1:=0;z2:=0;z3:=0;z4:=0;delay(500);
 m:='Move your Joystick to the Upper Left corner';
 gotoxy(40-length(m) div 2,12);write(m);
 gotoxy(40-length(m1) div 2,13);write(m1);
 repeat
  joy_read(x,y,z1,z2,z3,z4)
 until (z1<>0) or (z2<>0) or (z3<>0) or (z4<>0);
 lef:=x;upp:=y;
 clrscr;
 z1:=0;z2:=0;z3:=0;z4:=0;delay(500);
 m:='Move your Joystick to the Bottom Right corner';
 gotoxy(40-length(m) div 2,12);write(m);
 gotoxy(40-length(m1) div 2,13);write(m1); {<-waste of time, eh?}
 repeat
  joy_read(x,y,z1,z2,z3,z4)
 until (z1<>0) or (z2<>0) or (z3<>0) or (z4<>0);
 rig:=x;bot:=y;
 clrscr;
 z1:=0;z2:=0;z3:=0;z4:=0;delay(500)
end;
 
var xx,yy,a:byte;
 
begin
 textcolor(7);textbackground(0);clrscr;
 {turn the cursor off if you want over here..}
 xx:=40;yy:=12;
 calibrate(u,l,b,r);
 a:=178;                  {just a cursor character}
 repeat
  gotoxy(xx,yy);write(chr(a));
  joy_read(x,y,z1,z2,z3,z4);
  if z1=1 then begin textcolor(7);textbackground(1) end else
  if z2=1 then begin textcolor(7);textbackground(4) end else
  begin textcolor(7);textbackground(0) end;
 if (z1>0) and (z3>0) then begin textcolor(7);textbackground(0);clrscr end else
 if (z3>0) and (a>33) then dec(a);
 if (z4>0) and (a<254) then inc(a);
 gotoxy(xx,yy);write(' ');
 if x<(l+5) then dec(xx,1) else  {check joystick's x against l+5}
 if x>(r-5) then inc(xx,1);      {check joystick's x against r-5}
 if y<(u+5) then dec(yy,1) else  {and check the y too}
 if y>(b-5) then inc(yy,1);
 gotoxy(1,23);write(z1:3);
 gotoxy(5,23);write(z2:3);
 gotoxy(9,23);write(z3:3);
 gotoxy(13,23);write(z4:3);
 gotoxy(1,24);write(x:3);
 gotoxy(5,24);write(y:3);
 gotoxy(9,24);write(lx:3);
 gotoxy(13,24);write(ly:3);
 if xx<1 then xx:=1 else if xx>80 then xx:=80;
 if yy<1 then yy:=1 else if yy<23 then yy:=23
until keypressed
end.

