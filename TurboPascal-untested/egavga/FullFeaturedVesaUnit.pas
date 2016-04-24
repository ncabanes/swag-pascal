(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0277.PAS
  Description: Full featured VESA Unit
  Author: LIONEL CORDESSES
  Date: 08-30-96  09:36
*)

{ see the demo at the end of this unit }
(*
*****************************************************************************

  Copyright (C) 1995 Lionel CORDESSES

  This source is a part of a program that  allows you to read and display
a color or a black and  white  JPEG picture . I wrote the  full source in
order to understand how  it  works . Some  parts  are  translated  from C
language to Pascal (the reverse DCT for instance ).
	I used many sources of informations:
        - "The JPEG Still Picture Compression Standart" by G.K.Wallace,
        - C sources and doc from the Independent JPEG Group's software,
        - C sources and doc from  the Portable  Video Research Group (PVRG)
	code,
        - the FAQ about JPEG,
        - "JPEG Compression" by C.Cavigioli (ANALOG DEVICE application note
        AN-336B )
	- and many others ...

    You  can use , modified and distribute this source as long as credit is
given.

*****************************************************************************
*)

{
****************************************************************************

      Here is an other VESA unit !!!!!!

      It is based on various sources ( DVPEG,John Bridges VGAKIT,
    SWAG an many others ).
      You can use,modified an distribute this source as long as credit
    is given.


    Supported modes:
      - 256 colors
      - 32768 colors
      - 16 millions colors


    The demo program for this unit is DemoVesa.

                                              Lionel Cordesses
                                              From FRANCE.
                                              June 1995

****************************************************************************
}
unit usvesa3;
interface

uses dos,crt;


var

  use_16,use_32:boolean;
  x_size:word;

Function  write_fast_16(x1,y,x2,indice:word;var rouge,vert,bleu):boolean;
Function  get_time:longint;
Function  write_fast(x1,y,x2:word;var entree):boolean;
Procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);
Procedure find_black(max_color:word;var black,white:byte);
Function  setmode(mode:word):byte;  { return 0 if bad, 1 if OK }
Procedure setpix(x,y,col:word);
Procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
Function  getpix(x,y:word):byte;
Procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}

Function write_fast_16_BRG(x1,y,x2:word;var image):boolean;





implementation


var
  reg:registers;
  vgran,curbank:word;
  add_bank:Procedure;
  tps1,tps2:longint;
  heure,minute,seconde,sec100:word;

  bytes:word;





{$ifdef msdos}
Procedure setbank(bank:byte);far;
var banque:word;
  begin
    banque:=bank*longint(64) div vgran;
    asm
      mov bx, 0
      mov dx, banque
      call  [add_bank]
      mov bx, 1
      mov dx, banque
      call  [add_bank]

    end;
    curbank:=bank;
end;

{$else}

Procedure setbank(bank:byte{word});far;
var banque:word;

  begin
             reg.ax:=$4f05;
             reg.bx:=0;
             reg.dx:=bank*longint(64) div vgran;

             intr($10,reg);
             reg.ax:=$4f05;
             reg.bx:=1;
             intr($10,reg);

  curbank:=bank;
end;
{$endif}



Function setvesa(mode:word):byte;

  begin
    asm
     mov ax,4F02h
     mov bx,mode
     int 10h
     sub ax,004Fh
     mov @RESULT,al
   end;
  end;



{$ifdef msdos}
Function setmode(mode:word):byte;  { 0 if bad,1 if OK}
type type_vesarec=array[0..555] of byte;
     ves_ptr=^type_vesarec;

type
  long=record
         lo,hi:word;
       end;

var pro:byte;
    vesarec:ves_ptr;

    vesa_info:record
      debut:array[0..3] of byte;
      granularite:word;
      winsize,
      winaseg,
      winbseg:word;
      add_proc:Procedure;
      bytes:word;
      width,
      height:word;
      char_width,
      char_high,
      planes,
      bits_per_pixel:byte;
      reste:array[0..250] of byte;
    end;


  begin
    setmode:=1;
    getmem(vesarec,556);
    pro:=setvesa(mode);
    fillchar(vesarec^[0],256,0); { set all to zero  }

      reg.ax:=$4f01;
      reg.cx:=mode;
      reg.es:=long(vesarec).hi;
      reg.di:=long(vesarec).lo;

      intr($10,reg);
      if reg.ah=0 then
        begin
          setmode:=1;
          pro:=1;
        end
      else
        begin
          setmode:=0;
          pro:=0;
        end;

      move(vesarec^[0],vesa_info.debut[0],256);
      if reg.al=0 then
        begin
          setmode:=1;
          pro:=1;
        end;
      vgran:=vesa_info.granularite;
      { nb pixel per lines }
      if pro=1 then
        x_size:=vesa_info.bytes ;
      add_bank:=vesa_info.add_proc;        { change bank far ptr }
{      x_size:=vesa_info.bytes;}

    freemem(vesarec,556);

    use_16:=false;
    use_32:=false;
    if mode=$112 then use_16:=true;
    if mode=$110 then use_32:=true;




  end;


{$endif}

Procedure setpix(x,y,col:word);assembler;
var  decalage:word;
      asm
	mov	bx,x
	mov	ax,y	{removed all range checking on x,y for speed}
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
	adc	ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax = bank }
        @nonew:

          mov bx,col
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl
      end;

Procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);assembler;
var l:longint;
    provi:byte;
    couleur,decalage:word;

      asm
        mov al,use_16
        cmp al,0
        je @v32000

	mov	bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
	mov	ax,y	{removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
	adc	ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonewa
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax= bank }
        @nonewa:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,bleu
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew1:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,vert
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew2:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,rouge
          mov byte ptr [es:di],bl

          jmp @fin

      @v32000:
	mov	bx,x
	mov	ax,y	{removed all range checking on x,y for speed}
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
	shl	ax, 1
	shl	bx, 1
	adc	ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew:


        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov bx,[es:di]
        mov al,bl
        and al,31
        shl al,3
        les di,bleu
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,vert
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,rouge
        mov byte ptr [es:di],al

        @fin:
      end;



Procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
var l:longint;
    provi:byte;
    couleur,decalage:word;
  begin
    if use_16=true then
      asm

	mov	bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
	mov	ax,y	{removed all range checking on x,y for speed}
{        shl ax,1
        add ax,y}        { y }
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
	adc	ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov bl,bleu
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew1:

          mov bl,vert
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew2:

          mov bl,rouge
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl


      end;

  if use_32=true then
      asm
	mov	bx,x
        shl     bx,1
	mov	ax,y	{removed all range checking on x,y for speed}
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
{	shl	ax, 1
	shl	bx, 1}
	adc	ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew:


        mov al,rouge
        shr al,3
        mov ah,0
        shl ax,10
        mov bl,vert
        shr bl,3
        mov bh,0
        shl bx,5
        add ax,bx
        mov bl,bleu
        shr bl,3
        mov bh,0
        add bx,ax
        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov [es:di],bx
      end;
  end;

Procedure Move16(Var Source,Dest;Count:Word); Assembler;
Asm
  PUSH DS
  LDS SI,SOURCE
  LES DI,DEST
  MOV AX,COUNT
  MOV CX,AX
  SHR CX,1
  REP MOVSW
  TEST AX,1
  JZ @end
  MOVSB
@end:POP DS
end;


Function write_fast(x1,y,x2:word;var entree):boolean;
var coord1,coord2:longint;
    couleur:byte;
  begin
    write_fast:=false;
    coord1:=longint(y)*longint(x_size)+x1;
    coord2:=coord1+longint((x2-x1)+1);
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    if (coord1 shr 16)=(coord2 shr 16) then
      begin
         move16(entree,mem[sega000:(coord1 mod 65536)],(x2-x1+1));
         write_fast:=true;
      end;
  end;


Function get_time:longint;
var heure,minute,seconde,sec100:word;
  begin
    gettime(heure,minute,seconde,sec100);
    get_time:=heure*3600*100+minute*60*100+seconde*100+sec100;
  end;




Procedure find_black(max_color:word;var black,white:byte);
var luminance,n:byte;
    reg:registers;
    table:array[0..767] of byte;
    i,x,y:word;

  begin
       with reg do
         begin
           ah:=$10;
           al:=$17;
           bx:=0;
           cx:=max_color;
           es:=seg(table);
           dx:=ofs(table);
           intr($10,reg);
         end;
    i:=0;
    white:=0;
    black:=255;
    for n:=0 to max_color-1 do
      begin
        luminance:=round(((0.59*table[i+1])+(0.3*table[i])+
        (0.11*table[i+2])));
        if luminance>white then
          begin
            white:=luminance;
            x:=n;
          end;
        if luminance<black then
          begin
            black:=luminance;
            y:=n;
          end;
        inc(i,3);
      end;
    i:=0;
    black:=y;
    white:=x;
  end;


Procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}
type
  pchar=array[char] of array[0..15] of byte;
var
  p:^pchar;
  c:char;
  i,j,z,b:integer;
  noir,blanc:byte;
begin
  reg.ax:=$1130;
  reg.bh:=6;
  intr($10,reg);
  p:=ptr(reg.es,reg.bp);
  if (use_16=false) and (use_32=false) then
    find_black(256,noir,blanc)
  else
    begin
      noir:=0;
      blanc:=255;
    end;
      for z:=1 to length(txt) do
      begin
        c:=txt[z];
        for j:=0 to 15 do
        begin
          b:=p^[c][j];
          for i:=x+7 downto x do
          begin
            if (use_16=false) and (use_32=false)  then
              begin
                if odd(b) then setpix(i,y+j,blanc)
                          else setpix(i,y+j,noir);
              end
            else
              begin
                if odd(b) then setpix_16(i,y+j,blanc,blanc,blanc)
                          else setpix_16(i,y+j,noir,noir,noir);
              end;

            b:=b shr 1;
          end;
        end;
        inc(x,8);
      end;

end;

Function getpix(x,y:word):byte;assembler;
var  decalage:word;
      asm
	mov	bx,x
	mov	ax,y	{removed all range checking on x,y for speed}
	mul	x_size	{640 bytes wide in most cases}
	add	bx,ax
	adc	dx,0
	mov	ax, dx	{ what a $#%%# stupid microprocessor}
	adc	ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov al,[es:di]
      end;

Function write_fast_16(x1,y,x2,indice:word;var rouge,vert,bleu):boolean;
var coord1,coord2:longint;
    couleur:byte;
    i,from,i_mem,x_pixel:word;
  begin
    write_fast_16:=false;
    coord1:=longint(y)*longint(x_size)+longint(x1)*3;  {R+V+B=3 bytes  }
    coord2:=coord1+longint((x2-x1)+1)*3;
    (* is the first point in current bank ????  *)
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    (* if the first and the last points are in the same 64k bank        *)
    if ((coord1 shr 16)=(coord2 shr 16)) and (use_16=true) then
      begin
         i:=indice;
         i_mem:=0;
         from:=(coord1 mod 65536);
{         x_pixel:=(x2-x1+1);}
         x_pixel:=(x2-x1);
         asm
           push ds

           les di,bleu
           add di,i
           mov si,from
           mov cx,x_pixel
           mov ax,sega000
           mov ds,ax
         @@xloop_b:
             mov al,[es:di]
             mov [ds:si],al
             inc di
             add si,3
             dec cx
             jnz @@xloop_b

           pop ds
           mov si,from
           inc si
           mov cx,x_pixel
           push ds
           les di,vert
           add di,i
           mov ax,sega000
           mov ds,ax
         @@xloop_g:
             mov al,[es:di]
             mov [ds:si],al
             inc di
             add si,3
             dec cx
             jnz @@xloop_g

           pop ds
           mov si,from
           inc si
           inc si
           mov cx,x_pixel
           push ds
           les di,rouge
           add di,i
           mov ax,sega000
           mov ds,ax
         @@xloop_r:
             mov al,[es:di]
             mov [ds:si],al
             inc di
             add si,3
             dec cx
             jnz @@xloop_r

           pop ds
         end;
         write_fast_16:=true;
      end;
  end;




Function write_fast_16_BRG(x1,y,x2:word;var image):boolean;
var coord1,coord2:longint;
    couleur:byte;
    i,from,x_pixel:word;
  begin
    write_fast_16_BRG:=false;
    coord1:=(longint(y)*longint(x_size)+longint(x1))*1;
    coord2:=coord1+longint((x2-x1)+1)*3;
    (* is the first point in current bank ????  *)
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    (* if the first and the last points are in the same 64k bank        *)
    if ((coord1 shr 16)=(coord2 shr 16)) and (use_16=true) then
      begin
         from:=(coord1 mod 65536);
         x_pixel:=(x2-x1+1)*3 div 4;
         asm
            push ds
            mov cx,x_pixel
            mov di,from
            mov es,SegA000
            lds si,image
            cld
{          @boucle:
            mov ax,[ds:si]
            mov [es:di],ax
            add si,2
            add di,2
            dec cx
            jnz @boucle}
{            rep movsw}
            db      0f3h, 066h, 0a5h  { rep movsd }
            pop ds
         end;
         write_fast_16_BRG:=true;
      end;
  end;

end.

{ --------------------------   DEMO PROGRAM  ------------------------ }
(*
*****************************************************************************

  Copyright (C) 1995 Lionel CORDESSES

  This source is a part of a program that  allows you to read and display
a color or a black and  white  JPEG picture . I wrote the  full source in
order to understand how  it  works . Some  parts  are  translated  from C
language to Pascal (the reverse DCT for instance ).
	I used many sources of informations:
        - "The JPEG Still Picture Compression Standart" by G.K.Wallace,
        - C sources and doc from the Independent JPEG Group's software,
        - C sources and doc from  the Portable  Video Research Group (PVRG)
	code,
        - the FAQ about JPEG,
        - "JPEG Compression" by C.Cavigioli (ANALOG DEVICE application note
        AN-336B )
	- and many others ...

    You  can use , modified and distribute this source as long as credit is
given.

*****************************************************************************
*)

{
*****************************************************************************

    Sample program for the unit Usvesa3.

    Only 2 mode tested here:
      - 256 colors
      - 16 millions colors

    You can change the
       "n:=setmode($112);" and write :
       "n:=setmode($110);" .
    I am sure that you will see the difference between 32768 an 16 millions
  colors !!!

                                           Lionel Cordesses
                                           From FRANCE.
                                           June 1995
*****************************************************************************
}

program VesaDemo;

{$f+}

uses dos,crt,usvesa3;

var n:byte;
    x,y,i:word;
    ch:char;
    funckey:boolean;
    code:byte;
    tps1,tps2:longint;

procedure touche(var funckey:boolean;var code:byte);
var ch:char;
  begin
    while keypressed do
      ch:=readkey;
    repeat
    until not keypressed;
    ch:=readkey;
    if ch<>#0 then funckey:=false
    else
      begin
        funckey:=true;
        ch:=readkey;
      end;
    code:=ord(ch);
  end;



procedure test_256;
  begin
    clrscr;
    writeln('Testing VESA mode 640x480 256 colors');
    writeln('Press a key ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    n:=setmode($101);
    if n=0 then
      begin
        textmode(co80);
        writeln('WARNING:no VESA driver or unsupported mode !!! ');
        halt(1);
      end;
    for x:=0 to 255 do
      for y:=0 to 255 do
        setpix(x,y,x);
    wrtxt(10,300,'Mode VESA 101h OK : Press a key to quit ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    textmode(co80);
  end;

procedure test_32;
  begin
    clrscr;
    writeln('Testing VESA mode 640x480 32768  colors');
    writeln('Press a key ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    n:=setmode($110);
    if n=0 then
      begin
        textmode(co80);
        writeln('WARNING:no VESA driver or unsupported mode !!! ');
        halt(1);
      end;
    tps1:=get_time;
    for y:=0 to 255 do
      for x:=0 to 255 do
        setpix_16(x,y,x,y,255-x);
    tps2:=get_time;
    wrtxt(10,300,'Mode VESA 110h OK : Press a key to quit ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    textmode(co80);
  end;

procedure test_16;
  begin
    clrscr;
    writeln('Testing VESA mode 640x480 16 millions  colors');
    writeln('Press a key ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    n:=setmode($112);
    if n=0 then
      begin
        textmode(co80);
        writeln('WARNING:no VESA driver or unsupported mode !!! ');
        halt(1);
      end;
    tps1:=get_time;
    for y:=0 to 255 do
      for x:=0 to 255 do
        setpix_16(x,y,x,y,255-x);
    tps2:=get_time;
    wrtxt(10,300,'Mode VESA 112h OK : Press a key to quit ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    textmode(co80);
  end;


begin
  test_256;
  test_32;
  test_16;
  textmode(co80);
  writeln;
  writeln('VESATST.EXE (C) 1995 Lionel Cordesses ');
end.


