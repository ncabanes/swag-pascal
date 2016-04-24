(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0027.PAS
  Description: Text Scroller
  Author: RODRIGO MOREIRA SILVEIRA
  Date: 08-30-96  09:35
*)


Program txtscrooler;

uses crt,Dos;

Const
  vidseg : Word = $B800;
  ismono : Boolean = False;
  txt = 'ZεU$';
  tx = 'WaS HeRe!';
  t = 'Up ''n'' Down';

Type
  Windowrec = Array [0..4003] of Byte;

Var
  coded : string;
  Y, J: integer;
  CBuf: array [0..8191] of byte;
  NewWindow : Windowrec;
  kk,oo,ii : Boolean;
  c : Char;
  i,o,k : Byte;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

procedure CharGenModeOn;assembler;
asm
  cli
  mov       dx,03C4h
  mov       ax,0100h
  out       dx,ax
  mov       ax,0402h
  out       dx,ax
  mov       ax,0704h
  out       dx,ax
  mov       ax,0300h
  out       dx,ax
  sti
  mov       dl,0CEh
  mov       ax,0204h
  out       dx,ax
  mov       ax,0005h
  out       dx,ax
  mov       ax,0006h
  out       dx,ax
end;

procedure CharGenModeOff;assembler;
asm
  cli
  mov       dx,03C4h
  mov       ax,0100h
  out       dx,ax
  mov       ax,0302h
  out       dx,ax
  mov       ax,0304h
  out       dx,ax
  mov       ax,0300h
  out       dx,ax
  sti
  mov       dl,0CEh
  mov       ax,0004h
  out       dx,ax
  mov       ax,1005h
  out       dx,ax
  mov       ax,0E06h
  out       dx,ax
  mov       ah,0Fh
  int       10h
  cmp       al,7
  jne       @skip
  mov       ax,0806h
  out       dx,ax
@skip:
end;

Procedure checkvidseg;
begin
  if (mem [$0000 : $0449] = 7) then vidseg := $B000
  else vidseg := $B800;
  ismono := (vidseg = $B000);
end;

Procedure savescreen (Var wind : Windowrec;
 TLX, TLY, BRX, BRY : Integer);
Var x, y, i : Integer;
begin
  checkvidseg;
  wind [4000] := TLX;
  wind [4001] := TLY;
  wind [4002] := BRX;
  wind [4003] := BRY;
  i := 0;
  For y := TLY to BRY Do
    For x := TLX to BRX Do
    begin
      InLine ($FA);
      wind [i] := mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) ];
      wind [i + 1] := mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) + 1];
      InLine ($FB);
      Inc (i, 2);
    end;
end;

Procedure setWindow (Var wind : Windowrec; TLX, TLY, BRX, BRY : Integer);
Var
  i : Integer;
begin
  savescreen (wind, TLX, TLY, BRX, BRY);
  Window (TLX, TLY, BRX, BRY);
  ClrScr;
end;

Procedure removeWindow (wind : Windowrec);
Var TLX, TLY, BRX, BRY, x, y, i : Integer;
begin
  checkvidseg;
  Window (1, 1, 80, 25);
  TLX := wind [4000];
  TLY := wind [4001];
  BRX := wind [4002];
  BRY := wind [4003];
  i := 0;
  For y := TLY to BRY Do
    For x := TLX to BRX Do
    begin
      InLine ($FA);
      mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) ] := wind [i];
      mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) + 1] := wind [i + 1];
      InLine ($FB);
      Inc (i, 2);
    end;
end;

begin
  setWindow (NewWindow, 1, 1, 80, 25);
  Coded := 'CoDeD By ZεU$';
  while pos('ZεU$',coded) = 0 Do
  HideCursor;
  textbackground(0);
  textColor(7);
  i := 1;
  o := 70;
  k := 1;
  repeat
      gotoxy(i,10);
      inc (i);
      if i = 76 then ii := true;
      if ii Then i := i-2;
      if i = 1 then ii := false;
      write(txt);
      gotoxy(o,15);
      dec(o);
      if o = 1 then oo := true;
      if oo Then o := o+2;
      if o = 72 then oo := false;
      write(tx);
      gotoxy((80-length(t)) div 2,k);
      inc(k);
      if k = 25 then kk := true;
      if kk Then k := k-2;
      if k = 1 then kk := false;
      write(t);
      delay(22);
      clrscr;
  until keypressed;
  removeWindow (NewWindow);
  gotoxy(1,25);
  writeln('C:\I\SAW\3\SCROOLERS\>FORMAT C: /Q >NOW!');
  write(CoDeD);
  CharGenModeOn;
  move( mem[$A000: 0], CBuf, 8192 );
  for I := 0 to 255 do
    for J := 0 to 15 do
      mem[$a000:((I*32) + J)] := CBuf[(I*32) + (15 - J)];
   CharGenModeOff;
  ShowCursor;
end.

