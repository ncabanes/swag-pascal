{
  Mini FM Organ Using Yamaha OPL-3 Chip
  Autodetect Sound Blaster using BLASTER Environment variable
  By : Roby Johanes
  http://www.geocities.com/SiliconValley/Park/3230
  Finished in 1996

  Latest update: December 1997 for submission to SWAG
}
Program Sound_Blaster_Mini_FM_Organ;
uses crt,dos;
type
  CardType = (SB_1, SB_2, SBPro, SB_16, SBAWE32);
  Str4     = string[4];
  TSBdata  = record
               Portno : word;
               ctype  : CardType;
               irq    : byte;
               dma    : byte;
             end;
  TFMInst  = record
               modchr, carchr, modlev, carlev,
               modatk, caratk, modsus, carsus,
               modwav, carwav, feedback : byte;
               reserved : array[1..5] of byte;
             end;
const
  CardName : array [1..5] of string[8] = (
             'SB v1.0', 'SB v2.0', 'SB Pro', 'SB 16', 'SB AWE32');
  Notefreq : array[1..12] of word = ($16B,$181,$198,$1B0,$1CA,$1E5,
                                     $202,$220,$241,$263,$287,$2AE);
const
  waitctr   = $400;
  FMaddr    = $388;
  EOI       = $20;
  PIC       = $20;
  PICStatus = $21;
  Modofs    : array[1..9] of byte = (0,1,2,8,9,10,16,17,18);
  Carofs    : array[1..9] of byte = (3,4,5,11,12,13,19,20,21);
var
  SBdata : TSBdata;
  c      : TSBData;
  v      : word;
  f      : tfminst;
  s      : string;
  t      : string[3];

Function  WordToHex(no : word): Str4;
const
  h : array [0..15] of char = '0123456789ABCDEF';
begin
  WordToHex:=h[hi(no) shr 4]+h[hi(no) and 15]+h[lo(no) shr 4]+
             h[lo(no) and 15];
end;

Function ResetChip(Portno : Word) : Boolean; Assembler;
asm
  mov    bx,-1
  mov    dx,[Portno]
  add    dl,6
  mov    al,1
  out    dx,al
  mov    cx,waitctr

@@1:
  loop   @@1
  dec    al
  out    dx,al
  mov    cx,waitctr

@@2:
  loop   @@2
  add    dl,8
  mov    cx,waitctr

@@testreadybit:
  in     al,dx
  test   al,80h
  loopz  @@testreadybit
  jz     @@SBnotpresent
  sub    dl,4
  mov    cx,waitctr

@@pollfor0AAh:
  in     al,dx
  cmp    al,0AAh
  je     @@done
  loop   @@pollfor0AAh

@@SBnotpresent:
  xor    bx,bx

@@done:
  mov    ax,bx
end;

Function  SBRead: byte; assembler;
asm
  mov     dx,[SBData.Portno]
  add     dl,0eH
  mov     cx,waitctr
@@loopit:
  in      al,dx
  test    al,80H
  loopz   @@loopit
  sub     dx,4
  in      al,dx
end;

Procedure SBWrite(Data : byte); assembler;
asm
  mov    dx,[SBData.Portno]
  add    dl,0cH
  mov    cx,waitctr
@@loopit:
  in     al,dx
  test   al,80H
  loopnz @@loopit
  mov    al,[Data]
  out    dx,al
end;

Function  GetDSPVersion : Word; assembler;
asm
  push   00e1H
  call   SBwrite
  call   SBread
  mov    ah,al
  call   SBread
end;

Procedure FMwrite(reg, data : byte); assembler;
asm
  mov    dx,FMaddr
  mov    al,[reg]
  out    dx,al
  mov    cx,6
@@1:
  in     al,dx
  loop   @@1
  inc    dl
  mov    al,[data]
  out    dx,al
  dec    dl
  mov    cx,35
@@2:
  in     al,dx
  loop   @@2
end;

Procedure FMreset;
begin
  FMwrite(1,0);
end;

Procedure FMKeyon(channel: byte; freq: word; octave: byte);
begin
  FMWrite($A0+channel-1,freq and $FF);
  FMWrite($B0+channel-1,(freq shr 8) or (octave shl 2) or $20);
end;

Procedure FMKeyoff(channel: byte);
begin
  FMWrite($B0+channel-1,0);
end;

Procedure FMSetVolume(channel, vol: byte);
begin
  FMWrite($40+Modofs[channel],vol and $3F);
  FMWrite($40+Carofs[channel],vol and $3F);
end;

Procedure FMSetup(channel: byte; FMInst : TFMInst);
var
  i, j : byte;
begin
  i:=modofs[channel]; j:=carofs[channel];
  FMWrite($20+i,FMInst.modchr); FMWrite($20+j,FMInst.carchr);
  FMWrite($40+i,FMInst.modlev); FMWrite($40+j,FMInst.carlev);
  FMWrite($60+i,FMInst.modatk); FMWrite($60+j,FMInst.caratk);
  FMWrite($80+i,FMInst.modsus); FMWrite($80+j,FMInst.carsus);
  FMWrite($E0+i,FMInst.modwav); FMWrite($E0+j,FMInst.carwav);
  FMWrite($C0+channel-1,FMInst.feedback);
end;

Procedure SBSetcard(CardData : TSBdata);
begin
  with SBData do
  begin
    portno:=CardData.portno;
    ctype :=CardData.ctype;
    irq   :=CardData.irq;
    dma   :=CardData.dma;
  end;
end;

Function AutoDetectIRQ : Byte;
var
  i       : Integer;
  s       : string;
  j       : byte;
begin
  for I:=1 to EnvCount do
  begin
    s:=EnvStr(i);
    if copy(s,1,7)='BLASTER' then break;
  end;
  if copy(s,1,7)<>'BLASTER' then
  begin
    AutoDetectIRQ:=0;
    exit;
  end;
  j:=pos('I',s);
  if j=0 then
  begin
    j:=pos('i',s);
    if j=0 then
    begin
      AutoDetectIRQ:=0;
      exit;
    end;
  end;
  s:=copy(s,j+1,1);
  j:=ord(s[1])-48;
  AutoDetectIRQ:=j;
end;

Function AutoDetectDMA : Byte;
var
  i       : Integer;
  s       : string;
  j       : byte;
begin
  for I:=1 to EnvCount do
  begin
    s:=EnvStr(i);
    if copy(s,1,7)='BLASTER' then break;
  end;
  if copy(s,1,7)<>'BLASTER' then
  begin
    AutoDetectDMA:=0;
    exit;
  end;
  j:=pos('D',s);
  if j=0 then
  begin
    j:=pos('d',s);
    if j=0 then
    begin
      AutoDetectDMA:=0;
      exit;
    end;
  end;
  s:=copy(s,j+1,1);
  j:=ord(s[1])-48;
  AutoDetectDMA:=j;
end;

Procedure DetectSB (var CardData : TSBdata); assembler;
asm
  { Port AutoDetect }
  mov    ax,ds
  mov    es,ax
  mov    di,[offset SBData]
  mov    si,di
  mov    ax,220h
@@detectionloop:
  mov    bx,ax
  push   bx
  push   ax
  call   ResetChip
  pop    bx
  cmp    ax,-1
  je     @@success
  mov    ax,bx
  add    ax,20h
  cmp    ax,300h
  jb     @@detectionloop
  xor    bx,bx
@@success:
  mov    ax,bx
  cld
  stosw

  { Card Type AutoDetect }
  call   GetDSPVersion
  cmp    ah,4
  jne    @@nexts
  cmp    al,10
  jl     @@nexts
  inc    ah
@@nexts:
  mov    al,ah
  cld
  stosb

  { IRQ autodetect }
  push   es
  push   di
  push   si
  call   AutoDetectIRQ
  pop    si
  pop    di
  pop    es
  cld
  stosb

  { DMA autodetect }
  push   es
  push   di
  push   si
  call   AutoDetectDMA
  pop    si
  pop    di
  pop    es
  cld
  stosb
  les    di,[CardData]
  mov    cx,5
  cld
  rep    movsb
end;

procedure createbkgr; assembler;
asm
  mov  ax,0b800h
  mov  es,ax
  xor  di,di
  mov  cx,2000
  mov  ax,39b1h
  cld
  rep  stosw
  mov  ah,2
  xor  bh,bh
  xor  dx,dx
  int  10h
  mov  ah,1
  mov  cx,-1
  int  10h
end;

procedure writexy(x,y,c : byte; s : string); assembler;
asm
  mov  ax,0b800h
  mov  es,ax
  mov  al,[y]
  dec  al
  xor  ah,ah
  shl  ax,5
  mov  di,ax
  shl  ax,1
  shl  ax,1
  add  di,ax
  mov  al,[x]
  dec  al
  xor  ah,ah
  shl  ax,1
  add  di,ax
  xor  ch,ch
  push ds
  lds  si,[s]
  mov  cl,[si]
  jcxz @@done
  mov  ah,[c]
  inc  si
  cld
@@loops:
  lodsb
  stosw
  loop @@loops
@@done:
  pop  ds
end;

procedure organ;
var
  ch  : char;
  n,o : byte;
begin
  repeat
    n:=0;
    ch:=Upcase(readkey);
    FMKeyoff(2);
    case ch of
  ',','A': begin n:=1; o:=2; end;
      'W': begin n:=2; o:=2; end;
  '.','S': begin n:=3; o:=2; end;
      'E': begin n:=4; o:=2; end;
  '/','D': begin n:=5; o:=2; end;
      'F': begin n:=6; o:=2; end;
      'T': begin n:=7; o:=2; end;
      'G': begin n:=8; o:=2; end;
      'Y': begin n:=9; o:=2; end;
      'H': begin n:=10;o:=2; end;
      'U': begin n:=11;o:=2; end;
      'J': begin n:=12;o:=2; end;
      'K': begin n:=1; o:=3; end;
      'O': begin n:=2; o:=3; end;
      'L': begin n:=3; o:=3; end;
      'P': begin n:=4; o:=3; end;
      ';': begin n:=5; o:=3; end;
      #39: begin n:=6; o:=3; end;
      #13: begin n:=8; o:=3; end;
      'M': begin n:=12;o:=1; end;
      'N': begin n:=10;o:=1; end;
      'B': begin n:=8; o:=1; end;
      'V': begin n:=6; o:=1; end;
      'C': begin n:=5; o:=1; end;
      'X': begin n:=3; o:=1; end;
      'Z': begin n:=1; o:=1; end;
    end;
    if n>0 then FMKeyon(2,NoteFreq[n],o);
  until ch=#27;
end;

procedure DrawOrgan;
begin
  textattr:=$0F;
  gotoxy(21, 9); write('╔═════════════════════════════════════════╗');
  gotoxy(21,10); write('║▐█▌  ▐▌  ▐██▐█▌  ▐▌  ▐▌  ▐██▐█▌  ▐▌  ▐██ ║');
  gotoxy(21,11); write('║▐█▌  ▐▌  ▐██▐█▌  ▐▌  ▐▌  ▐██▐█▌  ▐▌  ▐██ ║');
  gotoxy(21,12); write('║▐█▌  ▐▌  ▐██▐█▌  ▐▌  ▐▌  ▐██▐█▌  ▐▌  ▐██ ║');
  gotoxy(21,13); write('║▐███▐███▐███▐███▐███▐███▐███▐███▐███▐███ ║');
  gotoxy(21,14); write('║▐███▐███▐███▐███▐███▐███▐███▐███▐███▐███ ║');
  gotoxy(21,15); write('║▐███▐███▐███▐███▐███▐███▐███▐███▐███▐███ ║');
  gotoxy(21,16); write('╚═════════════════════════════════════════╝');
end;

procedure ShowCursor; assembler;
asm
  mov  ah,1
  mov  cx,0708h
  int  10h
end;

begin
  with SBdata do
  begin
    portno:=$220;
    ctype :=sb_16;
    irq   :=7;
    dma   :=1;
  end;
  DetectSB(c);
  If c.portno=0 then
  begin
    writeln('Sound Blaster not present !',#10,#13); halt;
  end;
  createbkgr;
  textattr:=$1E;
  fillchar(s,81,' '); s[0]:=#80;
  writexy(1,1,$1E,s);
  writeln('Sound Blaster present in '+WordToHex(c.portno)+'h'+
  ' of type '+cardname[ord(c.ctype)]+' with IRQ ',c.irq,' and DMA ',c.dma);
  v:=GetDSPversion; textattr:=$1F;
  s:=s+t; writexy(1,25, $1E,s);
  fillchar(s,81,' '); s[0]:=#80;
  str(v shr 8,t);
  s:='DSP version '+t+'.';
  str(v and $FF,t); s:=s+t;
  writexy(1,25, $1E,s);
  writexy(64,25,$1E,'By : Roby Johanes');
  gotoxy(36,7); writeln('FM Mini Organ'); textattr:=$4E;
  gotoxy(36,8); writeln('version 0.007'); textattr:=$2F;
  gotoxy(19,17); writeln('Press a key to produce a sound, or Esc to quit');
  with f do
  begin
    modchr:=$41; carchr:=$41; modlev:=$8a; carlev:=$40;
    modatk:=$F1; caratk:=$F1; modsus:=$31; carsus:=$33;
    modwav:=0;   carwav:=0;   feedback:=6;
  end;
  DrawOrgan; FMReset;
  FMSetup(2,f); organ;
  FMKeyoff(2); FMReset;
  textattr:=7; clrscr; ShowCursor;
end.
