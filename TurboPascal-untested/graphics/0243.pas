{Magnify glass moving over ANY background, needs 386 machine}
{Jaco van Niekerk, jvn@rkw.rau.ac.za}
{Mail me if you have any questions/ideas/comments about this code}
program magnify_glass;
uses crt;

const r : byte = 40;                  {radius of sphere}
      h : integer = 20;               {distace from plane to focus point}
      d : byte = 80;                  {diameter of magnify glass}

var offs : array[0..22500] of integer; {150x150}
    b, v : pointer;

{This is the easiest mouse routines available!}
function initmouse: word;assembler;
{Initialize mouse driver}
asm mov ax, 0h; int 33h; end;

procedure showmousecursor;assembler;
{Instruct BIOS to show mouse cursor}
asm mov ax, 01h; int 33h; end;

procedure hidemousecursor;assembler;
{Instruct BIOS to hide mouse cursor}
asm mov ax, 02h; int 33h; end;

procedure getmousepos (var x, y, button: word);
{Return the current location of the mouse}
var x1, y1, b : word;
begin
     Asm mov ax, 03h; int 33h; mov [b], bx; mov [x1], cx; mov [y1], dx; end;
     x:=x1; y:=y1; button := b;
end;

Procedure setmousewindow (X1, Y1, X2, Y2: Word);assembler;
{Set the mouse window}
asm mov ax, 07h; mov cx,[x1]; mov dx,[x2]; int 33h; inc ax;
    mov cx,[y1]; mov dx,[y2]; int 33h; end;

procedure copyw(source : pointer; dest : pointer; cnt : word);assembler;
asm {copy [cnt] words from [source] to [dest]}
   les di, [dest]    {[dest] moves into [es:di]}
   push ds           {ds must be preserved}
   lds si, [source]  {[source] moves into [ds:di]}
   mov cx, [cnt]     {cx <- [cnt] : number of words to move}
   cld               {clear the direction flag, si will increment}
   rep movsw         {copies cx words from source to destination}
   pop ds            {restore ds to it's original state}
end;

procedure cls(dest : pointer);assembler;
asm
   les di, [dest]
   mov cx, 16000
   xor ax, ax
   db $66; rep stosw
end;

procedure calc_mask; {a bit of maths!}
{this calculates the pixel mask, to optimize the speed}
var x, y, z : integer;
    ux, uy : integer;
    sx, sy : integer;
begin
     for y:=0 to d do
         for x:=0 to d do
         begin
              ux:=x - d div 2;
              uy:=y - d div 2;
              if (ux*ux+uy*uy < r*r) then {point is defined on sphere}
              begin
                   z:=round(sqrt(r*r-ux*ux-uy*uy));
                   sx:=round((h-z)*(ux/z)); {took me 2 hours to work, these}
                   sy:=round((h-z)*(uy/z)); {two formulas out!!!}
                   {point on "s phere"}
                   offs[x+y*d]:=sy*320+sx;
              end else offs[x+y*d]:=0;
         end;
end;

procedure construct(xp, yp : word);
{if you want to optimize the code, do it in this procedure, since it}
{does all the main thingies, please send me a copy then too ;)  }
var seg1, ofs1, seg2, ofs2 : word;
    x, y : word;
    vp, hp : word;
    ux, uy : integer;
begin
     seg1:=seg(b^); ofs1:=ofs(b^);
     seg2:=seg(v^); ofs2:=ofs(v^);
     copyw(b,v,32000);
     for y:=0 to d do
         for x:=0 to d do
         begin
              ux:=x - d div 2;
              uy:=y - d div 2;
              vp:=y+yp+offs[y*d+x] div 320;
              hp:=x+xp+offs[y*d+x] mod 320;
              if (vp<200) and (vp>0) and (xp<320) and (xp>0) and
                 (sqr(r-1)> ux*ux+uy*uy) then
              begin
                 mem[seg2:ofs2+(y+yp)*320+x+xp]:=
                    mem[seg1:(ofs1+vp*320+hp)];
              end;
         end;
     copyw(v,ptr($a000,000),32000);
end;

procedure background;
{replace this with any background, of your choice, even a dynamic }
{background, like a fire or plasma, just remember to copy it to b^}
var i, j : integer;
begin
     directvideo:=false;
     writeln; writeln; writeln; writeln;
     textcolor(15);
     writeln('  This is a test. Please feel free');
     writeln('  to do anything you wish with this');
     writeln('  code, but please do give credit');
     writeln('  where credit is due.');
     writeln;
     writeln('  Real programmers, do!');
     writeln;
     writeln('  J v Niekerk (jvn@rkw.rau.ac.za)');
     writeln;
     writeln(' O, yes, if nothing is happening,');
     writeln(' now try moving your mouse around!!');
     directvideo:=true;

     for i:=0 to 319 do
         for j:=0 to 199 do
             if mem[$a000:320*j+i]=0 then mem[$a000:320*j+i]:=((i+j) mod 10)+20;

     copyw(ptr($a000,000),b,32000);
end;

var deg : real;
    x, y, but : word;

begin
     clrscr;
     getmem(v,64000); getmem(b,64000);

     asm
        mov ax, 13h
        int 10h
     end;

     background;
     calc_mask;
     initmouse;
     setmousewindow(5,5,315-d, 200-d);

     repeat
           getmousepos(x, y, but);
           construct(x,y);
     until but=1;

     freemem(v, 64000);
     freemem(b, 64000);
     asm
        mov ax, 03h
        int 10h
     end;
end.

