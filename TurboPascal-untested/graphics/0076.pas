{
---------------------------------------------------------------------------

    This is a PD source that I came across not too long ago.. It displays a
simulation of flames or fire.. Its pretty good..
}

{*        credit were given, however. If you have any improvements,       *}
{*        find any bugs etc. mail me at mackey@aqueous.ml.csiro.au        *}
{*        with MARK: in the subject header.                               *}
{*                                                                        *}
{*************************************************************************}


uses crt;
type bigarr=array[0..102,0..159] of integer;
var f:bigarr;
    i,j,k,l:word;
    delta:integer;
    pal:array[0..255,1..3] of byte;
    ch:char;

procedure setmode13;
assembler;
asm
  mov ax,13h
  int 10h
end;

procedure setpalette;
var mapfile:text;
    i,j:integer;

begin
  assign(mapfile,'flames5.map');  {kludgy, but it works!}
  reset(mapfile);
  for i:=0 to 255 do
  for j:=1 to 3 do
  begin
    read(mapfile,pal[i,j]);
    pal[i,j]:=pal[i,j] shr 2;
  end;
  asm
    mov si,offset pal
    mov cx,768      {no of colour registers}
    mov dx,03c8h
    xor al,al     {First colour to change pal for = 0}
    out dx,al
    inc dx
@1: outsb
    dec cx        {safer than rep outsb}
    jnz @1
  end;
end;

begin
  setmode13;
  setpalette;
  randomize;
  ch:=' ';
  for i:=0 to 102 do
  for j:=0 to 159 do
    f[i,j]:=0;        {initialise array}

  repeat
    asm                {move lines up, averaging}
      mov cx,16159;    {no. elements to change}
      mov di,offset f
      add di,320   {di points to 1st element of f in upper row (320 bytes/row)}
@1:
      mov ax,ds:[di-2]
      add ax,ds:[di]
      add ax,ds:[di+2]
      add ax,ds:[di+320]
      shr ax,2     {divide by 4: average 4 elements of f}
      jz @2
      sub ax,1
@2:   mov word ptr ds:[di-320],ax
      add di,2
      dec cx
      jnz @1    {faster than _loop_ on 486}
    end;


    for j:=0 to 159 do  {set new bottom line}

--- Maximus 2.01wb
 * Origin: *THE K-W AMATEUR RADIO BBS-(VE3MTS)* ->DS16.8<- (1:221/177)
===========================================================================
 BBS: Canada Remote Systems
Date: 12-02-93 (17:42)             Number: 46962
From: FIASAL JUMA                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: Fire                           Conf: (1221) F-PASCAL
---------------------------------------------------------------------------


       This is a PD source that I came across a while ago.. It simulates flames
or fire.. its pretty good source..

program flames;
{**************************************************************************}
{*                                                                        *}
{*    FLAMES by M.D.Mackey  (C) 1993                                      *}
{*        This code released into the public domain. It may be freely     *}
{*        used, distributed and modified. I would appreciate it if        *}
{*        credit were given, however. If you have any improvements,       *}
{*        find any bugs etc. mail me at mackey@aqueous.ml.csiro.au        *}
{*        with MARK: in the subject header.                               *}
{*                                                                        *}
{**************************************************************************}


uses crt;

Const pal : array [1..768] of Byte =( 0,  0,  0,  0,  0, 24,  0,  0, 24,  0,
0, 28,
                          0,  0, 32,  0,  0, 32,  0,  0, 36,  0,  0, 40,
                           8,  0, 40, 16,  0, 36, 24,  0, 36, 32,  0, 32,
                          40,  0, 28, 48,  0, 28, 56,  0, 24, 64,  0, 20,
                          72,  0, 20, 80,  0, 16, 88,  0, 16, 96,  0, 12,
                         104,  0,  8,112,  0,  8,120,  0,  4,128,  0,  0,
                         128,  0,  0,132,  0,  0,136,  0,  0,140,  0,  0,
                         144,  0,  0,144,  0,  0,148,  0,  0,152,  0,  0,
                         156,  0,  0,160,  0,  0,160,  0,  0,164,  0,  0,
                         168,  0,  0,172,  0,  0,176,  0,  0,180,  0,  0,
                         184,  4,  0,188,  4,  0,192,  8,  0,196,  8,  0,
                         200, 12,  0,204, 12,  0,208, 16,  0,212, 16,  0,
                         216, 20,  0,220, 20,  0,224, 24,  0,228, 24,  0,
                         232, 28,  0,236, 28,  0,240, 32,  0,244, 32,  0,
                         252, 36,  0,252, 36,  0,252, 40,  0,252, 40,  0,
                         252, 44,  0,252, 44,  0,252, 48,  0,252, 48,  0,
                         252, 52,  0,252, 52,  0,252, 56,  0,252, 56,  0,
                         252, 60,  0,252, 60,  0,252, 64,  0,252, 64,  0,
                         252, 68,  0,252, 68,  0,252, 72,  0,252, 72,  0,
                         252, 76,  0,252, 76,  0,252, 80,  0,252, 80,  0,
                         252, 84,  0,252, 84,  0,252, 88,  0,252, 88,  0,
                         252, 92,  0,252, 96,  0,252, 96,  0,252,100,  0,
                         252,100,  0,252,104,  0,252,104,  0,252,108,  0,
                         252,108,  0,252,112,  0,252,112,  0,252,116,  0,
                         252,116,  0,252,120,  0,252,120,  0,252,124,  0,
                         252,124,  0,252,128,  0,252,128,  0,252,132,  0,
                         252,132,  0,252,136,  0,252, 136,   0,252, 140,   0,
                         252, 140,   0,252, 144,   0,252, 144,   0,252, 148,
0,
                         252, 152,   0,252, 152,   0,252, 156,   0,252, 156,
0,
                         252, 160,   0,252, 160,   0,252, 164,   0,252, 164,
0,
                         252, 168,   0,252, 168,   0,252, 172,   0,252, 172,
0,
                         252, 176,   0,252, 176,   0,252, 180,   0,252, 180,
0,
                         252, 184,   0,252, 184,   0,252, 188,   0,252, 188,
0,
                         252, 192,   0,252, 192,   0,252, 196,   0,252, 196,
0,
                         252, 200,   0,252, 200,   0,252, 204,   0,252, 208,
0,
                         252, 208,   0,252, 208,   0,252, 208,   0,252, 208,
0,
                         252, 212,   0,252, 212,   0,252, 212,   0,252, 212,
0,
                         252, 216,   0,252, 216,   0,252, 216,   0,252, 216,
0,
                         252, 216,   0,252, 220,   0,252, 220,   0,252, 220,
0,
                         252, 220,   0,252, 224,   0,252, 224,   0,252, 224,
0,
                         252, 224,   0,252, 228,   0,252, 228,   0,252, 228,
0,
                         252, 228,   0,252, 228,   0,252, 232,   0,252, 232,
0,
                         252, 232,   0,252, 232,   0,252, 236,   0,252, 236,
0,
                         252, 236,   0,252, 236,   0,252, 240,   0,252, 240,
0,

--- Maximus 2.01wb
 * Origin: *THE K-W AMATEUR RADIO BBS-(VE3MTS)* ->DS16.8<- (1:221/177)
===========================================================================
 BBS: Canada Remote Systems
Date: 12-02-93 (17:45)             Number: 46963
From: FIASAL JUMA                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: Fire II                        Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Continue.....

                252, 244,   0,252, 244,   0,252, 244,   0,252, 248,   0,
                252, 248,   0,252, 248,   0,252, 248,   0,252, 252,   0,
                252, 252,   4,252, 252,   8,252, 252,  12,252, 252,  16,
                252, 252,  20,252, 252,  24,252, 252,  28,252, 252,  32,
                252, 252,  36,252, 252,  40,252, 252,  40,252, 252,  44,
                252, 252,  48,252, 252,  52,252, 252,  56,252, 252,  60,
                252, 252,  64,252, 252,  68,252, 252,  72,252, 252,  76,
                252, 252,  80,252, 252,  84,252, 252,  84,252, 252,  88,
                252, 252,  92,252, 252,  96,252, 252, 100,252, 252, 104,
                252, 252, 108,252, 252, 112,252, 252, 116,252, 252, 120,
                252, 252, 124,252, 252, 124,252, 252, 128,252, 252, 132,
                252, 252, 136,252, 252, 140,252, 252, 144,252, 252, 148,
                252, 252, 152,252, 252, 156,252, 252, 160,252, 252, 164,
                252, 252, 168,252, 252, 168,252, 252, 172,252, 252, 176,
                252, 252, 180,252, 252, 184,252, 252, 188,252, 252, 192,
                252, 252, 196,252, 252, 200,252, 252, 204,252, 252, 208,
                252, 252, 208,252, 252, 212,252, 252, 216,252, 252, 220,
                252, 252, 224,252, 252, 228,252, 252, 232,252, 252, 236,
                252, 252, 240,252, 252, 244,252, 252, 248,252, 252, 252);


type bigarr=array[0..102,0..159] of integer;
var f:bigarr;
    i,j,k,l:word;
    delta:integer;
    pal:array[0..255,1..3] of byte;
    ch:char;

procedure setmode13;
assembler;
asm
  mov ax,13h
  int 10h
end;

procedure setpalette;
var mapfile:text;
    i,j:integer;

begin
  for j:=1 to 768 do
  begin
    pal[j]:=pal[j] shr 2;
  end;

  asm
    mov si,offset pal
    mov cx,768
    mov dx,03c8h
    xor al,al
    out dx,al
    inc dx
@1:
    outsb
    dec cx
    jnz @1
  end;
end;

begin
  setmode13;
  setpalette;
  randomize;
  ch:=' ';
  for i:=0 to 102 do
  for j:=0 to 159 do
    f[i,j]:=0;        {initialise array}

  repeat
    asm                {move lines up, averaging}
      mov cx,16159;    {no. elements to change}
      mov di,offset f
      add di,320   {di points to 1st element of f in upper row (320 bytes/row)}
@1:
      mov ax,ds:[di-2]
      add ax,ds:[di]
      add ax,ds:[di+2]
      add ax,ds:[di+320]
      shr ax,2     {divide by 4: average 4 elements of f}
      jz @2
      sub ax,1
@2:   mov word ptr ds:[di-320],ax
      add di,2
      dec cx
      jnz @1    {faster than _loop_ on 486}
    end;


    for j:=0 to 159 do  {set new bottom line}
    begin
      if random<0.4 then
        delta:=random(2)*255;
      f[101,j]:=delta;
      f[102,j]:=delta;
    end;

--- Maximus 2.01wb
 * Origin: *THE K-W AMATEUR RADIO BBS-(VE3MTS)* ->DS16.8<- (1:221/177)
===========================================================================
 BBS: Canada Remote Systems
Date: 12-02-93 (17:47)             Number: 46964
From: FIASAL JUMA                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: Fire III                       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Continue..

    asm                 {output to screen}
      mov si,offset f
      mov ax,0a000h
      mov es,ax
      mov di,0
      mov dx,100
@3:
      mov bx,2
@2:
      mov cx,160
@1:
      mov al,[si]
      mov ah,al
      mov es:[di],ax     {word aligned write to display mem}
      add di,2
      add si,2
      dec cx
      jnz @1

      sub si,320
      dec bx
      jnz @2

      add si,320
      dec dx
      jnz @3
    end;
    if keypressed then ch:=readkey;
  until ch=#27;
  asm   {restore text mode}
    mov ax,03h
    int 10h
  end;
end.

      There is a million things you can do to modify that code to look better
or run faster.. Making it work in modex is one good possibility and its not
that hard.. later
