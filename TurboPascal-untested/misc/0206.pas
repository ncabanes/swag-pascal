(*
  This is a Nibble game example.

  I grabbed the keyboard interrupt code from GAMETHIN.PAS ( Founded in SWAG )
 by Lou DuChez, Nice work ! Thank you...

  I'm planning to make a greater game with sprites, music, and other features
 so if you have any suggestion be free to contact me.

  You can change and distribute it freely.
  If you want, Greet me..
  Any doubt, bug or suggestion
  please, E-Mail me at:

  arlindo@solar.com.br
  godzeus@brasilia.com.br

  Or write me:

  SQS 113 Bl "G" Apto 102
  Brasil - Brasília - DF
  Cep: 70.376-070

  Written By G0D ZεU$ - Rodrigo M. Silveira - Brazil -  Brasilia
  It is for Rodrigo frédéric, hi brother :) !
*)

Program Nibbles;

Uses games,crt;

Const
  MaxX      = 62; { Size of Screen - Hmmm... Better not change :) }
  MaxY      = 34;
  Nupl      : array[0..1] of string= { The Strings }
    ('One Player','Two Players');
  desc      : array[0..1] of string=
    ('Play alone - use keyboard arrows','Play with something - P1=Arrows P2="ADWS"');
  Diff      : Array[0..5] of String=
    ('Very Easy','Easy','Normal','Hard','Very Hard','VeryVery Hard!!!');
  Disc      : Array[0..5] of String=
    ('40 Blocks','80 Blocks','120 Blocks','160 Blocks','200 Blocks',
    'Many Blocks!!!');
  sc        = 'CoDeD By ZεU$/NiTRo'; { The Little Scrooler }

{----------------------------------------------------------------------------}
Type
  xy = Record
    x,y : Byte;
  end;

  Stage = Record { The Stage Record }
    StPl           : Array[1..2,1..2] of Byte;{ X,Y And of Start }
    StDirPl        : Array[1..2] of Integer; { Direction of Start }
    SMax           : Array[1..2] of Byte; { Screen Max of Stage }
    Screen         : Array[1..MaxX,1..MaxY] of Byte; { Array of the Screen }
  end;

{----------------------------------------------------------------------------}
var
  Nopl                    : Byte;
  maxnib                  : Byte;
  Nibble                  : Array[1..2,1..255] of xy;
  Direction               : array[1..2] of Integer;
  NibColor                : Array[1..2] of Byte;
  timer                   : longint absolute $40:$6C;
  Score                   : String;
  ntime,time              : integer;
  Dificult                : Byte;
  fim                     : boolean;
  Fase                    : Stage;
  point                   : xy;
  Colorbacktag,Colorutag  : Byte;
  loop                    : Byte;

{----------------------------------------------------------------------------}
PROCEDURE NWrite(Str : String; Color : Byte); Assembler;
{ Bios Write }
Asm
  les  di, Str
  mov  cl, es:[di]
  inc  di
  xor  ch, ch
  mov  bl, Color
  jcxz @ExitBW
@BoucleBW:
  mov  ah, 0eh
  mov  al, es:[di]
  int  10h
  inc  di
  loop @BoucleBW
@ExitBW:
End;
{----------------------------------------------------------------------------}
Procedure Hide;Assembler;
Asm MOV ax,$0100; MOV cx,$2607; INT $10; end; { Hide cursor }
{----------------------------------------------------------------------------}
Procedure Show;Assembler;
Asm MOV ax,$0100; MOV cx,$0506; INT $10; end; { Show cursor }
{----------------------------------------------------------------------------}
Function Light(No : Byte;local,desc: Array of String ):Byte;
var { Variables }
  b,c,i : byte;
  k : char;
  ii : Boolean;

  Procedure scr; { The little scrooler }
  begin
    textcolor(15);
    textbackground(0);
    if i = 80-length(sc) then ii := true;
    if ii Then i := i-2;
    if i = 1 then ii := false;
    gotoxy(1,1);
    while (port[$3da] and 8)<>0 do;
    while (port[$3da] and 8)=0 do;
    fillchar(MEM[$B800:0],160,0);
    gotoxy(i,1);
    write(sc);
  end;

  Procedure St(qt:byte); { Write the options with one tagged }
  begin
    for loop := 0 to no do begin
      gotoxy((80-Length(local[loop])+2) div 2,((25-no) div 2) + loop);
      textbackground(0);
      write(' '+local[loop]+' ');end;
    textbackground(ColorBacktag);
    gotoxy((80-Length(local[qt])+2) div 2,((25-no) div 2) + qt);
    write(' '+Local[qt]+' ');
    gotoxy(1,25); ClrEol;
    gotoxy((80-length(Desc[qt])) div 2,25);
    write(desc[qt]);
  end;

begin
  b := 0;
  i := 1;
  ii := false;
  textcolor(Colorutag);
  st(b);
  repeat
  repeat
    repeat
      inc(i);
      scr;
    until keypressed;
  k := upcase(readkey);
  until k in [#72,#75,#80,#77,#27,#13,'A','Z','Q'];
  c := b;
  case k of
    #72,#75,'A' : Begin if b <> 0 then dec(b) else b := no end;
    #80,#77,'Z' : Begin if b <> no then inc(b) else b := 0 end;
    #27,'Q' : b := 255;
    #13 : b := 100;
  end;
  if b = 255 Then Light := 0;
    if b = 100 Then Begin
      Light := c;
      b := 255;end;
  if b <= no Then st(b);
  until b = 255;
  fillchar(MEM[$B800:0],4000,0);
end;
{----------------------------------------------------------------------------}
Procedure Block(x,y : Word;Cor : Byte);
var a : Byte;
  Procedure Hline (x1,x2,y:word;col:byte); Assembler;
  Asm
    mov   ax,$A000
    mov   es,ax
    mov   ax,y
    mov   di,ax
    shl   ax,8
    shl   di,6
    add   di,ax
    add   di,x1
    mov   al,col
    mov   ah,al
    mov   cx,x2
    sub   cx,x1
    shr   cx,1
    jnc   @start
    stosb
  @Start :
    rep   stosw
  End;

Begin
  for a := 0 to 4 do Hline((X*5),(X*5)+5,(Y*5)+a,cor)
end;
{----------------------------------------------------------------------------}
Procedure StScreen;
var a,b : Byte;
Begin
  For a := 0 to Fase.Smax[1]+1 do Block(a,0,7);
  For a := 0 to Fase.Smax[2]+1 do Block(0,a,7);
  For a := 0 to Fase.Smax[1]+1 do Block(a,Fase.Smax[2]+1,7);
  For a := 0 to Fase.Smax[2]+1 do Block(Fase.Smax[1]+1,a,7);
  For a := 1 to Fase.Smax[2] do
    For b := 1 to Fase.Smax[1] do
      if Fase.Screen[b,a] <> 0 Then Block(b,a,7);
end;
{----------------------------------------------------------------------------}
procedure BlockNibbles;
var a,b : Byte;
Begin
  for b := 1 to nopl do begin
    if ((Nibble[b,MaxNib].x <> 0) and (Nibble[b,MaxNib].y <> 0)) Then
      Block(Nibble[b,MaxNib].x,Nibble[b,MaxNib].y,0);
    for a := 1 to MaxNib-1 do
      if ((Nibble[b,a].x <> 0) or (Nibble[b,a].y <> 0)) Then
        Block(Nibble[b,a].x,Nibble[b,a].y,NibColor[b]);
  end;
end;
{----------------------------------------------------------------------------}
Procedure InitNibbles;
var a : Byte;
Begin
  FillChar(Nibble,SizeOf(nibble),0);
  for a := 1 to NoPl do begin
    Nibble[a,1].x := Fase.StPl[a,1];
    Nibble[a,1].y := Fase.StPl[a,2];
    Direction[a] := Fase.StDirPl[a];
  end;
end;
{----------------------------------------------------------------------------}
Procedure Walk;
var a: byte;
  Procedure SubNibble(Nib:byte;nX,nY:Integer);
  var
    a,b : Byte;
  begin
      for a := MaxNib downto 2 do Nibble[nib,a] := Nibble[nib,a-1];
      Nibble[nib,1].x := Nibble[nib,2].x+nx;
      Nibble[nib,1].y := Nibble[nib,2].y+ny;
  end;

Begin
  for a := 1 to 2 do
  case direction[a] of
    1  : SubNibble(a,1,0);
    -1 : SubNibble(a,-1,0);
    2  : SubNibble(a,0,-1);
    -2 : SubNibble(a,0,1);end;
end;
{----------------------------------------------------------------------------}
Procedure Check;
var
  a,b : byte;
  Tempo : String;

  Procedure Fuck(Player:Byte);
  var stri : String;
  begin
    Gotoxy(10,10);
    str(Player,Stri);
    nWrite('Player '+Stri+' HITTED!!!',1);
    fim := true;
    repeat until Keydown[1]
  end;

Begin
  Time := (timer-Ntime);
  Str(TIME*(DIFICULT div 40),Score);
  Str(Time/18.2:8:1,Tempo);
  gotoxy(1,23);
  NWRITE('Score:                                                         ',1);
  gotoxy(8,23);
  Nwrite(Score,1);
  gotoxy(1,24);
  NWRITE('Time :                                                         ',1);
  gotoxy(8,24);
  Nwrite(Tempo+' Secs',1);
  for  b := 1 to nopl do begin
    if ((Nibble[b,1].x = 0) or (Nibble[b,1].y = 0)) then fuck(b);
    If (Nibble[b,1].x>Fase.SMax[1]) Then Fuck(b);
    If (Nibble[b,1].y>Fase.SMax[2]) Then Fuck(b);
    for a := 2 to maxnib-1 do
      If (Nibble[b,a].x = Nibble[b,1].x) Then
        if (Nibble[b,a].y = Nibble[b,1].y) Then Fuck(b);
    if Fase.Screen[Nibble[b,1].x,Nibble[b,1].y]>=2 Then Fuck(b);
  end;
  if nopl <> 1 Then begin
    for a := 1 to maxnib do
      if Nibble[1,1].x = Nibble[2,a].x Then
        if (Nibble[1,1].y = Nibble[2,a].y) Then Fuck(1);
    for a := 1 to maxnib do
      if Nibble[2,1].x = Nibble[1,a].x Then
        if (Nibble[2,1].y = Nibble[1,a].y) Then Fuck(2);
  end;
end;
{----------------------------------------------------------------------------}
Procedure SetPoint(var Pt:xy);
var a,b:byte;
Begin
  Pt.x := random(Fase.Smax[1]-1)+2; { We dont want the players to crash }
  Pt.y := random(Fase.Smax[2]-1)+2; { before he gains control!          }
  for  b := 1 to nopl do
    for a := 1 to MaxNib do
      if (Pt.x = Nibble[b,a].x) Then
        if (Pt.y = Nibble[b,a].y) Then SetPoint(pt);
  if Fase.Screen[Pt.x,Pt.y] <> 0 Then SetPoint(pt);
end;
{----------------------------------------------------------------------------}
Procedure ReadDir;
var a,b : integer;
Begin
  a := Direction[1];
  b := Direction[2];
{1}
  if WasDown[72] then Direction[1] := 2;
  if WasDown[75] then Direction[1] := -1;
  if WasDown[77] then Direction[1] := 1;
  if WasDown[80] then Direction[1] := -2;
{2}
  if Nopl = 2 then begin
    if WasDown[17] then Direction[2] := 2;
    if WasDown[30] then Direction[2] := -1;
    if WasDown[32] then Direction[2] := 1;
    if WasDown[31] then Direction[2] := -2;
  end;
  if Direction[1]*(-1) = a Then Direction[1] := a;
  if nopl = 2 then if Direction[2]*(-1) = b Then Direction[2] := b;
  ClearWasDownArray;
(* 77 = Direita
   75 = Esquerda
   72 = Cima
   80 = Baixo*)
end;
{----------------------------------------------------------------------------}
Procedure Start;
var make : Boolean;
Begin
  make := True;
  ntime := Timer;
  repeat
    Delay(100);
    ReadDir;
    Walk;
    Check;
    if not fim then BlockNibbles;
  until KeyDown[$01] or fim;
end;
{----------------------------------------------------------------------------}
Procedure InitStage{(st : Stage)};
var a : byte;
Begin
  NibColor[1] := 97;
  NibColor[2] := 31;
  Fase.StPl[1,1]  := 1;
  Fase.StPl[1,2]  := 1;
  Fase.StPl[2,1]  := 1;
  Fase.StPl[2,2]  := 2;
  Fase.StDirPl[1]  := 1;
  Fase.StDirPl[2]  := -2;
  Fase.Smax[1]   := 50;
  Fase.Smax[2]   := 30;
  fillChar(fase.Screen,Sizeof(Fase.Screen),0);
  Randomize;
  for a := 1 to Dificult do begin
    SetPoint(point);
    fase.Screen[Point.x,Point.y]:=2;
  end;
  InitNibbles;
end;
{----------------------------------------------------------------------------}
Procedure StartUp;
Begin
  Textmode(co80);
  Hide;
  FillChar(MEM[$B800:0],4000,0);
  Colorutag:=15;
  Colorbacktag:=1;
  Nopl:=light(1,Nupl,desc)+1;
  Dificult:=40*(Light(5,Diff,Disc)+1);
  MaxNib:=6;
  asm mov ax,$13;int $10;end;
  InitNewKeyInt;
  INITNEWBRKINT;
  FillChar(MEM[$A000:0],64000,0);
  InitStage;
  StScreen;
  Start;
  SETOLDKEYINT;
  SetOldBrkInt;
  asm mov ax,$03;int $10;end;
end;
{----------------------------------------------------------------------------}
Begin
  StartUp;
  TEXTMODE(co80);
  Writeln('You played for ',Time/18.2:8:1,' Secs on difficult level ',Diff[(Dificult div 40)-1]);
  WriteLn('Your Score = ',Score);
  WriteLn('Coded by G0D ZeU$ - NiTR0');
  WriteLn('This is Just a pre-alpha-beta-previous-realize, wait for official realize');
  WriteLN('Press ESC');
  Repeat Until Port[$60]=1;
end.
(* Line 400 *)