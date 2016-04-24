(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0185.PAS
  Description: Vesa and 320x200x256
  Author: JOHN STEPHENSON
  Date: 02-28-95  10:11
*)

{CF> Does any one have code to do Vesa 320x200x256?  Also page flipping?
 CF> And s' stuff? }

 
{Here's my VESA unit}
 
{$A+,B-,D+,E+,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M 1024,0,65536}
Unit Vesa;
Interface
Uses Crt,Dos;
Var
  xMax,
  yMax: word; { VERY important you set these upon init'ing }
Type
  tRGB = record R,G,B: byte; end;
  tDAC = array[0..255] of tRGB;
Const
  { Standard text }
  _40x25t        = $02;
  _80x25t        = $03;
  { Standard VGA }
  _640x480x2     = $11;
  _640x480x16    = $12;
  _320x200x256   = $13;
  { Standard VESA }
  _640x400x256   = $100;
  _640x480x256   = $101;
  _800x600x16    = $102;
  _800x600x256   = $103;
  _1024x768x16   = $104;
  _1024x768x256  = $105;
  _1280x1024x16  = $106;
  _1280x1024x256 = $107;
  { Textmode modes for VESA }
  _80x60t        = $108;
  _132x25t       = $109;
  _132x43t       = $10A;
  _132x50t       = $10B;
  _132x60t       = $10C;
  { Pretty much standard VESA }
  _320x200x32K   = $10D;
  _320x200x64K   = $10E;
  _320x200x16M   = $10F;
  _640x480x32K   = $110;
  _640x480x64K   = $111;
  _640x480x16M   = $112;
  _800x600x32K   = $113;
  _800x600x64K   = $114;
  _800x600x16M   = $115;
  _1024x768x32K  = $116;
  _1024x768x64K  = $117;
  _1024x768x16M  = $118;
  _1280x1024x32K = $119;
  _1280x1024x64K = $11A;
  _1280x1024x16M = $11B;
Var
  Current_bank: byte;
  Pp: byte;
Const
  vCycle_direction: byte = 1;

{═══════════════════════════════════════════════════════════════════════════}
Procedure Clearscreen(c: byte);
procedure Line(X1,Y1,X2,Y2: Integer; Color: Byte);
Procedure HLine(x,y,x2: integer; color: byte);
Procedure VLine(x,y,y2: integer; color: byte);
Procedure Circle(X,y,size: longint; color: byte);
Procedure SwitchBank(bank: byte);
Procedure PutPix(x,y: word; c: byte);
Procedure Cycle(var vpTemp: tDAC; start,finish: Byte);
Procedure LoadPal(fn: pathstr);
Procedure SetColor(Color,r,g,b: Byte);
Procedure GetColor(Color: byte; var R,G,B : Byte);
Procedure SetPalette(var vPal: tDAC);
Procedure GetPalette(var vPal: tDAC);
procedure Rectangle(x1, y1, x2, y2 : word; Color : byte);
{───────────────────────────────────────────────────────────────────────────}
Function SetMode(mode: word): boolean; { VGA & VESA modes }
Function GetMode(var mode: word): boolean;
{═══════════════════════════════════════════════════════════════════════════}

Implementation

Procedure Cycle(var vpTemp: tDAC; start,finish: Byte);
Var
  count,
  speed : Byte;
  temp : tRGB;
Begin
  If vCycle_direction = 0 then Exit;

  For speed := 1 to Abs(vCycle_direction) do begin
    { Forwards? }
    If Abs(vCycle_direction) = vCycle_direction then begin
      temp := vpTemp[start];
      for count := start to finish-1 do
        vpTemp[count] := vpTemp[count+1];
      vpTemp[finish] := temp;
    end
    { Backwards? }
    else begin
      temp := vpTemp[finish];
      for count := finish downto start+1 do
        vpTemp[count] := vpTemp[count-1];
      vpTemp[start] := temp;
    End;
  End;

  Setpalette(vpTemp);
End;

procedure Rectangle(x1,y1,x2,y2: word; Color: byte);
begin
  Line(x1,y1,x2,y1,Color);
  Line(x2,y1,x2,y2,Color);
  Line(x2,y2,x1,y2,Color);
  Line(x1,y2,x1,y1,Color);
end;

Procedure SetPalette(var vPal: tDAC);
Var loop: byte;
Begin
  For loop := 0 to 255 do with vPal[loop] do SetColor(loop,r,g,b);
End;

Procedure GetPalette(var vPal: tDAC);
Var loop: byte;
Begin
  For loop := 0 to 255 do with vPal[loop] do GetColor(loop,r,g,b);
End;

Procedure SetColor(color,r,g,b: Byte); Assembler;
Asm
  mov  dx, 3C8h   { Color port }
  mov  al, color  { Number of color to change }
  out  dx, al
  inc  dx         { Inc dx to write }
  mov  al, r      { Red value }
  out  dx, al
  mov  al, g      { Green }
  out  dx, al
  mov  al, b      { Blue }
  out  dx, al
End;

Procedure GetColor(Color: byte; var r,g,b: byte); Assembler;
{ This reads the values of the Red, Green and Blue DAC values of a
  certain color and returns them to you in r (red), g (green), b (blue) }
asm
  mov  dx, 3C7h
  mov  al, color
  out  dx, al
  add  dx, 2
  in   al, dx
  les  di, r
  stosb
  in   al, dx
  les  di, g
  stosb
  in   al, dx
  les  di, b
  stosb
end;

Procedure Circle(X,Y,size: longint; color: byte);
Var Xl,Yl : LongInt;
Begin
  If Size=0 Then Begin
    PutPix(X,Y,color);
    Exit;
  End;
  Xl := 0;
  Yl := Size;
  Size := Size*Size+1;
  Repeat
    PutPix(X+Xl,Y+Yl,color);
    PutPix(X-Xl,Y+Yl,color);
    PutPix(X+Xl,Y-Yl,color);
    PutPix(X-Xl,Y-Yl,color);
    If Xl*Xl+Yl*Yl >= Size Then Dec(Yl)
    Else Inc(Xl);
  Until Yl = 0;
  PutPix(X+Xl,Y+Yl,color);
  PutPix(X-Xl,Y+Yl,color);
  PutPix(X+Xl,Y-Yl,color);
  PutPix(X-Xl,Y-Yl,color);
end;

Procedure HLine(x,y,x2: integer; color: byte);
Begin
  for x := x to x2 do putpix(x,y,color);
End;

Procedure VLine(x,y,y2: integer; color: byte);
Begin
  for y := y to y2 do putpix(x,y,color);
End;
 
procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);
var X, Y, Dx, Dy, Xs, Ys, Direction: Integer;
begin
  if x1 = x2 then hline(x1,y1,y2,color)
  else if y1 = y2 then vline(x1,y1,x2,color)
  else begin
    X := X1; Y := Y1; Xs := 1; Ys := 1;
    if X1 > X2 then Xs := -1;
    if Y1 > Y2 then Ys := 01;
    Dx := Abs(X2 - X1); Dy := Abs(Y2 - Y1);
    if Dx = 0 then direction := -1
    else Direction := 0;
    while not ((X = X2) and (Y = Y2)) do begin
      PutPix(X,Y,Color);
      if Direction < 0 then begin                               
        Inc(Y,Ys);
        Inc(Direction,Dx);
      end 
      else begin
        Inc(x,Xs);
        Dec(Direction,Dy);
      end;
    end;
  end;
end;  { Line }

Function GetMode(var mode: word): boolean; assembler;
asm
  Mov  ax, 4F03h
  Int  10h
  Mov  word ptr mode, bx
  Cmp  Al, 4Fh
  Je   @Yes
  mov  al, false
  Jmp  @end
 @Yes:
  mov  al, true
 @End:
end;

Function SetMode(mode: word): boolean; assembler;
{ This function will work for more than just VESA modes, and more than  }
{ Just VESA cards also.  If it's under $100 (where vesa modes begin) it }
{ will use the normal video bios instead. So people without VESA cards/ }
{ drivers still can use this for 320x200x256, etc.                      }
asm
  { Comment this part out if you want to use vesa for this }
  {--}
  Cmp Mode, 100h
  Jb  @Normal_VGA { If it's below 100h then it's a std mode, why use VESA? }
  {--}
  Mov Ax, 4F02h   { VESA set modes }
  Mov Bx, mode
  Int 10h
  Cmp Ax, 004Fh   { AL=4F VESA supported, AH=00 successful }
  Jne @Error      { Else Error }
  mov al, true
  jmp @done
 @Error:
  mov al, false
  Jmp @done
 @Normal_VGA:
  mov ax, mode    { AH will of course be zero, as intended }
  int 10h
  Mov al, true
 @done:
end;

Procedure SwitchBank(bank: byte); Assembler;
Asm
  Mov al, bank
  Cmp Current_bank, al
  je @End
  Mov Current_bank, al
  Mov Ax, 4F05h
  Xor Bx, Bx
  Adc Dx, 0
  Mov Dl, bank
  Int 10h
 @End:
End;

Procedure Clearscreen(c: byte);
var loop: byte;
begin
  for loop := 0 to (longint(xmax)*ymax) div $FFFF do begin
    switchbank(loop);
    Fillchar(mem[SegA000:0],$FFFF,c);
    Fillchar(mem[SegA000:$FFFF],$1,c);
  end;
end;

Procedure LoadPal(Fn: PathStr);
Var
  DAC: tDAC;
  F: file;
  Loop: integer;
Begin
  Assign(f,Fn);
  Reset(f,1);
  If ioresult <> 0 then exit;
  BlockRead(f,DAC,Sizeof(DAC));
  Close(f);
  for Loop := 0 to 255 do with dac[loop] do SetColor(Loop,r,g,b);
end;

Procedure PutPix(x,y: word; c: byte); assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end

  mov  ax, y
  cmp  ymax, ax
  jb   @end
  
  dec  x

  { Calculate where we're going to place the pixel at A000:???? }
  Mov  ES, SegA000
  Mov  AX, Ymax
  Mul  pp
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  Al, C
  Mov  Es:[Di], Al
 @End:
End;

End.

... How do blonds get minks?  The same way Minks get Minks!
--- Blue Wave/Max v2.12 [NR]
 * Origin: Infinity Complex -= 28.8k =- (613)549-7847 (1:249/153)
SEEN-BY: 12/12 163/99 211 167/90 221/100 224/25 240/99 241/99
SEEN-BY: 243/3 244/99 246/1 249/1 99 100 101 112 127 128 152
SEEN-BY: 249/153 200 201 396/1 3615/50 51
PATH: 249/153 100 99 12/12 3615/50
                                       
{SWAG=???.SWG,JOHN STEPHENSON,Vesa and 320x200x256 3/3}
MSGID: 1:249/153.0 2efc50b2
{CF> Does any one have code to do Vesa 320x200x256?  Also page flipping? 
 CF> And s' stuff? 

 Lastly, an example:}
 
uses crt,vesa,asmmisc;
var
  loop: word;
  vpTemp: tDac;
  pixels : word;
  hx,hy: longint;

begin
  xmax := 320;
  ymax := 200;
  setmode(_320x200x256);
  LoadPal('TUNNEL.PAL'); { Get your own palette! }
  GetPalette(vpTemp);
  
  { Calculate the amount of pixels to 1,1 from xmax div 2,ymax div 2 using }
  { the pythagorean theorm }
  hy := ymax div 2; { Centre Y }
  hx := xmax div 2; { Centre X }          {       _____ }
  pixels := round(sqrt((hx*hx)+(hy*hy))); { c := √a²+b² }

  for loop := 0 to pixels do begin
    circle(xmax div 2,ymax div 2,loop,loop mod 255+1);
    Cycle(vpTemp,1,255);
  end;
  while keypressed do readkey;
  { Don't rotate black! }
  while not keypressed do begin
    Retrace;
    Cycle(vpTemp,1,255);
  end;
  readkey;
  setmode(lastmode);
end.

