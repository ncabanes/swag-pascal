(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0287.PAS
  Description: Very fast and usable graphics unit
  Author: PAVEL STRATIL
  Date: 01-02-98  07:35
*)


version 2.02
copile/use this in far model
wait for the new 3.00 version - 70k large

{$G+}
type VirtualArray = array[1..64000] of byte;
     VPointer = ^VirtualArray;
     coor = record
               x,y:word;
            end;
     coordtyp = array [1..2,1..12] of integer;
     fp = longint;
var  coord : array [1..20] of coor;

{ ******************************* DOS ************************************ }

function DosMax : longint;assembler;{vrati velikost volne dol. pam. v bytech}
asm  {OK}
  mov bx,0ffffh
  mov ah,48h
  int 21h
  mov ax,bx
  mov bx,16
  mul bx
end;

function GMem(size:longint) : pointer;assembler;
asm   {OK}
@@1:
  mov ax,word ptr [size]
  mov dx,word ptr [size+2]
  mov cx,16
  div cx
  inc ax
  mov bx,ax
  mov ah,48h
  int 21h
  jnc @@2
  xor ax,ax
@@2:
  mov dx,ax
  xor ax,ax
end;

procedure FMem(p:pointer);assembler;
asm   {OK}
  mov es,word ptr [p+2]
  mov ah,49h
  int 21h
end;

function ReAlloc(p:pointer; newsize:longint) : pointer;assembler;
asm   {OK}
  mov ax,word ptr [p+2]
  mov es,ax
  mov ax,word ptr [newsize]
  mov dx,word ptr [newsize+2]
  mov cx,16
  div cx
  inc ax
  mov bx,ax
  mov ah,4ah
  int 21h
  jnc @@end
  xor dx,dx
  xor ax,ax
@@end:
end;


{ ******************************* CRT ************************************ }

{ MOUSE }

procedure MouseInit(no:word);assembler;
asm
  mov ax,no
  int 33h
end;

procedure GetMouse(var x,y,b:word);assembler;
asm   {OK}
  mov ax,3
  int 33h
  les di,dword ptr [bp+0eh]
  mov word ptr es:[di],bx
  les di,dword ptr [bp+0ah]
  mov word ptr es:[di],cx
  les di,dword ptr [bp+6]
  mov word ptr es:[di],dx
end;

procedure SetMWin(x,y,x2,y2:word);assembler;
asm   {OK}
  mov ax,7
  mov cx,[x]
  mov dx,[x2]
  int 33h
  inc ax
  mov cx,[y]
  mov dx,[y2]
  int 33h
end;  {OK}

procedure NewCur(hotspotx,hotspoty:word;var newcursor);assembler;
asm
mov ax,word ptr newcursor+2
mov es,ax
mov dx,word ptr newcursor
mov ax,9h
mov bx,hotspotx
mov cx,hotspoty
int 33h
end;

{ KEYBOARD }

procedure KeybOn;assembler;
asm   {OK}
  in al,21h
  and al,11111101b
  out 21h,al
end;

procedure KeybOff;assembler;
asm   {OK}
  in al,21h
  or al,00000010b
  out 21h,al
end;

function KeyPressed:boolean;
begin
  asm
    mov	ah,1
    int	16h
    jnz	@true
    mov	[@result],false
    jmp	@end
@true:
    mov	[@result],true
@end:
  end;
end;

function ReadKey:char;assembler;
asm   {OK}
  mov ah,0h
  int 16h
end;

{ PC SPEAKER }

procedure NoSound;assembler;
asm   {OK}
  in al,61h
  and al,0fch
  out 61h,al
end;

procedure Sound(hz:word);assembler;
asm   {OK}
  mov bx,hz
  mov ax,34ddh
  mov dx,0012h
  cmp dx,bx
  jnc @2
  div bx
  mov bx,ax
  in al,61h
  test al,3
  jnz @1
  or al,3
  out 61h,al
  mov al,0b6h
  out 43h,al
@1:
  mov al,bl
  out 42h,al
  mov al,bh
  out 42h,al
@2:
end;

{ MISCELANEOUS }

procedure XDelay(ms:word);assembler;
asm   {OK}
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,86h
  int 15h
end;

{ ******************************** GRAPH ********************************** }

{ BASIC }

procedure SetVga(mode:word);assembler;
asm   {OK}
  mov ax,[mode]
  int 10h
end;

procedure Cls(target:word);assembler;
asm   {OK}
  mov ax,[bp+offset target]
  mov es,ax
  xor di,di
  db 66h; xor ax,ax
  mov cx,16000
  db 0f3h,66h,0abh
end;

procedure CCls(color:byte;target:word);assembler;
asm   {OK}
  mov ax,[target]
  mov es,ax
  xor di,di
  mov cx,16000
  mov al,[color]
  mov ah,al          {hi i low maji hodnotu barvy}
  mov bx,ax
  db 66h; shl ax,16  {ax*65535 -> hi word eax}
  mov ax, bx         {dolni word eax - v kazdym bytu eax je hodnota barvy}
  db 0f3h,66h,0abh   {rep movsd}
end;

procedure PPix(x,y: Integer;color:byte;target:word); assembler;
asm   {OK}
  mov ax,target
  mov es,ax
  mov ax,y
  mov di,ax
  shl ax,6
  shl di,8
  add di,ax
  add di,x
  mov al,color
  mov es:[di],al
end;

function GPix(x,y:integer;target:word):byte;assembler;
 asm  {OK}
  mov ax,target
  mov es,ax
   mov ax,y
   mov di,ax
   shl ax,6
   shl di,8
   add di,ax
   add di,x
   mov al,es:[di]
   mov [bp-1],al
end;

{ 2D GRAPHIC }

procedure HLn(x1,x2,y:word;col:byte;target:word);assembler;
asm   {OK}
  mov ax,target
  mov es,ax
  mov ax,y
  mov di,ax
  shl ax,8
  shl di,6
  add di,ax
  add di,x1        {pocatecni x1}
  mov al,col
  mov ah,al
  mov cx,x2
  sub cx,x1        {cx:=x2-x1}
  inc cx
  shr cx,1         {cx:=cx/2}
  jnc @1           {sklace na @1 a misto stosb jede 2* rychlejsi stosw}
  mov es:[di],ah
  inc di
@1:
  rep stosw      {mov es:[di],ah cx/2*2 krat}
end;

procedure HLn32(x1,x2,y:word;col:byte;target:word);assembler;
asm   {OK}
  mov ax,target
  mov es,ax
  mov ax,y
  mov di,ax
  shl ax,8
  shl di,6
  add di,ax
  add di,x1        {pocatecni x1}
  mov al,col
  mov ah,al
  mov bx,ax
  db $66; shl ax,16
  mov ax,bx
  mov cx,x2
  sub cx,x1        {cx:=x2-x1}
  inc cx
  mov bx,cx
  and bx,3
  shr cx,2
  db 66h; rep stosw
@2:
  mov es:[di],al
  add di,1
  dec cx
jns @2
end;

procedure VLn(x1,y1,y2:word;c:byte;target:word);assembler;
asm   {OK}
  mov ax,x1
  mov bx,y1
  mov dx,y2
@1:
  mov di,bx
  mov cx,di
  shl cx,8
  shl di,6
  add di,cx
  add di,ax
  mov cx,[target]
  mov es,cx
  mov cx,dx
  sub cx,bx
  inc cx
  mov al,c
@2:
  stosb
  add di,319
  loop @2
end;

procedure XLine(x,y,x2,y2:integer;color:byte;target:word);
var ax,bx,ay,by,f,aa,bb:integer;
begin
  if x<x2 then begin ax:=1;bx:=x2-x; end
          else begin ax:=-1;bx:=x-x2; end;
  if y<y2 then begin ay:=1;by:=y2-y; end
          else begin ay:=-1;by:=y-y2; end;
  if bx>by then begin
    aa:=(by-bx)*2;
    bb:=by*2;
    f:=bb-bx;
    repeat
      if(f>=0)then begin inc(y,ay);inc(f,aa);end
              else inc(f,bb);inc(x,ax);
      PPix(x,y,color,target);
    until(x=x2);
  end
           else begin
    aa:=(bx-by)*2;
    bb:=bx*2;
    f:=bb-by;
    repeat
      if(f>=0)then begin inc(x,ax);inc(f,aa);end
              else inc(f,bb);inc(y,ay);
      PPix(x,y,color,target);
    until(y=y2);
  end;
end;

procedure XCircle(x,y:integer;radius,ankle:word;color:byte;
                  presnost:word;posun:integer;target:word); {posun- 1/8 presnosti}
var g,h,e,f,c,d,a:real;
i,rotX,rotY:integer;
b:word;
begin
  a:=presnost/ankle;
  b:=round(presnost*(ankle/360));
  c:=a*radius;
  d:=(2*Pi)/presnost;
  e:=5/6;
  for i:=posun to posun+b do begin
    f:=d*i;
    g:=c*sin(f);
    h:=c*cos(f);
    rotX:=round((g-h)/a);
    rotY:=round(((g+h)/a)*e);
    ppix((rotX+x),(rotY+y),color,target);
  end;
end;

procedure Ellipse(x,y,a,b:integer;c:byte;target:word);
var xa,ya:integer;
    aa,aa2,bb,bb2,d,dx,dy:longint;
begin
  xa:=0;ya:=b;
  aa:=longint(a)*a;aa2:=2*aa;
  bb:=longint(b)*b;bb2:=2*bb;
  d:=bb-aa*b+aa div 4;
  dx:=0;dy:=aa2*b;
  ppix(x,y-ya,c,target);
  ppix(x,y+ya,c,target);
  ppix(x-a,y,c,target);
  ppix(x+a,y,c,target);
  while(dx<dy)do begin
      if(d>0)then begin dec(ya);
      dec(dy,aa2);
      dec(d,dy);
    end;
    inc(xa);
    inc(dx,bb2);
    inc(d,bb+dx);
    ppix(x+xa,y+ya,c,target);
    ppix(x-xa,y+ya,c,target);
    ppix(x+xa,y-ya,c,target);
    ppix(x-xa,y-ya,c,target);
  end;
  inc(d,(3*(aa-bb)div 2-(dx+dy))div 2);
  while(ya>0)do begin
      if(d<0)then begin
      inc(xa);
      inc(dx,bb2);
      inc(d,bb+dx);
    end;
    dec(ya);
    dec(dy,aa2);
    inc(d,aa-dy);
    ppix(x+xa,y+ya,c,target);
    ppix(x-xa,y+ya,c,target);
    ppix(x+xa,y-ya,c,target);
    ppix(x-xa,y-ya,c,target);
  end;
end;

procedure FillEllipse(x,y,a,b:integer;c:byte;target:word);
var xa,ya:integer;
    aa,aa2,bb,bb2,d,dx,dy:longint;
begin
  xa:=0;ya:=b;
  aa:=longint(a)*a;
  aa2:=2*aa;
  bb:=longint(b)*b;
  bb2:=2*bb;
  d:=bb-aa*b+aa div 4;
  dx:=0;dy:=aa2*b;
  vLn(x,y-ya,y+ya,c,target);
  while(dx<dy)do begin
      if(d>0)then begin dec(ya);
      dec(dy,aa2);
      dec(d,dy);
    end;
    inc(xa);
    inc(dx,bb2);
    inc(d,bb+dx);
    vLn(x-xa,y-ya,y+ya,c,target);
    vLn(x+xa,y-ya,y+ya,c,target);
  end;
  inc(d,(3*(aa-bb)div 2-(dx+dy))div 2);
  while(ya>=0)do begin
      if(d<0)then begin
      inc(xa);
      inc(dx,bb2);
      inc(d,bb+dx);
      vLn(x-xa,y-ya,y+ya,c,target);
      vLn(x+xa,y-ya,y+ya,c,target);
    end;
    dec(ya);
    dec(dy,aa2);
    inc(d,aa-dy);
  end;
end;

procedure Triangle(x1,y1,x2,y2,x3,y3:integer;color:byte;target:word);
var
 x,minY,maxY,ax,bx,yy,p1,q1,p2,q2,p3,q3:integer;
begin
  minY:=y1; maxY:=y1;
  if y2<minY then minY:=y2;
  if y2>maxY then maxY:=y2;
  if y3<minY then minY:=y3;
  if y3>maxY then maxY:=y3;
  p1:=x1-x3; q1:=y1-y3;
  p2:=x2-x1; q2:=y2-y1;
  p3:=x3-x2; q3:=y3-y2;
  for yy:=minY to maxY do
    begin
      ax:=320;
      bx:=-1;
      if (y3>=yy) or (y1>=yy) then
        if (y3<=yy) or (y1<=yy) then
          if not(y3=y1) then begin
              x:=(yy-y3)*p1 div q1+x3;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if ax<=bx then hln(ax,bx,yy,color,target);
    end;
end;

procedure XTriangle(x1,y1,x2,y2,x3,y3:integer;color:byte;target:word);assembler;
var tmp1,tmp2,neg1,neg2,ax1,ax2,ay1,ay2:integer;
asm   {OK}
  cli                      {y-trideni}
  mov cx,2                 {cx=2}
@sort:
  mov ax,[y2]
  cmp ax,[y3]
  jbe @ok1                { if y2 <= y3 then @ok1 }
  xor ax,[y3]
  xor [y3],ax
  xor ax,[y3]
  mov [y2],ax
  mov ax,[x2]             {ted neco jako xchg y2,y3}
  xor ax,[x3]
  xor [x3],ax
  xor ax,[x3]
  mov [x2],ax             {stejne pro x}
  @ok1:
    mov ax,[y1]
    cmp ax,[y2]
    jbe @ok2              {kdyz je y1 vetsi,jak y2 pak na @3}
    xor ax,[y2]
    xor [y2],ax
    xor ax,[y2]
    mov [y1],ax           {jinak xchg y1,y2}
    mov ax,[x1]
    xor ax,[x2]
    xor [x2],ax
    xor ax,[x2]
    mov [x1],ax           {xchg x1,x2}
  @ok2:
    mov ax,[y1]
    cmp ax,[y3]
    jbe @ok3              {y1<=y3 pak ok}
    xor ax,[y3]
    xor [y3],ax
    xor ax,[y3]
    mov [y1],ax           {xchg y1,y3}
    mov ax,[x1]
    xor ax,[x3]
    xor [x3],ax
    xor ax,[x3]           {xchg x1,x3}
    mov [x1],ax
  @ok3:
loop @sort
  mov dx,[y1]             {vypocet offsetu}
  shl dx,6
  mov bx,dx
  shl dx,2
  add dx,bx
  add dx,[x1]
  mov si,dx               {si,dx:=320*y1+x1}
  mov ax,[y3]             {vypocet ay-nu}
  sub ax,[y1]
  inc ax
  mov [ay1],ax            {*ay1=y3-y1}
  mov [tmp1],ax           {*tmp1=y3-y1}
  mov ax,[y2]
  sub ax,[y1]
  inc ax
  mov [ay2],ax            {*ay2=y2-y1}
  mov [tmp2],ax           {*tmp2=y2-y1}
                          {vypocet ax-u}
  mov [neg1],1            {*if1=1}
  mov ax,[x3]
  sub ax,[x1]             {ax,sirka}
  jnc @noneg1             {kdyz>=0 pak skip, jinak}
  neg ax                  {a dostanu abs(x3-x1)}
  neg [neg1]              {*neg1=65535}
@noneg1:
  inc ax                  {inc sirka}
  mov [ax1],ax            {*ax1=x3-x1}
  mov [neg2],1            {*neg2=1}
  mov ax,[x2]
  sub ax,[x1]
  jnc @noneg2             {x2-x1 jnc skok}
  neg ax                  {neg-abs}
  neg [neg2]              {*neg2=65535}
@noneg2:
  inc ax
  mov [ax2],ax            {*ax2=x2-x1}

  mov ax,[target]
  mov es,ax
  mov al,[color]
  mov ah,al               {ax,color}
  mov cx,[ay2]            {od y1 do y2}
@draw1:
  push cx
  mov di,dx               {hln}
  mov cx,si
  cmp cx,di
  ja @noswap1
  xchg cx,di
@noswap1:
  sub cx,di
  inc cx
  shr cx,1
  jnc @1
  stosb
@1:
  rep stosw
                          {zmena tmpu a ay}
  mov bx,[tmp1]           {bx=y3-y1}
  sub bx,[ax1]            {bx:=(y3-y1)-(x3-x1)}
  cmp bx,0
  jg @no1                 {=0 then skok, else..}
@yes1:
  add bx,[ay1]            {bx:=2*(y3-y1)-(x3-x1)}
  add dx,[neg1]           {add dx,1 nebo 65535}
  cmp bx,0
  jle @yes1               {loop}
@no1:
  add dx,320              {offset+320}
  mov [tmp1],bx

  mov bx,[tmp2]           {y2-y1}
  sub bx,[ax2]            {-(x2-x1)}
  cmp bx,0
  jg @no2
@yes2:
  add bx,[ay2]
  add si,[neg2]
  cmp bx,0
  jle @yes2               {dokud bx>=0}
@no2:
  add si,320              {add ofs2,320}
  mov [tmp2],bx
  pop  cx
loop @draw1

{2. cast polyho}
  push dx
  mov dx,[y3]
  sub dx,[y2]
  inc dx
  mov [ay2],dx
  mov [tmp2],dx
  mov [neg2],1
  mov dx,[x3]
  sub dx,[x2]
  jnc @x2pos
  neg dx
  neg [neg2]
@x2pos:
  inc dx
  mov [ax2],dx
  pop dx
  mov cx,[ay2]
@draw2:
  push cx
  mov di,dx
  mov cx,si
  cmp cx,di
  ja @noswap2
  xchg cx,di
@noswap2:
  sub cx,di
  inc cx
  shr cx,1
  jnc @2
  stosb
@2:
  rep stosw
  mov bx,[tmp1]
  sub bx,[ax1]
  cmp bx,0
  jg @no3
@yes3:
  add bx,[ay1]
  add dx,[neg1]
  cmp bx,0
  jle @yes3
@no3:
  add dx,320
  mov [tmp1],bx

  mov bx,[tmp2]
  sub bx,[ax2]
  cmp bx,0
  jg @no4
@yes4:
  add bx,[ay2]
  add si,[neg2]
  cmp bx,0
  jle @yes4
@no4:
  add si,320
  mov [tmp2],bx
  pop cx
  loop @draw2
@exit:
  sti
end;

procedure Poly4(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;target:word);
var
 x,minY,maxY,ax,bx,yy,p1,q1,p2,q2,p3,q3,p4,q4:integer;
begin
  minY:=y1; maxY:=y1;
  if y2<minY then minY:=y2;
  if y2>maxY then maxY:=y2;
  if y3<minY then minY:=y3;
  if y3>maxY then maxY:=y3;
  if y4<minY then minY:=y4;
  if y4>maxY then maxY:=y4;
{y2-4 se porovnaji k y1, ziska se nejmensi a nejvetsi y}
  if minY<0 then minY:=0;
  if maxY>199 then maxY:=199;
  if minY>199 then exit;
  if maxY<0 then exit;
{nebude se prekreslovat zpatky}
  p1:=x1-x4; q1:=y1-y4;
  p2:=x2-x1; q2:=y2-y1;
  p3:=x3-x2; q3:=y3-y2;
  p4:=x4-x3; q4:=y4-y3;
{vzdalenosti mezi vsemy x a mezi vsemy y}
{pro vysku polyho dela..}
  for yy:=minY to maxY do
    begin
      ax:=320;
      bx:=-1;
      if (y4>=yy) or (y1>=yy) then
        if (y4<=yy) or (y1<=yy) then   {jestlize je yy mezi y1 a y4 pak.. }
          if not(y4=y1) then begin
              x:=(yy-y4)*p1 div q1+x4;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then   {jestlize je yy mezi y1 a y2 pak..}
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then  {jestlize je yy mezi y2 a y3 pak..}
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y3>=yy) or (y4>=yy) then
        if (y3<=yy) or (y4<=yy) then   {jestlize je yy mezi y3 a y4 pak..}
          if not(y3=y4) then begin
              x:=(yy-y3)*p4 div q4+x3;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if ax<0 then ax:=0;
      if bx>319 then bx:=319;
      if ax<=bx then hln(ax,bx,yy,color,target);      {horesli horiz. caru}
    end;
end;

procedure PolyInit(var init:coordtyp;PocetBodu:byte);
var i:byte;
begin
for i:=1 to PocetBodu do
  begin
    coord[i].x:=init[1,i];
    coord[i].y:=init[2,i];
  end;
end;

procedure XPoly(rohu:byte;color:byte;target:word);
type int=record
       p,q:integer;
       end;
var yy,x,ax,bx,i,minY,maxY:integer;
internal:array[1..20] of int;
begin
  minY:=coord[1].y;
  maxY:=coord[1].y;
  for i:=2 to rohu do begin
    if coord[i].y<minY then minY:=coord[i].y;
    if coord[i].y>maxY then maxY:=coord[i].y;
  end;
  if minY<0 then minY:=0;
  if maxY>199 then maxY:=199;
  if minY>199 then exit;
  if maxY<0 then exit;
  internal[1].p:=coord[1].x-coord[rohu].x;
  internal[1].q:=coord[1].y-coord[rohu].y;
  for i:=0 to rohu-2 do
    begin
      internal[i+2].p:=coord[i+2].x-coord[i+1].x;
      internal[i+2].q:=coord[i+2].y-coord[i+1].y;
    end;
  for yy:=minY to MaxY do
    begin
      ax:=320;
      bx:=-1;
      if (coord[rohu].y>=yy) or (coord[1].y>=yy) then
        if (coord[rohu].y<=yy) or (coord[1].y<=yy) then
          if not(coord[rohu].y=coord[1].y) then begin
              x:=(yy-coord[rohu].y)*internal[1].p div internal[1].q+coord[rohu].x;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
          if ax<0 then ax:=0;
          if bx>319 then bx:=319;
          if ax<=bx then hln(ax,bx,yy,color,target);
       for i:=0 to rohu-2 do begin
         if (coord[i+1].y>=yy) or (coord[i+2].y>=yy) then
           if (coord[i+1].y<=yy) or (coord[i+2].y<=yy) then
             if not(coord[i+1].y=coord[i+2].y) then begin
                 x:=(yy-coord[i+1].y)*internal[i+2].p div internal[i+2].q+coord[i+1].x;
                 if x<ax then ax:=x;
                 if x>bx then bx:=x;
             if ax<0 then ax:=0;
             if bx>319 then bx:=319;
             if ax<=bx then hln(ax,bx,yy,color,target);
      end;
    end;
  end;
end;

{ PALETTE }

procedure SetRGB(color,r,g,b:Byte);assembler;
asm   {OK}
  mov dx,3c8h
  mov al,[Color]
  out dx,al
  inc dx
  mov al,[r]
  out dx,al
  mov al,[g]
  out dx,al
  mov al,[b]
  out dx,al
end;

procedure GetRGB(Color:byte;var r,g,b:byte);assembler;
asm   {OK}
  mov dx,3c7h
  mov al,[color]
  out dx,al
  inc dx
  inc dx
  in  al,dx
  les di,dword ptr [bp+14]
  mov byte ptr es:[di],al
  in al,dx
  les di,dword ptr [bp+10]
  mov byte ptr es:[di],al
  in al,dx
  les di,dword ptr [bp+6]
  mov byte ptr es:[di],al
end;

procedure RotPal(r,g,b:byte;skipR,skipG,skipB:boolean;loops,ms:integer);
type
  tcount = record
            r,g,b:real;
          end;
var
  i,c,rr,gg,bb:byte;
  red,blue,green:real;
  current,count:array [0..255] of tcount;
begin
  for c:=0 to 255 do begin
    getrgb(c,rr,gg,bb);
    if skipr=false then count[c].r:=(r-rr)/loops;
    if skipg=false then count[c].g:=(g-gg)/loops;
    if skipb=false then count[c].b:=(b-bb)/loops;
    current[c].r:=rr;
    current[c].g:=gg;
    current[c].b:=bb;
  end;
  for i:=1 to loops do begin
    for c:=0 to 255 do begin
      if skipr=false then current[c].r:=count[c].r+current[c].r;
      if skipg=false then current[c].g:=count[c].g+current[c].g;
      if skipb=false then current[c].b:=count[c].b+current[c].b;
      setrgb(c,round(current[c].r),round(current[c].g),round(current[c].b));
    end;
    xdelay(ms);
  end;
end;

procedure FadeIn(r,g,b:byte;loops,ms:integer);
type
  tcount = record
            r,g,b:real;
          end;
var
  i,c,rr,gg,bb:byte;
  red,blue,green:real;
  current,count:array [0..255] of tcount;
begin
  for c:=0 to 255 do begin
    getrgb(c,rr,gg,bb);
    count[c].r:=(r-rr)/loops;
    count[c].g:=(g-gg)/loops;
    count[c].b:=(b-bb)/loops;
    current[c].r:=rr;
    current[c].g:=gg;
    current[c].b:=bb;
  end;
  for i:=1 to loops do begin
    for c:=0 to 255 do begin
      current[c].r:=count[c].r+current[c].r;
      current[c].g:=count[c].g+current[c].g;
      current[c].b:=count[c].b+current[c].b;
      setrgb(c,round(current[c].r),round(current[c].g),round(current[c].b));
    end;
    xdelay(ms);
  end;
end;

{ VIRTUAL SCREENS }

function VSetup(VScreen:VPointer):word;
begin {OK}
  new(Vscreen);
  VSetup:=seg(vscreen^);
end;

procedure VDispose(Va:word);
var vscreen:pointer absolute va;
begin {OK}
  dispose(Vscreen);
end;

procedure Flip(source,target:word);assembler;
asm   {OK}
  push ds {kdyz se neulozi, pak je hodnota pointru nil a je to v prdeli}
  mov ax,target
  mov es,ax         {target:=es:[di]}
  mov ax,Source
  mov ds,ax         {sourcre:=ds:[si]}
  xor si,si
  xor di,di
  mov cx,16000
  db $f3,66h,$a5    {rep movsd}
  pop ds
end;

procedure FImage(x1,y1,x2,y2,sx,sy:integer;source,target:word);assembler;
asm
push ds
  mov ax,target
  mov es,ax         {target:=es:[di]}
  mov ax,Source
  mov ds,ax         {sourcre:=ds:[si]}
  mov si,y1
  mov ax,si
  shl si,6
  shl ax,8
  add si,ax
  add si,x1          {source}
  mov di,sy
  mov ax,di
  shl di,6
  shl ax,8
  add di,ax
  add di,sx           {dest}
  mov cx,y2
  sub cx,y1
  inc cx  {h}
  mov dx,x2
  sub dx,x1
  inc dx  {w}
  mov ax,dx
  and ax,3
@loop:
  mov bx,cx
  mov cx,dx
  shr cx,2
  db 66h; rep movsw
  mov cx,ax
  rep movsb
  add si,320
  add di,320
  sub si,dx
  sub di,dx
  mov cx,bx
  loop @loop
  pop ds
end;

{ IMGAES & BITMAPS }

procedure Bitmap(x,y,w,h:word;var bitmap);assembler;
asm
  push ds
  mov ax,word ptr bitmap+2
  mov ds,ax
  mov ax,$0a000
  mov es,ax
  mov si,word ptr bitmap
  mov ax,[y]
  mov di,ax
  shl ax,8
  shl di,6
  add di,ax
  add di,[x]
  mov cx,[h]
@loop:
  mov bx,cx
  mov cx,[w]
  shr cx,1
  jnc @1
  movsb
@1:
  rep movsw
  add di,320
  sub di,[w]
  mov cx,bx
  loop @loop
  pop ds
end;

procedure RLEBitmap(x,y,w,h:word;var bitmap);assembler;
asm
  push ds
  mov ax,word ptr bitmap+2
  mov ds,ax
  mov ax,$0a000
  mov es,ax
  xor si,si
  xor di,di
  mov si,word ptr bitmap
  mov ax,[y]
  mov di,ax
  shl ax,8
  shl di,6
  add di,ax
  add di,[x]
  mov cx,[h]
@loop:
  mov bx,cx
  mov cx,[w]
@1:
  mov al,ds:[si]
  cmp al,0
  je @2
  mov es:[di],al
  @2:
  inc di
  inc si
loop @1
  add di,320
  sub di,[w]
  mov cx,bx
  loop @loop
  pop ds
end;

procedure ScBitmap(x,y,w,h,tox,toy:word;var bitmap);
var tmp1,rx,repx,restx,ry,repy,resty:word;
{tmp1=add di,320 sub di,tox}
begin
repx:=tox div w;
restx:=tox mod w;
rx:=restx;
repy:=toy div h;
resty:=toy mod h;
ry:=resty;
asm
mov ax,320
sub ax,tox
mov tmp1,ax

push ds
mov ax,word ptr bitmap+2
mov ds,ax
mov ax,0a000h
mov es,ax
mov si,word ptr bitmap
mov ax,[y]
mov di,ax
shl ax,8
shl di,6
add di,ax
add di,[x]

mov cx,[h]
@loop:
  mov dx,cx
  mov bx,repy
  @line:
     mov cx,[w]
     @pixel:
        mov ax,repx
        @rep:
          movsb
          dec si
          dec ax
        jnz @rep
        mov ax,restx
        cmp ax,0
        je @no_rest
          movsb
          dec restx
          dec si
        @no_rest:
        inc si
        dec cx
    jnz @pixel
  add di,tmp1
  mov ax,rx
  mov restx,ax
sub si,[w]
dec bx
jnz @line

mov bx,resty
cmp bx,0
je @no_ry
  mov cx,[w]
  @pixel2:
     mov ax,repx
     @rep2:
       movsb
       dec si
       dec ax
     jnz @rep2
     mov ax,restx
     cmp ax,0
     je @no_rest2
       movsb
       dec restx
       dec si
     @no_rest2:
     inc si
     dec cx
  jnz @pixel2
  add di,tmp1
  mov ax,rx
  mov restx,ax
sub si,[w]
dec bx
mov resty,bx
 @no_ry:
add si,[w]
mov cx,dx
dec cx
jnz @loop
end;
end;

procedure GImage(x,y,x2,y2:word;p:pointer);assembler;
asm   {OK}
  push ds
  mov es,word ptr p+2
  mov di,word ptr p
  mov ax,0a000h
  mov ds,ax
  mov dx,[bp+offset x2]
  sub dx,[bp+offset x]
  inc dx
  mov ax,dx
  and ax,3
  mov es:[di],dx        {sirka dx}
  mov cx,[bp+offset y2]
  sub cx,[bp+offset y]
  inc cx
  mov es:[di+2],cx      {vyska cx}
  add di,4
  mov si,[bp+offset y]
  mov bx,si
  shl si,8
  shl bx,6
  add si,bx
  add si,[bp+offset x]
@loop:
  mov bx,cx
  mov cx,dx
  shr cx,2
  db 66h; rep movsw
  mov cx,ax
  rep movsb
  add si,320
  sub si,dx
  mov cx,bx
  loop @loop
  pop ds
end;

procedure PImage(x,y:word;p:pointer);assembler;
asm
  push ds
  mov ds,word ptr p+2
  mov si,word ptr p
  mov ax,0a000h
  mov es,ax
  mov cx,word ptr ds:[si+2]   {vyska}
  mov ax,word ptr ds:[si]
  mov dx,ax                   {sirka}
  and ax,3   {sub dx,(dx shr,2 ; dx shl,2)}
  add si,4
  mov di,[bp+offset y]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[bp+offset x]
@loop:
  mov bx,cx
  mov cx,dx
  shr cx,2
  db 66h; rep movsw
  mov cx,ax
  rep movsb
  add di,320
  sub di,dx
  mov cx,bx
  loop @loop
  pop ds
end;

procedure Save2File(x,y,x2,y2:integer;filename:string);
var
f:file;
p:pointer;
size:word;
begin
  assign(f,filename);
  size:=abs(x2-x)*abs(y2-y)+10;
  rewrite(f,size);
  GetMem(p,size);
  GImage(x,y,x2,y2,p);
  BlockWrite(f,p^, 1);
  freemem(p,size);
  close(f);
end;

procedure LoadFFile(x,y,sx,sy,sx2,sy2:integer;filename:string);
var
f:file;
p:pointer;
size:word;
begin
  assign(f,filename);
  size:=abs(sx2-sx)*abs(sy2-sy)+10;
  reset(f,size);
  GetMem(p,size);
  BlockRead(f,p^, 1);
  PImage(x,y,p);
  FreeMem(p,size);
  close(f);
end;

{ SCROLLING }

procedure ScrollDown(x1,y1,x2,y2:integer);assembler;
asm   {OK}
  push ds
  mov ax,$a000
  mov es,ax
  mov ds,ax
  mov si,[y1]
  mov cx,[y2]
  mov ax,cx
  mov bx,cx
  shl ax,8
  shl bx,6
  add ax,bx
  sub cx,si
  inc cx
  mov bx,[x1]
  mov dx,[x2]
  add ax,bx
  sub dx,bx
  inc dx
  cld
@1:
  mov bx,cx
  mov di,ax
  mov si,ax
  sub si,320
  mov cx,dx
  shr cx,2
  db $f3,$66,$a5  {rep movsd}
  mov cx,dx
  and cx,3
  rep movsb
@2:
  mov cx,bx
  sub ax,320
  loop @1
  pop ds
end;

procedure ScrollLeft(X1,Y1,X2,Y2:integer);assembler;
asm   {OK}
  push ds
  mov ax,$a000
  mov es,ax
  mov ds,ax
  mov si,[y1]
  mov ax,si
  shl ax,6
  shl si,8
  add si,ax
  mov cx,[y2]
  sub cx,si
  inc cx
  mov dx,[x1]
  add ax,dx
  mov bx,[x2]
  sub bx,dx
  inc bx
  cld
@1:
  mov dx,cx
  mov di,ax
  dec di
  mov si,ax
  mov cx,bx
  shr cx,2
  db $f3,$66,$a5  {rep movsd}
  mov cx,bx
  and cx,3
  rep movsb
@2:
  mov cx,dx
  add ax,320
  loop @1
  pop ds
end;

procedure ScrollRight(x1,y1,x2,y2:integer);assembler;
asm   {OK}
  push ds
  mov ax,$a000
  mov es,ax
  mov ds,ax
  mov si,[y1]
  mov ax,si
  shl ax,6
  shl si,8
  add si,ax
  mov cx,[y2]
  sub cx,si
  inc cx
  mov dx,[x1]
  mov bx,[x2]
  add ax,bx
  sub bx,dx
  inc bx
  std
@1:
  mov dx,cx
  mov di,ax
  mov si,ax
  dec si
  mov cx,bx
  shr cx,2
  db $f3,$66,$a5  {rep movsd}
  mov cx,bx
  and cx,3
  rep movsb

@2:
  mov cx,dx
  add ax,320
  loop @1
  cld
  pop ds
end;

procedure ScrollUp(x1,y1,x2,y2:integer);assembler;
asm   {OK}
  push ds
  mov ax,$a000
  mov es,ax
  mov ds,ax
  mov si,[y1]
  mov cx,[y2]
  sub cx,si
  inc cx
  mov ax,si
  shl si,8
  shl ax,6
  add ax,si
  mov dx,[x1]
  add ax,dx
  mov bx,[x2]
  sub bx,dx
  inc bx
  cld
@1:
  mov dx,cx
  mov di,ax
  sub di,320
  mov si,ax
  mov cx,bx
  shr cx,2
  db $f3,$66,$a5  {rep movsd}
  mov cx,bx
  and cx,3
  rep movsb

@2:
  mov cx,dx
  add ax,320
  loop @1
  pop ds
end;

{ MISCELANEOUS }

procedure WaitRet; assembler;
asm   {OK}
  mov dx,3dah
  @1:
    in al,dx
    test al,08h
    jnz @1
  @2:
    in al,dx
    test al,08h
    jz @2
end;

{ VESA }

var  VI : record
             MAtrib : word;
             WinA : byte;
             WinB : byte;
             WGran : word;
             WSize : word;
             WsegA : word;
             WsegB : word;
             SetBank : procedure;
             ScanLn : word;
             ScreenW : word;
             ScreenH : word;
             CharW : byte;
             CharH : byte;
             Planes : byte;
             BitsPixel : byte;
             Banks : byte;
             MemModel : byte;
             BnkSize : byte;
             ImgPages : byte;
             Res1 : byte;
             RMSize : byte;
             RFPos : byte;
             GMSize : byte;
             GFPos : byte;
             BMSize : byte;
             BFPos : byte;
             MSize : byte;
             MPos : byte;
             DCinfo : byte;
             Res2 : byte;
             trash : array [$2a..255] of byte;
end;
cbank : byte;

procedure GetMode(mode:word);assembler;
asm   {OK}
  mov ax,ds       { protoze je to vlastne promenna }
  mov es,ax
  mov ax,4f01h
  mov cx,mode
  mov di,offset VI
  int 10h
end;


function SetVesa(mode:word):boolean;assembler;
asm   {OK}
  mov ax,4f02h
  mov bx,mode
  int 10h
  sub ax,004fh
  mov [bp-1],al
end;

function GetVesa:word;assembler;
asm   {OK}
  mov ax,4f03h
  int 10h
  cmp ax,004fh
  je @ok
  mov ax,-1
  jmp @end
@ok:
  mov ax,bx
@end:
 end;

procedure GScanLn(var BytesPerScanline,PixsPerScanline,NumOfScanlines:word);assembler;
asm   {OK}
  mov ax,4f06h
  mov bl,01h
  int 10h
  les di,dword ptr [bp+0eh]
  mov word ptr es:[di],bx
  les di,dword ptr [bp+0ah]
  mov word ptr es:[di],cx
  les di,dword ptr [bp+6]
  mov word ptr es:[di],dx
end;

procedure SScanLn(width:word);assembler;
asm   {OK}
mov ax,4f06h
mov bl,00h
mov cx,word ptr width
int 10h
end;

procedure GDStart(var x,y:integer);assembler; { Get Display Start }
asm   {OK}
  mov ax,4f07h
  mov bx,0001h
  int 10h
  les di,dword ptr [bp+0ah]
  mov word ptr es:[di],cx
  les di,dword ptr [bp+6]
  mov word ptr es:[di],dx
end;

procedure SDStart(x,y:integer);assembler; { Set Display Start }
asm   {OK}
  mov ax,4f07h
  sub bx,bx
  mov cx,word ptr x
  mov dx,word ptr y
  int 10h
end;


procedure PPix8(x,y:word;c:byte);assembler;
{ vypocet efektivni adresy:
1024x768x256:
db 66h;mov di,y
db 66h;shl di,10
db 66h;add di,x      ;  y:=y*1024+x
db 66h;mov dx,di     ;  puvodni mul uklada to co se nevleze do r16,r/m16
db 66h;shr dx,16     ;  do dx:ax, s dx se ale dal pracuje a nepouziva se
edx proto nakonci ten shrdx,16}
asm   {OK}
  mov ax,$0a000
  mov es,ax
  mov di,x
  mov ax,y
  mul vi.screenw
  add di,ax
  adc dx,0
  cmp dl,cbank
  je @skip
  mov cbank,dl
  mov ax,4f05h
  xor bx,bx
  adc dx,0
  int 10h
@skip:
  mov al,byte ptr c
  mov es:[di],al
end;

{ ********************************* MATH ********************************** }
{ 8087x }

procedure Init8087;assembler;
asm
  finit
end;

function fmul(s1,s2:single):single;
var s:single;
begin
asm
  fld s1
  fmul s2
  fstp s
end;
  fmul:=s;
end;

function fdiv(s1,s2:single):single;
var s:single;
begin
asm
  fld s1
  fdiv s2
  fstp s
end;
  fdiv:=s;
end;

function fadd(s1,s2:single):single;
var s:single;
begin
asm
  fld s1
  fadd s2
  fstp s
end;
  fadd:=s;
end;

function fsub(s1,s2:single):single;
var s:single;
begin
asm
  fld s1
  fsub s2
  fstp s
end;
  fsub:=s;
end;

function fabs(s1:single):single;
var s:single;
begin
asm
  fld s1
  fabs
  fstp s
end;
  fabs:=s;
end;

function fneg(s1:single):single;
var s:single;
begin
asm
  fld s1
  fchs
  fstp s
end;
  fneg:=s;
end;

function fsqrt(s1:single):single;
var s:single;
begin
asm
  fld s1
  fsqrt
  fstp s
end;
  fsqrt:=s;
end;

function fround(s1:single):single;
var s:single;
begin
asm
  fld s1
  frndint
  fstp s
end;
  fround:=s;
end;

procedure fnop;assembler;
asm
fnop
end;


function esc:byte;assembler;
asm
in al,60h
mov [bp-1],al
end;

{ ----------------------------- CUT HERE ---------------------------------- }

var va1,c,color:word;
x,y,Gd,Gm:integer;
vs1:vpointer;
p:pointer;

const Cur: array [0..1,0..15] of word=
                     (($FFCF,                    { 1111111111001111 } { PenCursor}
                       $FF87,                    { 1111111110000111 }
                       $FF03,                    { 1111111100000011 }
                       $FE01,                    { 1111111000000001 }
                       $FC03,                    { 1111110000000011 }
                       $F807,                    { 1111100000000111 }
                       $F00F,                    { 1111000000001111 }
                       $E01F,                    { 1110000000011111 }
                       $C03F,                    { 1100000000111111 }
                       $807F,                    { 1000000001111111 }
                       $00FF,                    { 0000000011111111 }
                       $01FF,                    { 0000000111111111 }
                       $03FF,                    { 0000001111111111 }
                       $07FF,                    { 0000011111111111 }
                       $0FFF,                    { 0000111111111111 }
                       $9FFF),                   { 1001111111111111 }
                      ($0000,                    { 0000000000000000 }
                       $0030,                    { 0000000000110000 }
                       $0078,                    { 0000000001111000 }
                       $009C,                    { 0000000010011100 }
                       $01E8,                    { 0000000111101000 }
                       $03F0,                    { 0000001111110000 }
                       $07E0,                    { 0000011111100000 }
                       $0FC0,                    { 0000111111000000 }
                       $1F80,                    { 0001111110000000 }
                       $2700,                    { 0010011100000000 }
                       $7A00,                    { 0111101000000000 }
                       $5C00,                    { 0101110000000000 }
                       $4800,                    { 0100100000000000 }
                       $5000,                    { 0101000000000000 }
                       $6000,                    { 0110000000000000 }
                       $0000));                  { 0000000000000000 }

const Cur2: array [0..1,0..15] of word=
                     (($0000,                    { 0000000000000000 }
                       $0000,                    { 0000000000110000 }
                       $0000,                    { 0000000001111000 }
                       $0000,                    { 0000000010011100 }
                       $0000,                    { 0000000111101000 }
                       $0000,                    { 0000001111110000 }
                       $0000,                    { 0000011111100000 }
                       $0000,                    { 0000111111000000 }
                       $0000,                    { 0001111110000000 }
                       $0000,                    { 0010011100000000 }
                       $0000,                    { 0111101000000000 }
                       $0000,                    { 0101110000000000 }
                       $0000,                    { 0100100000000000 }
                       $0000,                    { 0101000000000000 }
                       $0000,                    { 0110000000000000 }
                       $0000)
                       ,($FFfF,                    { 1111111111001111 } { PenCursor}
                       $FFff,                    { 1111111110000111 }
                       $FFff,                    { 1111111100000011 }
                       $Ffff,                    { 1111111000000001 }
                       $Ffff,                    { 1111110000000011 }
                       $Ffff,                    { 1111100000000111 }
                       $FffF,                    { 1111000000001111 }
                       $fffF,                    { 1110000000011111 }
                       $fffF,                    { 1100000000111111 }
                       $ffff,                    { 1000000001111111 }
                       $ffFF,                    { 0000000011111111 }
                       $fffF,                    { 0000000111111111 }
                       $fFfF,                    { 0000001111111111 }
                       $fFFf,                    { 0000011111111111 }
                       $FfFF,                    { 0000111111111111 }
                       $FFfF));                  { 1001111111111111 }
                                        { 0000000000000000 }


const map:array[1..7,1..17] of byte=(
(05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05),
(15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15),
(05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05),
(15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15),
(05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05),
(15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15),
(05,15,05,15,05,15,05,15,05,15,05,15,05,15,05,15,05));

const map2:array[1..7,1..17] of byte=(
(02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02),
(15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15),
(02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02),
(15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15),
(02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02),
(15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15),
(02,15,02,15,02,15,02,15,02,15,02,15,02,15,02,15,02));

const bar1 : coordtyp =((0,100,100,0,0,0,0,0,0,0,0,0),{x}
                        (0,0,100,100,0,0,0,0,0,0,0,0));{y}


begin
setvesa($101);
getmode($101);
ppix8(100,100,156);
ppix8(200,200,14);
readln;
setvga($13);
rlebitmap(100,100,17,7,map);
readln;
scbitmap(20,20,17,7,100,100,map2);
readln;
mouseinit(0);
mouseinit(1);
readln;
newcur(1,1,cur);
readln;
newcur(1,2,cur2);
readln;
xtriangle(50,50,100,100,100,0,14,$0a000);
xcircle(170,100,85,300,9,400,20,$0a000);
ppix(100,100,2,$0a000);
c:=gpix(100,100,$0a000);
ppix(101,100,c,$0a000);
repeat
SetRGB(16,x,y,63);
xcircle(170,100,85,300,16,400,20,$0a000);
x:=succ(x);
if x=63 then begin y:=y+9; x:=0;end;
xdelay(5);
until y=63;
p:=gmem(150);
{if realloc(p,10000)=nil then writeln('ee');}
{realloc(p,10050);}
p:=gmem(10050);
gimage(0,0,100,100,p);
ccls(14,$0a000);
pimage(30,30,p);
waitret;

readln;
cls($0a000);
Xline(0,0,300,199,1,$0a000);
{Poly(100,100,15,05,45,45,94,43,2,$0a000);}
readln;
va1:=vsetup(vs1);
flip($0a000,va1);
cls($0a000);
xline(0,100,319,100,2,$0a000);
randomize;
x:=0;
repeat
inc(x);
ppix(random(320),random(100),random(15),$0a000);
until x=200;

readln;

flip(va1,$0a000);
Vdispose(va1);
readln;
cls($0a000);
x:=330;
repeat
inc(x);

until x=3000;
x:=0;
repeat
ppix(random(320),random(200),random(15),$0a000);
inc(x);
until x=3000;{
polyinit(bar1,4);
xpoly(4,2,$0a000);
coord[1].x:=0;
coord[1].y:=0;
coord[2].x:=20;
coord[2].y:=5;
coord[3].x:=30;
coord[3].y:=30;
coord[4].x:=50;
coord[4].y:=40;
coord[5].x:=28;
coord[5].y:=100;
coord[6].x:=10;
coord[6].y:=60;
Xpoly(6,1,$0a000);
va1:=vsetup(vs1);
fimage(0,0,100,100,0,0,$0a000,va1);
readln;
fimage(0,0,100,100,219,100,va1,$0a000);
vdispose(va1);
readln;                                 }
rotpal(63,0,0,false,false,false,63,18);

end.


