(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0001.PAS
  Description: DOTSPIN.PAS
  Author: SEAN PALMER
  Date: 05-28-93  13:47
*)

program dotspin;

var inPort1:word;
procedure waitRetrace;assembler;asm
 mov dx,inPort1; {find crt status reg (input port #1)}
@L1: in al,dx; test al,8; jnz @L1;  {wait for no v retrace}
@L2: in al,dx; test al,8; jz @L2; {wait for v retrace}
 end;

const
 tableWriteIndex=$3C8;
 tableDataRegister=$3C9;

procedure setColor(color,r,g,b:byte);assembler;asm {set DAC color}
 mov dx,tableWriteIndex; mov al,color; out dx,al; inc dx;
 mov al,r; out dx,al; mov al,g; out dx,al; mov al,b;out dx,al;
 end; {write index now points to next color}

{plot a pixel in mode $13}
procedure plot(x,y:word);Inline(
  $5E/                   { pop si  ;y}
  $5F/                   { pop di  ;x}
  $B8/$00/$A0/           { mov ax,$A000}
  $8E/$C0/               { mov es,ax}
  $B8/$40/$01/           { mov ax,320}
  $F7/$E6/               { mul si}
  $01/$C7/               { add di,ax}
  $26/$F6/$15);          {es: not byte[di]}

procedure plot4(x,y:word);const f=60;begin
 plot(x+f,y);
 plot(199+f-x,199-y);
 plot(199+f-y,x);
 plot(y+f,199-x);
 end;

procedure click;assembler;asm
 in al,$61; xor al,2; out $61,al;
 end;

const nDots=21;

var
 dot:array[0..nDots-1]of record
  x,y,sx,sy:integer;
  end;

function colorFn(x:integer):byte;begin
 colorFn:=63-(abs(100-x)div 2);
 end;

procedure moveDots;var i:word;begin
 for i:=0 to nDots-1 do with dot[i] do begin
  plot4(x,y);
  inc(x,sx);inc(y,sy);
  if(word(x)>200)then begin
   sx:=-sx;inc(x,sx);click;
   end;
  if(word(y)>199)then begin
   sy:=-sy;inc(y,sy);click;
   end;
  plot4(x,y);
  end;
 waitRetrace;waitRetrace;waitRetrace;{waitRetrace;}
 setcolor(255,colorFn(dot[0].x),colorFn(dot[3].x),colorFn(dot[6].x));
 end;

procedure drawdots;var i:word;begin
 for i:=0 to nDots-1 do with dot[i] do plot4(x,y);
 end;

procedure initDots;var i,j,k:word;begin
 j:=1;k:=1;
 for i:=0 to nDots-1 do with dot[i] do begin
  x:=100;y:=99;
  sx:=j;sy:=k;
  inc(j);if j>=k then begin j:=1;inc(k); end;
  end;
 end;

function readKey:char;Inline(
  $B4/$07/               {mov ah,7}
  $CD/$21);              {int $21}

function keyPressed:boolean;Inline(
  $B4/$0B/               {mov ah,$B}
  $CD/$21/               {int $21}
  $24/$FE);              {and al,$FE}

begin
 inPort1:=memw[$40:$63]+6;
 port[$61]:=port[$61]and (not 1);
 setcolor(255,60,60,63);
 initDots;
 asm mov ax,$13; int $10; end;
 drawDots;
 repeat moveDots until keypressed;
 readkey;
 drawDots;
 asm mov ax,3; int $10; end;
 end.


 * OLX 2.2 * Printers do it without wrinkling the sheets.

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)
                                                                                                 
