{
 > I'm glad this was brought up.  I recently made a simple program (in
 > assembly, hope I'm not being off-topic here) that would continually
 > change the status of each LED on the keyboard.  I noticed that the
 > LED's would not actually change unless the program ended or I
 > continually pressed keys down, and I eventually had to call a check
 > for keypress interupt to get it to work properly.  Why exactly was
 > this necessary?

I'm sorry, but right now I don't have time to see that. Here goes a
program that does that kind of stuff: }

program keyboard;
uses crt;
const bit:array[0..7] of byte=(1,2,4,8,16,32,64,128);
var tec: byte absolute $40:$17;
    tec1:byte absolute $40:$18;
    tec2:byte absolute $40:$96;
begin
     clrscr;
     textcolor(15);
     write('                                  TECLAS ACTIVAS');
     gotoxy(1,3);
     write('                   ScrollLock  NumLock  CapsLock  Insert       ');
     gotoxy(1,7);
     write('                                  TECLAS PREMIDAS');
     gotoxy(1,9);
     write('RightAlt  LeftAlt  RightCtrl  LeftCtrl  RightShift  LeftShift  Ins Caps  Num');
     gotoxy(1,12);
     write('Scroll  SysReq');
     repeat
           if (tec and bit[0])<>0 then textcolor(15) else textcolor(0);
           gotoxy(45,10);
           write('√');
           if (tec and bit[1])<>0 then textcolor(15) else textcolor(0);
           gotoxy(57,10);
           write('√');
           if (tec and bit[4])<>0 then textcolor(15) else textcolor(0);
           gotoxy(25,4);
           write('√');
           if (tec and bit[5])<>0 then textcolor(15) else textcolor(0);
           gotoxy(35,4);
           write('√');
           if (tec and bit[6])<>0 then textcolor(15) else textcolor(0);
           gotoxy(45,4);
           write('√');
           if (tec and bit[7])<>0 then textcolor(15) else textcolor(0);
           gotoxy(54,4);
           write('√');
           if (tec1 and bit[5])<>0 then textcolor(15) else textcolor(0);
           gotoxy(76,10);
           write('√');
           if (tec1 and bit[6])<>0 then textcolor(15) else textcolor(0);
           gotoxy(70,10);
           write('√');
           if (tec1 and bit[7])<>0 then textcolor(15) else textcolor(0);
           gotoxy(65,10);
           write('√');
           if (tec1 and bit[4])<>0 then textcolor(15) else textcolor(0);
           gotoxy(3,13);
           write('√');
           if (tec1 and bit[2])<>0 then textcolor(15) else textcolor(0);
           gotoxy(11,13);
           write('√');
           if (tec2 and bit[3])<>0 then textcolor(15) else textcolor(0);
           gotoxy(4,10);
           write('√');
           if (tec2 and bit[2])<>0 then textcolor(15) else textcolor(0);
           gotoxy(24,10);
           write('√');
           if (tec1 and bit[1])<>0 then textcolor(15) else textcolor(0);
           gotoxy(14,10);
           write('√');
           if (tec1 and bit[0])<>0 then textcolor(15) else textcolor(0);
           gotoxy(35,10);
           write('√');
     until keypressed and (upcase(readkey)='X');
end.

It's for Turbo Pascal.

You can also get info on this in Ralph's Brown Interrupt List,
available on some BBS.

