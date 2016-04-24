(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0189.PAS
  Description: StarField 2!
  Author: GRANT SMITH
  Date: 05-26-95  22:57
*)


{ Updated EGAVGA.SWG on May 26, 1995 }

(*
From: denthor@goth.vironix.co.za (Grant Smith)

Scott Stone (Scott.Stone@m.cc.utah.edu) wrote:

Your code is not too bad .. here is my version which is quite a bit faster,
but uses assembler to acheive this... the stars also move in smaller
increments, which makes them slightly smoother.

:   for i:=0 to 63999 do
:   begin
:     mem[seg(p3^):i]:=0;
:   end;

Ouch! Even   fillchar (mem[seg(p3^):0, 64000, 0) would be much faster...
loops are generally a bad plan ... you could gain quite a big speedup by
converting this.

: Procedure SwapPages;
: Begin
:   move(mem[seg(p2^):0],mem[$A000:0],64000);
:   move(mem[seg(p3^):0],mem[seg(p2^):0],64000);
: End;
:     {Moves the data from the imaginary "page 2" to the visible page #1,}
:     {Then moves the blank page 3 over to page 2, to start over.  this}
:     {is how you do smooth animation.}

You ony need one virtual page ... sort of say
cls (virtual screen)
draw (virtual screen)
flip (virtual screen, vga)


Here goes ... this source is from my trainer series, available on
ftp.eng.ufl.edu pub/msdos/demos/code/graph/tutor

Byeeeeee....
  - Denthor
*)

{$X+}
USES crt; 
 
CONST Num = 400;     { Number of stars }
      VGA = $A000; 
 
TYPE Star = Record 
              x,y,z:integer; 
            End;     { Information on each star } 
     Pos = Record 
             x,y:integer; 
           End;      { Information on each point to be plotted } 
     Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen } 
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen } 
 
VAR Stars : Array [1..num] of star; 
    Clear : Array [1..2,1..num] of pos; 
    Virscr : VirtPtr;                     { Our first Virtual screen } 
    Vaddr  : word;                        { The segment of our virtual screen} 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure SetUpVirtual; 
   { This sets up the memory needed for the virtual screen } 
BEGIN 
  GetMem (VirScr,64000); 
  vaddr := seg (virscr^); 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure ShutDown; 
   { This frees the memory used by the virtual screen } 
BEGIN 
  FreeMem (VirScr,64000); 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. } 
BEGIN 
  asm 
     mov        ax,0013h 
     int        10h 
  end; 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure SetText;  { This procedure returns you to text mode.  }
BEGIN 
  asm 
     mov        ax,0003h
     int        10h 
  end; 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Cls (Where:word;Col : Byte); assembler; 
   { This clears the screen to the specified color } 
asm 
   push    es 
   mov     cx, 32000; 
   mov     es,[where] 
   xor     di,di 
   mov     al,[col] 
   mov     ah,al 
   rep     stosw 
   pop     es 
End; 
 
{──────────────────────────────────────────────────────────────────────────} 
procedure flip(source,dest:Word); assembler; 
  { This copies the entire screen at "source" to destination } 
asm 
  push    ds 
  mov     ax, [Dest] 
  mov     es, ax 
  mov     ax, [Source] 
  mov     ds, ax 
  xor     si, si 
  xor     di, di 
  mov     cx, 32000 
  rep     movsw 
  pop     ds 
end; 
 
{──────────────────────────────────────────────────────────────────────────} 
procedure WaitRetrace; assembler; 
  {  This waits for a vertical retrace to reduce snow on the screen } 
label 
  l1, l2; 
asm 
    mov dx,3DAh 
l1:
    in al,dx 
    and al,08h 
    jnz l1
l2: 
    in al,dx 
    and al,08h 
    jz  l2 
end; 
 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Pal(Col,R,G,B : Byte); assembler; 
  { This sets the Red, Green and Blue values of a certain color } 
asm 
   mov    dx,3c8h 
   mov    al,[col] 
   out    dx,al 
   inc    dx 
   mov    al,[r] 
   out    dx,al 
   mov    al,[g] 
   out    dx,al 
   mov    al,[b] 
   out    dx,al 
end; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler; 
  { This puts a pixel on the screen by writing directly to memory. } 
Asm 
  mov     ax,[where] 
  mov     es,ax 
  mov     bx,[X] 
  mov     dx,[Y] 
  mov     di,bx 
  mov     bx, dx                  {; bx = dx} 
  shl     dx, 8 
  shl     bx, 6 
  add     dx, bx                  {; dx = dx + bx (ie y*320)} 
  add     di, dx                  {; finalise location} 
  mov     al, [Col] 
  stosb 
End; 
 

{──────────────────────────────────────────────────────────────────────────} 
Procedure Init; 
VAR loop1,loop2:integer;
BEGIN 
  for loop1:=1 to num do 
    Repeat 
      stars[loop1].x:=random (400)-200; 
      stars[loop1].y:=random (400)-200; 
      stars[loop1].z:=loop1; 
    Until (stars[loop1].x<>0) and (stars[loop1].y<>0); 
      { Make sure no stars are heading directly towards the viewer } 
  pal (32,00,00,30); 
  pal (33,10,10,40); 
  pal (34,20,20,50); 
  pal (35,30,30,60);   { Pallette for the stars coming towards you } 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Calcstars; 
  { This calculates the 2-d coordinates of our stars and saves these values 
    into the variable clear } 
VAR loop1,x,y:integer; 
BEGIN 
  For loop1:=1 to num do BEGIN 
    x:=((stars[loop1].x shl 7) div stars[loop1].z)+160; 
    y:=((stars[loop1].y shl 7) div stars[loop1].z)+100; 
    clear[1,loop1].x:=x; 
    clear[1,loop1].y:=y; 
  END; 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Drawstars; 
  { This draws the 2-d values stored in clear to the vga screen, with various 
    colors according to how far away it is. } 
VAR loop1,x,y:integer; 
BEGIN 
  For loop1:=1 to num do BEGIN 
    x:=clear[1,loop1].x; 
    y:=clear[1,loop1].y; 
    if (x>0) and (x<320) and (y>0) and (y<200) then 
      putpixel(x,y,35-stars[loop1].z shr 7,vaddr) 
  END; 
END; 

{──────────────────────────────────────────────────────────────────────────} 
Procedure Clearstars; 
  { This clears the 2-d values from the virtual screen, which is faster then a
    cls (vaddr,0) } 
VAR loop1,x,y:integer; 
BEGIN 
  For loop1:=1 to num do BEGIN 
    x:=clear[2,loop1].x; 
    y:=clear[2,loop1].y; 
    if (x>0) and (x<320) and (y>0) and (y<200) then 
      putpixel (x,y,0,vaddr); 
  END; 
END; 
 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure MoveStars (Towards:boolean); 
  { If towards is True, then the z-value of each star is decreased to come 
    towards the viewer, otherwise the z-value is increased to go away from 
    the viewer } 
VAR loop1:integer; 
BEGIN 
  If towards then 
    for loop1:=1 to num do BEGIN 
      stars[loop1].z:=stars[loop1].z-2; 
      if stars[loop1].z<1 then stars[loop1].z:=stars[loop1].z+num; 
    END 
    else 
    for loop1:=1 to num do BEGIN 
      stars[loop1].z:=stars[loop1].z+2; 
      if stars[loop1].z>num then stars[loop1].z:=stars[loop1].z-num; 
    END; 
END; 
 
{──────────────────────────────────────────────────────────────────────────} 
Procedure Play; 
  { This is our main procedure } 
VAR ch:char; 
BEGIN 
  Calcstars; 
  Drawstars;  { This draws our stars for the first time } 
  ch:=#0; 
  cls (vaddr,0); 
  Repeat 
    if keypressed then ch:=readkey;
    clear[2]:=clear[1]; 
    Calcstars;     { Calculate new star positions } 
    waitretrace;
    Clearstars;    { Erase old stars } 
    Drawstars;     { Draw new stars } 
    flip (vaddr,vga); 
    if ch=' ' then Movestars(False) else Movestars(True); 
      { Move stars towards or away from the viewer } 
  Until ch=#27; 
    { Until the escape key is pressed } 
END; 
 
BEGIN 
  clrscr; 
  writeln ('Hello! Another effect for you, this one is on starfields, again by');
  writeln ('request.  In this sample program, a starfield will be coming towards');
  writeln ('you. Hit the space bar to have it move away from you, any other key');
  writeln ('to have it come towards you again. Hit [ESC] to end.');
  writeln;
  writeln ('The code is very easy to follow, and the documentation is as usual in the');
  writeln ('main text. Leave me mail with further ideas for future trainers.');

  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  randomize;
  setmcga;
  setupvirtual;
  init;
  Play;
  settext;
  shutdown;
  Writeln ('All done. This concludes the thirteenth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid');
  Writeln ('Connectix BBS user, and occasionally read RSAProg. E-mail me at :');
  Writeln ('    denthor@beastie.cs.und.ac.za');
  Writeln ('The numbers are available in the main text. You may also write to me at:');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('             Natal');
  Writeln ('             South Africa');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  readkey;
END.


