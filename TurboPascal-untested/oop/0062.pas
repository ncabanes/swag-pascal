unit grafwin;

{****************************************************************************}
{**                                                                        **}
{**                                GRAFWIN                                 **}
{**                                                                        **}
{**                  Grafics in Turbo-Vision's Textmode                    **}
{**                                                                        **}
{**               This program and source are PUBLIC DOMAIN                **}
{**                                                                        **}
{****************************************************************************}
{**                                                                        **}
{** by Stefan Michel (2:2490/1145.6)                                       **}
{**                                                                        **}
{** Fontmanipulations by David Dahl (1:272/38.0)                           **}
{**                                                                        **}
{****************************************************************************}
{**                                                                        **}
{** This example uses a second font as a pseudo-graphics window.           **}
{** This program requires VGA.                                             **}
{**                                                                        **}
{****************************************************************************}

interface

uses objects,views;

{Palette for TGraf}

const
  CGraf = #8#6;

type
  pgraf=^tgraf;
  tgraf=object(tview)
  {A View graphic-view-object}
    constructor Init(Var Bounds: TRect);
    destructor Done; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure Update(Const isdraw:boolean); virtual;
      {Draws the graphic, use PutPixel, etc. here!}
    procedure Clear;
      {Clear the graphic}
    procedure PutPixel (Xin, Yin : Word; FG:Boolean);
      {Puts a Pixel. if FG then color is the Foregroundcolor}
    procedure PutLine (XStart, YStart, XEnd, YEnd : Word; FG:Boolean);
    procedure PutCircle (XCoord, YCoord, Radius : Integer; FG:Boolean);
    procedure PutRectangle (X1, Y1, X2, Y2 : Word; FG:Boolean);
  end;

  pclock=^tclock;
  tclock=object(tgraf)
  {shows a analog clock in a TV-Window}
  Hours,Mins,Secs:Word;
    Constructor Init(var Bounds:TRect);
    procedure update(const isdraw:boolean); virtual;
  end;

  pgrafwin=^tgrafwin;
  tgrafwin=object(twindow)
  {A window, that changes the boarder of tgraf correctly}
    graf:pgraf;
    constructor Init(var Bounds: TRect; ATitle: TTitleStr; ANumber:Integer);
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure insertgraf(agraf:pgraf);
  end;

const
  grcount:word=0; {Counter how many graf-objects are initialized}

implementation

uses dos,drivers,app;

Procedure SetCharWidthTo8; Assembler;
{by David Dahl}
Asm
   { Change To 640 Horz Res }
   MOV DX, $3CC
   IN  AL, DX
   AND AL, Not(4 OR 8)
   MOV DX, $3C2
   OUT DX, AL
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 0
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Switch To 8 Pixel Wide Fonts }
   MOV DX, $3C4
   MOV AL, 1
   OUT DX, AL
   MOV DX, $3C5
   IN  AL, DX
   OR  AL, 1
   OUT DX, AL
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 0
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Center Screen }
   MOV DX, $3DA
   IN  AL, DX
   MOV DX, $3C0
   MOV AL, $13 OR 32
   OUT DX, AL
   MOV AL, 0
   OUT DX, AL
End;

{-[ Turn On Dual Fonts ]--------------------------------------------------}
Procedure SetDualFonts; Assembler;
{by David Dahl}
ASM
   { Set Fonts 0 & 1 }
   MOV BL, 4
   MOV AX, $1103
   INT $10
END;
{-[ Turn On Access To Font Memory ]---------------------------------------}
Procedure SetAccessToFontMemory; Assembler;
{by David Dahl}
ASM
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 1
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Change From Odd/Even Addressing to Linear }
   MOV DX, $3C4
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 7
   OUT DX, AL
   { Switch Write Access To Plane 2 }
   MOV DX, $3C4
   MOV AL, 2
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 4
   OUT DX, AL
   { Set Read Map Reg To Plane 2 }
   MOV DX, $3CE
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 2
   OUT DX, AL
   { Set Graphics Mode Reg }
   MOV DX, $3CE
   MOV AL, 5
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 0
   OUT DX, AL
   { Set Misc. Reg }
   MOV DX, $3CE
   MOV AL, 6
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 12
   OUT DX, AL
End;
{-[ Turn On Access to Text Memory ]---------------------------------------}
Procedure SetAccessToTextMemory; Assembler;
{by David Dahl}
ASM
   { Turn Off Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 1
   OUT DX, AL
   { Reset Sequence Controller }
   MOV DX, $3C4
   MOV AL, 0
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Change To Odd/Even Addressing }
   MOV DX, $3C4
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3
   OUT DX, AL
   { Switch Write Access }
   MOV DX, $3C4
   MOV AL, 2
   OUT DX, AL
   MOV DX, $3C5
   MOV AL, 3  {?}
   OUT DX, AL
   { Set Read Map Reg }
   MOV DX, $3CE
   MOV AL, 4
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 0
   OUT DX, AL
   { Set Graphics Mode Reg }
   MOV DX, $3CE
   MOV AL, 5
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, $10
   OUT DX, AL
   { Set Misc. Reg }
   MOV DX, $3CE
   MOV AL, 6
   OUT DX, AL
   MOV DX, $3CF
   MOV AL, 14
   OUT DX, AL
End;

constructor tgraf.Init(var Bounds: TRect);
var t:byte;p:^byte;
begin
  {a new graf-object}
  inc(grcount);
  {redefining vga palette 4->B,5->E,6->F}
  asm
    mov ax,1000h
    mov bl,4
    mov bh,3Bh
    int 10h
    mov ax,1000h
    mov bl,5
    mov bh,3Eh
    int 10h
    mov ax,1000h
    mov bl,6
    mov bh,3Fh
    int 10h
  end;
  {delete bit3 of all palette-entries}
  with Application^ do
    for t:=1 to byte(getpalette^[0]) do
    begin
      p:=@GetPalette^[t];
      case p^ and $F of
           $B:p^:=p^ and $F0 or $4;
        $A,$E:p^:=p^ and $F0 or $5;
           $F:p^:=p^ and $F0 or $6;
        else p^:=p^ and $f7;
      end;
    end;
  {suppress shadow-errors with the graphic-view}
  shadowattr:=0;
  {color of graphics; use reserved palette-entry}
  application^.getpalette^[15]:=#$1F;
  {calc bounds}
  if (bounds.b.y-bounds.a.y)*(bounds.b.x-bounds.a.x)>255 then
    bounds.b.y:=bounds.a.y+256 div (bounds.b.x-bounds.a.x);
  inherited init(bounds);
  {setup video}
  SetCharWidthTo8;
  SetDualFonts;
  clear;
end;

destructor tgraf.done;
begin
  inherited done;
  {delete a graf-object}
  dec(grcount);
end;

procedure tgraf.SetState(AState: Word; Enable: Boolean);
var s:word;
begin
  {redraw, if an other is selected}
  s:=state and (sfactive or sfdragging);
  inherited setstate(astate,enable);
  if s <>(state and (sfactive or sfdragging)) then
    draw;
end;

procedure tgraf.draw;
var
  b:tdrawbuffer;
  x,y,t,col:byte; c:char;
begin
  hidemouse;
  col:=getcolor(1);
  {draw only if active and not dragging}
  if (not getstate(sfdragging)) and (getstate(sfactive) or (grcount<2)) then
  begin
    clear;
    for y:=0 to size.y-1 do
    begin
      for x:= 0 to size.x-1 do
        B[x]:=(x+y*size.x) or col shl 8;
      WriteLine(0, y, Size.X, 1, B);
    end;
    update(true);
  end
  else
  {draw nothing}
  begin
    movechar(b[0],#32,getcolor(2),size.x);
    WriteLine(0, 0, Size.X, size.y, B);
  end;
  showmouse;
end;

procedure tgraf.ChangeBounds(var Bounds: TRect);
var
  t:tpoint;
begin
  {redraw if size changed}
  t:=size;
  if (bounds.b.y-bounds.a.y)*(bounds.b.x-bounds.a.x)>255 then
    bounds.b.y:=bounds.a.y+256 div (bounds.b.x-bounds.a.x);
  inherited changeBounds(Bounds);
  if (T.x<>size.x) or (t.y<>size.y) then
    draw;
end;

function tgraf.GetPalette: PPalette;
const
  P: String[Length(Cgraf)] = Cgraf;
begin
  GetPalette := @P;
end;

procedure tgraf.update(const isdraw:boolean);
{dummy}
begin
end;

{-[ Clear The Pseudo-Graphics Window by Clearing Font Definition ]--------}
Procedure tgraf.Clear;
{by David Dahl}
Begin
     SetAccessToFontMemory;
     FillChar (MEM[$B800:$4000], 32 * 256, 0);
     SetAccessToTextMemory;
End;
{-[ Plot a Pixel in The Pseudo-Graphics Window ]--------------------------}
Procedure tgraf.PutPixel (Xin, Yin : Word; FG:Boolean);
{partially by David Dahl}
Var RealY,
    RealX      : Word;
Begin
     If (Xin > 0 ) AND (Yin > 0 ) AND
        (Xin < size.x*8) AND
        (Yin < size.y*16)
     Then
     Begin
          RealX := (Xin DIV 8) * 32;
          RealY := (Yin MOD 16) + ((Yin DIV 16) * (32 * size.x));
          SetAccessToFontMemory;
          if FG then
            MEM[$B800:$4000 + RealX + RealY] :=
              MEM[$B800:$4000 + RealX + RealY] OR (128 SHR (Xin MOD 8))
          else
            MEM[$B800:$4000 + RealX + RealY] :=
              MEM[$B800:$4000 + RealX + RealY] AND NOT (128 SHR (Xin MOD 8));
          SetAccessToTextMemory;
     End;
End;
{-[ Draw A Line ]---------------------------------------------------------}
{ OCTANT DDA Subroutine converted from the BASIC listing on pages 26 - 27 }
{ from the book _Microcomputer_Displays,_Graphics,_ And_Animation_ by     }
{ Bruce A. Artwick                                                        }
Procedure tgraf.PutLine (XStart, YStart, XEnd, YEnd : Word; FG:Boolean);
{by David Dahl}
Var StartX,
    StartY,
    EndX,
    EndY    : Word;
    DX,
    DY      : Integer;
    CNTDWN  : Integer;
    Errr    : Integer;
    Temp    : Integer;
    NotDone : Boolean;
Begin
     NotDone := True;
     StartX := XStart;
     StartY := YStart;
     EndX   := XEnd;
     EndY   := YEnd;
     If EndX < StartX Then
     Begin
          { Mirror Quadrants 2,3 to 1,4 }
          Temp   := StartX;
          StartX := EndX;
          EndX   := Temp;
          Temp   := StartY;
          StartY := EndY;
          EndY   := Temp;
     End;
     DX := EndX - StartX;
     DY := EndY - StartY;
     If DY < 0 Then
     Begin
          If -DY > DX Then
          Begin
               { Octant 7 Line Generation }
               CntDwn := -DY + 1;
               ERRR   := -(-DY shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY,FG);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Dec(StartY);
                         Inc(Errr, DX);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartX);
                              Inc(Errr, DY);
                         End;
                    End;
               End;
          End
          Else
          Begin
               { Octant 8 Line Generation }
               CntDwn := DX + 1;
               ERRR   := -(DX shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY, FG);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartX);
                         Dec(Errr, DY);
                         If Errr >= 0 Then
                         Begin
                              Dec(StartY);
                              Dec(Errr, DX);
                         End;
                    End;
               End;
          End;
     End
     Else If DY > DX Then
          Begin
               { Octant 2 Line Generation }
               CntDwn := DY + 1;
               ERRR   := -(DY shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY, FG);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartY);
                         Inc(Errr, DX);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartX);
                              Dec(Errr, DY);
                         End;
                    End;
               End;
          End
          Else
          { Octant 1 Line Generation }
          Begin
               CntDwn := DX + 1;
               ERRR   := -(DX shr 1);   {Fast Divide By 2}
               While NotDone do
               Begin
                    PutPixel (StartX, StartY, FG);
                    Dec (CntDwn);
                    If CntDwn <= 0
                    Then NotDone := False
                    Else
                    Begin
                         Inc(StartX);
                         Inc(Errr, DY);
                         If Errr >= 0 Then
                         Begin
                              Inc(StartY);
                              Dec(Errr, DX);
                         End;
                    End;
               End;
          End;
End;
{-[ Draw A Circle ]-----------------------------------------------------}
{ Algorithm based on the Pseudocode from page 83 of the book _Advanced  }
{ Graphics_In_C_ by Nelson Johnson                                      }
Procedure tgraf.PutCircle (XCoord, YCoord, Radius : Integer; FG : Boolean);
{by David Dahl}
Var   d     : Integer;
      X, Y  : Integer;
    Procedure Symmetry (xc, yc, x, y : integer);
    Begin
         PutPixel ( X+xc,  Y+yc, FG);
         PutPixel ( X+xc, -Y+yc, FG);
         PutPixel (-X+xc, -Y+yc, FG);
         PutPixel (-X+xc,  Y+yc, FG);
         PutPixel ( Y+xc,  X+yc, FG);
         PutPixel ( Y+xc, -X+yc, FG);
         PutPixel (-Y+xc, -X+yc, FG);
         PutPixel (-Y+xc,  X+yc, FG);
    End;
Begin
     x := 0;
     y := abs(Radius);
     d := 3 - 2 * y;
     While (x < y) do
     Begin
          Symmetry (XCoord, YCoord, x, y);
          if (d < 0) Then
             inc(d, (4 * x) + 6)
          else
          Begin
               inc (d, 4 * (x - y) + 10);
               dec (y);
          End;
          inc(x);
     End;
     If x = y then
        Symmetry (XCoord, YCoord, x, y);
End;
{-[ Draw A Rectangle ]----------------------------------------------------}
Procedure tgraf.PutRectangle (X1, Y1, X2, Y2 : Word; FG : Boolean);
{by David Dahl}
Begin
     { Draw Top Of Box }
     PutLine (X1, Y1, X2, Y1, FG);
     { Draw Right Side Of Box }
     PutLine (X2, Y1, X2, Y2, FG);
     { Draw Left Side Of Box }
     PutLine (X1, Y1, X1, Y2, FG);
     { Draw Botton Of Box }
     PutLine (X1, Y2, X2, Y2, FG);
End;

Constructor TClock.Init(var Bounds:TRect);
var S,HS:Word;
begin
  inherited Init(Bounds);
  GetTime(Hours,Mins,S,HS);
end;

procedure TClock.update;
var H,M,S,HS:Word;
X1,Y1,X2,Y2,Xm,Ym,
Xd,Yd,xd2,yd2,DX,DY,R:Integer;
sec,si,co:real;

 procedure PtrLine(Part,DX,DY:Integer;
 var Xd,Yd:Integer);
 begin
    sec:=(pi*2/60)*part;
    xd:=round(xm+sin(sec)*(xm-dx));
    yd:=round(ym-cos(sec)*(ym-dy));
 end;

begin
  X1:=2;
  X2:=Size.X*8-2;
  Y1:=2;
  Y2:=Size.Y*16-2;
  Xm:=(X1+X2)DIV 2;
  Ym:=(Y1+Y2)DIV 2;
  DX:=(X2-X1)DIV 32;
  DY:=(Y2-Y1)DIV 32;
  if isdraw then
  begin
    {the face}
    hidemouse;
    for R:=0 to 59 do
    begin
      sec:=(pi*2/60)*r;
      si:=sin(sec); co:=cos(sec);
      if r mod 5 =0 then
      begin
        xd:=round(xm+si*(xm-2*dx));
        yd:=round(ym-co*(ym-2*dy));
      end
      else
      begin
        xd:=round(xm+si*(xm-dx));
        yd:=round(ym-co*(ym-dy));
      end;
      xd2:=round(xm+si*x2/2);
      yd2:=round(ym-co*y2/2);
      putline(xd,yd,xd2,yd2,True);
    end;
    showmouse;
  end;
  GetTime(H,M,S,HS);
  if(S<>Secs)OR(M<>Mins)
  OR(H<>Hours)then
  begin
    {the hand}
    hidemouse;

    DX:=(X2-X1)DIV 16;
    DY:=(Y2-Y1)DIV 16;
    PtrLine(Secs,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,False);
    PtrLine(S,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,True);

    DX:=(X2-X1)DIV 8;
    DY:=(Y2-Y1)DIV 8;
    PtrLine(Mins,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,False);
    PtrLine(M,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,True);

    DX:=(X2-X1)DIV 4;
    DY:=(Y2-Y1)DIV 4;
    PtrLine(Hours MOD 12*5,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,False);
    PtrLine(H MOD 12*5,DX,DY,Xd,Yd);
    PutLine(Xm,Ym,Xd,Yd,True);

    showmouse;

    Hours:=H;
    Mins:=M;
    Secs:=S;
  end;
end;


constructor tgrafwin.Init(var Bounds: TRect; ATitle: TTitleStr;
ANumber:Integer); begin inherited init(bounds,atitle,anumber);
getextent(bounds); {graf^.growmode:=gfgrowhix or gfgrowhiy;} end;

procedure tgrafwin.insertgraf(agraf:pgraf);
var bounds:trect;
begin
  graf:=agraf;
  getextent(bounds);
  bounds.grow(-1,-1);
  graf^.changebounds(bounds);
  insert(graf);
end;

procedure tgrafwin.ChangeBounds(var Bounds: TRect);
var t:trect;
begin
  inherited changeBounds(Bounds);
  getextent(t);
  t.grow(-1,-1);
  if graf<>nil then
    graf^.changeBounds(t);
  redraw;
end;

end.

program grafwi_d;

{****************************************************************************}
{**                                                                        **}
{**                             GRAFWIN (DEMO)                             **}
{**                                                                        **}
{**                  Grafics in Turbo-Vision's Textmode                    **}
{**                                                                        **}
{**               This program and source are PUBLIC DOMAIN                **}
{**                                                                        **}
{****************************************************************************}
{**                                                                        **}
{** by Stefan Michel (2:2490/1145.6)                                       **}
{**                                                                        **}
{** Fontmanipulations by David Dahl (1:272/38.0)                           **}
{**                                                                        **}
{****************************************************************************}
{**                                                                        **}
{** This example uses a second font as a pseudo-graphics window.           **}
{** This program requires VGA.                                             **}
{**                                                                        **}
{****************************************************************************}

uses dos,objects,drivers,views,app,grafwin,msgbox;

type
  tmyapp=object(tapplication)
    grafclock:pclock;
    constructor init;
    procedure idle; virtual;
  end;

constructor tmyapp.init;
var
  g:pgrafwin;
  r:trect;
begin
  inherited init;
  r.assign(58,1,78,10);
  new(g,init(r,'Clock',0));
  grafclock:=new(pclock,init(r));
  g^.insertgraf(grafclock);
  desktop^.insert(g);
  showmouse;
  messagebox(^c'Yes, this is textmode!',nil,mfinformation+mfokbutton);
  messagebox(^c'GRAFWIN (c) 1994 by'^m^c'Stefan Michel'^m^c'Irisstraße 12'+
             ^m^c'D-90542 Brand',nil,mfinformation+mfokbutton);
end;

procedure tmyapp.idle;
begin
  inherited idle;
  grafclock^.update(false);
end;

var
  a:tmyapp;
begin
  setvideomode(smco80);
  a.init;
  a.run;
  a.done;
  setvideomode(smco80);
end.

