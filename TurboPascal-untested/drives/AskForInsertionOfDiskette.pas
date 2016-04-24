(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0115.PAS
  Description: Ask for insertion of diskette
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

{$g+,n-,e-,d-,q-,r-,s-,t-,v-,x-}
uses crt,dos;

function diskettedrives:integer; assembler;
asm
  xor ax,ax
  xor bx,bx
  xor cx,cx
  xor dx,dx
  int 011h
  cmp ax,00001h
  je @@exit2
  @@exit2:
    xor ax,ax
  @@exit:
  shl ax,8
  shl ax,14
  inc ax
end;

var
  buf:array [1..512]of byte;
  ch:char;

function ready(drivespec:char):boolean; {A,B,etc}
var
  result:word;
  drive,number,logical:word;
begin
  ready:=true;
  drive:=ord(upcase(drivespec))-65;
  if(drive>diskettedrives)then exit;
  number:=1;
  logical:=1;
  asm
    push bp
    push ds
    xor ax,ax
    mov result,ax
    mov al,byte ptr drive
    mov cx,number
    mov dx,logical
    mov bx,seg buf
    mov ds,bx
    mov bx,offset buf
    int 25h
    pop bx
    pop ds
    pop bp
    jnb @@done
    mov result,ax
   @@done:
  end;
  ready:=(result=0);
end;

function dodummy(const d:char):boolean;
var f:file;
begin
  dodummy:=false;
  assign(f,d+':\dummy');
  {$i-} rewrite(f,1); {$i+}
  if(ioresult<>0)then
  begin
    exit;
  end;
  {$i-} close(f); {$i+}
  if(ioresult<>0)then exit;
  {$i-} erase(f); {$i+}
  if(ioresult<>0)then exit;
  dodummy:=true;
end;

begin
  repeat
    writeln('insert a unprotected disk in drive A: and press any key!');
    ch:=readkey;
  until(ready('a'))and(dodummy('a'));
end.
