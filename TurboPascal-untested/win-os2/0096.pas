
            (***************************************************)
            (*                 The Color Window                *)
            (*-------------------------------------------------*)
            (*  Copyright (c) 1995-`97 UNIVERSAL SOFTWARE Inc  *)
            (*               All Rights Reserved               *)
            (***************************************************)

{ example program at the end !! }

unit ColorWin;

{$S-}

INTERFACE

uses
 WinTypes,
 WinProcs,
 oWindows;

(************************************************************)
(****************** TpCrt types, consts, vars ***************)
(************************************************************)

type
 { the color window object }
 pColorWin=^tColorWin;
 tColorWin=object(tWindow)
  ScreenSize:tPoint;
  CharBuffer:pChar;
  AttrBuffer:pChar;
  TextAttr:byte;
  TextChar:char;
  CharSize:tPoint;
  CharAscent:integer;
  Range:tPoint;        { scrollbar ranges }
  Origin:tPoint;       { client area origin }
  ClientSize:tPoint;   { client area dimensions }
  { colorwin methods }
  procedure Byte2bkRgb(c:byte; var bkRGB:tColorRef);
  procedure Byte2fgRgb(c:byte; var fgRGB:tColorRef);
  procedure Byte2rgb(c:byte; var bkRGB:tColorRef; var fgRGB:tColorRef);
  constructor Init(AParent:pWindowsObject; aTitle:pChar);
  destructor Done; virtual;
  procedure SetupWindow; virtual;
  function GetClassName: pChar; virtual;
  procedure GetWindowClass(var aWndClass: tWndClass); virtual;
  procedure wmSize(var Msg:tMessage); virtual wm_First+wm_Size;
  {---}
  function GetNewPos(Action:word; Pos,Page,_Range, Thumb:integer):integer;
  procedure wmVScroll(var Msg:tMessage); virtual wm_First+wm_VScroll;
  procedure wmHScroll(var Msg:tMessage); virtual wm_First+wm_HScroll;
  {---}
  procedure SetScrollBars;
  function CharPtr(X,Y:integer):pChar;
  function AttrPtr(X,Y:integer):pChar;
  procedure Paint(PaintDC:hDC; var PS:tPaintStruct); virtual;
  procedure ClrScr;
  {\-clear current window}
  procedure ScrollTo(X,Y:integer);
  procedure FastWrite(St:string; Row,Col,_Attr:byte);
  {\-write St at Row,Col in Attr (video attribute)}
  procedure FastFill(Number:word; Ch:char; Row,Col,_Attr:byte);
  {\-fill Number chs at Row,Col in Attr (video attribute)}
  procedure FastCenter(St:string; Row,_Attr:byte);
  {\-write St centered on window Row in Attr (video attribute)}
 end;

IMPLEMENTATION

{ Double word record }
type
 LongRec=record
  Lo,Hi:integer;
 end;

const
 vgaColor:array[0..15] of tColorRef=(
  $00000000,   { Black }
  $00800000,   { Dark Cyan }
  $00008000,   { Dark Green}
  $00808000,   { Dark Blue }
  $00000080,   { Dark red }
  $00800080,   { Dark violet }
  $00008080,   { Brown }
  $00C0C0C0,   { light Gray }
  $00808080,   { Dark Gray }
  $00FF0000,   { light blue }
  $0000FF00,   { light green }
  $00FFFF00,   { Blue }
  $000000FF,   { light red }
  $00FF00FF,   { violet }
  $0000FFFF,   { yellow }
  $00FFFFFF    { White }
 );

type
 BufPtr=^BufferArray;
 BufferArray=array[0..MaxInt] of char;

function Min(X,Y:integer):integer;
{Return the smaller of two integer values}
begin
 if X <Y then Min:=X else Min:=Y;
end;

function Max(X,Y:integer):integer;
{Return the larger of two integer values}
begin
  if X >Y then Max:=X else Max:=Y;
end;

(*** colorwin ***)
constructor tColorWin.Init(aParent:pWindowsObject; aTitle:pChar);
begin
 inherited Init(aParent,aTitle);
 Attr.Style:=Attr.Style or ws_HScroll or ws_VScroll or cs_ByteAlignClient;
             {ws_Border or ws_Child or ws_Visible or
             ws_HScroll or ws_VScroll or
             cs_ByteAlignClient;}
 with ScreenSize do begin
  X:=80;  { screen width \ in chars }
  Y:=25;  { screen height/          }
  TextAttr:=$03;
  TextChar:='*';
  CharSize.X:=0;
  CharSize.Y:=0;
  CharAscent:=0;
  Origin.X:=0;
  Origin.Y:=0;
  Range.X:=0;
  Range.Y:=0;
  GetMem(CharBuffer,(ScreenSize.X*ScreenSize.Y)+1);
  GetMem(AttrBuffer,(ScreenSize.X*ScreenSize.Y)+1);
  FillChar(CharBuffer^,ScreenSize.X*ScreenSize.Y,TextChar);
  FillChar(AttrBuffer^,ScreenSize.X*ScreenSize.Y,char(TextAttr));
 end;
end;

destructor tColorWin.Done;
begin
 with ScreenSize do begin
  FreeMem(CharBuffer, X*Y);
  FreeMem(AttrBuffer, X*Y);
 end;
 inherited Done;
end;

procedure tColorWin.SetupWindow;
var
 DC:hDC;
 Metrics:tTextMetric;

begin
 inherited SetupWindow;
 DC:=GetDC(hWindow);
 SelectObject(DC,GetStockObject(System_Fixed_Font));
 GetTextMetrics(DC,Metrics);
 with Metrics, CharSize  do begin
  X:=tmMaxCharWidth;
  Y:=tmHeight+tmExternalLeading;
  CharAscent:=tmAscent;
 end;
 DeleteDC(DC);
 SetScrollRange(hWindow,sb_Horz,0,ScreenSize.X-1,false);
 SetScrollRange(hWindow,sb_Vert,0,ScreenSize.Y-1,false);
end;

function tColorWin.GetClassName:pChar;
begin
 GetClassName:='ColorWin';
end;

procedure tColorWin.GetWindowClass(var aWndClass:tWndClass);
begin
 inherited GetWindowClass(aWndClass);
 aWndClass.hIcon:=LoadIcon(0,idi_Application);
end;

procedure tColorWin.wmSize(var Msg:tMessage);
var
 x,y:integer;

begin
 with Msg do begin
  x:=LoWord(Msg.lParam);
  y:=HiWord(Msg.lParam);
 end;
 ClientSize.X:=X div CharSize.X;
 ClientSize.Y:=Y div CharSize.Y;
 Range.X:=Max(0,ScreenSize.X-ClientSize.X);
 Range.Y:=Max(0,ScreenSize.Y-ClientSize.Y);
 Origin.X:=Min(Origin.X, Range.X);
 Origin.Y:=Min(Origin.Y, Range.Y);
 SetScrollBars;
end;

function tColorWin.CharPtr(X,Y:integer):pChar;
{Return pointer to the Char at (X,Y) in the screen buffer}
begin
 CharPtr:=@CharBuffer[Y*ScreenSize.X+X];
end;

function tColorWin.AttrPtr(X,Y:integer):pChar;
{Return pointer to the Attr at (X,Y) in the screen buffer}
begin
 AttrPtr:=@AttrBuffer[Y*ScreenSize.X+X];
end;

procedure tColorWin.SetScrollBars;
{Update scroll bars}
begin
 SetScrollRange(hWindow, sb_Horz, 0, Max(0,Range.X), false);
 SetScrollPos(hWindow, sb_Horz, Origin.X, true);
 SetScrollRange(hWindow, sb_Vert, 0, Max(0,Range.Y), false);
 SetScrollPos(hWindow, sb_Vert, Origin.Y, true);
end;

procedure tColorWin.ScrollTo(X,Y:integer);
{Scroll window to given origin}
begin
 X:=Max(0,Min(X,Range.X));
 Y:=Max(0,Min(Y,Range.Y));
 if (X <>Origin.X) or (Y <>Origin.Y) then begin
  if X <>Origin.X then SetScrollPos(hWindow,sb_Horz,X,true);
  if Y <>Origin.Y then SetScrollPos(hWindow,sb_Vert,Y,true);
  ScrollWindow(hWindow,(Origin.X-X)*CharSize.X,(Origin.Y-Y)*CharSize.Y, nil,nil);
  Origin.X:=X;
  Origin.Y:=Y;
  UpdateWindow(hWindow);
 end;
end;

procedure tColorWin.Byte2bkRgb(c:byte; var bkRGB:tColorRef);
begin
 bkRGB:=vgaColor[c shr 4];
end;

procedure tColorWin.Byte2fgRgb(c:byte; var fgRGB:tColorRef);
begin
 fgRGB:=vgaColor[c and $F];
end;

procedure tColorWin.Byte2rgb(c:byte; var bkRGB:tColorRef; var fgRGB:tColorRef);
begin
 bkRGB:=vgaColor[c shr 4];
 fgRGB:=vgaColor[c and $F];
end;

procedure tColorWin.ClrScr;
{Clear the screen}
var
 _y:integer;

begin
 FillChar(CharBuffer^,ScreenSize.X*ScreenSize.Y,TextChar);
 FillChar(AttrBuffer^,ScreenSize.X*ScreenSize.Y,char(TextAttr));
 Longint(Origin):=0;
 SetScrollBars;
 InvalidateRect(hWindow,nil,false {true});
 UpdateWindow(hWindow);
end;

procedure tColorWin.Paint(PaintDC:hDC; var PS:tPaintStruct);
{wm_Paint message handler}
var
 X1,X2,Y1,Y2:integer;
 bkRGB,fgRGB:tColorRef;
 i:integer;

begin
 SelectObject(PaintDC, GetStockObject(System_Fixed_Font));
 {---}
 MoveTo(PaintDC, ScreenSize.X*CharSize.X,0);
 LineTo(PaintDC, ScreenSize.X*CharSize.X,ScreenSize.Y*CharSize.Y);
 LineTo(PaintDC, 0,ScreenSize.Y*CharSize.Y);
 X1:=Max(0, PS.rcPaint.left div CharSize.X+Origin.X);
 X2:=Min((PS.rcPaint.right+CharSize.X-1) div CharSize.X+Origin.X,ScreenSize.X);
 Y1:=Max(0, PS.rcPaint.top div CharSize.Y+Origin.Y-1);
 Y2:=Min((PS.rcPaint.bottom+CharSize.Y-1) div CharSize.Y+Origin.Y,ScreenSize.Y);
 while Y1 <Y2 do begin
  for i:=X1 to X2 do begin
   Byte2rgb(byte(AttrPtr(i,Y1)^),bkRGB,fgRGB);
   SetTextColor(PaintDC,fgRGB);
   SetBkColor(PaintDC,bkRGB);
   if i <ScreenSize.X then
    TextOut(PaintDC,(i-Origin.X)*CharSize.X,(Y1-Origin.Y)*CharSize.Y,CharPtr(i,Y1), 1);
  end;
  Inc(Y1);
 end;
end;

procedure tColorWin.FastWrite(St:string; Row,Col,_Attr:byte);
begin
 Move(St[1],CharPtr(pred(Col),pred(Row))^,Length(St));
 FillChar(AttrPtr(pred(Col),pred(Row))^,Length(St),char(_Attr));
end;

procedure tColorWin.FastFill(Number:word; Ch:char; Row,Col,_Attr:byte);
begin
 if Number >(ScreenSize.X*ScreenSize.Y-(Row*ScreenSize.X+Col)) then
  Number:=ScreenSize.X*ScreenSize.Y-(Row*ScreenSize.X+Col);
 FillChar(CharPtr(pred(Col),pred(Row))^,Number,Ch);
 FillChar(AttrPtr(pred(Col),pred(Row))^,Number,_Attr);
end;

procedure tColorWin.FastCenter(St:string; Row,_Attr:byte);
var
 sL:byte absolute St;

begin
 if sL >succ(ScreenSize.X-ScreenSize.X) then
  sL:=succ(ScreenSize.X-ScreenSize.X);
 FastWrite(St,ScreenSize.Y+Row,ScreenSize.X+
  succ((succ(ScreenSize.X-ScreenSize.X)-sL) shr 1),_Attr);
end;

function tColorWin.GetNewPos(Action:word; Pos,Page,_Range, Thumb:integer):integer;
begin
 case Action of
  sb_LineUp: GetNewPos:=Pos-1;
  sb_LineDown: GetNewPos:=Pos+1;
  sb_PageUp: GetNewPos:=Pos-Page;
  sb_PageDown: GetNewPos:=Pos+Page;
  sb_Top: GetNewPos:=0;
  sb_Bottom: GetNewPos:=_Range;
  sb_ThumbPosition: GetNewPos:=Thumb;
 else
  GetNewPos:=Pos;
 end;
end;

procedure tColorWin.wmHScroll(var Msg:tMessage);
{wm_HScroll handler}
var
 X:integer;

begin
 X:=Origin.X;
 X:=GetNewPos(Msg.wParam, X, ClientSize.X div 2, Range.X, Msg.lParamLo);
 ScrollTo(X, Origin.Y);
end;

procedure tColorWin.wmVScroll(var Msg:tMessage);
{wm_VScroll handler}
var
 Y:integer;

begin
 Y:=Origin.Y;
 Y:=GetNewPos(Msg.wParam, Y, ClientSize.Y, Range.Y, Msg.lParamLo);
 ScrollTo(Origin.X, Y);
end;

end.

{ ----------------------   CUT  ----------------------- }

              (************************************************)
              (* The Demostration Module for tColorWin object *)
              (************************************************)

uses
 WinTypes,
 WinProcs,
 oWindows,
 ColorWin;     {-tColorWin object}

const
 AppName:pChar='tColorWin demo';
 CaptionText:pChar='Color Window test..';

 {===[ This application does nothing but shows you ]===}
 {===[ how to use tColorWin object                 ]===}

type
 tMyApp=object(tApplication)
  procedure InitMainWindow; virtual;
 end;

 pMyWin=^tMyWin;
 tMyWin=object(tColorWin)
  procedure SetupWindow; virtual;
 end;

procedure tMyWin.SetupWindow;
var
 i:byte;

begin
 inherited SetupWindow;
 for i:=1 to 15 do
  FastWrite('Test string for check ColorWin. Don`t panic! ;-)',i,2,i);
end;

procedure tMyApp.InitMainWindow;
begin
 MainWindow:=New(pMyWin,Init(nil,CaptionText));
end;

var
 MyApp:tMyApp;

begin
 MyApp.Init(AppName);
 MyApp.Run;
 MyApp.Done;
end.
