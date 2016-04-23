{
>   All this posting about programming flame and which 3x3 grid thing gives
> the best results has got me interested.  Can anyone post some _FAST_ flame
> code?
Here is a routine I wrote a while ago. It is PAS with a lot of ASM for
speed, but we are still on topic :-). It draws a fire from the right side
of the screen to the left. I was going to use this as a scroller type
thing but didn't get around to it so far.
}

program fire01; {$g+,x+}
uses crt;
type
 pal=array[0..255,1..3]of byte;
 color=array[1..3] of byte;
 pplanes=^tplanes;
 tplanes=array[0..3,0..199,0..79]of byte;
 pfire=^tfire;
 tfire=array[0..99,0..159]of byte;

var
 i,j,origmode:integer;
 palette,firepal,zeropal:pal;
 planes:pplanes;
 fire:pfire;

Procedure WaitRetrace; Assembler;
Asm
 Mov DX,3DAh
@L1:
 In   AL,DX
 Test AL,08
 Jne  @L1
@L2:
 In   AL,DX
 Test AL,08
 Je   @L2
End;

procedure vmode13h;assembler;
asm
mov ax,0013h
int 10h
end;

procedure vmodeuc;assembler;
asm
 call vmode13h
 mov  ax,0604h
 mov  dx,3c4h
 out  dx,ax
 mov  dx,3d4h
 mov  ax,0e317h
 out  dx,ax
 mov  ax,0014h
 out  dx,ax
end;

procedure vselectbitplanes(i:byte);assembler;
asm
 mov ah,i
 mov al,2
 mov dx,3c4h
 out dx,ax
end;

procedure vputpix(x,y:word;color:byte);assembler;
asm
 mov cx,x
 shl cx,6
 shr cl,6

 mov ax,102h
 shl ah,cl
 mov dx,3c4h
 out dx,ax

 mov ax, $a000
 mov es,ax

 shr cx,8

 mov ax,y
 mov bx,ax
 shl bx,4
 shl ax,6
 add ax,bx
 mov di,ax
 add di,cx
 mov bl,color

 mov [es:di],bl
end;

procedure writeplanes(planes:pplanes);assembler;
asm
 cld
 push ds
 mov cx,4
 mov ax,$a000
 mov es,ax
@loop1:
 push cx
  neg cl
  add cl,4

  mov ax,0102h
  shl ah,cl
  mov dx,3c4h
  out dx,ax

		mov di,0
		mov ax,word ptr planes[2]
		mov ds,ax
		mov ax,word ptr planes
		or cl,cl

		jz @1
@2:
		add ax,16000
		loop @2
@1:
		mov si,ax
		mov cx,16000
		rep movsb
	pop cx
	loop @loop1
	pop ds
end;


procedure vclrscr(i:byte);
begin
	vselectbitplanes(15);
	fillchar(ptr($a000,0000)^,65535,i);
end;

procedure getpal(var l:pal);
var i,j:byte;
begin
	for i:=0 to 255 do begin
		port[$3c7]:=i;
		for j:=1 to 3 do l[i,j]:=port[$3c9];
	end;
end;

procedure setpal(l:pal);
var i,j:byte;
begin
	for i:=0 to 255 do begin
		port[$3c8]:=i;
		for j:=1 to 3 do port[$3c9]:=l[i,j];
	end;
end;

procedure loadpal(s:string;var palette:pal);
var f:file;
begin
	assign(f,s);
	reset(f,1);
	blockread(f,palette,768);
	close(f);
end;

procedure fadeto(start,stop:byte;dest:pal);
var
	i,j:byte;
	c:color;
begin
	for i:=start to stop do begin
		port[$3c7]:=i;
		for j:=1 to 3 do begin
			c[j]:=port[$3c9];
			if c[j]>dest[i,j] then dec(c[j]);
			if c[j]<dest[i,j] then inc(c[j]);
		end;
		port[$3c8]:=i;
		for j:=1 to 3 do port[$3c9]:=c[j];
	end;
end;

procedure fadeout(start,stop:byte);
var i,j:byte;
	c:color;
begin
	for i:=start to stop do begin
		port[$3c7]:=i;
		for j:=1 to 3 do begin
			c[j]:=port[$3c9];
			if c[j]>1 then dec(c[j]) else c[j]:=0;
		end;
		port[$3c8]:=i;
		for j:=1 to 3 do port[$3c9]:=c[j];
	end;
end;

procedure calcfire(fire:pfire);assembler;
asm
	les di,fire
	mov cx,159
	add di,1
	xor ax,ax
	xor bx,bx
	xor dx,dx
@loop1:
	push cx
	mov cx,98
@loop2:
	add di,159
	xor ax,ax
	mov al,[es:di+2]
	add al,[es:di+1]
	adc ah,0
	add al,[es:di-159]
	adc ah,0
	add al,[es:di+161]
	adc ah,0

	add ax,1
	shr ax,2
	stosb
	loop @loop2
	sub di,160*98-1
	pop cx
	loop @loop1

	mov cx,80
	mov ax,0
	mov di,0
	rep stosw
	mov cx,80
	mov di,16000-160
	rep stosw

	mov cx,100
	mov di,0
@loop3:
	add di,159
	stosb
	loop @loop3
end;

procedure writefire(fire:pfire);assembler;
asm
	push ds
	lds si,fire
	add si,160
	mov ax,$a000
	mov es,ax
	mov di,160

	mov ax,0302h
	mov dx,3c4h
	out dx,ax
	mov cx,98
@loopa:
	push cx
	mov cx,80
@loop1:
	lodsw
	stosb
	loop @loop1

	sub si,160
	mov cx,80
@loop2:
	lodsw
	stosb
	loop @loop2
	pop cx
	loop @loopa

	lds si,fire
	add si,160
	mov ax,$a000
	mov es,ax
	mov di,160
	mov ax,0c02h
	out dx,ax
	mov cx,98
@loopb:
	push cx
	mov cx,80
@loop3:
	lodsw
	shr ax,8
	stosb
	loop @loop3

	sub si,160
	mov cx,80
@loop4:
	lodsw
	shr ax,8
	stosb
	loop @loop4
	pop cx
	loop @loopb

	pop ds
end;

begin
	origmode:=lastmode;
	getpal(palette);
	fillchar(zeropal,768,0);
	for i:=1 to 64 do begin
		fadeto(0,255,zeropal);
		delay(10);
	end;

	loadpal('pal1.pal',firepal);

	vmodeuc;
	vclrscr(0);
	randomize;


	setpal(firepal);
	new(fire);
	fillchar(fire^,16000,0);
	writefire(fire);
	readkey;
	repeat
		for i:=20 to 70 do fire^[i,159]:=random(30);
		for i:=1 to 20 do fire^[20+random(50),159]:=255;
		calcfire(fire);
		writefire(fire);
	until keypressed;

	readkey;
	for i:=1 to 64 do begin
		fadeto(0,255,zeropal);
		delay(10);
	end;
	textmode (origmode);
end.


-------------------------------------------
And here is pal1.pal which is needed by the program. Well, you could
include it in the code, but what the heck...
----------------------------------------------
section 1 of uuencode 4.02 of file pal1.pal    by R.E.M.

begin 644 pal1.pal
M```````!`0`"`0`#`@$$`P$&!`$'!0$(!@$*!P(+"`(-"0(."@,/"@,1"P,2O
M#`03#005#@06#P48$`49$04:$@8<$P8<%08=%@8>&`8>&@8?'`8@'08@'P<AY
M(0<A(@<A(P<@(P<?)`<?)0<>)0<=)@<<)P<;)P@:*`@8*0@7*0@6*@@5*P@3]
M*P@2+`@0+`@/+0@-+@@++@D*+PD(,`L),`X),0\),A(),Q,),Q,),Q,),Q,)T
M,Q,),Q0),Q0),Q0*,Q0*,Q0*,Q4*,Q4*,Q4*,Q4*,Q4+,Q8+,Q8+,Q8+,Q8++
M,Q8+,Q<+,Q<+,Q<+,Q<,,Q<,,Q@,,Q@,,Q@,-!@,-!@,-!D,-!D,-!D--!D-_
M-!D--!D--!H--!H--!H--!H.-!H.-!H.-!L.-!L.-!L.-!L.-!L/-!P/-!P/6
M-!P/-!P/-!P/-!P/-!T/-!T/-!T0-!T0-!T0-!X0-1X0-1X0-1X0-1X1-1X1B
M-1X1-1\1-1\1-1\1-1\1-1\1-2`1-2`2-2`2-2`2-2`2-2$2-2$2-2$2-2$3'
M-2$3-2$3-2$3-2(3-2(3-2(3-2(4-2(4-2(4-2,4-2,4-2,4-B,4-B,5-B,5M
M-B05-B05-B06-B06-B46-B46-B47-B47-B88-B88-B88-R89-R89-R<9-R<:>
M-R<:-R<:-R@;-R@;-R@<-R@<-R@<."D=."D=."D=."H>."H>."H>."H?."H?R
M."L?."L@."L@."LA.2PA.2PB.2PB.2TB.2TC.2TC.2TC.2TD.2XD.2XD.2XE-
M.2XE.B\F.B\F.B\F.B\G.C`G.C`H.C`H.C`H.C$I.C$I.C$J.S(J.S(J.S(K>
M.S(K.S,L.S,L.S,L.S,M.S,M.S0N.S0N.S0N/#4O/#4O/#4P/#4P/#8Q/#8Q<
M/#8R/#8R/#<R/#<S/#<S/#<S/3@T/3@T/3@U/3DU/3DV/3DV/3HW/3HW/3HW4
M/3HX/3LX/CLY/CLY/CLY/CPZ/CPZ/CP[/CT[/CT\/CT\/CT]/CX]/CX]/SX^P
#/S\_]
``
end
sum -r/size 33571/1104 section (from "begin" to "end")
sum -r/size 13047/768 entire input file
