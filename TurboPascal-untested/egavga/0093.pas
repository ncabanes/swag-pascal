{
Here's some VESA routines. The drawing stuff is quite limited right now
(to pixels and horizontal lines in 256-color linear modes only) but it
detects/sets/describes most everything else. Also no save/restore video
state yet. It uses direct VESA function calls instead of interrupts, and
tries to optimize where it puts the window based on what the routines
will be used for . . .
}

{VESA1.PAS}
{by Sean Palmer}
{with help from Ferraro and Olaf Bartlett}

type
  pModeList = ^tModeList;
  tModeList = Array [0..255] of word; {list of modes terminated by -1}
                                      {VESA modes are >=100h}

  modeAttrBits = (modeAvail,
                  modeExtendInfo,
                  modeBIOSsupport,
                  modeColor,
                  modeGraphics,
                  modeBit5,
                  modeBit6,
                  modeBit7,
                  modeBit8);

  winAttrBits  = (winSupported,
                  winReadable,
                  winWriteable);

  tMemModel    = (modelText,
                  modelCGA,
                  modelHerc,
                  model4Plane,
                  modelPacked,
                  modelModeX,
                  modelRGB);


var
  VESAinfo : record
    signature : array [1..4] of char;
    version   : word;
    str       : pChar;
    caps      : longint;
    modeList  : pModeList;
    pad       : array [18..255] of byte;
  end;

  modeInfo : record
    attr           : set of modeAttrBits;
    winAAttr,
    winBAttr       : set of winAttrBits;
    winGranularity : word;  {in K}
    winSize        : word;         {in K}
    winASeg,
    winBSeg        : word; {segment to access window with}
    winFunct       : procedure;
    scanBytes      : word;       {bytes per scan line}
    extendedInfo   : record
      xRes, yRes : word;    {pixels}
      xCharSize,
      yCharSize  : byte;
      planes     : byte;
      bitsPixel  : byte;
      banks      : byte;
      memModel   : tMemModel;
      bankSize   : byte;  {in K}
    end;

    pad : array [29..255] of byte;
  end;

  xSize,
  ySize,
  xBytes     : word;
  bits       : byte;
  model      : tMemModel;
  window     : byte;
  winSeg     : word;
  granShifts : byte;
  winLo,
  winHi,
  winBytes,
  granMask   : longint;
  funct      : procedure;

  m, i : word;



function getVESAInfo : boolean; assembler;
asm
  mov ax,4F00h
  push ds
  pop es
  mov di,offset VESAinfo
  int 10h
  sub ax,004Fh  {make sure we got 004Fh back}
  cmp ax,1
  sbb al,al
  cmp word ptr es:[di],'V'or('E'shl 8)  {signature should be 'VESA'}
  jne @@ERR
  cmp word ptr es:[di+2],'S'or('A'shl 8)
  je @@X
 @@ERR:
  mov al,0
 @@X:
end;


function getModeInfo(mode:word):boolean;assembler;asm
 mov ax,4F01h
 mov cx,mode
 push ds
 pop es
 mov di,offset modeInfo
 int 10h
 sub ax,004Fh   {make sure it's 004Fh}
 cmp ax,1
 sbb al,al
 end;


{if the VESA driver supports info on the regular VGA modes, add them to list}
procedure includeStandardVGAModes;var p:^word;begin
 p:=pointer(VESAInfo.modeList);
 while p^<>$FFFF do inc(p);
 if getModeInfo($10) then begin p^:=$10; inc(p);end;
 if getModeInfo($12) then begin p^:=$12; inc(p);end;
 if getModeInfo($13) then begin p^:=$13; inc(p);end;
 p^:=$FFFF;
 end;


function setMode(mode:word):boolean;var i:word;begin
 if getModeInfo(mode) then begin
  with modeInfo do begin
   if winSupported in winAAttr then begin window:=0; winSeg:=winASeg;end
   else if winSupported in winBAttr then begin window:=1; winSeg:=winBSeg;end
   else exit;  {you call this a VESA mode?}
   with extendedInfo do begin
    xSize:=xRes; ySize:=yRes; xBytes:=scanBytes; bits:=bitsPixel;
    model:=memModel;
    end;
   winBytes:=longint(winSize)*1024;  {wraps to 0 if 64k}
   winLo:=0; winHi:=winBytes;
   i:=winGranularity;
   granShifts:=10; {for 1K}
   while not odd(i) do begin
    i:=i shr 1;
    inc(granShifts);
    end;
   if i<>1 then begin setMode:=false;exit;end;  {granularity not power of 2}
   granMask:=(longint(1)shl granShifts)-1;
   funct:=winFunct;
   end;
  asm
   mov ax,4F02h
   mov bx,mode
   int 10h
   sub ax,004Fh
   cmp ax,1
   sbb al,al
   mov @RESULT,al
   end;
  end;
 end;

function getMode:word;assembler;asm  {return -1 if error}
 mov ax,4F03h
 int 10h
 cmp ax,004Fh
 je @@OK
 mov ax,-1
 jmp @@X
@@OK: mov ax,bx
@@X:
 end;


procedure plot(x, y : word; c : byte);
var
  bank : word;
  offs : longint;
begin
  offs := longint(y) * xBytes + x;
  if (offs < winLo) or (offs >= winHi) then
  begin
    winLo := (offs - (winBytes shr 1)) and not granMask;
    winHi := winLo + winBytes;
    bank  := winLo shr granShifts;
    asm
      mov bl, window
      mov dx, bank
      call [funct]
    end;
  end;
  mem[winSeg : word(offs) - word(winLo)] := c;
end;

procedure hLin(x,x2,y:word;c:byte);
var bank,w:word; offs:longint;
begin
  w:=x2-x;
  offs:=longint(y)*xBytes+x;
  if (offs<winLo)or(offs+w>=winHi) then begin
   winLo:=offs and not granMask;
   winHi:=winLo+winBytes;
   bank:=winLo shr granShifts;
   asm
    mov bl,window
    mov dx,bank
    call [funct]
    end;
   end;
  fillChar(mem[winSeg:word(offs)-word(winLo)],w,c);
  end;

function scrn(x,y:word):byte;
var bank:word; offs:longint;
begin
  offs:=longint(y)*xBytes+x;
  if (offs<winLo)or(offs>=winHi) then begin
   winLo:=(offs-(winBytes shr 1))and not granMask;
   winHi:=winLo+winBytes;
bank:=winLo shr granShifts;
   asm
    mov bl,window
    mov dx,bank
    call [funct]
    end;
   end;
  scrn:=mem[winSeg:word(offs)-word(winLo)];
  end;

{will find a color graphics mode that matches parms}
{if parm is 0, finds best mode for that parm}
function findMode(x,y:word;model:tMemModel;nBits,nPlanes,nBanks:byte):word;
var p:^word; m:word; gx,gy,gb,lp,lb:word;
begin
 gx:=0;gy:=0;gb:=0;lp:=255;lb:=255;
 p:=pointer(VESAInfo.modeList);
 m:=$FFFF;
 while p^<>$FFFF do begin
  if getModeInfo(p^) then
   with modeInfo do
    if attr+[modeAvail,modeExtendInfo,modeColor,modeGraphics]=attr then
     with extendedInfo do
if ((xRes=x)or((x=0)and(gx<=xRes)))
      and((yRes=y)or((y=0)and(gy<=yRes)))
      and(memModel=model)
      and((bitsPixel=nBits)or((nBits=0)and(gb<=bitsPixel)))
      and((planes=nPlanes)or((nPlanes=0)and(lp>=planes)))
      and((banks=nBanks)or((nBanks=0)and(lb>=banks)))
      then begin
       gx:=xRes;gy:=yRes;gb:=bitsPixel;lp:=planes;lb:=banks;
       m:=p^;
       end;
  inc(p);
  end;
 if m<>$FFFF then getModeInfo(m);
 findMode:=m;  {0FFFFh if not found. Try a standard mode number then.}
 end;


procedure displayVESAInfo;

type
  string2=string[2];
  string4=string[4];
  string8=string[8];
const
  modelStr : array[tMemModel]of pChar=
    ('Text','CGA','Hercules','EGA','Linear','mode X','RGB');
var
  p:^word;

  function hexB(n:byte):string2; assembler;asm
   les di,@RESULT;                    {adr of function result}
  cld; mov al,2; stosb;              {set len}
   mov al,n; mov ah,al;               {save it}
   shr al,1; shr al,1; shr al,1; shr al,1; {high nibble}
   add al,$90; daa; adc al,$40; daa;  {convert hex nibble to ASCII}
   stosb;
   mov al,ah; and al,$F;              {low nibble}
   add al,$90; daa; adc al,$40; daa;
   stosb;
   end;

  function hexW(n:word):string4;
  begin
    hexW:=hexB(hi(n))+hexB(lo(n));
  end;

  function hexL(n:longint):string8;
  begin
    hexL:=hexW(n shr 16)+hexW(n);
  end;

begin
 if getVESAInfo then
  with VESAinfo do begin
   includeStandardVGAModes;
   writeln(signature,' Version ',hexB(hi(version)),'.',hexB(version));
   writeln(str);
   writeln('Capabilities: $',hexL(caps));
   p:=pointer(modeList);
while p^<>$FFFF do begin
    write('Mode $',hexW(p^),' = ');
    if getModeInfo(p^) then
     with modeInfo do begin
      if not(modeAvail in attr) then write('Unavailable-');
      if modeColor in attr then write('Color ') else write('Mono ');
      if modeGraphics in attr then write('Graphics') else write('Text');
      if modeBIOSSupport in attr then write('-BIOSsupport');
      writeln;
      if modeExtendInfo in attr then
       with extendedInfo do begin
        write('  ',xRes,'x',yRes,', ',bitsPixel,' bits, ',modelStr[memModel],
                ', ',scanBytes,' bytes per row');
        if not (modeGraphics in attr) then
         write(^M^J'  Character size ',xCharSize,'x',yCharSize);
        if planes>1 then write(', ',planes,' planes');
        if banks>1 then write(', ',banks,' banks of ',bankSize,'K');
        writeln;
        end
      else write('  No extended info available');
      if winSupported in winAAttr then begin
       write('  Window A: ');
       if winReadable in winAAttr then write('R');
if winWriteable in winAAttr then write('W');
       writeln(' at segment $',hexW(winASeg),', ',winSize,'K, granular by '
               ,winGranularity,'K, function at $',hexL(longint(@winFunct)));
       end;
      if winSupported in winBAttr then begin
       write('  Window B: ');
       if winReadable in winBAttr then write('R');
       if winWriteable in winBAttr then write('W');
       writeln(' at segment $',hexW(winBSeg),', ',winSize,'K, granular by '
               ,winGranularity,'K, function at $',hexL(longint(@winFunct)));
       end;
      end
    else writeln('ERROR');
    inc(p);
    end;
   end
 else writeln('No VESA driver found');
 end;

begin
  writeln;
  displayVESAInfo;
  readln;
  m := findMode(0, 0, modelPacked, 8, 1, 1);
  getModeInfo(m);
  if m <> $FFFF then
  with modeInfo.extendedInfo do
    writeln('Found ', xRes, 'x', yRes, 'x',
            longint(1) shl bitsPixel, ' mode ', m)
  else
    exit;

  setMode(m);
  for i := 1 to 10000 do
    plot(random(xSize), random(ySize), random(256));

  readln;

  for i := 1 to 200 do
    hlin(random(xSize shr 1), random(xSize shr 1) + xSize shr 1,
                random(ySize), random(256));
  readln;

  asm
    mov ax, 3h
    int 10h
  end;
end.
