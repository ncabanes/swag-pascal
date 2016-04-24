(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0040.PAS
  Description: Graphics Mouse Cursor Editor
  Author: BRUCE WINTERBON
  Date: 08-30-96  09:35
*)


{ Mouse-Cursor Editor working in VGA graphics mode.
  Written by Bruce Winterbon, 96 Aug.
  Various mouse cursors were taken from SWAG code.
  A mouse-cursor editor written by Olaf Bartelt was also taken from SWAG
     as a starting point. It was completely rewritten.
  It needs the usual EGAVGA.BGI file in the same directory, of course.}

PROGRAM Graphics_Mouse_Editor;
uses Crt,dos,graph,drivers;

function hex(v:longint;const w:integer):string;
var
  s:String;
  i:Integer;
const
  hexc:array[0..15] of char='0123456789ABCDEF';
begin
  s[0]:=Chr(w);
  for i:=w downto 1 do begin
    s[i]:=hexc[v and $F];
    v:=v shr 4
  end;
  Hex:=s;
end {Hex};

type
  MCursor=record
    masks:array[0..31] of word;
    hsx,hsy:integer;
  end;

const
  bitMask:array[0..15] of word = ($8000,$4000,$2000,$1000,$800,$400,$200,$100,
                                    $80,$40,$20,$10,$8,$4,$2,$1);
  clr:array[0..3]of integer=(14,12,2,4);
  cursNum=27;
  cursorList: array[0..cursNum] of MCursor = (
    (Masks:($7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF, {0:black arrow}
            $007F,$03FF,$03FF,$29FF,$71FF,$F0FF,$FAFF,$F8FF,
            $8000,$C000,$A000,$9000,$8800,$8400,$8200,$8100,
            $8780,$8400,$B400,$D200,$8A00,$0900,$0500,$0700);hsx:1;hsy:2),

    (masks:($9FFF,$8FFF,$87FF,$83FF,$81FF,$80FF,$807F,$803F, {1:white arrow}
            $801F,$800F,$80FF,$887F,$987F,$FC3F,$FC3F,$FE3F,
            $0000,$2000,$3000,$3800,$3C00,$3E00,$3F00,$3F80,
            $3FC0,$3E00,$3600,$2300,$0300,$0180,$0180,$0000);hsx:2;hsy:1),

    (Masks:($FBEF,$F3E7,$E3E3,$C001,$8000,$C001,$E3E3,$F3E7, {2:mcHArrow}
            $FBEF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
            $0410,$0C18,$1414,$27F2,$4001,$27F2,$1414,$0C18,
            $0410,$0000,$0000,$0000,$0000,$0000,$0000,$0000);hsx:8;hsy:4),

    (Masks:($FFFF,$FBFF,$F1FF,$E0FF,$C07F,$803F,$F1FF,$F1FF, {3:mcVArrow}
            $F1FF,$F1FF,$F1FF,$803F,$C07F,$E0FF,$F1FF,$FBFF,
            $0000,$0400,$0A00,$1100,$2080,$7BC0,$0A00,$0A00,
            $0A00,$0A00,$0A00,$7BC0,$2080,$1100,$0A00,$0400);hsx:5;hsy:8),

    (Masks:($FFFF,$81FF,$83FF,$83FF,$81FF,$80FF,$B07F,$F83F, {4:mcSlArrow}
            $FC1F,$FE0F,$FF06,$FF80,$FFC0,$FFE0,$FFE0,$FFC0,
            $0000,$7E00,$4400,$4400,$4200,$7100,$4880,$0440,
            $0220,$0110,$0089,$0047,$0021,$0011,$0011,$003F);hsx:8;hsy:8),

    (Masks:($FFFF,$81C0,$83E0,$83E0,$81C0,$8080,$B006,$F80F, {5:crossed arrows}
            $FC1F,$F80F,$B006,$8080,$81C0,$83E0,$83E0,$81C0,
            $0000,$7E3F,$4411,$4411,$4221,$7147,$4889,$0410,
            $0220,$0410,$4889,$7147,$4221,$4411,$4411,$7E3F);hsx:8;hsy:8),

    (masks:($f9ff,$f0ff,$e07f,$e07f,$c03f,$c03f,$801f,$801f, {6:up arrow}
            $000f,$000f,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,
            $0000,$0600,$0f00,$0f00,$1f80,$1f80,$3fc0,$3fc0,
            $7fe0,$0600,$0600,$0600,$0600,$0600,$0600,$0600);hsx:5;hsy:0),

    (masks:($fe1f,$f01f,$0000,$0000,$0000,$f01f,$fe1f,$ffff, {7:left arrow}
            $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
            $0,   $c0,  $7c0, $7ffe,$7c0, $c0,  $0,   $0,
            $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);hsx:1;hsy:3),

    (Masks:($FFFF,$FE3F,$FE3F,$FE3F,$FE3F,$FE3F,$FE3F,$8000,  {8:mcCrossHair}
            $8000,$8000,$FE3F,$FE3F,$FE3F,$FE3F,$FE3F,$FE3F,
            $0000,$0140,$0140,$0140,$0140,$0140,$0140,$7E3F,
            $0000,$7E3F,$0140,$0140,$0140,$0140,$0140,$0140);hsx:8;hsy:8),

    (Masks:($FFFF,$FFFF,$FFFF,$FFFF,$FE3F,$FE3F,$FE3F,$F007, {9:mcSmallCross}
            $F007,$F007,$FE3F,$FE3F,$FE3F,$FFFF,$FFFF,$FFFF,
            $0000,$0000,$0000,$0000,$01C0,$0140,$0140,$0E38,
            $0808,$0E38,$0140,$0140,$01C0,$0000,$0000,$0000);hsx:8;hsy:8),

    (Masks:($F01F,$E00F,$C007,$8003,$0441,$0C61,$0381,$0381, {10:circle,
centre cross }
            $0381,$0C61,$0441,$8003,$C007,$E00F,$F01F,$FFFF,
            $0000,$07C0,$0920,$1110,$2108,$4004,$4004,$783C,
            $4004,$4004,$2108,$1110,$0920,$07C0,$0000,$0000);hsx:7;hsy:7),

    (masks:($7e0, $180, $0,   $c003,$f00f,$c003,$0,   $180, {11:diagonal cross}
            $7e0, $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
            $0,   $700e,$1c38,$660, $3c0, $660, $1c38,$700e,
            $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);hsx:7;hsy:4),

    (masks:($fc3f,$fc3f,$fc3f,$0000,$0000,   $0,$fc3f,$fc3f, {12:rectangular
cross}
            $fc3f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
            $0,   $180, $180, $180, $7ffe,$180, $180, $180,
            $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);hsx:7;hsy:4),

    (Masks:($FFFF,$0FE1,$07C1,$0381,$8103,$C107,$E00F,$F01F, {13:X}
            $FC7F,$F01F,$E00F,$C107,$8103,$0381,$07C1,$0FE1,
            $0000,$C006,$600C,$3018,$1830,$0C60,$0440,$0280,
            $0100,$0280,$0440,$0C60,$1830,$3018,$600C,$C006);hsx:7;hsy:8),

    (Masks:($FF7F,$FC1F,$F807,$F803,$F803,$F803,$9801,$0801, {14:mcHand}
            $0001,$8001,$C001,$E003,$F007,$F80F,$FC0F,$FC0F,
            $0080,$0360,$0558,$0554,$0554,$0554,$6416,$9402,
            $8C02,$4402,$2006,$1004,$0808,$0410,$0210,$03F0);hsx:8;hsy:8),

    (Masks:($F3FF,$E1FF,$E1FF,$E1FF,$E1FF,$E049,$E000,$8000, {15:pointing
finger}
            $0000,$0000,$07FC,$07F8,$9FF9,$8FF1,$C003,$E007,
            $0C00,$1200,$1200,$1200,$1200,$13B6,$1249,$7249,
            $9249,$9001,$9001,$8001,$4002,$4002,$2004,$1FF8);hsx:4;hsy:0),

    (masks:($e1ff,$e1ff,$e1ff,$e1ff,$e1ff,$e000,$e000,$e000, {16:pointing hand}
            $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0,
            $1e00,$1200,$1200,$1200,$1200,$13ff,$1249,$1249,
            $f249,$9001,$9001,$9001,$8001,$8001,$8001,$ffff);hsx:4;hsy:0),

    (Masks:($0000,$0000,$0000,$C003,$E007,$F00F,$F81F,$FC3F, {17:HourGlassMask}
            $FC3F,$F81F,$F00F,$E007,$C003,$0000,$0000,$0000,
            $0000,$7FFE,$0000,$1FF8,$0FF0,$0000,$0000,$0000,
            $0180,$03C0,$07E0,$0E78,$1818,$0000,$7FFE,$0000);hsx:8;hsy:8),

    (masks:($0,   $0,   $0,   $0,   $8001,$c003,$e007,$f00f, {18:hourglass}
            $e007,$c003,$8001,$0,   $0,   $0,   $0,   $ffff,
            $0,   $7ffe,$6006,$300c,$1818,$c30, $660, $3c0,
            $660, $c30, $1998,$33cc,$67e6,$7ffe,$0,   $0);hsx:8;hsy:7),

    (masks:($0001,$0001,$8003,$C7C7,$E38F,$F11F,$F83F,$FC7F, {19:hourglass}
            $F83F,$F11F,$E38F,$C7C7,$8003,$0001,$0001,$0000,
            $0000,$7FFC,$2008,$1010,$0820,$0440,$0280,$0100,
            $0280,$0440,$0820,$1010,$2008,$7FFC,$0000,$0000);hsx:7;hsy:7),

    (masks:($ffff,$c003,$8001,$0000,   $0,   $0,   $0,   $0, {20:watch}
            $0000,   $0,   $0,   $0,   $0,$8001,$c003,$ffff,
            $0000,   $0,$1ff8,$2004,$4992,$4022,$4042,$518a,
            $4782,$4002,$4992,$4002,$2004,$1ff8,   $0,   $0);hsx:8;hsy:8),

    (masks:($E007,$C003,$8001,$0000,$0000,$0000,$0000,$0000, {21:watch}
            $0000,$0000,$0000,$0000,$0000,$8001,$C003,$E007,
            $0000,$1FF8,$318C,$6186,$4012,$4022,$4042,$718C,
            $718C,$4062,$4032,$4002,$6186,$318C,$1FF8,$0000);hsx:7;hsy:7),

    (Masks:($8003,$0001,$0001,$1831,$1011,$0001,$0001,$8003, {22:hammer of THOR}
            $F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,
            $0000,$3FF8,$4284,$4104,$4284,$4444,$3FF8,$0380,
            $0380,$0380,$0380,$0380,$0380,$0380,$0380,$0000);hsx:7;hsy:3),

    (Masks:($FFF0,$FFE0,$FFC0,$FF81,$FF03,$0607,$000F,$001F, {23:check-mark}
            $803F,$C07F,$E0FF,$F1FF,$FFFF,$FFFF,$FFFF,$FFFF,
            $0000,$0006,$000C,$0018,$0030,$0060,$70C0,$3980,
            $1F00,$0E00,$0400,$0000,$0000,$0000,$0000,$0000);hsx:5;hsy:10),

    (masks:($fff0,$ffe0,$ffc0,$ff81,$ff03,$607, $f,   $1f,    {24:check mark}
            $c03f,$f07f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
            $0,   $6,   $c,   $18,  $30,  $60,  $70c0,$1d80,
            $700, $0,   $0,   $0,   $0,   $0,   $0,   $0);hsx:6;hsy:8),

    (Masks:($E10F,$E00F,$F01F,$FC7F,$FC7F,$FC7F,$FC7F,$FC7F, {25:I shape}
            $FC7F,$FC7F,$FC7F,$FC7F,$F01F,$E00F,$E10F,$FFFF,
            $0000,$0C60,$0280,$0100,$0100,$0100,$0100,$0100,
            $0100,$0100,$0100,$0100,$0280,$0C60,$0000,$0000);hsx:7;hsy:7),

    (Masks:($C003,$8001,$07E0,$0000,$0000,$0000,$0000,$0000, {26:Smiley}
            $0000,$0000,$0000,$8001,$C003,$C003,$E007,$F81F,
            $0FF0,$1008,$2004,$4002,$4E72,$4A52,$4E72,$4002,
            $4992,$581A,$2424,$13C8,$1008,$0C30,$03C0,$0000);hsx:7;hsy:8),

    (Masks:($F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F, {27:sword}
            $8003,$8003,$8003,$8003,$8003,$F83F,$F01F,$F01F,
            $0100,$0380,$0380,$0380,$0380,$0380,$0380,$0380,
            $0380,$3398,$3398,$3FF8,$0380,$0380,$0380,$07C0);hsx:7;hsy:0)
);

  xb0=10;
  yb0=10;
  dxb=20;
  x0=40;
  y0=50;
  dx=10;
  dy=10;
  ddx=200;
  xs=220;
  ys=420;

var
  cn,l0,l1:integer;
  mBut,mwx,mwy:integer;
  dest : text;

procedure drawMouseCursor(const x,y,n:integer);
var
  i,j,v:integer;
  s:string[2];
begin
  with cursorList[n] do begin
    for i:=0 to 15 do for j:=0 to 15 do begin
      v:=0;
      if (masks[i] and bitmask[j])<>0 then inc(v,1);
      if (masks[i+16] and bitmask[j])<>0 then inc(v,2);
      putPixel(x+j,y+i,clr[v]);
    end;
  end;
  str(n,s);
  setColor(0);
  outTextXY(x,y+20,s);
end;

procedure drawBigCursor(const n:integer);
var
  i,j,c,x1,y1,v:integer;
begin
  hideMouse;
  with cursorList[n] do begin
    for i:=0 to 15 do for j:=0 to 15 do begin
      v:=0;
      x1:=x0+j*dx;
      y1:=y0+i*dy;
      if (masks[i] and bitmask[j])<>0 then inc(v,1);
      if (masks[i+16] and bitmask[j])<>0 then inc(v,2);
      c:=clr[v and 1];
      setFillStyle(1,c);
      bar(x1,y1,x1+dx-2,y1+dy-2);
      c:=clr[v and 2];
      setFillStyle(1,c);
      inc(x1,ddx);
      bar(x1,y1,x1+dx-2,y1+dy-2);
      c:=clr[v];
      setFillStyle(1,c);
      inc(x1,ddx);
      bar(x1,y1,x1+dx-2,y1+dy-2);
    end;
    c:=1;
    setFillStyle(1,c);
    i:=dx div 3;
    j:=dy div 3;
    x1:=x0+hsx*dx+i;
    y1:=y0+hsy*dy+j;
    bar(x1,y1,x1+i,y1+j);
    inc(x1,ddx);
    bar(x1,y1,x1+i,y1+j);
    inc(x1,ddx);
    bar(x1,y1,x1+i,y1+j);
  end;
  showMouse;
end;

function locateMouse:integer; {0:nothing; 1:top line; 2:lh box;3:rh box}
var
  xx:integer;
begin
  locateMouse:=0;
  if (mwy>=yb0) and (mwy<=yb0+15) then begin {bar}
    xx:=mwx-xb0;
    if xx<0 then exit;
    l0:=xx div dxb;
    if l0>cursNum then exit;
    if (xx mod dxb)<=15 then locateMouse:=1;
  end;
  if (mwy>=y0) and (mwy<=y0+16*dy) then begin {cursors}
    xx:=mwx-x0;
    if xx<0 then exit;
    l0:=xx div ddx;
    if l0>1 then exit;
    if (xx mod ddx)<=16*dx then locateMouse:=l0+2;
    if l0=1 then dec(xx,ddx);
    {check for hot spot here!!}
    l0:=(mwy-y0) div dy;
    l1:=xx div dx;
  end;
end;

procedure ChangeMousePointer(n:integer);
var r:registers;
begin
  hideMouse;
  with cursorList[n] do with r do begin
    ax:=9;
    bx:=hsx;
    cx:=hsy;
    es:=seg(masks);
    dx:=ofs(masks);
  end;
  intr($33,r);
  showMouse;
end; {ChangeMousePointer}

procedure checkMouse; assembler;
asm
  mov ax,3
  int $33
  mov mBut,bx
  mov mwx,cx
  mov mwy,dx
end;

procedure UpdateBigCursor(const i:integer); {i=2,lhs; i=3,rhs}
    {toggle bit, redraw appropriate parts of figures}
var
  j,c,x1,y1,v:integer;
begin
  hideMouse;
  with cursorList[cn] do begin
{  l0=i<=>y,l1=j<=>x}
    x1:=x0+l1*dx;
    y1:=y0+l0*dy;
    if i=2 then masks[l0]:=masks[l0] xor bitmask[l1]
           else masks[l0+16]:=masks[l0+16] xor bitmask[l1];
    v:=0;
    if (masks[l0] and bitmask[l1])<>0 then inc(v,1);
    if (masks[l0+16] and bitmask[l1])<>0 then inc(v,2);
    c:=clr[v and 1];
    setFillStyle(1,c);
    bar(x1,y1,x1+dx-2,y1+dy-2);
    c:=clr[v and 2];
    setFillStyle(1,c);
    inc(x1,ddx);
    bar(x1,y1,x1+dx-2,y1+dy-2);
    c:=clr[v];
    setFillStyle(1,c);
    inc(x1,ddx);
    bar(x1,y1,x1+dx-2,y1+dy-2);
    c:=1;
    setFillStyle(1,c);
    v:=dx div 3;
    j:=dy div 3;
    x1:=x0+hsx*dx+v;
    y1:=y0+hsy*dy+j;
    bar(x1,y1,x1+v,y1+j);
    inc(x1,ddx);
    bar(x1,y1,x1+v,y1+j);
    inc(x1,ddx);
    bar(x1,y1,x1+v,y1+j);
  end;
  ChangeMousePointer(cn);
  showMouse;
end;

procedure SaveWork(const cn:integer);
var
  s:string;
  i:integer;
begin
  str(cn,s);
  writeln(dest,'{case '+s+'}');
  write (dest,'    (Masks:(');
  with cursorList[cn] do begin
    for i:=0 to 31 do begin
      s:='$'+hex(masks[i],4);
      write(dest,s);
      if i<31 then begin
        write(dest,',');
        if i mod 8 = 7 then begin
          writeln(dest);
          write(dest,'            ');
        end;
      end;
    end;
    str(hsx,s);
    write(dest,');hsx:'+s);
    str(hsy,s);
    writeln(dest,';hsy:'+s+'),');
    writeln(dest);
  end;
end;

const
  fname='cursors.dat';
var
  gd,gm,x,y,n,i,j,k:integer;
  buttonDown:Boolean;
begin
  repeat
    if not keypressed then break;
    i:=ord(readKey);
  until false;
  gd:=VGA; gm := VGAHi;
  initgraph(gd,gm,'d:\turbo\tp\');  { change this as needed !! }
  setfillstyle(solidfill,white);
  bar (0,0,getMaxX,getMaxY);
  SetColor(black);
  y:=220;
  outTextxy(0,y,'          Screen mask             Cursor mask  Combination');
  y:=450;
  x:=30;
  outtextxy(x,y,'Press any non-special key to exit.');
  dec(y,12);
  outtextxy(x,y,'Press <F2> to append current cursor data to file "cursors.dat".');
  dec(y,12);
  outtextxy(x,y,'The cursor changes appearance automatically.');
  dec(y,12);
  outtextxy(x,y,'Move hot spot with arrow keys.');
  dec(y,12);
  outTextXY(x,y,'Alter screen and cursor masks by clicking.');
  dec(y,12);
  outTextxy(x,y,'Select starting cursor by clicking on top row.');
  setfillstyle(solidfill,black);
  bar(0,250,getMaxX,350);
  x:=xb0; y:=yb0;
  for n:=0 to cursNum do begin
    drawMouseCursor(x,y,n);
    inc(x,dxb);
  end;
  cn:=0;
  drawBigCursor(cn);
  ChangeMousePointer(cn);
  ShowMouse;
  buttonDown:=false;
  assign(dest,fname);
  {$I-}
  append(dest);
  if IOResult<>0 then rewrite(dest);
  {$I+}
  repeat
    checkMouse;
    if (mBut=0)=buttonDown then begin
      buttonDown:=not buttonDown;
      if not buttonDown then begin
        i:=locateMouse;
        case i of
1: begin {top line}
     cn:=l0;
     drawBigCursor(cn);
     ChangeMousePointer(l0);
   end;
2,3: UpdateBigCursor(i); {lh,rh boxes}
        end;{case}
      end;
    end;
    if keyPressed then begin
      i:=ord(readkey);
      if i<>0 then break;
      i:=ord(readkey);
      with cursorList[cn] do case i of
60: {F2}    saveWork(cn);
72: {up}    if hsy>0 then dec(hsy);
75: {left}  if hsx>0 then dec(hsx);
77: {right} if hsx<16 then inc(hsx);
80: {down}  if hsy<16 then inc(hsy);
      end;
      drawBigCursor(cn);
    end;
  until false;
  closegraph;
  close(Dest);
end.



