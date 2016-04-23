uses dos,crt,cfont,graph;

const
     no = 16;

type
    info = record
        name   : string;
        secs   : integer;
        mins   : integer;
        hours  : integer;
    end;

var
   lastno : integer;
   loop   : integer;
   loop2  : integer;
   data   : array[1..no] of info;
   gm,gd  : integer;
   co     : integer;

function lz(w : integer) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  lz := s;
end;

procedure precalc;

var
   x : integer;

begin
     x := 0;
     for loop := 1 to no do
     begin
          if data[loop].hours > 23 then
          begin
               x := data[loop].hours - 24;
               data[loop].hours := x;
          end;
          if data[loop].mins > 59 then
          begin
               x := data[loop].mins - 59;
               data[loop].mins := x;
          end;
          if data[loop].secs > 59 then
          begin
               x := data[loop].secs - 59;
               data[loop].secs := x;
          end;
     end;
end;

procedure presetclock;

var
   h,m,s,hund : word;
   loop       : integer;

begin
     GetTime(h,m,s,hund);
     for loop := 1 to no do
     begin
          data[loop].hours := data[loop].hours + h;
          data[loop].mins := data[loop].mins + m;
          data[loop].secs := data[loop].secs + s;
     end;
end;

procedure showtime;

begin
     delay(710);
     for loop := 1 to no do
     begin
          inc(data[loop].secs);
          if data[loop].secs > 59 then
          begin
               inc(data[loop].mins);
               data[loop].secs := 0;
               if data[loop].mins > 59 then
               begin
                    data[loop].mins := 0;
                    inc(data[loop].hours);
                    if data[loop].hours > 23 then
                     begin
                          data[loop].hours := 0;
                     end;
               end;
         end;
    end;
end;

begin
     gd := detect;
     initgraph(gd,gm,'\turbo\tp');  { change this !! }
     data[1].name := 'LONDON';
     data[1].secs := 0;
     data[1].mins := 0;
     data[1].hours := 0;
     data[2].name := 'PARIS';
     data[2].secs := 0;
     data[2].mins := 0;
     data[2].hours := 1;
     data[3].name := 'ATHINS';
     data[3].secs := 0;
     data[3].mins := 0;
     data[3].hours := 2;
     data[4].name := 'PEKING';
     data[4].secs := 0;
     data[4].mins := 0;
     data[4].hours := 8;
     data[5].name := 'TOKYO';
     data[5].secs := 0;
     data[5].mins := 0;
     data[5].hours := 9;
     data[6].name := 'SYDNEY';
     data[6].secs := 0;
     data[6].mins := 0;
     data[6].hours := 10;
     data[7].name := 'NEW YORK';
     data[7].secs := 0;
     data[7].mins := 0;
     data[7].hours := -5;
     data[8].name := 'MOSCOW';
     data[8].secs := 0;
     data[8].mins := 0;
     data[8].hours := 3;
     data[9].name := 'RIO';
     data[9].secs := 0;
     data[9].mins := 0;
     data[9].hours := -3;
     data[10].name := 'LOS ANGELES';
     data[10].secs := 0;
     data[10].mins := 0;
     data[10].hours := -8;
     data[11].name := 'HONOLULU';
     data[11].secs := 0;
     data[11].mins := 0;
     data[11].hours := -10;
     data[12].name := 'HONG KONG';
     data[12].secs := 0;
     data[12].mins := 0;
     data[12].hours := 8;
     data[13].name := 'SINGAPORE';
     data[13].secs := 0;
     data[13].mins := 0;
     data[13].hours := 7;
     data[14].name := 'NAIROBI';
     data[14].secs := 0;
     data[14].mins := 0;
     data[14].hours := 3;
     data[15].name := 'AUCKLAND';
     data[15].secs := 0;
     data[15].mins := 0;
     data[15].hours := 12;
     data[16].name := 'MEXICO CITY';
     data[16].secs := 0;
     data[16].mins := 0;
     data[16].hours := 6;
     presetclock;
     precalc;
     cleardevice;
     setcolor(lightblue);
     settextstyle(8,0,3);
     outtextxy(200,10,'WORLD TIME CLOCK');
     outtextxy(200,440,'By Nathan Dawson');
     rectangle(1,1,639,479);
     settextstyle(7,0,1);
     setcolor(lightgreen);
     for loop := 1 to 8 do
     begin
          outtextxy(10,10+loop*50,data[loop].name);
     end;
     co := 50;
     for loop2 := 9 to no do
     begin
          outtextxy(300,loop2+co,data[loop2].name);
          co := co + 49;
     end;
     repeat
     for loop := 1 to 8 do
     begin
          clock(200,10+loop*50,lz(data[loop].secs));
          clock(155,10+loop*50,lz(data[loop].mins));
          clock(110,10+loop*50,lz(data[loop].hours));
     end;
     co := 40;
     for loop2 := 9 to no do
     begin
          clock(520,10+loop2+co,lz(data[loop2].secs));
          clock(475,10+loop2+co,lz(data[loop2].mins));
          clock(430,10+loop2+co,lz(data[loop2].hours));
          co := co + 49;
     end;
     showtime;
     until keypressed;
     closegraph;
     gotoxy(17,1);
     textcolor(blue);
     write('Thank you for using the World Time Clock');
     gotoxy(17,3);
     textcolor(cyan);
     write('      Look out for more software by     ');
     gotoxy(17,5);
     textcolor(lightcyan);
     write('       ░▒▓                     ▓▒░      ');
     gotoxy(31,5);
     textcolor(lightred+blink);
     write('NATHAN DAWSON');
     writeln;
     textcolor(lightgray);
end.

{ CFONT UNIT NEEDED FOR CLOCK.PAS }

unit cfont;

interface

procedure clock(px,y:integer;numbers:string);

implementation

uses crt,graph;

procedure clock;

var
   gm,gd  : integer;
   p1     : integer;
   p2     : integer;
   p3     : integer;
   testno : string;
   no1    : string[1];
   count  : integer;
   posx   : integer;
   posy   : integer;

function IntToStr(I: Longint): String;

var
 S: string[11];

begin
 Str(I, S);
 IntToStr := S;
end;

procedure resetvars;
begin
     p1 := 0;
     p2 := 0;
     p3 := 0;
end;

procedure section1;
begin
     resetvars;
     p3 := 3;
     repeat
           dec(p3);
           dec(p2);
           inc(p1);
           line(posx+p3,posy+p2,posx+p3,posy+5+p1);
     until p3 = 0;
end;

procedure section2;
begin
     resetvars;
     repeat
           inc(p3);
           dec(p2);
           inc(p1);
           line(posx+10+p3,posy+p2,posx+10+p3,posy+5+p1);
     until p3 = 3;
end;

procedure section3;
begin
     resetvars;
     p3 := 3;
     repeat
           dec(p3);
           dec(p2);
           inc(p1);
           line(posx+p3,posy+14+p2,posx+p3,posy+19+p1);
     until p3 = 0;
end;

procedure section4;
begin
     resetvars;
     repeat
           inc(p3);
           dec(p2);
           inc(p1);
           line(posx+10+p3,posy+14+p2,posx+10+p3,posy+19+p1);
     until p3 = 3;
end;

procedure section5;

begin
     resetvars;
     p3 := 3;
     repeat
           dec(p3);
           dec(p2);
           inc(p1);
           line(posx+5+p2,posy-5+p3,posx+8+p1,posy-5+p3);
     until p3 = 0;
end;

procedure section6;

begin
     resetvars;
     repeat
           inc(p3);
           dec(p2);
           inc(p1);
           line(posx+5+p2,posy+21+p3,posx+8+p1,posy+21+p3);
     until p3 = 3;
end;

procedure section7;

begin
     resetvars;
           line(posx+4,posy+9,posx+9,posy+9);
           line(posx+3,posy+10,posx+10,posy+10);
           line(posx+4,posy+11,posx+9,posy+11);
end;

procedure on;
begin
     setcolor(lightgreen);
{     setrgbpalette(lightgreen,0,60,0);}
end;

procedure off;
begin
     setcolor(green);
{     setrgbpalette(green,0,20,0);       }
end;

procedure shownumber(x:string);

begin
     if x = '0' then
     begin
          on;
          section1;
          section2;
          section3;
          section4;
          section5;
          section6;
          off;
          section7;
     end;
     if x = '1' then
     begin
          off;
          section1;
          on;
          section2;
          off;
          section3;
          on;
          section4;
          off;
          section5;
          section6;
          section7;

     end;
     if x = '2' then
     begin
          off;
          section1;
          on;
          section2;
          section3;
          off;
          section4;
          on;
          section5;
          section6;
          section7;
     end;
     if x = '3' then
     begin
          off;
          section1;
          on;
          section2;
          off;
          section3;
          on;
          section4;
          section5;
          section6;
          section7;

     end;
     if x = '4' then
     begin
          on;
          section1;
          section2;
          off;
          section3;
          on;
          section4;
          off;
          section5;
          section6;
          on;
          section7;
     end;
     if x = '5' then
     begin
          on;
          section1;
          off;
          section2;
          section3;
          on;
          section4;
          section5;
          section6;
          section7;
     end;
     if x = '6' then
     begin
          on;
          section1;
          off;
          section2;
          on;
          section3;
          section4;
          section5;
          section6;
          section7;
     end;
     if x = '7' then
     begin
          off;
          section1;
          on;
          section2;
          off;
          section3;
          on;
          section4;
          section5;
          off;
          section6;
          section7;
     end;
     if x = '8' then
     begin
          on;
          section1;
          section2;
          section3;
          section4;
          section5;
          section6;
          section7;
     end;
     if x = '9' then
     begin
          on;
          section1;
          section2;
          off;
          section3;
          on;
          section4;
          section5;
          section6;
          section7;
     end;
end;

procedure setup;

var
   loop : integer;

begin
     for loop := 1 to 2 do
     begin
          posx := px+loop*20;
          posy := y;
          no1 := copy(numbers,loop,loop);
          shownumber(no1);
     end;
end;

begin
     setcolor(lightgreen);
     setrgbpalette(lightgreen,0,60,0);
     setcolor(green);
     setrgbpalette(green,0,20,0);
     setup;
end;
end.