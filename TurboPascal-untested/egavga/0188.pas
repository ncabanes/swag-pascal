
{ Updated EGAVGA.SWG on May 26, 1995 }

{
From: Scott Stone <Scott.Stone@m.cc.utah.edu>

Ok, here's that 3-D starfield code that I promised.  (it works)
}

Program Starfield_3D;
Uses dos,crt;
Const
  NumStars=100;
  StarSpeed=20;
{change these to change the # of stars/speed, then recompile}
Type
  Starrec=record
    x : integer;
    y : integer;
    z : integer
  end;
Var
  a,b,c : integer;
  ch : char;
  stars : array [1..numstars] of starrec;
  p2,p3 : pointer; {Pointers to "virtual" VGA screens}

Procedure InitVGA;
Begin
  asm
    mov ax,13h
    int 10h
  end;
end; {Moves the 320x200x256 mode identifier, 13 hexadecimal, into
      the AX system register then calls interrupt 10 hex, which handles
      the video card.  Basically, it sets up the video mode}

Procedure Restoretext;
begin
  asm
    mov ax,03h
    int 10h
  end;
end; {restores textmode - text mode is mode 03 hex}

Procedure AllocatePages;
Begin
  getmem(p2,64000);
  getmem(p3,64000);
End; {gets 64k for each of the 2 pointer variables, p2 and p3}
     {These pointers represent "imaginary" vga pages, for swapping}

Procedure ClearPage3;
var
  i : longint;
Begin
  for i:=0 to 63999 do
  begin
    mem[seg(p3^):i]:=0;
  end;
end;

Procedure Deallocatepages;
begin
  freemem(p2,64000);
  freemem(p3,64000);
End; {frees system memory so you don't get a heap overflow later}

Procedure SwapPages;
Begin
  move(mem[seg(p2^):0],mem[$A000:0],64000);
  move(mem[seg(p3^):0],mem[seg(p2^):0],64000);
End;
    {Moves the data from the imaginary "page 2" to the visible page #1,}
    {Then moves the blank page 3 over to page 2, to start over.  this}
    {is how you do smooth animation.}

Procedure PutPixel(x,y : integer; c : integer);
Begin
  mem[$A000:((320*y)+x)]:=c;
End;
    {A000 Hex is the VGA segment address - the thing after the colon is
     the offset - imagine a 320x200 array, that's how you'd find the
     "linear" address in the array.  After finding the right byte, it simply
     sets it equal to c, the color of the pixel you want}

Procedure PP2(x,y : integer; c: integer);
begin
  mem[seg(p2^):((320*y)+x)]:=c;
End;
    {Same as putpixel, but puts it on the imaginary page #2 instead of the
     visual page}

Procedure CalculateStars;
Begin
  for a:=1 to numstars do
  begin
    stars[a].x:=(random(2000)-1000);
    {this produces a range from -1000 to +1000}
    stars[a].y:=(random(2000)-1000);
    stars[a].z:=(random(400)+1); {don't want Z to ever be negative -you'll see}
  end;
end;
    {Basically, we've calculated the stars' initial positions}

Procedure DisplayStars;
Const
  expf=75; {local constant} {play with this value for some interesting FX}
Var
  sx,sy : integer; {these are variables defined only for THIS procedure}
  tempcolor : integer;
  okshow : boolean;
Begin
  for a:=1 to numstars do
  begin
    okshow:=true;
    {remember - positive Z is AWAY from you}
    if (stars[a].z<200) then tempcolor:=7;  {light gray}
    if (stars[a].z<100) then tempcolor:=15; {white}
    if (stars[a].z>=200) then tempcolor:=8; {dark gray}
    if (stars[a].z>0) then {have to do this or get div by 0 error}
    begin
      sx:=round((stars[a].x*expf)/stars[a].z);
      sy:=round((stars[a].y*expf)/stars[a].z);
      sx:=sx+160;
      sy:=sy+100; {put the origin at the center, not upper-left}
      if (sx<0) then okshow:=false;
      if (sx>319) then okshow:=false;
      if (sy<0) then okshow:=false;
      if (sy>199) then okshow:=false;
      if (okshow=true) then pp2(sx,sy,tempcolor);
    end;
  end;
end; {Displays one frame of the starfield, basically}

Procedure MoveStars;
Begin
  for a:=1 to numstars do
  begin
    stars[a].z:=(stars[a].z-starspeed);
    if (stars[a].z<=0) then stars[a].z:=400; {can't have 0 or negative value}
  end;
End; {Updates the position of the stars}

Begin {main program execution begins here}
  initvga; {first, setup the screen - we have lots of predef procedures now!}
  allocatepages; {get the virtual pages set up}
  clearpage3; {make sure page 3 is blank}
  calculatestars; {setup initial positions}
  repeat
    displaystars; {display one frame}
    swappages; {copy frame to visual page and erase working page}
    movestars; {update star data}
  until keypressed; {repeats the loop until you hit a key}
  restoretext; {put the video card back in 80x25 text mode}
  deallocatepages; {free up the system RAM we used}
End. {end the program execution}
