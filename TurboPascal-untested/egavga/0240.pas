{$M 4096,0,0}
{$a+,b-,d+,e-,f-,g+,i+,l+,n-,o-,p-,q-,r-,s+,t-,v+,x+}

{ if you have a 386 or better 'uncomment' the next line }
{define cpu386}

{ if you want circles 'incomment' the next line }
{$define CIRCLES }

Program WrmhDance; { Demo by Wil Barath Oct 1994, Public Domain }
     { Based on Vortex demo by ??? } 
Var
  Map:word; {used as a pointer to the bitmap}
  stab,ctab:array[0..255] of integer;
  virseg:word;
  lstep:byte;
const
  vidseg:word=$a000;
  pfx=1;    {try '1' for weird palette fx}
  SlowMode:Boolean=False;
  Circles:Boolean=False;
Procedure AllocateMem;  {returns a segment pointer for a 64K bitmap}
label noerror;
begin
     asm
              mov   ah,$48
              mov   bx,$1000     { request 64K }
              int   $21
              jnc   noerror
              mov   ax,0000
     noerror: mov   Map,ax       { The segment pointer goes in Map }
              end;
     If Map=0 then begin
        Writeln('Could not allocate enough memory');
        Writeln('Program ending...');
        Halt;end;
end;

Procedure GiveBackMem; {returns the memory used for the map to the system}
begin
     asm
        mov  ah,$49
        mov  dx,Map
        mov  es,dx
        int  $21
     end;
end;
procedure setpal(col,r,g,b : byte); assembler;
asm
  mov dx,03c8h
  mov al,col
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
end;

procedure cls(lvseg:word); assembler;
asm
  mov es,[lvseg]
  xor di,di
  xor ax,ax
{$ifdef cpu386}
  mov cx,256*256/4
  rep
  db $66; stosw
{$else}
  mov cx,256*256/2
  rep stosw
{$endif}
end;

procedure retrace; assembler;
asm
  mov dx,03dah
 @vert1:
  in al,dx
  test al,8
  jnz @vert1
 @vert2:
  in al,dx
  test al,8
  jz @vert2
end;

Var cotable:Array[0..256] of Integer;
Const costabptr:Pointer=(@CoTable);
{----------------------------------------------------------------------}
Procedure VideoMode(mode:word);assembler;
Asm Mov ax,mode;Int 10h;end;
Function MouseExists:Boolean;Assembler;
asm Xor ax,ax;Int 33h;end;
Function MouseAt(Var X:Word;Var y:Word):Word;assembler;
asm Mov ax,03h;Int 33h;Les di,x;Mov ES:[DI],cx;Les di,y;Mov ES:[DI],dx
Mov ax,bx;end;
Function Readkey:Char;Assembler;
asm Xor ax,ax;Int 16h;end;
Function Keypressed:Boolean;Assembler;
asm Mov ax,0100h;int 16h;Jnz @1;Xor ax,ax;@1:
end;
Function MouseStatus:LongInt;Assembler;
asm Xor ax,ax;Int 33h;end;
Procedure Pset(x,y,c:byte);Assembler;
asm mov es,virseg;mov bh,y;Mov bl,x;Mov al,c;Mov es:[bx],al;end;
Var ra,rb,rc:Word;
Function rand:Word; Near ;Assembler;
asm Mov ax,ra; Add ax,ax; Adc ax,904; Xor ax,$aaaa;Mov ra,ax;Xor ax,rb;Mov rb,ax;
Xor ax,rc; Mov rc,ax; end;
Function random(n:Word):Word; Near ;Assembler;
asm Call Rand; Mul n;Mov ax,dx;end;
Procedure mktabl;assembler;             {generates Sine approx. table}
Const x:Integer=127*256+221;y:integer=0;{much smaller than using BP's}
label cosloop;                          {FP math to make it!         }
asm                                     {Oct 10/94 by Wil Barath     }
  Mov si,804      {sine portion of O }
  Mov bx,32758    {cosine portion of O }
  Mov cx,256      {number of degrees in our circle}
  Les di,costabptr{destination for our table}
  Push bp
cosloop:
  Mov ax,x
  stosw
  Imul bx
  adc dx,dx
  Mov bp,dx       {bp:= x*cos(O)}
  Mov ax,si
  Imul y
  adc dx,dx
  Sub bp,dx       {bp:= x*cos(O)-y*sin(O)}
  Mov ax,bp
  Mov al,ah
  Mov ax,si
  Imul x
  adc dx,dx
  Mov x,bp        {x:=bp}
  Mov bp,dx       {bp:= x*sin(O)}
  Mov ax,bx
  Imul y
  adc dx,dx
  add bp,dx       {bp:= x*sin(O)+y*cos(O)}
  Mov y,bp        {y:=bp}
  Loop cosloop
  Pop bp
end;
{----------------------------------------------------------------------}
Procedure DrawScreen(x,y,scale:Word;rot:word);assembler;
label start,hloop,vloop;
Procedure I;assembler;asm db 0;end; {fool the compiler into giving us}
Procedure j;assembler;asm db 0;end; {2 WORD variables in CODE segment}
asm
  push ds    { gotta save these or all hell breaks loose :-( }
  Push bp
  Mov bx,rot {compute scanning vectors}
  Add bx,bx
  Mov ax,word(cotable[bx])
  Imul scale {result in dx = scale*(ah/256)+scale*(al/65536)}
  Mov si,dx  {thusly si:=costable[rot]*scale/256}
  Add bx,128
  AND bx,511
  Mov ax,word(cotable[bx])
  Imul scale
  Mov cx,dx  {cx:=costable[(rot+64)Mod 256]*scale/256}
             {this gives us the same as sin(...)}
  Mov bx,x   {compute screen center for rotation}
  Mov ax,160
  Mul si
  Sub bx,ax
  Mov ax,100
  Mul cx
  add bx,ax
  Mov Word(i),bx    {i:=x-si*160+cx*100}
 Mov bx,y
  Mov ax,160
  Mul cx
  Sub bx,ax
  Mov ax,100
  Mul si
  Sub bx,ax
  Mov Word(j),bx    {j:=y-cx*160-si*100}
  Mov  bp,cx        { put movement vector component here...}
                    { from here on we can't reference STACK variables...}
  mov  ax,[Map]     { get segment of bitmap (in the DATA segment)}
  mov  ds,ax
  mov  ax,$a000     { set es: to video memory}
  mov  es,ax
  sub  di,di        { start at 0,0 on the screen}
  mov  cx,200       { Number of rows on Screen}
{-----This section has been hyper-optimised for 286+-------------------}
vloop:
  push cx
  mov  bx,Word(j)   { start scanning the source bitmap}
  mov  dx,Word(i)   { at i,j which were calculated above.}
  mov  cx,160       { Number of columns on screen/2}
hloop:
  add  bx,bp        { add the 'right' vector }
  add  dx,si    { add the 'down' vector }
  xchg bl,dh        { set up 8.8 fixed w/ Right MOD 256 and Down MOD 256}
  mov  al,[bx]      { load a pixel from source }
  xchg bl,dh        { restore the counting registers}
  add  bx,bp        { add the 'right' vector }
  add  dx,si    { add the 'down' vector }
  xchg bl,dh        { set up 8.8 fixed w/ Right MOD 256 and Down MOD 256}
  mov  ah,[bx]      { load a pixel from source }
  Stosw        { write and advance 2 
pixels (could do 4 w/386!)}
  xchg bl,dh        { restore the counting registers}
  Loop  hloop       { End of horizontal loop}
  dec  si;dec bp  { Unquote one or both of these to cause mag. f/x}
  sub  Word(i),bp   { i,j is the starting coords for a line }
  add  Word(j),si   { so this moves down one line }
  Pop  cx
  loop vloop        { End of verticle loop }
{-----That's all there is to the actual screen-writing section!--------}
  Pop  bp
  pop  ds           { Restore the ds }
end;
{----------------------------------------------------------------------}
var ax,ay,mx,my,x,y,h,i,j:word; c:byte;
    rot,dist,mouse:Word;
    dr,dx,dy,dd:Integer;

procedure Circle(cx,cy,r,c:Integer);
var rr,xx,yy:longint;x320,y320,p:Word;x,y:Integer;
label Draw;
begin
  rr:=r;y:=0;x:=r;rr:=r*r;xx:=rr-x;yy:=0;
  x320:=x*256;y320:=y;p:=cx+cy*256;
  asm
    Jmp @Skip
@Curse:
    Add di,dx    {dx is the x offset from center}
    Mov es:[di+bx],al  {draw 4 cursor positions}
    Neg bx
    Mov es:[di+bx],al
    Sub di,dx
    Sub di,dx
    Mov es:[di+bx],al
    Neg bx
    Mov es:[di+bx],al
    Add di,dx
    Ret
Draw:
    Mov es,VirSeg
    Mov di,p     {di is the center of the circle}
    Mov bx,y320   {bx is the Y offset from center}
    Mov dx,x
    Mov ax,c
    Call @Curse  {draw the 4 cursors in their quadrants}
    Mov bx,x320
    Mov dx,y
    Call @Curse  {draw the 4 cursors at 90 degrees}
    ret
@Skip:
  end;
  Repeat
    if xx>(rr-yy) then
    Begin
{      asm call draw;end;{}
      Inc(xx,1-x-x);dec(x);dec(x320,256);
    end;
    asm call draw;end;
    Inc(yy,y+y+1);inc(y);inc(y320,256);
  Until x<y;
end;{}


Procedure DoStars;
var dsa,dsb,dsc,l:word;
const x:Word=0;
Begin
  inc(x,2);
  dsa:=ra;dsb:=rb;dsc:=rc;
  ra:=0;rb:=0;rc:=0;
  For l:=0 to 1024 do Mem[VirSeg:rand+x]:=240+rand AND $15;
  ra:=dsa;rb:=dsb;rc:=dsc;
end;

begin
  ra:=1;
  MouseStatus;
  AllocateMem;
  mktabl;
  mx:=128*256; my:=32*256;         {this corresponds to (128,32) in fixed 
point}
  rot:=192; dr:=1;          {rotation angle and it's delta}
  dist:=500; dd:=Word(0);  {distance to bitmap (sort of) and its delta}
  videomode($13);
  for i:=0 to 255 do begin
    ctab[i]:=cotable[i] div 400;
    stab[i]:=cotable[Byte(i+64)]div 640;
  end;
  virseg:=Map;
  x:=30; y:=90;
  repeat
  cls(virseg);
  {  retrace;{}
    dostars;
    c:=3; lstep:=33;
    if mx<128 then ax:=x else ax:=256-x;
    if my<128 then ay:=y else ay:=256-y;
   for i:=1 to 255 do Setpal(i,i+i+ax shr pfx,i+i+ay shr 
pfx,i+i+(ax+ay)shr (pfx+1));
    While c<20 do
    Begin
      j:=(c*(c+3))SHR(2)+5;
      i:=0;
   ax:=ctab[Byte(x-j+200)];
      ay:=stab[Byte(y-j+200)];
{$ifdef CIRCLES}
      If Circles then circle(ax+160,ay+100,j,c)
      Else If Random(1000)=3 then Begin Circles:=True; SlowMode:=True; end;
{$endif}
      If SlowMode then
    Begin
      DrawScreen(mx,my,dist,lo(rot));
        If Random(200)=0 then SlowMode:=False;
      end;
      Inc(c);
    end;
    DRAWScreen(mx,my,dist,lo(rot));
    If random(10)=0 then
  Begin
    dx:=dx+random(51)-25;
      dx:=dx*6 Div 9;
    end;
    If random(20)=0 then
  Begin
    dy:=dy+random(51)-25;
      dy:=dy*6 div 9;
    end;
    x:=Byte((x+dx+x+random(2)) SHR 1);
    y:=Byte((y+dy+y+random(2)) SHR 1);
    If Random(12)=0 then
   Begin
     dd:=dd+10-Random(21);
        dd:=dd*7 DIV 8;
      end;
    If Random(50)=1 then
   Begin
     dr:=dr+3-Random(7);
        dr:=dr*8 DIV 9;
      end;
        rot:=rot+dr;
        mouse:=MouseAt(mx,my);
        Case Mouse of
          1: Inc(dist,1+(dist SHR 4));
          2: Dec(dist,1+(dist SHR 4));
          3: dist:=1000;
          4: rot:=mx;
        end;
        mx:=mx*100;my:=my*256;
        if ((dist+dd)>500) THEN DD:=-5;
    If ((dist+dd)<10) then dd:=10;
        dist:=dist+dd;
  until keypressed;
  while keypressed do readkey;
     GiveBackMem;
     VideoMode($03);
end.
