(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0185.PAS
  Description: Helpful Procedures and Functions
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

unit utils;
{$g+,d+}

INTERFACE

const
  c_warning=$01;
  c_error=$02;
  c_display=$fe;
  c_fatal=$ff;

var
  timer:longint absolute $0040:$006c;

procedure keep(const code:byte);
procedure getint(const num:byte;var p:pointer);
procedure setint(const num:byte;const p:pointer);
procedure asmcall(const p:pointer);
function  fex(const fn:string):boolean;
function  fsearch(const namep,pathp:string):string;
function  percent(const a,b:longint):longint;
function  hexbyte(const b:byte):string;
function  hexword(const w:word):string;
function  hexlong(const ww:longint):string;
function  fsize(const fn:string):longint;
function  fsize2(var f:file):longint;
function  smartdrver:integer;
procedure starttime;
function  stoptime:longint;
procedure error(s:string;x,y,mode:byte);
function  small(a,b:word):word;
function  large(a,b:word):word;
function  fdel(fn:string):boolean;
function  fren(n1,n2:string):boolean;
function  legalname(const fn:string):boolean;
function  buildstr(const ch:char;const num:byte):string;
procedure flush_cache;

IMPLEMENTATION

uses crt;

var
  oldtime:longint;

procedure keep(const code:byte); assembler;
asm
  mov ax,prefixseg
  mov es,ax
  mov dx,word ptr es:2
  sub dx,ax
  mov al,code
  mov ah,31h
  int 21h
end;

procedure getint(const num:byte;var p:pointer); assembler;
asm
  push ds
  xor ax,ax
  mov ds,ax
  mov al,num
  mov si,ax
  shl si,2
  les di,p
  db 66h; movsw
  pop ds
end;

procedure setint(const num:byte;const p:pointer); assembler;
asm
  cli
  xor ax,ax
  mov es,ax
  mov al,num
  mov di,ax
  shl di,2
  mov ax,word ptr [p]
  mov es:[di],ax
  mov ax,word ptr [p+2]
  mov es:[di+2],ax
  sti
end;

procedure asmcall(const p:pointer);assembler;
asm
  call p
end;

function fsearch(const namep,pathp:string):string; assembler;
asm
  push ds
  cld
  lds si,pathp
  lodsb
  mov bl,al
  xor bh,bh
  add bx,si
  les di,@result
  inc di
@@1:
  push si
  push ds
  lds si,namep
  lodsb
  mov cl,al
  xor ch,ch
  rep movsb
  xor al,al
  stosb
  dec di
  mov ax,4300h
  lds dx,@result
  inc dx
  int 21h
  pop ds
  pop si
  jc @@2
  test cx,18h
  je @@5
@@2:
  les di,@result
  inc di
  cmp si,bx
  je @@5
  xor ax,ax
@@3:
  lodsb
  cmp al,';'
  je @@4
  stosb
  mov ah,al
  cmp si,bx
  jne @@3
@@4:
  cmp ah,':'
  je @@1
  cmp ah,'\'
  je @@1
  mov al,'\'
  stosb
  jmp @@1
@@5:
  mov ax,di
  les di,@result
  sub ax,di
  dec ax
  stosb
@@6:
  pop ds
end;

function fex(const fn:string):boolean;
begin
  fex:=(fsearch(fn,'')<>'');
end;

function percent(const a,b:longint):longint;
begin
  percent:=round(a/b*100);
end;

function hexbyte(const b:byte):string;
const hex:array[0..16]of char='0123456789abcdef';
begin
  hexbyte:=hex[b shr 4]+hex[b and $f];
end;

function hexword(const w:word):string;
begin
  hexword:=hexbyte(hi(w))+hexbyte(lo(w));
end;

function hexlong(const ww:longint):string;
var w:array[1..2]of word absolute ww;
begin
  hexlong:=hexword(w[2])+hexword(w[1]);
end;

function fsize(const fn:string):longint;
var f:file;
begin
  fsize:=-1;
  if not(fex(fn))then exit;
  assign(f,fn);
  {$i-} reset(f,1); {$i+}
  if(ioresult<>0)then exit;
  fsize:=filesize(f);
  close(f);
end;

function fsize2(var f:file):longint;
begin
  fsize2:=-1;
  {$i-} close(f); {$i+} if(ioresult<>0)then ;
  {$i-} reset(f,1); {$i+}
  if(ioresult<>0)then exit;
  fsize2:=filesize(f);
  close(f);
end;

function smartdrver:integer; assembler;
asm
  xor bx,bx
  xor cx,cx
  xor dx,dx
  mov ax,04a10h
  int 02fh
  jc @@error
  cmp ax,0babeh
  jne @@error
  mov ax,bp
  jmp @@exit
  @@error:
    mov ax,1
    neg ax
  @@exit:
end;

procedure starttime;
begin
  oldtime:=timer;
end;

function stoptime:longint;
var tmp:longint;
begin
  tmp:=timer;
  stoptime:=(tmp-oldtime);
end;

procedure error(s:string;x,y,mode:byte);
var
  fore:string;
  old:byte;
begin
  old:=textattr;
  gotoxy(x,y);
  case mode of
    c_warning:begin fore:='warning: '; textcolor(darkgray); end;
    c_error:  begin fore:='error: '; textcolor(lightred); end;
    c_fatal:  begin fore:='fatal: '; textcolor(red); end;
    c_display:begin fore:=''; textcolor(white); end;
  end;
  write(fore,s);
  textattr:=old;
  if(mode in [c_fatal,c_display])then halt(1);
end;

function small(a,b:word):word; assembler;
asm
  mov ax,a
  mov bx,b
  cmp ax,bx
  jbe  @@exit
  mov ax,bx
  @@exit:
end;

function large(a,b:word):word; assembler;
asm
  mov ax,a
  mov bx,b
  cmp ax,bx
  jae  @@exit
  mov ax,bx
  @@exit:
end;

function setfattr(var filep:file;const attr:word):word; assembler;
asm
  push ds
  lds dx,filep
  add dx,48
  mov cx,attr
  mov ax,4301h
  int 21h
  pop ds
  jc  @@exit
  xor ax,ax
@@exit:
end;

function legalname(const fn:string):boolean;
var f:file;
begin
  legalname:=true;
  if(fex(fn))then exit;
  assign(f,fn);
  setfattr(f,0);
  {$i-} rewrite(f,1); {$i+}
  if(ioresult<>0)then legalname:=false;
  {$i-} erase(f); {$i+} if(ioresult<>0)then ;
end;

function fdel(fn:string):boolean;
var f:file;
begin
  fdel:=false;
  if not(fex(fn))then exit;
  assign(f,fn);
  if(setfattr(f,0)<>0)then exit;
  {$i-} erase(f); {$i+} if(ioresult<>0)then exit;
  fdel:=true;
end;

function fren(n1,n2:string):boolean;
var f:file;
begin
  fren:=false;
  if not(fex(n1))or(fex(n2))then exit;
  assign(f,n1);
  {$i-} rename(f,n2); {$i+} if(ioresult<>0)then exit;
  fren:=true;
end;

function buildstr(const ch:char;const num:byte):string; assembler;
asm
  xor ch,ch
  mov al,[num]
  mov cl,al
  les di,@result
  stosb
  jcxz @@exit
  mov al,[&ch]
  mov ah,al
  shr cl,1
  rep stosw
  adc cl,cl
  rep stosb
  @@exit:
end;

procedure flush_cache; assembler;
asm
  mov ax,04a10h
  mov bx,1
  int 02fh
end;

end.
