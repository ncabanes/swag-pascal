
{Hello All! I've recently coded this screen saver.It really looks like snow
is falling all over, don't you think?
However, I did not set out to do a snow screen saver and if you experiment
with it a little you will see that it can even turn out to be a firework!
If anyone can improve this code or make anything out of it, I would be
very pleased to have a copy of the source.
Please, excuse my English.I haven't practised it for a long time.}

PROGRAM SnowScreenSaver; {Nick Batalas 14-6-1994}
USES crt,dos;
const
  dots =100;   {Set this to more than 100 and the result is awful}

var
  j,k : integer; {loop variables}
  i : longint;
  x,y : array[1..dots] of integer;
  cols    : array[1..dots] of byte;
  f,g : word;

{--------------Procedures Needed For This Great Screen Saver------------}
PROCEDURE SetVideoMode(mode : byte);assembler;
  ASM
    mov AH,0
    mov AL,mode
    int 10h
  END;

PROCEDURE writeDACreg(color,red,green,blue : byte);
  BEGIN
     port[$03C8]:=color;
     port[$03C9]:=red;
     port[$03C9]:=green;
     port[$03C9]:=blue;
  END;

PROCEDURE SetBordColB(color : byte); Assembler;
  ASM
    mov AH,10h
    mov AL,01h
    mov BH,color
    int 10h
  END;

PROCEDURE PutPixel1(x, y : word; color : byte);
  BEGIN
    mem[$A000:x+y*320] := color;
  END;

PROCEDURE HideTextCursor;
  VAR
    regs : registers;

  BEGIN
    regs.ah:= 1;
    regs.cx:=$2000;
    intr($10,regs);
  END;

Procedure WaitrBest;Assembler;
  ASM
    cli
    mov dx,3DAh
    @l1:
    in al,dx
    and al,08h
    jnz @l1
    @l2:
    in al,dx
    and al,08h
    jz  @l2
    sti
  END;

FUNCTION xf3(ux,t : real) : word;   {Calculates the speed of a point}
  BEGIN                             {on the x axis}
    xf3 := round(ux*t)  +160;
  END;

FUNCTION yf3(uy,g,t : real) : word; {Calculates the speed of a point}
  VAR                               {on the y axis (which is affected}
    u,tmax,hmax : real;             {by gravity)}
    ym : array[1..200] of word;
    a  : word;
  BEGIN
    u := uy-g*t;
    a:= round(uy*t-1/2*g*t*t);
    yf3 := 200-a ;
  END;

Function RandomCol :byte;   {Just a random value between 7 and 15 (I think)}
  BEGIN
    randomcol:=random(6)+9;
  END;

{-------------------------------MAIN PROGRAMME-------------------------}
BEGIN
  hideTextCursor;
  j:=-50;                   {calculate the values of the speed of each dot}
  for k:=1 to dots do begin {with this loop}
    j:=j+3;
    x[k]:=j;
    y[k]:=random(150);
  END;
  For i:=1 to dots do      {Calculate the color of each dot}
    cols[i]:= randomcol;
  SetVideoMode($13);
  For i:= 1 to 63 do
    writedacreg(15,i,i,i);
  writedacreg(7,15,15,15);       {modify color registers in order}
  writedacreg(8,20,20,20);       {to give a sense of depth to the}
  writedacreg(9,25,25,25);       {dots}
  writedacreg(10,30,30,30);
  writedacreg(11,35,35,35);
  writedacreg(12,40,40,40);
  writedacreg(13,45,45,45);
  writedacreg(14,50,50,50);
  For i:=1 to 5 do             {the background color turns to dark blue}
    writedacreg(0,0,0,i);
  setbordcolb(0);
  i:=18500;
  j:=1;
  Repeat
    i:=i+1;
    FOR k:=1 to dots do
      putpixel1(xf3(x[k],0.01*i),yf3(y[k],j,0.01*i),cols[k]);
    waitrbest;
    FOR k:=1 to dots do
      putpixel1(xf3(x[k],0.01*i),yf3(y[k],j,0.01*i),0);
  Until keypressed;
  SetVideoMode(3);

END.
