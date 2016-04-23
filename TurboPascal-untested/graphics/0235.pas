program new_flame_test;
{New! FLAME by OVERLAYING! Flame that you have *NEVER* seen!
 By Nelson Chu, July 1996, Macau}
{$X+,S-,R-,E-,N-,G+,D-,L-,A+}
uses crt, graphic{, misc};
{Unit GRAPHIC to be found in GRAPHICS.SWG }

const width  = 62;  height = 80; intensity  = 190; hot = width div 2;
      reserved = width div 10;
      quit:boolean=false;      dx:byte=10; dc:byte=25;

type ftype=array[0..height+1, 0..width+1] of byte;

var f:array[1..2] of ftype;
    t :word; a:byte;

procedure setpal;
var a,x:byte;
begin
 for a:= 1 to 32 do setcolor(a,0,0,a*2-1);
 for a:= 1 to 32 do setcolor(a+32,0,a*2-1,63);
 for a:= 1 to 32 do setcolor(a+32*2,a*2-1,63,63);

 for a:= 32*2+1 to 120 do setcolor(a,63,63,63);
 for a:= 1 to 63 do setcolor(120+a,64-a,64-a,64-a);
 for a:= 120+64 to 255 do setcolor(a,0,0,0);
end;

procedure showflame(var flame:ftype; x,y:word);
var a: byte;
begin
for a:= 1 to height-2 do
move( flame[a], screen^[a+y, x + sine[byte((t+a) shl 2)] div 32],
      sizeof(flame[1]));
end;

procedure clearbuf(var flame:ftype);
begin fillchar(flame,sizeof(flame),#0); end;

procedure genfrow(var flame:ftype);{GENerate Front ROW}
var b: byte;
begin
 for b:= 1 to hot div 2 do
  flame[height,reserved+random(width-reserved*8)+1]:=intensity;
 for b:= 1 to hot div 2 do
  flame[height,reserved*4+random(width-reserved*8)+1]:=intensity;
end;

procedure up(var flame:ftype);
begin move(flame[2],flame[1],(width+2)*(height-1)); end;

procedure render2(sfm,ofm:word);
var a,b,base:word;
const w=width+2;
begin
for a:= height downto 1 do
for b:= 1 to width do
begin
base:=ofm+a*w+b;
 mem[sfm:base]:= (mem[sfm:base+1] + mem[sfm:base-1] +
                  mem[sfm:base+w-1] + mem[sfm:base+w+1] )
                  div 4;
end;
end;

procedure render(sfm,ofm:word);
var a,b,base:word;
const w=width+2;
begin
for a:= height downto 1 do
for b:= 1 to width do
begin
base:=ofm+a*w+b;
case random(2) of{don't forget to add some random factor;)}
0:mem[sfm:base]:= ((mem[sfm:base-w-2] + mem[sfm:base-w+2]) +
                  (mem[sfm:base-1] + mem[sfm:base+1]) +
                  mem[sfm:base+w] * 2
                  )
                 div 6;
{1:mem[sfm:base]:= (mem[sfm:base+2] + mem[sfm:base] +
                  mem[sfm:base+w] + mem[sfm:base+w+2] )
                  div 4;
2:mem[sfm:base]:= (mem[sfm:base-2] + mem[sfm:base] +
                  mem[sfm:base+w] + mem[sfm:base+w-2] )
                  div 4}
else
  mem[sfm:base]:= (mem[sfm:base+1] + mem[sfm:base-1] +
                  mem[sfm:base+w-1] + mem[sfm:base+w+1] )
                  div 4;
end;{case}
end;
end;


procedure combineshow(x,y:word);
var a,b,base:word; temp:byte; p1,p2:shortint;
begin
{showflame(f[1], x,y);}
for a:= height-2 downto 1 do
for b:= 1 to width do
 begin
 p1:= sine[byte((t+a)*2)] shr 7;
 p2:= sine[byte((t+10+a)shl 2 + random(3) )] shr 6 +
      sine[byte((t shl 1+a)shl 2)] shr 7 - p1;

 screen^[ y+a, x+b ]:= f[1][a,b + p1] - f[1][a,b + p2+dx]+dc;
                                     {^ This minus sign means negative
                                        overlaying, secret of the strange
                                        flame ;)}
{dec(screen^[ y+a, x+b ], f[2][a,b + p2-10]-60);}
 end;
end;

procedure init;
begin
setcrtmode($13);
setpal;
clearbuf(f[1]); clearbuf(f[2]);
directvideo:=false;
textcolor(70);
gotoxy(4,24);write('Old flame with');
gotoxy(7,25);write('sin effect');
gotoxy(22,24);write('My new flame!(with');
gotoxy(23,25);write('sin effect,too.)');
end;

begin
init;

repeat
      for a:=1 to 1 do
      begin
      genfrow(f[a]);
      up(f[a]);
      render2(seg(f[a]), ofs(f[a]));
      vSync;
      showflame( f[a], a*(width+10), 200-height-16);
      combineshow(200, 200-height-16);
      end;
      inc(t);
until keypressed;
readkey;
gotoxy(6,10);write('Now both stopped ''generating''.');
repeat
      vSync;
 {     showflame( f[a], a*(width+10), 200-height-16);}
{uncomment the about call if you want to see a just-sinus flame}
      combineshow(200, 200-height-16);
      inc(t);
      if keypressed then
       case readkey of
       #27:quit:=true;{ESC ah!}
       'z':inc(dx);
       'x':dec(dx);
       'a':inc(dc);
       's':dec(dc);
      end;
until quit;
setcrtmode($3);
writeln('By Nelson Chu 1996.');
end.
{ Well, I originally wanted to do it by just "adding" two flame buffers with
  sinusoidal displacement to make a moving flame without "generating" it. But
  I tried "minusing" one from the other, and it turned out to be very nice!
  I was so happy when I got this...

  I think "adding" two flame buffers can give you a flame which resembles
  those found in the kitchen(blue when gas is burning, with momentary
  orange/red spurts from the bottom.). You want to try it?


  Enjoy!

  By Nelson Chu  Internet e-mail: eg_cshaa@stu.ust.hk}
P.S. Did you know that I'm from Hong Kong? (Consult your geographic teacher
if you don't know where Hong kong is. ;)

