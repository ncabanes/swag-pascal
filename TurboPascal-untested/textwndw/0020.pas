{
> I really like the windowing routines you use.  Specifically the
> ones you have used with the SWAG Reader and your DIZ Editor.  I
> really like the way you have used the color offsets in the
> borders - i.e. black & white lines on the blue background -
> giving it depth.  Have you incorporated these into a unit?  Are
> they available?

well you wrote to ALL so heres something I just whipped up:
look for my other posts for popupwindows if you want to use shadows
with this...
}

{
USAGE: Drawbox( upper left column,upper row,right column,lower row,
upper border color,lower border color,background color,window true/false)
Released to the Public Domain By Martin Woods 1:3412/1112.1
}

unit testwin;

interface
uses crt;
procedure Drawbox(x1,y1,x2,y2,UPborder,DNborder,Back: byte;win:boolean);

implementation

procedure Drawbox(x1,y1,x2,y2,UPborder,DNborder,Back: byte;win:boolean);
var
 x,y: byte;
begin;
 textcolor(UPborder);
 textbackground(Back);
 gotoxy(x1,y1);
 for x:=x1+1 to x2 do write('─');
 textcolor(dnborder);
 gotoxy(x1,y2);
 for x:=x1+1 to x2 do write('─');
 for y:=y1+1 to y2-1 do begin;
  textcolor(upborder);
  gotoxy(x1,y);
  write('│');
  textcolor(dnborder);
  gotoxy(x2,y);
  write('│');
 end;
 textcolor(upborder);
 gotoxy(x1,y1);
 write('┌');
 textcolor(dnborder);
 gotoxy(x2,y1);
 write('┐');
 textcolor(upborder);
 gotoxy(x1,y2);
 write('└');
 textcolor(dnborder);
 gotoxy(x2,y2);
 write('┘');
  if win=true then
   window(x1+1,y1+1,x2-1,y2-1);
  end;
end.{testwin}



program testbox;

uses crt,testwin;
begin;
textcolor(7);
textbackground(7);
clrscr;
drawbox(17,9,62,17,15,0,1,true); {uses the crt window here}
clrscr;
drawbox(2,1,43,7,0,15,1,false); {no window here just a box inside the window}
{notice I reversed 15 on 0 to 0 on 15 (white on black to black on white)
which is what this is all about :-)}
gotoxy(7,3);
textcolor(14);
write('Is this what your looking for?');
drawbox(8,4,15,6,0,15,1,false);
drawbox(28,4,35,6,0,15,1,false);
textcolor(14);
gotoxy(10,5);
write('Yes');
gotoxy(31,5);
write('No');
readkey;
end.

