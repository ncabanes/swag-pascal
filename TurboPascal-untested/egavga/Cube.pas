(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0113.PAS
  Description: Cube
  Author: YVES HETZER
  Date: 08-24-94  13:29
*)

program cube;      { Author: Yves Hetzer   2:248/1003.8  }
uses crt;                   {     Erfurt, Germany }

const gCrtc          = $3d4; gScreensize    = 400*80;
      gscreenPage0   = $0000; gScreenpage1   = gscreensize;
      gscreensegment = $0a000; gscrwidth = 80; scal= 20;
      sintab : array[0..90] of byte = (0,4,9,13,18,22,27,31,36,40,44,49,53,58,62,66,71,75,79,83,88,
                                       92,96,100,104,108,112,116,120,124,128,132,136,139,143,147,150,154,158,161,165,
                                       168,171,175,178,181,184,187,190,193,196,199,202,204,207,210,212,215,217,219,222,
                                       224,226,228,230,232,234,236,237,239,241,242,243,245,246,247,248,249,250,251,252,
                                       253,254,254,254,255,255,255,255,255,255);

type tupel = record
             x,y,z : integer;
             end;
     rtupel = record
              x,y,z : real;
              end;
     PointType = record
              X, Y : integer;
              end;
     bild_point = array[1..12] of rtupel;
     kehrtab = array [1..10000] of real;

const pk : bild_point =((x:0;y:6;z:0),(x:2;y:2;z:2),(x:-2;y:2;z:2),
           (x:2;y:2;z:-2),(x:-2;y:2;z:-2),(x:2;y:-2;z:2),(x:-2;y:-2;z:2),
           (x:2;y:-2;z:-2),(x:-2;y:-2;z:-2),(x:0;y:-6;z:0),(x:6;y:0;z:0),
           (x:-6;y:0;z:0));

var scrofs, hlength, scrmemoff,offs,gscreen : word;
    bit_maske :byte;
    rp   : array[1..3,1..3] of real;
    pd  : bild_point;
    u,v:   array[1..12] of integer;
    lauf,al,ga,f,leftb,rightb,upb,downb,help : integer;
    eck : array [0..4] of pointtype;
    kehrt:^kehrtab;
    rmask,lmask:array [0..639] of byte;

procedure waitblank;
assembler;
asm;
mov dx,gCRTC+6;@g_r: in al,dx;test al,8;jz @g_r;@g_d: in al,dx;
test al,8;jnz @g_d
end;

procedure calcxy;
assembler;
asm;
 mov cx,ax;mov ax,80;mul bx;mov dx,0a000h;push dx;mov dx,ax;
 mov ax,cx;shr ax,1;shr ax,1;shr ax,1;add dx,ax;mov di,dx;
 and cl,7;mov dl,80h;shr dl,cl;pop es;mov ax,gscreen;add di,ax;
 mov ds:[offs], di;mov ds:[bit_maske],dl
end;

procedure set_dot(x,y,farbe : word);
assembler;
asm;
 mov ax,x;mov bx,y;mov cx,farbe;call calcxy;mov ah,bit_maske;
 mov dx,3ceh;mov al,08h;out dx,ax;mov ax,0a000h;mov es,ax;
 mov di,offs;mov cx,farbe;mov ch,[es:di];mov [es:di], cl;
end;

procedure graph_init;
assembler;
asm;
 mov ax,0012h;int 10h;mov dx,3ceh;mov ax,0205h;out dx,ax;mov ax,1003h;
 out dx,ax;   end;

PROCEDURE Draw(xA,yA,xB,yB,col:Integer);     { DRAWALL.INC }
VAR
  x,y,kriterium,dX,dY,stepX,stepY:Integer;
BEGIN
  dX:=Abs(xB-xA);
  dY:=Abs(yB-yA);
  IF dX=0 THEN kriterium:=0 ELSE  kriterium:=Round(-dX/2);
  IF xB>xA THEN stepX:=1 ELSE stepX:=-1;
  IF yB>yA THEN stepY:=1 ELSE stepY:=-1;
  x:=xA;y:=yA;
  set_dot(x,y,col);
  WHILE Not ((x=xB) And (y=yB)) DO
  BEGIN
    IF kriterium <0 THEN
    BEGIN
      x:=x+stepX; kriterium:=kriterium+dY;
    END;
    IF (kriterium>=0) And ( y<>yB) THEN
    BEGIN
      y:=y+stepY; kriterium:=kriterium-dX;
    END;
    set_dot(x,y,col);
  END;
END;

procedure hline(x1,x2:integer);
var y : word;
Begin
 if x1>x2 then Begin help := x2;x2:=x1;x1:=help;end;
 help := x1 shr 3;
 scrofs := help + scrmemoff;
 hlength := x2 shr 3 - help;
 if hlength = 0 then
 Begin
  port[$3cf] := lmask[x1] and rmask[x2];
  inc (mem[$a000:scrofs]);
 end else
 if hlength > 1 then
 Begin
  port[$3cf] := lmask[x1];
  inc (mem[$a000:scrofs]);
  port [$3cf] := $ff;
  for lauf := 1 to hlength-1 do inc(mem[$a000:scrofs+lauf]);
  port [$3cf] := rmask[x2];
  inc (mem[$a000:scrofs+hlength]);
 end else
 Begin
  port [$3cf] := lmask [x1];
  inc (mem[$a000:scrofs]);
  port [$3cf] := rmask [x2];
  inc (mem[$a000:scrofs+1]);
 end;
end;

procedure fillfourangle(var x1,y1,x2,y2,x3,y3,x4,y4,ficol:integer);
var ho1,ho2,ho3,ho4,ypos,start,ende,diff,counter1,counter2,polyho,
    ya,ye,yr,yl,dy : integer;
    stepx1,stepx2,stepx3,stepx4,links,rechts,xa,xe,xr,xl : longint;
    sre,ore,sl,ol : word;
    trapez,clip : boolean;
    stepx : real;
procedure height (var h : integer);
Begin
 if h = 0 then h := 1 else if h > 5000 then h := 5000;
end;
Begin
asm;mov dx,3ceh;mov ax,0005h;out dx,ax;mov ax,1003h;out dx,ax;end;
 if ((x1<leftb) and (x2<leftb) and (x3<leftb) and (x4<leftb)) or
 ((x1>rightb) and (x2>rightb) and (x3>rightb) and (x4> rightb)) then exit;
 clip := false;
 if (x1<=leftb) or (x2<=leftb) or (x3<=leftb) or (x4<=leftb) or
 (x1>=rightb) or (x2 >= rightb) or (x3 >= rightb) or (x4>=rightb) then clip :=
true;
 eck[1].x := x1;eck[2].x := x2;eck[3].x := x3;eck[4].x := x4;
 eck[1].y := y1;eck[2].y := y2;eck[3].y := y3;eck[4].y := y4;
 for start := 1 to 3 do
 for ende := 4 downto start do
 if eck[start].y > eck[ende].y then begin
 eck[0] := eck[start];
 eck[start] := eck[ende];
 eck[ende] := eck[0];
 end;
 polyho := eck[4].y-eck[1].y;
 if (eck[1].y > downb) or (eck[4].y < upb) or (polyho < 1) then exit;
 dy := eck[4].y - eck[1].y;
 if dy = 0 then dy := 1;
 if dy < 5000 then stepx := (eck[4].x-eck[1].x)*kehrt^[dy] else
    stepx := (eck[4].x-eck[1].x)/dy;
 xa := trunc ((eck[2].y-eck[1].y)*stepx+eck[1].x);
 xe := trunc (eck[4].x-(eck[4].y-eck[3].y)*stepx);
 if ((xa<eck[2].x)and(xe<eck[3].x)) or ((xa>eck[2].x) and (xe>eck[3].x))
    then trapez := true else trapez := false;
 xa := eck[1].x; xa := xa * 256;ya := eck[1].y; xe := eck[4].x;
 xe := xe * 256; ye := eck[4].y;xl := eck[2].x; xl := xl * 256;
 yl := eck[2].y; xr := eck[3].x;xr := xr * 256; yr := eck[3].y;
if not trapez then
Begin
 ho1 := abs(yr-ya);ho2 := abs(ye-yr);height (ho1);height (ho2);
 stepx1 := trunc((xr-xa)*kehrt^[ho1]);stepx2 := trunc((xe-xr)*kehrt^[ho2]);
 ho4 := abs(yl-ya);ho3 := abs(ye-yl);height (ho4);height (ho3);
 stepx4 := trunc((xl-xa)*kehrt^[ho4]);stepx3 := trunc((xe-xl)*kehrt^[ho3]);
end else
Begin
 ho1 := abs(yl-ya);ho2 := abs(yr-yl);height (ho1);height (ho2);
 stepx1 := trunc((xl-xa)*kehrt^[ho1]);stepx2 := trunc((xr-xl)*kehrt^[ho2]);
 ho4 := abs(ye-ya);ho3 := abs(ye-yr);height (ho4);height (ho3);
 stepx4 := trunc((xe-xa)*kehrt^[ho4]);stepx3 := trunc((xe-xr)*kehrt^[ho3]);
end;
 port[$3ce] := 1; port[$3cf] := $0f;port[$3ce] := 0; port[$3cf]:=ficol;
 port[$3ce] := 8;
 links := xa; rechts := links; start := ya; ende := start + polyho - 1;
 counter1:= 0; counter2 :=0;
 if start < upb then Begin
     diff := upb - start;inc (start,diff);inc (counter1,diff);
     if not trapez then Begin
         inc (counter2,diff);
         if counter2<ho4 then inc (links,diff*stepx4)
         else links := xl + (upb-yl)*stepx3;
         if counter1<ho1 then inc(rechts,diff*stepx1)
         else rechts := xr + (upb-yr)*stepx2;
     end else Begin
         inc(links,diff*stepx4);
         if counter1<ho1 then inc(rechts,diff*stepx1)
         else Begin
           inc (counter2,diff-ho1);
           if counter2 < ho2 then rechts := xl + (upb-yl)*stepx2
           else rechts := xr + (upb-yr)*stepx3;
         end;
     end;
 end;
 scrmemoff := gscreen+start*gscrwidth;
 if ende > downb then ende := downb;
 sl := seg(links);ol := ofs(links)+1;sre := seg(rechts);ore := ofs(rechts)+1;
  if not trapez then
  begin
   for ypos := start to ende do
    begin
     if counter2< ho4 then
     Begin
      inc(links,stepx4);inc(counter2);
     end else inc(links,stepx3);
     if counter1<ho1 then
     begin
      inc(rechts,stepx1);inc(counter1);
     end else inc (rechts,stepx2);
     hline(memw[sl:ol],memw[sre:ore]);
     inc(scrmemoff,gscrwidth);
   end;
  end else
  begin
  for ypos := start to ende do
  begin
   inc(links,stepx4);
   if counter1<ho1 then
   begin
    inc(rechts,stepx1);inc(counter1);
   end else
   if counter2<ho2 then
   begin
    inc(rechts,stepx2);inc(counter2);
   end else inc(rechts,stepx3);
   hline(memw[sl:ol],memw[sre:ore]);
   inc(scrmemoff,gscrwidth);
  end;
 end;
port [$3cf] := $ff; port[$3ce] := 1;port [$3cf] := 0; port [$3ce] := 0;
port [$3cf] := 15;
end;

procedure setrgbpalette(i,r,g,b : byte);
begin
asm;mov dx,3c8h;mov al,i;out dx,al;inc dx;mov al,r;out dx,ax;mov al,g;
out dx,al;mov al,b;out dx,al;end;end;

function csin(winkel :integer): integer;
begin
while winkel < 0 do winkel := winkel + 360;
winkel := winkel mod 360;
if (winkel >= 0) and (winkel <= 90) then csin := sintab[winkel];
if (winkel > 90) and (winkel <= 180) then csin := sintab[180-winkel];
if (winkel > 180) and (winkel <= 270) then csin := -sintab[winkel-180];
if (winkel > 270) and (winkel <= 360) then csin := -sintab[360-winkel];
end;

function ccos(winkel :integer): integer;
begin
winkel := winkel+ 90;
while winkel < 0 do winkel := winkel + 360;
winkel := winkel mod 360;
ccos := csin(winkel);
end;

procedure gstartaddr(addr : word);
assembler;
asm;
mov bx,addr;push ds;mov dx,gCRTC;mov ah,bh;mov al,0ch;out dx,ax;
mov ah,bl;mov al,0dh;out dx,ax;mov cx,0040h;mov ds,cx;
mov word ptr ds:[004eh],bx;pop ds;end;

procedure waehle_seite (seite : byte);
begin
gscreen := seite * gscreensize;
end;

procedure zeige_seite(seite : byte);
var adr : word;
begin
 adr := seite * gscreensize;
 gstartaddr (adr);
end;

procedure wechsel5;

begin
if gscreen = gscreenpage0 then begin
                                zeige_seite(0); waehle_seite(1); end
                               else begin
                                zeige_seite(1); waehle_seite(0);
                               end;
end;

procedure gclear;
assembler;
asm;
mov ax,gscreensegment;mov es,ax;mov al,es:[0];mov di,gscreen;mov dx,3ceh;
mov ax,0205h;out dx,ax;mov ax,0003h;out dx,ax;mov ax,0ffffh;out dx,ax;
mov ax,$00;mov cx,gscreensize/2;rep stosw;mov dx,3ceh;mov ax,0205h;out dx,ax;
mov ax,1003h;out dx,ax;end;

procedure dreh_m;
var x,y,u,v : real;
begin
 x:=csin(ga)/256; y:=ccos(al)/256; u:=csin(al)/256; v:=ccos(ga)/256;
 rp[1,1]:=v; rp[2,1]:=x; rp[3,1]:=0; rp[1,2]:=y*x; rp[2,2]:=y*v; rp[3,2]:=-u;
 rp[1,3]:=u*x; rp[2,3]:=u*v; rp[3,3]:=y;end;

procedure dreh(var x:rtupel);
var temp:rtupel;
begin
 temp.x:=(x.x*rp[1,1]+x.y*rp[1,2]+x.z*rp[1,3]) * scal;
 temp.y:=(x.x*rp[2,1]+x.y*rp[2,2]+x.z*rp[2,3])*scal;
 temp.z:=(x.y*rp[3,2]+x.z*rp[3,3])*scal;
 x:=temp;
end;

procedure zeichnen;
begin
for lauf := 1 to 12 do begin
u[lauf] := round(pd[lauf].x)+320;v[lauf] := round(pd[lauf].z)+200;end;

draw(u[1],v[1],u[2],v[2],1);draw(u[1],v[1],u[4],v[4],1);
draw(u[1],v[1],u[3],v[3],1);draw(u[1],v[1],u[5],v[5],1);
draw(u[2],v[2],u[3],v[3],1);draw(u[2],v[2],u[4],v[4],1);
draw(u[3],v[3],u[5],v[5],1);draw(u[5],v[5],u[4],v[4],1);
draw(u[6],v[6],u[7],v[7],1);draw(u[6],v[6],u[8],v[8],1);
draw(u[7],v[7],u[9],v[9],1);draw(u[9],v[9],u[8],v[8],1);
draw(u[2],v[2],u[6],v[6],1);draw(u[3],v[3],u[7],v[7],1);
draw(u[4],v[4],u[8],v[8],1);draw(u[5],v[5],u[9],v[9],1);
draw(u[10],v[10],u[6],v[6],1);draw(u[10],v[10],u[7],v[7],1);
draw(u[10],v[10],u[8],v[8],1);draw(u[10],v[10],u[9],v[9],1);
draw(u[11],v[11],u[6],v[6],1);draw(u[11],v[11],u[2],v[2],1);
draw(u[11],v[11],u[8],v[8],1);draw(u[11],v[11],u[4],v[4],1);
draw(u[12],v[12],u[3],v[3],1);draw(u[12],v[12],u[5],v[5],1);
draw(u[12],v[12],u[7],v[7],1);draw(u[12],v[12],u[9],v[9],1); end;

procedure initkehrtaB;
var a: word;
begin new (kehrt); for a:= 1 to 10000 do kehrt^[a] := 1/a; end;

procedure initmasktab;
var a,wert : word;
begin
 for a:= 0 to 639 do
 begin
  lmask[a]:=$ff shr (a and 7);wert := $ff shl (7-(a and 7));
  rmask[a] := lo(wert); end;end;

procedure gexit;
assembler; asm;push ax;xor ah,ah;mov al,3h;int 10h;pop ax;end;


begin
  graph_init;
  setrgbpalette(1,63,0,0); setrgbpalette(2,0,42,0); setrgbpalette(3,10,63,10);
  setrgbpalette(4,42,0,0); setrgbpalette(5,63,10,10);setrgbpalette(6,42,21,0);
  setrgbpalette(7,42,42,42);
  gscreen := 0; initkehrtab; initmasktab;
  al := 0; ga := 0;leftb := 10;upb := 10;rightb := 600;downb := 400;
  repeat
   dec(al,5);ga := ga + csin(al) div 25+csin(ga) div 50;pd := pk;
   dreh_m;for lauf := 1 to 12 do dreh(pd[lauf]);
  zeichnen;f := 2;
  fillfourangle(u[1],v[1],u[4],v[4],u[5],v[5],u[1],v[1],f);
  fillfourangle(u[1],v[1],u[2],v[2],u[3],v[3],u[1],v[1],f);
  fillfourangle(u[1],v[1],u[5],v[5],u[3],v[3],u[1],v[1],f);
  fillfourangle(u[1],v[1],u[2],v[2],u[4],v[4],u[1],v[1],f);f := 4;
  fillfourangle(u[11],v[11],u[2],v[2],u[6],v[6],u[11],v[11],f);
  fillfourangle(u[11],v[11],u[4],v[4],u[8],v[8],u[11],v[11],f);
  fillfourangle(u[11],v[11],u[6],v[6],u[8],v[8],u[11],v[11],f);
  fillfourangle(u[11],v[11],u[2],v[2],u[4],v[4],u[11],v[11],f);f := 2;
  fillfourangle(u[10],v[10],u[8],v[8],u[9],v[9],u[10],v[10],f);
  fillfourangle(u[10],v[10],u[6],v[6],u[7],v[7],u[10],v[10],f);
  fillfourangle(u[10],v[10],u[9],v[9],u[7],v[7],u[10],v[10],f);
  fillfourangle(u[10],v[10],u[6],v[6],u[8],v[8],u[10],v[10],f);f := 4;
  fillfourangle(u[12],v[12],u[3],v[3],u[7],v[7],u[12],v[12],f);
  fillfourangle(u[12],v[12],u[5],v[5],u[9],v[9],u[12],v[12],f);
  fillfourangle(u[12],v[12],u[3],v[3],u[5],v[5],u[12],v[12],f);
  fillfourangle(u[12],v[12],u[7],v[7],u[9],v[9],u[12],v[12],f);
  wechsel5; waitblank; gclear;
 until keypressed;
dispose(kehrt);gexit;end.

