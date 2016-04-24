(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0038.PAS
  Description: CRT Replacement Unit
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

unit mycrt;
{$g+}

INTERFACE

const
  colseg:word=$b800;

procedure ch2scr(x,y:word;ch:char;c:byte);
procedure str2scr(const s:string;const x,y:word;const c:byte);
function  readkey:char;
function  keypressed:boolean;
procedure centerstr(const s:string;const y:word;const c:byte);
procedure centerstr2(const s:string;const y:word;const c:byte);
procedure textbox(const x,y,x2,y2:byte;const c:byte;const cha:char);
procedure clrscr(const where:word;const c:byte;const c2:char);
function  activepage:byte;
function  where_x(const page:byte):byte;
function  where_y(const page:byte):byte;
function  wherex:byte;
function  wherey:byte;
procedure goto_xy(const page,x,y:byte);
procedure gotoxy(const x,y:byte);
procedure setcursor(const cursor:word);
function  getcursor:word;
procedure hcursor;
procedure scursor;
procedure dupeit(c:char;co:byte;n,x,y:word);
procedure statbar(snum,bnum:longint;x,y,fc,ec:byte);

IMPLEMENTATION

procedure ch2scr(x,y:word;ch:char;c:byte); assembler;
asm
  mov es,segb800
  dec [x]
  dec [y]
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  add di,[x]
  mov al,[&ch]
  mov ah,[c]
  mov es:[di],ax
end;

procedure str2scr(const s:string;const x,y:word;const c:byte); assembler;
asm
  push ds
  dec [x]
  dec [y]
  mov es,segb800
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  add di,[x]
  shl di,1
  lds si,s

  xor ch,ch
  mov cl,ds:[si]
  inc si
  mov ah,[c]
 @@loop:
   lodsb
   stosw
   loop @@loop
 @@exit:
 pop ds
end;

function readkey:char; assembler;
asm
  xor ah,ah
  int 16h
end;

function keypressed:boolean; assembler;
asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz @1
  inc ax
  @1:
end;

procedure centerstr(const s:string;const y:word;const c:byte); assembler;
asm
  push ds
  xor ax,ax
  xor cx,cx
  dec [y]
  mov es,segb800
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  shl di,1
  lds si,s
  mov bx,40
  mov al,ds:[si]
  mov cl,al
  sub bx,ax
  add di,bx
  add di,bx
  inc si
  mov ah,[c]
 @@loop:
   lodsb
   stosw
   loop @@loop
 @@exit:
 pop ds
end;

procedure centerstr2(const s:string;const y:word;const c:byte); assembler;
var tempy:word;
asm
  push ds
  xor ax,ax
  xor cx,cx
  xor dx,dx
  dec [y]
  mov es,segb800
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  shl di,1
  mov tempy,di
  lds si,s
  mov cl,ds:[si]
  mov dl,cl
  mov bx,tempy
  add bx,159
  inc si
  mov ah,[c]
  mov al,' '
 @@loop1: { This loop makes the 'bar'. }
   stosw
   cmp di,bx
   jbe @@loop1
  mov di,tempy
  mov bx,40
  shr dl,1
  sub bx,dx
  shl bx,1
  sub bx,2
  add di,bx
 @@loop2: { This loop draws the text. }
   lodsb
   stosw
   loop @@loop2
 @@exit:
  pop ds
end;

procedure textbox(const x,y,x2,y2:byte;const c:byte;const cha:char); assembler;
{
  bl=X counter.
  bh=Y counter.
  cl=X max.
  ch=Y max.
}
asm
  mov es,segb800
  xor ax,ax
  mov al,[y]
  mov di,ax
  dec di
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  xor ax,ax
  mov al,[x]
  add di,ax
  dec di
  shl di,1

  mov bl,[x]
  mov bh,[y]
  mov cl,[x2]
  mov ch,[y2]

  @@vertloop:

end;

procedure clrscr(const where:word;const c:byte;const c2:char); assembler;
asm
  mov ax,[where]
  mov es,ax
  xor di,di
  mov cx,8000
  mov al,[c2]
  mov ah,[c]
  rep stosw
{ The next code is just to recenter the cursor at (0,0) }
  mov ah,0Fh
  int 010h
  mov ah,02h
  mov dl,0
  mov dh,0
  int 010h
end;

function activepage:byte; assembler;
asm
  mov ah,0Fh
  int 010h
  mov al,bh
end;

function where_x(const page:byte):byte; assembler;
asm
  mov ah,03h
  mov bh,[page]
  int 010h
  mov al,dl
end;

function where_y(const page:byte):byte; assembler;
asm
  mov ah,03h
  mov bh,[page]
  int 010h
  mov al,dh
end;

function wherex:byte;
begin
  wherex:=succ(where_x(activepage));
end;

function wherey:byte;
begin
  wherey:=succ(where_y(activepage));
end;

procedure goto_xy(const page,x,y:byte); assembler;
asm
  mov ah,02h
  mov bh,[page]
  mov dl,[x]
  mov dh,[y]
  int 010h
end;

procedure gotoxy(const x,y:byte);
begin
  goto_xy(activepage,pred(x),pred(y));
end;

procedure setcursor(const cursor:word); assembler;
asm
  mov ah,1
  mov bh,0
  mov cx,[cursor]
  int 010h
end;

function getcursor:word; assembler;
asm
  mov ah,3
  mov bh,0
  int 010h
  mov ax,cx
end;

procedure hcursor;
begin
  setcursor($2000);
end;

procedure scursor;
begin
  setcursor($0607);
end;

procedure dupeit(c:char;co:byte;n,x,y:word); assembler;
asm
  mov es,segb800
  mov di,[y]
  dec di
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  add di,[x]
  dec di
  shl di,1
  mov ah,[co]
  mov al,[c]
  cld
  mov cx,n
  rep stosw
end;

procedure statbar(snum,bnum:longint;x,y,fc,ec:byte);
const
  magic=2; { 100/magic(2) = 50 }
  empty='▒'; { #177 }
  full='█';  { #219 }
var
  p1,p2:word;
  s:string;
begin
  p1:=round(snum/bnum*100/magic);
  p2:=round(snum/bnum*100);
  str(p2,s);
  dupeit(empty,ec,{50}(100 div magic)-p1,x,y);
  dupeit(full,fc,p1-1,x,y);
  str2scr(s,(x+(p1+((100 div magic)-p1))),y,fc);
end;

end.
