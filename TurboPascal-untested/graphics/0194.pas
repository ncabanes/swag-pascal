
unit fli;
interface
uses crt;
type
fliheader=record
size : longint;
htype:word;
framecount:word;
width:word;
height:word;
bitsperpixel:word;
flags:integer;
speed:integer;
nexthead:longint;
framesintable:longint;
hfile:integer;
hframe1offset:longint;
strokes:longint;
session:longint;
reserved:array [1..88] of byte;
end;
frameheader=record
size :longint;
ftype:word;
chunks:word;
expand:array[1..8] of byte;
end;
chunkheader=record
size : longint;
id:word;
end;
buffer=array[1..65535] of byte;
rgb=record
r,g,b : byte;
end;
paltype=array[0..255] of rgb;
var
buf:^buffer;
pal1:^paltype;
h:fliheader;
fh:frameheader;
ch:chunkheader;
i,j : word;
speed : word;
f:file;
fname:string;
firstframe : longint;
procedure fliplay(s:string;pauza:integer);
procedure decodefli_black;
procedure decodefli_color;
function setgraphmode:word;
procedure settextmode;
procedure waitforscreen;
procedure decodefli_lc;
procedure waiting;
procedure decodefli_brun;
procedure decodefli_copy;
implementation
function setgraphmode:word;assembler;
asm
mov ax,0013h
int 10h
mov ah,0fh
int 10h
xor ah,ah
end;
procedure settextmode;assembler;
asm
mov ax,0003h
int 10h
end;
procedure waitforscreen;assembler;
asm
mov dx,3dah
@wait1:
in al,dx
test al,8
jnz @wait1
@wait2:
in al,dx
test al,8
jnz @wait2
end;
procedure waiting;assembler;
asm
mov cx,speed
jcxz @end
dec cx
@wait:
call waitforscreen
loop @wait
@end:
end;
procedure decodefli_color;assembler;
asm
les ax,pal1
mov bx,es
mov dx,ax
and ax,15
mov di,ax
shr dx,4
add bx,dx
mov ax,bx
push ds
lds ax,buf
mov bx,ds
mov dx,ax
and ax,15
mov si,ax
shr dx,4
add bx,dx
mov ds,bx
cld
lodsw
mov bx,ax
test bx,bx
jmp @endu
@u:
lodsb
add di,ax
add di,ax
add di,ax
lodsb
or al,al
jnz @u2
mov ax,256
@u2:
mov cx,ax
add cx,ax
add cx,ax
rep movsb
dec bx
@endu:
jnz @u
sub di,768
mov si,di
push es
pop ds
mov cx,256
mov bl,0
@setpal:
mov dx,3c8h
mov al,bl
out dx,al
inc dx
lodsb
out dx,al
lodsb
out dx,al
lodsb
out dx,al
inc bl
loop @setpal
pop ds
end;
procedure decodefli_black;assembler;
asm
mov cx,32000
mov ax,0a000h
mov es,ax
xor ax,ax
mov di,ax
rep stosw
call waiting
end;
procedure decodefli_brun;assembler;
var linecount:word;
asm
call waitforscreen
mov linecount,200
mov ax,0a000h
mov es,ax
xor di,di
push ds
lds ax,buf
mov bx,ds
mov dx,ax
and ax,15
mov si,ax
shr dx,4
add bx,dx
mov ds,bx
cld
mov dx,di
xor ah,ah
@linelp:
mov di,dx
lodsb
mov bl,al
test bl,bl
jmp @endulcloop
@ulcloop:
lodsb
test al,al
js @ucopy
mov cx,ax
lodsb
rep stosb
dec bl
jnz @ulcloop
jmp @ulcout
@ucopy:
neg al
mov cx,ax
rep movsb
dec bl
@endulcloop:
jnz @ulcloop
@ulcout:
add dx,320
dec linecount
jnz @linelp
pop ds
call waiting
end;
procedure decodefli_lc;assembler;
var linecount:word;
asm
call waitforscreen
mov ax,0a000h
mov es,ax
xor di,di
push ds
lds ax,buf
mov bx,ds
mov dx,ax
and ax,15
mov si,ax
shr dx,4
add bx,dx
mov ds,bx
cld
lodsw
mov dx,320
mul dx
add di,ax
lodsw
mov linecount,ax
mov dx,di
xor ah,ah
@linelp:
mov di,dx
lodsb
mov bl,al
test bl,bl
jmp @endulcloop
@ulcloop:
lodsb
add di,ax
lodsb
test al,al
js @ulcrun
mov cx,ax
rep movsb
dec bl
jnz @ulcloop
jmp @ulcout
@ulcrun:
neg al
mov cx,ax
lodsb
rep stosb
dec bl
@endulcloop:
jnz @ulcloop
@ulcout:
add dx,320
dec linecount
jnz @linelp
pop ds
call waiting
end;
procedure decodefli_copy;assembler;
asm
call waitforscreen
mov ax,0a000h
mov es,ax
xor di,di
push ds
lds ax,buf
mov bx,ds
mov dx,ax
add ax,15
mov si,ax
shr dx,4
add bx,dx
mov ds,bx
mov cx,32000
rep movsw
pop ds
call waiting
end;
procedure fliplay(s:string;pauza:integer);
label daley;
begin
fname:=s;
if fname='' then begin
writeln ('Uzycie:fli <plik[.fli]>');halt(1);end;
if pos('.',fname)=0 then fname:=fname+'.fli';
assign (f,fname);
{$I-}
reset (f,1);{$i+}
{$I-}
blockread (f,h,sizeof(h));{$I+}
if setgraphmode<>$13 then begin writeln ('VGA REQUIRED');halt(5);end;
new(buf);new(pal1);
speed:=h.speed;
firstframe:=filepos(f);
while 1=1 do begin
for i:=1 to h.framecount do begin
{$i-}blockread(f,fh,sizeof(fh));{$i+}
if fh.ftype<>$f1fa then begin writeln ('Nieznany typ animacji!');
close(f);halt(4);end;if fh.chunks>0 then
for j:=1 to fh.chunks do begin
{$i-} blockread(f,ch,sizeof(ch));{$i+}
{$i-} blockread(f,buf^,ch.size-sizeof(ch));{$i+}

delay (pauza);
case ch.id of
11 : decodefli_color;
12 : decodefli_lc;
13 : decodefli_black;
15 : decodefli_brun;
16 : decodefli_copy;
end;
end else waiting;
if (port[$60]<$80) then begin
close (f);
dispose(pal1);dispose(buf);
settextmode;
exit;
end;

end;
daley:
seek (f,firstframe);
end;
end;
end.
