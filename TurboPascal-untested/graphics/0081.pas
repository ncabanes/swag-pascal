
{ NEEDS A MOUSE !!!
And here as promised to several fellows, the moving landscape!
It needs a mouse, as you can see...
Again nothing realy nifty (imho), no bankswitching, no mode-x, no virtual
screens, no palette tricks, just some hard math! ;-) Have fun with it...

--- cut here ---}

program landscape_2d;
{ 2D landscape (without rotating). Made by Bas van Gaalen, Holland, PD }
const
  vseg = $a000;
  a_density = 4;
  roughness = 20;
  maxx_scape = 320; maxy_scape = 200;
  maxh = 128;
  maxx = 250 div a_density; maxy = 110 div a_density;
var landscape : array[0..maxx_scape*maxy_scape] of byte;

{ mouse routines ------------------------------------------------------------}

function mouseinstalled : boolean; assembler; asm
  xor ax,ax; int 33h; cmp ax,-1; je @skip; xor al,al; @skip: end;

function getmousex : word; assembler; asm
  mov ax,3; int 33h; mov ax,cx end;

function getmousey : word; assembler; asm
  mov ax,3; int 33h; mov ax,dx end;

function leftpressed : boolean; assembler; asm
  mov ax,3; int 33h; and bx,1; mov ax,bx end;

procedure mousesensetivity(x,y : word); assembler; asm
  mov ax,1ah; mov bx,x; mov cx,y; xor dx,dx; int 33h end;

procedure mousewindow(l,t,r,b : word); assembler; asm
  mov ax,7; mov cx,l; mov dx,r; int 33h; mov ax,8
  mov cx,t; mov dx,b; int 33h end;

{ lowlevel video routines ---------------------------------------------------}

procedure setvideo(m : word); assembler; asm
  mov ax,m; int 10h end;

procedure putpixel(x,y : word; c : byte); assembler; asm
  mov ax,vseg; mov es,ax; mov ax,y; mov dx,320; mul dx
  mov di,ax; add di,x; mov al,c; mov [es:di],al end;

function getpixel(x,y : word) : byte; assembler; asm
  mov ax,vseg; mov es,ax; mov ax,y; mov dx,320; mul dx
  mov di,ax; add di,x; mov al,[es:di] end;

procedure setpal(c,r,g,b : byte); assembler; asm
  mov dx,03c8h; mov al,c; out dx,al; inc dx; mov al,r
  out dx,al; mov al,g; out dx,al; mov al,b; out dx,al end;

procedure retrace; assembler; asm
  mov dx,03dah; @l1: in al,dx; test al,8; jnz @l1
  @l2: in al,dx; test al,8; jz @l2 end;

{ initialize palette colors -------------------------------------------------}

procedure initcolors;
var i : byte;
begin
  for i := 0 to 63 do begin
    setpal(i+1,21+i div 3,21+i div 3,63-i);
    setpal(i+65,42-i div 3,42+i div 3,i div 3);
  end;
end;

{ landscape generating routines ---------------------------------------------}

procedure adjust(xa,ya,x,y,xb,yb : integer);
var d,c : integer;
begin
  if getpixel(x,y) <> 0 then exit;
  d := abs(xa-xb)+abs(ya-yb);
  c := (50*(getpixel(xa,ya)+getpixel(xb,yb))+trunc((10*random-5)*d*roughness))
div 100;
  if c < 1 then c := 1;
  if c >= maxh then c := maxh;
  putpixel(x,y,c);
end;

procedure subdivide(l,t,r,b : integer);
var x,y : integer; c : integer;
begin
  if (r-l < 2) and (b-t < 2) then exit;
  x := (l+r) div 2; y := (t+b) div 2;
  adjust(l,t,X,t,r,t);
  adjust(r,t,r,Y,r,b);
  adjust(l,b,X,b,r,b);
  adjust(l,t,l,Y,l,b);
  if getpixel(x,y) = 0 then begin
    c := (getpixel(l,t)+getpixel(r,t)+getpixel(r,b)+getpixel(l,b)) div 4;
    putpixel(x,y,c);
  end;
  subdivide(l,t,x,y);
  subdivide(x,t,r,y);
  subdivide(l,y,x,b);
  subdivide(x,y,r,b);
end;

procedure generatelandscape;
var image : file; vidram : byte absolute vseg:0000; i : word;
begin
  assign(image,'plasma.img');
  {$I-} reset(image,1); {$I+}
  if ioresult <> 0 then begin
    randomize;
    putpixel(0,0,random(maxh));
    putpixel(maxx_scape-1,0,random(maxh));
    putpixel(maxx_scape-1,maxy_scape-1,random(maxh));
    putpixel(0,maxy_scape-1,random(maxh));
    subdivide(0,0,maxx_scape,maxy_scape);
    rewrite(image,1);
    blockwrite(image,mem[vseg:0],maxx_scape*maxy_scape);
  end else blockread(image,mem[vseg:0],maxx_scape*maxy_scape);
  close(image);
  move(vidram,landscape,sizeof(landscape));
  fillchar(vidram,maxx_scape*maxy_scape,0);
  for i := 0 to maxx_scape*maxy_scape-1 do landscape[i] := 110+Landscape[i] div
2;
end;

{ the actual displaying of the whole thing! ---------------------------------}

procedure displayscape;
var i,j,previ,prevj,n : word; x : integer;
begin
  i := 0; j := 0;
  repeat
    {retrace;}
    previ := i; i := getmousex; prevj := j; j := getmousey;
    for n := 0 to maxx*maxy-1 do begin
      x := -(a_density*(integer(n mod maxx)-(maxx shr 1)-1)*45) div (integer(n
div maxx)-45)-90;
      if (x >= -250) and (X <= 60) then begin
        mem[vseg:320*(a_density*integer(n div maxx)-landscape[n mod
maxx+previ+(n div maxx+prevj)*maxx_scape])+x] := 0;
        mem[vseg:320*(a_density*integer(n div maxx)-landscape[n mod maxx+i+(n
div maxx+j)*maxx_scape])+x] :=
          landscape[(integer(n mod maxx)+i)+(integer(n div
maxx)+j)*maxx_scape]-100;
      end;
    end;
  until leftpressed;
end;

{ main routine --------------------------------------------------------------}

begin
  if mouseinstalled then begin
    setvideo($13);
    initcolors;
    generatelandscape;
    mousewindow(0,0,maxx_scape-maxx,maxy_scape-maxy);
    mousesensetivity(25,25);
    displayscape;
    setvideo(3);
  end else writeln('This interactive thing realy needs a mouse...');
end.

