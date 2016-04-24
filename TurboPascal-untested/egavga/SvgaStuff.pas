(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0266.PAS
  Description: Svga stuff
  Author: DAVID HENNINGSSON
  Date: 02-21-96  21:04
*)


uses crt;
{
  Public Domain Code By David Henningsson 1996 (DIWIC)
  Spread it and use it, if you like.
  Written in Turbo Pascal 6.0
  Warning: This stuff is very slow and inoptimal.
  Do some "brain physics" and speed it up yourself!
}


const Svgatext:Array[0..4,0..15] of Byte = (
(0,1,1,0,1,0,1,0,0,1,1,0,0,1,0,0),
(1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0),
(0,1,0,0,1,0,1,0,1,0,1,0,1,1,1,0),
(0,0,1,0,1,1,1,0,1,0,1,0,1,0,1,0),
(1,1,0,0,0,1,0,0,0,1,1,0,1,0,1,0));


var Pro:Procedure;
    CurBank:Byte;

{ Only for 640x480x256 }
Procedure PutVpixel(X,Y:Word;F:Byte); assembler;
asm
  mov ax,640
  mul Y
  add ax,X     { If this putpixel routine seems to skip parts of the screen }
  adc dx,0     { or overwrites stuff already written }
  mov bx,4096  { <- try changing this number (to another power of two) }
  div bx   { This line is inoptimal... }
  xchg ax,dx
  push ax
  cmp dl,CurBank
  je @@DontSwitchBanks
  mov CurBank,dl
  mov ax,$4F05
  mov bx,0
  Call Pro
@@DontSwitchBanks:
  pop di
  mov ax,0A000h
  mov es,ax
  mov al,F
  stosb
end;

{ Goes a little bit faster, inline bank switching, only for Cirrus Logic }
{ Have tried to optimize it a bit }
Procedure PutVpixel2(X,Y:Word;F:Byte); assembler;
asm
  mov ax,640
  mul Y
  add ax,X
  adc dx,0
  mov di,ax
  mov ah,dl
  shl ah,4
  cmp ah,CurBank
  je @@DontSwitchBanks
  mov CurBank,ah
  mov dx,$3CE
{  in al,dx  }     { These four lines don't seem to be needed. If there is }
{  mov bl,al }     { trouble, try putting them back in business.}
  mov al,9
  out dx,ax
{  mov al,bl }
{  out dx,al }
@@DontSwitchBanks:
  mov ax,0A000h
  mov es,ax
  mov al,F
  stosb
end;

var I,J:Integer;
    K,L,M:Byte;
    Pal:Array[0..255,1..3] of Byte;

begin
  asm
    mov ax,$4F02
    mov bx,$101
    int 10h     { Set SVGA mode: 640x480x256 }
    mov ax,$4F01
    mov cx,$101
    push ds
    pop es
    mov di,OFFSET Pal
    int 10h
    mov di,OFFSET Pal+12
    mov bx,[di]
    mov cx,[di+2]
    mov WORD [Pro],bx
    mov WORD [Pro+2],cx  { Look up pointer to bank switcher }
  end;
  CurBank := 255; { Will always switch banks the first time }
  Fillchar(Pal,Sizeof(Pal),0);
  For I := 0 to 63 do begin
    Pal[I,1] := I;
    Pal[I+64,1] := 63-I;
    Pal[I+64,2] := I;
    Pal[I+128,2] := 63-I;
    Pal[I+128,3] := I;
    Pal[I+192,3] := 63-I;
  end;
  asm
    cld
    mov si,OFFSET Pal
    mov cx,256*3
    mov dx,$3C8
    mov al,0
    out dx,al
    inc dx
    rep outsb { Set palette }
  end;

{ K is random, since it is uninitialized! }
  For J := 0 to 479 div 6 do begin
    For I := 0 to 639 div 16 do begin
      Inc(K);
      For L := 0 to 4 do
        For M := 0 to 15 do
          If Svgatext[L,M] <> 0 then
            PutVPixel(I*16+M,J*6+L,K); { Here is the inoptimal stuff lying }
    end;
    Dec(K,43);
  end;
  Directvideo := FALSE;
  Textattr := 128;
  WindMax := 30*256+80; { Sets up the CRT unit }
  GotoXY(28,15);
  Writeln('Is this SVGA or aint it?');
  GotoXY(25,17);
  Writeln('Is this 640x480x256 or aint it?');
  REadkey;
  Textmode(3);
end.

