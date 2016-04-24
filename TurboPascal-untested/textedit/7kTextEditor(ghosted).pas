(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0011.PAS
  Description: 7K Text Editor (GHOSTED)
  Author: SEAN PALMER
  Date: 04-06-94  07:44
*)

{
SEAN PALMER

> Can anyone (please, it's important) , post here an example of a source
> code that will show a Text File , and let me scroll it (Up , Down ) ?
> Also I need an example of a simple editor.

Try this For an example. Turbo Pascal 6.0+ source.
Compiles to a 7K Text editor. Neat?
}

{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X+}
{$M $C00,0,0}

Program ghostEd; {Ghost Editor v0.4 (C) 1993 Sean L. Palmer}

Const
  version  = '0.4';
  maxF     = $3FFF;     {only handles small Files!}
  txtColor = $B;
  vSeg     : Word = $B800;

Var
  nLines   : Byte;
  halfPage : Byte;
  txt      : Array [0..maxF] of Char;
  crs,
  endF,
  pgBase,
  lnBase   : Integer;
  x, y     : Word;
  update   : Boolean;
  theFile  : File;
  ticks    : Word Absolute $40 : $6C;   {ticks happen 18.2 times/second}

Procedure syncTick;
Var
  i : Word;
begin
  i := ticks;
  Repeat Until i <> ticks;
end;

Function readKey : Char; Assembler;
Asm
  mov ah, $07
  int $21
end;

Function keyPressed : Boolean; Assembler;
Asm
  mov ah, $B
  int $21
  and al, $FE
end;

Procedure moveScrUp(s, d, n : Word); Assembler;
Asm
  mov  cx, n
  push ds
  mov  ax, vSeg
  mov  es, ax
  mov  ds, ax
        mov  si, s
  shl  si, 1
  mov  di, d
  shl  di, 1
  cld
  repz movsw {attr too!}
  pop  ds
 @X:
end;

Procedure moveScrDn(s, d, n : Word); Assembler;
Asm
  mov  cx, n
  push ds
  mov  ax, vSeg
  mov  es, ax
  mov  ds, ax
  mov  si, s
  add  si, cx
  shl  si, 1
  mov  di, d
  add  di, cx
  shl  di, 1
  std
  repz movsw {attr too!}
  pop  ds
 @X:
end;

Procedure moveScr(Var s; d, n : Word); Assembler;
Asm
  mov  cx, n
  jcxz @X
  push ds
  mov  ax, vSeg
  mov  es, ax
  mov  di, d
  shl  di, 1
  lds  si, s
  cld
 @L:
  movsb
  inc  di
  loop @L
  pop  ds
 @X:
end;

Procedure fillScr(d, n : Word; c : Char); Assembler;
Asm
  mov  cx, n
  jcxz @X
  mov  ax, vSeg
  mov  es, ax
  mov  di, d
  shl  di, 1
  mov  al, c
  cld
 @L:
  stosb
  inc  di
  loop @L
 @X:
end;

Procedure fillAttr(d, n : Word; c : Byte); Assembler;
Asm
  mov  cx, n
  jcxz @X
  mov  ax, vSeg
  mov  es, ax
  mov  di, d
  shl  di, 1
  mov  al, c
  cld
 @L:
  inc  di
  stosb
  loop @L
 @X:
end;

Procedure cls;
begin
  fillAttr(80, pred(nLines) * 80, txtColor);
  fillScr(80, pred(nLines) * 80, ' ');
end;

Procedure scrollUp;
begin
  moveScrUp(320, 160, pred(nLines) * 160);
  fillScr(pred(nLines) * 160, 80, ' ');
end;

Procedure scrollDn;
begin
  moveScrDn(160, 320, pred(nLines) * 320);
  fillScr(160, 80, ' ');
end;

{put cursor after preceding CR or at 0}
Function scanCrUp(i : Integer) : Integer; Assembler;
Asm
  mov   di, i
  mov   cx, di
  add   di, offset txt
  mov   ax, ds
  mov   es, ax
  std;
  mov   al, $D
  dec   di
  repnz scasb
  jnz   @S
  inc   di
 @S:
  inc   di
  sub   di, offset txt
  mov   ax, di
end;

{put cursor on next CR or endF}
Function scanCrDn(i:Integer):Integer;Assembler;Asm
  mov   di, i
  mov   cx, endF
  sub   cx, di
  inc   cx
  add   di, offset txt
  mov   ax, ds
  mov   es, ax
  cld
  mov   al, $D
  repnz scasb
  dec   di
  sub   di, offset txt
  mov   ax, di
end;

Procedure findxy;
begin
  lnBase := scanCrUp(crs);
  x      := crs - lnBase;
  y      := 1;
  pgBase := lnBase;
  While (pgBase > 0) and (y < halfPage) do
  begin
    pgBase := scanCrUp(pred(pgBase));
    inc(y);
  end;
end;

Procedure display;
Var
  i, j, k, oldY : Integer;
begin
  findXY;
  if update then
  begin
    update := False;
    j := pgBase;
    i := 1;
    While (j <= endf) and (i < pred(nLines)) do
    begin
      k := scanCrDn(j);
      moveScr(txt[j], i * 80, k - j);
      fillScr(i * 80 + k - j, 80 - k + j, ' ');
      fillAttr(i * 80, 80, txtColor);
      j := succ(k);
      inc(i);
    end;
    if i < pred(nLines) then
    begin
      fillScr(i * 80, 80 * pred(nLines - i), 'X');
      fillAttr(i * 80, 80 * pred(nLines - i), 1);
    end;
  end
  else
  begin
    i := scanCrDn(lnBase) - lnBase;
    moveScr(txt[lnBase], y * 80, i);
    fillScr(y * 80 + i, 80 - i, ' ');
  end;
end;

Procedure title;
Const
  menuStr : String = 'Ghost Editor v' + version + '-(C) Sean Palmer 1993';
begin
  fillAttr(0, 80, $70);
  fillScr(0, 80, ' ');
  MoveScr(MenuStr[1], 1, length(MenuStr));
end;

Procedure error(s : String);
begin
  fillattr(0, 80, $CE);
  fillScr(0, 80, ' ');
  moveScr(s[1], 1, length(s));
  Write(^G);
  ReadKey;
  title;
end;

Procedure tooBigErr;
begin
  error('File too big');
end;

Procedure insChar(c : Char); forward;
Procedure delChar; forward;
Procedure backChar; forward;

Procedure trimLine;
Var
  i, t, b : Integer;
begin
  i   := crs;
  b   := scanCrDn(crs);
  t   := scanCrUp(crs);
  crs := b;
  While txt[crs] = ' ' do
  begin
    delChar;
    if i > crs then
      dec(i);
    if crs > 0 then
      dec(crs);
  end;
  crs := i;
end;

Procedure checkWrap(c : Integer);
Var
  i, t, b : Integer;
begin
  b := scanCrDn(c);
  t := scanCrUp(c);
  i := b;
  if i - t >= 79 then
  begin
    i := t + 79;
    Repeat
      dec(i);
    Until (txt[i] = ' ') or (i = t);
    if i = t then
      backChar   {just disallow lines that long With no spaces}
    else
    begin
      txt[i] := ^M;  {change sp into cr, to wrap}
      update := True;
      if (b < endF) and (txt[b] = ^M) and (txt[succ(b)] <> ^M) then
      begin
        txt[b] := ' '; {change cr into sp, to append wrapped part to next
line}         checkWrap(b);  {recursively check next line since it got stuff
added}       end;
    end;
  end;
end;

Procedure changeLines;
begin
  trimLine;
  update := True;  {signal to display to redraw}
end;

Procedure insChar(c : Char);
begin
  if endf = maxF then
  begin
    tooBigErr;
    exit;
  end;
  move(txt[crs], txt[succ(crs)], endf - crs);
  txt[crs] := c;
  inc(crs);
  inc(endf);
  if c = ^M then
    changeLines;
  checkWrap(crs);
end;

Procedure delChar;
begin
  if crs = endf then
    Exit;
  if txt[crs] = ^M then
    changeLines;
  move(txt[succ(crs)], txt[crs], endf - crs);
  dec(endf);
  checkWrap(crs);
end;

Procedure addLF;
Var
  i : Integer;
begin
  For crs := endF downto 1 do
  if txt[pred(crs)] = ^M then
  begin
    insChar(^J);
    dec(crs);
  end;
end;

Procedure stripLF;
Var
  i : Integer;
begin
  For crs := endF downto 0 do
  if txt[crs] = ^J then
    delChar;
end;

Procedure WriteErr;
begin
  error('Write Error');
end;

Procedure saveFile;
begin
  addLF;
  reWrite(theFile, 1);
  if ioresult <> 0 then
    WriteErr
  else
  begin
    blockWrite(theFile, txt, endf);
    if ioresult <> 0 then
      WriteErr;
    close(theFile);
  end;
end;

Procedure newFile;
begin
  crs    := 0;
  endF   := 0;
  update := True;
end;

Procedure readErr;
begin
  error('Read Error');
end;

Procedure loadFile;
Var
  i, n : Integer;
begin
  reset(theFile, 1);
  if ioresult <> 0 then
    newFile
  else
  begin
    n := Filesize(theFile);
    if n > maxF then
    begin
      tooBigErr;
      n := maxF;
    end;
    blockread(theFile, txt, n, i);
    if i < n then
      readErr;
    close(theFile);
    crs    := 0;
    endf   := i;
    update := True;
    stripLF;
  end;
end;

Procedure signOff;
Var
  f    : File;
  i, n : Integer;
begin
  assign(f, 'signoff.txt');
  reset(f, 1);
  if ioresult <> 0 then
    error('No SIGNOFF.TXT defined')  {no macro defined}
  else
  begin
    n := Filesize(f);
    blockread(f, txt[endF], n, i);
    if i < n then
      readErr;
    close(f);
    inc(endf, i);
    update := True;
    i := crs;
    stripLF;
    crs := i; {stripLF messes With crs}
  end;
end;

Procedure goLf;
begin
  if crs > 0 then
    dec(crs);
  if txt[crs] = ^M then
    changeLines;
end;

Procedure goRt;
begin
  if txt[crs] = ^M then
    changeLines;
  if crs < endf then
    inc(crs);
end;

Procedure goCtrlLf;
Var
  c : Char;
begin
  Repeat
    goLf;
    c := txt[crs];
  Until (c <= ' ') or (crs = 0);
end;

Procedure goCtrlRt;
Var
  c : Char;
begin
  Repeat
    goRt;
    c := txt[crs];
  Until (c <= ' ') or (crs >= endF);
end;

Procedure goUp;
Var
  i : Integer;
begin
  if lnBase > 0 then
  begin
    changeLines;
    lnBase := scanCrUp(pred(lnBase));
    crs := lnBase;
    i := scanCrDn(crs) - crs;
    if i >= x then
      inc(crs, x)
    else
      inc(crs,i);
  end;
end;

Procedure goDn;
Var
  i : Integer;
begin
  changeLines;
  crs := scanCrDn(crs);
  if crs >= endF then
    Exit;
  inc(crs);
  lnBase := crs;
  i := scanCrDn(crs) - crs;
  if i >= x then
    inc(crs, x)
  else
    inc(crs, i);
end;

Procedure goPgUp;
Var
  i : Byte;
begin
  For i := halfPage downto 0 do
    goUp;
end;

Procedure goPgDn;
Var
  i : Byte;
begin
  For i := halfPage downto 0 do
    goDn;
end;

Procedure goHome;
begin
  crs := scanCrUp(crs);
end;

Procedure goend;
begin
  crs := scanCrDn(crs);
end;

Procedure backChar;
begin
  if (crs > 0) then
  begin
    goLf;
    delChar;
  end;
end;

Procedure deleteLine;
Var
  i : Integer;
begin
  i := scanCrDn(crs);
  crs := scanCrUp(crs);
  if i < endF then
  begin
    move(txt[succ(i)], txt[crs], endf - i);
    dec(endF);
  end;
  dec(endf, i - crs);
  changeLines;
end;

Procedure flipCursor;
Var
  j, k, l : Word;
begin
  j := succ((y * 80 + x) shl 1);
  l := mem[vSeg : j];   {save attr under cursor}
  mem[vSeg : j] := $7B;
  if not KeyPressed then
    syncTick;
  mem[vSeg : j] := l;
  if not KeyPressed then
    syncTick;
end;

Procedure edit;
Var
  c : Char;
begin
  Repeat
    display;
    Repeat
      flipcursor;
    Until KeyPressed;

    c := ReadKey;
    if c = #0 then
      Case ReadKey of
        #59  : signOff;
        #75  : goLf;
        #77  : goRt;
        #115 : goCtrlLf;
        #116 : goCtrlRt;
        #72  : goUp;
        #80  : goDn;
        #83  : delChar;
        #73  : goPgUp;
        #81  : goPgDn;
        #71  : goHome;
        #79  : goend;
      end
    else
      Case c of
        ^[ : saveFile;
        ^H : backChar;
        ^C : {abortFile};
        ^Y : deleteLine;
     else
       insChar(c);
     end;
  Until (c = ^[) or (c = ^C);
end;

Function getRows : Byte; Assembler;
Asm
  mov  ax, $1130
  xor  dx, dx
  int  $10
  or   dx, dx
  jnz  @S
  mov  dx, 24
 @S: {cga/mda don't have this fn}
  inc  dx
  mov  al, dl
end;

Var
  oldMode : Byte;
begin
  Asm
    mov ah, $F
    int $10
    mov oldMode, al
  end;  {save old Gr mode}

  if oldMode = 7 then
    vSeg := $B000;  {check For Mono}

  nLines := getRows;
  halfPage := pred(nLines shr 1);
  cls;
  title;

  if paramCount = 0 then
    error('Need Filename as parameter')
  else
  begin
    Asm
      mov bh, 0
      mov dl, 0
      mov dh, nLines
      mov ah, 2
      int $10
    end; {put cursor of}

    assign(theFile, paramStr(1));
    loadFile;
    edit;
  end;
end.

