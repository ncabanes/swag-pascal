(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0192.PAS
  Description: Cool Fonts
  Author: WILLIAM BARATH
  Date: 05-26-95  23:00
*)

{ (C) 1994  By William Barath,  Public Domain}

Unit CoolFont;{ Draws 2 fonts in assorted sizes and styles }

Interface

Uses Hardware;

Var
  PSET:Procedure(x,y:Word);
  SetColor:Procedure(c:Word);

Const
  FBold  =$01;
  FItalic=$02;
  FULine =$04;
  FShadow=$08;
  FOLine =$10;
  FTiny  =$20;

  Shadow:Byte=$08;
  OutLine:Byte=$00;

  FontScaleS:Byte=$11;
Type
    pFntArray = ^FntArray;
    FntArray = Array[0..1] of byte;

Var F8x8:FntArray absolute $f000:$fa6e;

Procedure TextAt(s:String;x,y:Integer;C:Byte;Style:Byte);
Procedure CharSet_5P;

Implementation

Procedure TextAt(s:String;x,y:Integer;C:Byte;Style:Byte);
Var xlp,ylp,pos,size,width,italic,xd,yp,d,p,sx,sy:integer;
    f:pFntArray;
    us:String;

Label YLoop,XLoop,NotItalic,NoPlot,NoShift;
begin
  If (@PSET=Nil) or (@SetColor=Nil) then exit;
  sx:=FontScales AND $f; sy:=FontScales SHR 4;
  If Boolean(style AND FShadow) then TextAt(s,x+sx,y+sy,shadow,
     style AND (Not (FShadow)));
  If Boolean(Style And FULine) then
  Begin
    FillChar(us[1],Length(s),'_');
    us[0]:=s[0];
    TextAt(us,x,y+(sy+1)Div 2,c,
    Style AND Not(FUline+FShadow));
  end;
  If Boolean(style AND FOLine) then
  Begin
    If c= Shadow then Pos:=c else Pos:=OutLine;
    For xlp:=-1 to 1 do For ylp:=-1 to 1 do
    Begin
      If (Style and FItalic)>0 then Italic:=(ylp*(sy+1)) Div 4 else 
italic:=0;
      TextAT(s,x+xlp*(sx+1)div 2-italic,y+ylp*(sy+1)div 2,pos,
      style and (Not (FOLine+FULine+FShadow)));
    end;
  end;
  If Boolean(Style AND FBold) then TextAt(s,x+(sx+2) div 3,y,c,
     style AND (Not (FBold+FOLine+FShadow+FULine)));
  If Boolean(Style AND FTiny)
  then Begin size:=5;Width:=6;f:=@CharSet_5p;end
  Else Begin size:=8;Width:=8;f:=@F8x8;end;
  SetColor(c);
  Width:=Width*sx;
  If (Style AND FItalic)>0 then Inc (x,Width Div 4);
  For pos:= 1 to Byte(s[0]) do
    Begin
      p:=byte(s[pos]);
      If f=@Charset_5p then
        Begin
          Dec (p,33); if p<0 then continue;
          If p>62 then dec(p,32);
          If p>95 then continue;
        end;
{$Define ASMVersion}
{$IfDef ASMVersion}
      asm
        Mov  ax,Size
        Mul  sy
        Mov  cx,ax
        Mov  YLP,0
        Mov  ax,y
        Mov  yp,ax         {yp:=y}
YLoop:                     {For ylp:=0 to sy*size do}
        Push cx            {Begin}
        Xor  ah,ah
        Mov  al,Style
        And  al,FItalic
        JZ   NotItalic     {If Style AND FItal then SI:= YLP Div 2}
        Mov  ax,Ylp        {Else SI:=0}
        Shr  ax,1
NotItalic:
        Mov  si,ax
        Mov  ax,p
        Mul  Size
        Mov  bx,ax
        Mov  ax,ylp
        Div  sy
        Add  bx,ax
        Les  di,F
        Mov  al,es:[di+bx]
        Mov  d.byte,al     {d:=f^[p*Size+ylp Div sy]}
        Mov  xd,0          {xd:=0}
        Inc  yp            {Inc(yp)}
        Mov  ax,Pos
        Dec  ax
        Mul  Width
        Sub  ax,si
        Add  ax,x
        Mov  xlp,ax        {xlp:=x+SI+Pred(pos)*Width}
        Mov  cx,Width
XLoop:                     {For xlp:=xlp to xlp+Width do}
        Push cx            {Begin}
        Test d.byte,$80
        Jz   NoPlot
        Push xlp
        Push yp
        Call PSet          {If (d AND $80)>0 then Pset(xlp,yp)}
NoPLot:
        Mov  ax,xd
        Inc  ax
        Cmp  ax,sx         {Inc(xd);if xd>sx then Begin 
Inc(d,d);xd:=0;end;}
        Jb   NoShift
        Shl  d,1
        Xor  ax,ax
NoShift:
        Mov  xd,ax
        Inc  Xlp
        Pop  cx
        Loop Xloop         {End <Xloop>}
        Inc  Ylp
        Pop  cx
        Dec  cx
        Jnz  Yloop         {End <Yloop>}
      end;
{$Else}
      For ylp:= 0 to Pred(size*SY) do
        Begin
          If (Style and FItal)>0 then Italic:=ylp SHR 1 else italic:=0;
          d:=f^[p*size+Ylp Div SY];
          xd:=0;yp:=y+ylp;
          for xlp:=x+Pred(pos)*Width-Italic to x+pos*Width-italic do
            Begin
              If Boolean(d AND $80) then pset(xlp,yp);
              Inc (xd); if xd=SX then Begin Inc(d,d);xd:=0;end;
            end;
        end;
{$endif}
    end;
end; {OutTextXY}

Procedure CharSet_5P;assembler;
asm
db 00100000b {Character set on 5*5 matrix}
db 00100000b {covers ASCII $21..$5f}
db 00100000b {use ORD(Ucase(Char))-33 for offest}
db 00000000b {Don't draw it if <0 or >92 !!!}
db 00100000b

db 01010000b
db 01010000b
db 00000000b
db 00000000b
db 00000000b

db 01010000b
db 11111000b
db 01010000b
db 11111000b
db 01010000b

db 00100000b
db 01110000b
db 01100000b
db 00110000b
db 01110000b

db 11001000b
db 11010000b
db 00100000b
db 01011000b
db 10011000b

db 01100000b
db 01101000b
db 01110000b
db 10010000b
db 01101000b

db 00100000b
db 00100000b
db 00000000b
db 00000000b
db 00000000b

db 00010000b
db 00100000b
db 00100000b
db 00100000b
db 00010000b

db 01000000b
db 00100000b
db 00100000b
db 00100000b
db 01000000b

db 10101000b
db 01110000b
db 00100000b
db 01110000b
db 10101000b

db 00100000b
db 00100000b
db 11111000b
db 00100000b
db 00100000b

db 00000000b
db 00000000b
db 00000000b
db 00100000b
db 01000000b

db 00000000b
db 00000000b
db 11111000b
db 00000000b
db 00000000b

db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00100000b

db 00001000b
db 00010000b
db 00100000b
db 01000000b
db 10000000b

db 01110000b
db 10001000b
db 10001000b
db 10001000b
db 01110000b

db 00010000b
db 00110000b
db 00010000b
db 00010000b
db 00111000b

db 01110000b
db 00001000b
db 01110000b
db 10000000b
db 11111000b

db 11110000b
db 00001000b
db 01110000b
db 00001000b
db 11110000b

db 00010000b
db 10010000b
db 11110000b
db 00010000b
db 00010000b

db 11110000b
db 10000000b
db 11110000b
db 00001000b
db 11110000b

db 01110000b
db 10000000b
db 11110000b
db 10001000b
db 01110000b

db 01111000b
db 00001000b
db 00010000b
db 00100000b
db 00100000b

db 01110000b
db 10001000b
db 01110000b
db 10001000b
db 01110000b

db 01110000b
db 10001000b
db 01111000b
db 00001000b
db 01110000b

db 00000000b
db 00100000b
db 00000000b
db 00100000b
db 00000000b

db 00000000b
db 00100000b
db 00000000b
db 00100000b
db 01000000b

db 00010000b
db 00100000b
db 01000000b
db 00100000b
db 00010000b

db 00000000b
db 11111000b
db 00000000b
db 11111000b
db 00000000b

db 01000000b
db 00100000b
db 00010000b
db 00100000b
db 01000000b

db 01110000b
db 00001000b
db 00110000b
db 00000000b
db 00100000b

db 01110000b
db 10111000b
db 10111000b
db 10000000b
db 01110000b

db 01110000b
db 10001000b
db 11111000b
db 10001000b
db 10001000b

db 11110000b
db 10001000b
db 11110000b
db 10001000b
db 11110000b

db 01110000b
db 10000000b
db 10000000b
db 10000000b
db 01110000b

db 11110000b
db 10001000b
db 10001000b
db 10001000b
db 11110000b

db 11111000b
db 10000000b
db 11110000b
db 10000000b
db 11111000b

db 11111000b
db 10000000b
db 11110000b
db 10000000b
db 10000000b

db 01111000b
db 10000000b
db 10111000b
db 10001000b
db 01111000b

db 10001000b
db 10001000b
db 11111000b
db 10001000b
db 10001000b

db 11111000b
db 00100000b
db 00100000b
db 00100000b
db 11111000b

db 01111000b
db 00010000b
db 00010000b
db 10010000b
db 01100000b

db 10001000b
db 10010000b
db 11100000b
db 10010000b
db 10001000b

db 10000000b
db 10000000b
db 10000000b
db 10000000b
db 11111000b

db 10001000b
db 11011000b
db 10101000b
db 10001000b
db 10001000b

db 10001000b
db 11001000b
db 10101000b
db 10011000b
db 10001000b

db 01110000b
db 10001000b
db 10001000b
db 10001000b
db 01110000b

db 11110000b
db 10001000b
db 11110000b
db 10000000b
db 10000000b

db 01110000b
db 10001000b
db 10101000b
db 10011000b
db 01111000b

db 11110000b
db 10001000b
db 11110000b
db 10010000b
db 10001000b

db 01110000b
db 10000000b
db 01110000b
db 00001000b
db 01110000b

db 11111000b
db 00100000b
db 00100000b
db 00100000b
db 00100000b

db 10001000b
db 10001000b
db 10001000b
db 10001000b
db 01110000b

db 10001000b
db 10001000b
db 01010000b
db 01010000b
db 00100000b

db 10001000b
db 10001000b
db 10101000b
db 11011000b
db 10001000b

db 10001000b
db 01010000b
db 00100000b
db 01010000b
db 10001000b

db 10001000b
db 10001000b
db 01111000b
db 00001000b
db 01110000b

db 11111000b
db 00010000b
db 00100000b
db 01000000b
db 11111000b

db 01110000b
db 01000000b
db 01000000b
db 01000000b
db 01110000b

db 10000000b
db 01000000b
db 00100000b
db 00010000b
db 00001000b

db 01110000b
db 00010000b
db 00010000b
db 00010000b
db 01110000b

db 00100000b
db 01010000b
db 00000000b
db 00000000b
db 00000000b

db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 11111100b

end;

end.

