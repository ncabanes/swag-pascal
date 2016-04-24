(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0236.PAS
  Description: Fast PUTIMAGE
  Author: PETR SULLA
  Date: 11-29-96  08:17
*)

unit fastputimage;

{
 *******************************************************
 *                *VERY* FAST PUTIMAGE                 *
 *******************************************************
 *                (C) Petr Sulla 1996                  *
 *             E-mail: xsulla@fi.muni.cz               *
 *******************************************************
 *  Public domain, use at your own risk. Enjoy it !!!  *
 *******************************************************


 Hi all ! I was just in need of a *REALLY* fast putimage but I couldn't
 find it anywhere. So I sat down for a couple of hours and here it is !
 The FASTEST putimage I've ever seen.

 The x-position must be a multiplicate of 8 due to the VGA/EGA
 memory organisation. (will be automatically rounded)

 The image should not exceed the screen size (this case is not tested
 and could cause strange results...

 The image structure is *not* compatible with the Borland's one.
 Old images can be easily converted by displaying them and then
 saving them using this new getimage.

 It could be possibly even faster - some code optimization could help.
 I find it fast enough as it is now, anyway ;-)

 An example follows.
 }

interface

{$g+}

function myimagesize(x,y,x0,y0:word):word;
procedure mygetimage(x,y,x0,y0:word;p:pointer);
procedure myputimage(x,y:word;p:pointer);
procedure waitretrace;

implementation

function myimagesize(x,y,x0,y0:word):word;
var dummy:longint;
    sx,sy:word;
begin
  sx:=succ(abs(x0-x) div 8);
  sy:=succ(abs(y0-y));
  dummy:=sx*sy*4+10;        {*4 because of 4 bitplanes}
  if dummy<65520 then
    myimagesize:=dummy
  else
    myimagesize:=0;
end;

procedure mygetimage(x,y,x0,y0:word;p:pointer);assembler;
var m:word;
asm
    sti
    push es
    push ds
    cld                              {rep adds}
    les di,[p]                       {x0 <- width, y0 <- height, write to buffer}
    mov ax,x0
    sub ax,x
    shr ax,3                         {x0:=x0 div 8}
    mov x0,ax
    mov es:[di],ax
    inc x0
    mov ax,y0
    sub ax,y
    mov y0,ax
    mov es:[di+2],ax
    inc y0
    add di,4                         {es:di <- pointer to data}
    shr x,3                          {x:=x div 8}
    mov bx,y                         {m:=y*80+x - offset in vram}
    mov cx,bx
    shl bx,4
    shl cx,6
    add bx,cx
    add bx,x
    mov m,bx
    mov ax,0a000h                    {ds:si <- beginning of vram}
    mov ds,ax
    mov bx,y0                        {bx - lines counter}
    mov dx,03ceh                     {dx - port address}
    mov al,4
    out dx,al
    inc dx
@@1:
    mov ah,4                         {ah - 3=1.bit plane, 2=2.bitpl.,1=3.bitpl.,0=4.bitpl.}
@@2:
    mov al,ah
    dec al
    out dx,al                        {send number of bitplane to the graphic card}
    mov si,m                         {offset in videoram}
    mov cx,x0                        {image width to counter}
    rep movsb                        {send  cx bytes from DS:SI(vram) to ES:DI(image)}
    dec ah                           {decrement al - next bitplane}
    jnz @@2                          {is zero ? - no=next bitplane}
    add m,80                         {next line in vram}
    dec bx                           {decrement lines counter}
    jnz @@1                          {last line  ? no=next line}
    dec dx                           {set graphic card back to std. modus}
    mov al,3
    out dx,al
    inc dx
    xor al,al
    out dx,al
    pop ds
    pop es
    cli
end;

procedure myputimage(x,y:word;p:pointer);assembler;
var sx,sy,m:word;
asm
    sti
    push es
    push ds
    cld                              {rep adds}
    shr x,3                          {x:=x div 8}
    mov bx,y                         {m:=y*80+x - offset in vram}
    mov cx,bx
    shl bx,4
    shl cx,6
    add bx,cx
    add bx,x
    mov m,bx
    lds si,[p]                       {sx <- width, sy <- height}
    mov ax,word ptr ds:[si]
    inc ax
    mov sx,ax
    mov ax,word ptr ds:[si+2]
    inc ax
    mov sy,ax
    add si,4                         {ds:si <- pointer to data}
    mov ax,0a000h                    {es:di <- beginning of vram}
    mov es,ax
    mov bx,sy                        {bx - lines counter}
    mov dx,03c4h                     {dx - port address}
    mov al,2
    out dx,al
    inc dx
@@1:
    mov al,8                         {al - 8=1.bit plane, 4=2.bitpl.,2=3.bpl.,1=4.bpl.}
@@2:
    out dx,al                        {send bitplane number to the graphic card}
    mov di,m                         {offset in videoram}
    mov cx,sx                        {image width to counter}
    rep movsb                        {send cx bytes from DS:SI(image) to ES:DI(vram)}
    shr al,1                         {divide al by 2 - next bitplane of 4}
    jnz @@2                          {is zero ? - no=next bitplane}
    add m,80                         {next line in vram}
    dec bx                           {decrement lines counter}
    jnz @@1                          {last line ? no=next line}
    dec dx                           {set graphic card back to std. modus}
    mov al,2
    out dx,al
    inc dx
    mov al,15
    out dx,al
    pop ds
    pop es
    cli
end;

procedure waitretrace;assembler;    {can be handy for smooth animation}
asm
        mov dx,$3da
@1:     in al,dx
        test al,8
        jz @1
@2:     in al,dx
        test al,8
        jnz @2
end;

end.

{------------- 8< ------ Cut here ---------- 8< ----------------------}

{
 *******************************************************
 *                FAST PUTIMAGE EXAMPLE                *
 *******************************************************
 *                 (C) Petr Sulla 1996                 *
 *              E-mail: xsulla@fi.muni.cz              *
 *******************************************************
 *    Public domain, use at your own risk. Enjoy !!!   *
 *******************************************************
 }

uses crt,graph,fastputimage;
var gd,gm:integer;
    p,q:pointer;

procedure garbage;
var i,j,k:integer;
begin
  for i:=1 to 80 do
    begin
      j:=random(15)+1;
      setcolor(j);
      setfillstyle(1,j);
      j:=random(200);
      k:=random(200);
      case random(3) of
       0:rectangle(j,k,j+random(200),k+random(200));
       1:bar(j,k,j+random(200),k+random(200));
       2:circle(j,k,random(200));
      end;
    end;
end;

begin
  gd:=detect;
  initgraph(gd,gm,'');  {<- insert path to your egavga.bgi here}

  getmem(p,myimagesize(0,0,300,343));  {get some memory for the two test images}
  getmem(q,myimagesize(0,0,300,343));

  randomize;

  setfillstyle(1,8);
  bar(0,0,getmaxx,getmaxy);
  garbage;                             {generate some garbage on screen}
  mygetimage(0,0,300,343,p);           {and make it to an image ;-) }

  repeat until keypressed;
  while keypressed do readkey;
  cleardevice;

  setfillstyle(1,13);                  {and the same once more with}
  bar(0,0,getmaxx,getmaxy);            {another background color}
  garbage;
  mygetimage(0,0,300,343,q);

  repeat until keypressed;
  while keypressed do readkey;
  cleardevice;

  repeat
    myputimage(random(330),random(135),p);   {display both images in a loop}
    myputimage(random(330),random(135),q);
  until keypressed;
  while keypressed do readkey;

  freemem(p,myimagesize(0,0,300,343));       {free the memory occupied by the images}
  freemem(q,myimagesize(0,0,300,343));

  closegraph;
end.


