{************************************************}
{                                                }
{   UNIT XVIEWS   A collection of new Views      }
{   Copyright (c) 1994-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   EMail: wellige@itk.de                        }
{                                                }
{************************************************}

(*
  Some few words on this unit:
  ----------------------------

   - This units works fine with Turbo Pascal 6 or higher. If you use
     TP/BP 7 you can use the "inherited" command as shown in the
     comment lines on each line where it is possible.

   - This unit defines first of all a basic object (TXView) for status views
     which are updateable via messages (send from the applications Idle
     methode). All inheritances only have to override the abstract methode
     UPDATE and place the information to display in a string. In this manner
     there are a ClockView, a DateView and an HeapView as examples
     implemented. The usage of these objects (TClock, TDate and THeap) will
     be demonstrated in the programs XTEST1 and XTEST2.

   - There is also a 7-segment view implemented in this unit (T7Segment)
     capable of displaying all numbers from 0 to 9 and the characters
     "A" "b" "c" "d" "E" "F" and "-". The usage of this object is also
     demonstrated in this unit by the object TBigClock which is a clock
     in "hh:mm:ss" format. How to use this clock is demonstrated in the
     XTEST3 program.
*)

unit xviews;

interface

uses dos, objects, drivers, views;

const
  cmGetData        = 5000;   { Request data string from TXView object }
  cmChange7Segment = 5001;   { Set new value to display in T7Segment  }
  cmChangeBack     = 5002;   { Change Background of T7Segment         }

type
  PXView = ^TXView;                  (* Basic status view object  *)
  TXView = object(TView)
      Data: string;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Update; virtual;
    procedure Draw; virtual;
    function  GetString: PString; virtual;
  end;

  PClock = ^TClock;                   (* Displays current time           *)
  TClock = object(TXView)
    procedure Update; virtual;
  end;

  PDate = ^TDate;                     (* Displays current date           *)
  TDate = object(TXView)
    procedure Update; virtual;
  end;

  PHeap = ^THeap;                     (* Displays free bytes on the heap *)
  THeap = object(TXView)
    procedure Update; virtual;
  end;

  PInfoView = ^TInfoView;             (* Show all "actual" datas         *)
  TInfoView = object(TView)
    procedure Draw; virtual;
  end;

  PInfoWindow = ^TInfoWindow;         (* Window holding TInfoView        *)
  TInfoWindow = object(TWindow)
    constructor Init(var Bounds: TRect);
  end;

  TSegment = array[1..13] of byte;    (* Buffer for T7Sgement            *)

  P7Segment = ^T7Segment;             (* 7 Segment View (7x5)            *)
  T7Segment = object(TView)
      Segment: TSegment;
      Number: word;
        { 16 -> segm_ = "-",  >=17 -> segmBlank = " " }
      BackGround: boolean;
        { not active segment visible (gray) ? }
    constructor Init(Top: TPoint; ABackGround: boolean; ANumber: word);
      { Top: upper left corner of segment
        ABackGround: not active segments visible (gray) ?
        ANumber: default value to be displayed }
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
    procedure UpdateSegments;
  end;

  PBigClock = ^TBigClock;
  TBigClock = object(TGroup)
      Seg: Array[1..6] of P7Segment;
    constructor Init(Top: TPoint; BackGround: boolean);
      { Top: upper left corner of clock
        BackGround: will passed to each T7Segment: not active segments
                    visible (gray) ? }
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Update;
  end;

const
  Date : PDate  = nil;
  Clock: PClock = nil;
  Heap : PHeap  = nil;

implementation


{***********************************************************************}
{**                             TXView                                **}
{***********************************************************************}

procedure TXView.HandleEvent(var Event: TEvent);
begin
  { TP/BP7: inherited HandleEvent(Event); }
  TView.HandleEvent(Event);
  if Event.What = evBroadCast then
    if Event.Command = cmGetData then
    begin
      ClearEvent(Event);
      Event.InfoPtr:= GetString;
    end;
end;

procedure TXView.Update;
begin
  Abstract;
end;

procedure TXView.Draw;
var
  Buf: TDrawBuffer;
  C: word;
begin
  C:= GetColor(2);  (* Application -> "Menu normal"  *)
                    (* Window      -> "Frame active" *)
  MoveChar(Buf, ' ', C, Size.X);
  MoveStr(Buf, Data, C);
  WriteLine(0, 0, Size.X, 1, Buf);
end;

function TXView.GetString: PString;
begin
  GetString:= PString(@Data);
end;


{***********************************************************************}
{**                             TClock                                **}
{***********************************************************************}

procedure TClock.Update;
type
  Rec = record
    hh, mm, ss: longint; end;
var
  DataRec: Rec;
  hh, mm, ss, hs: word;
begin
  GetTime(hh, mm, ss, hs);
  DataRec.hh:= hh;
  DataRec.mm:= mm;
  DataRec.ss:= ss;
  FormatStr(Data, '%2d:%2d:%2d', DataRec);
  if hh < 10 then Data[1]:= '0';
  if mm < 10 then Data[4]:= '0';
  if ss < 10 then Data[7]:= '0';
  DrawView;
end;


{***********************************************************************}
{**                             TDate                                 **}
{***********************************************************************}

procedure TDate.Update;
type
  Rec = record
    dd, mm, yy: longint; end;
var
  DataRec: Rec;
  dd, mm, yy, dw: word;
begin
  GetDate(yy, mm, dd, dw);
  DataRec.dd:= dd;
  DataRec.mm:= mm;
  DataRec.yy:= yy;
  FormatStr(Data, '%2d.%2d.%4d', DataRec);
  if dd < 10 then Data[1]:= '0';
  if mm < 10 then Data[4]:= '0';
  DrawView;
end;


{***********************************************************************}
{**                             THeap                                 **}
{***********************************************************************}

procedure THeap.Update;
var
  Mem: longint;
begin
  Mem:= MemAvail;
  FormatStr(Data, '%d Bytes', Mem);
  DrawView;
end;


{***********************************************************************}
{**                            TInfoView                              **}
{***********************************************************************}

procedure TInfoView.Draw;
var
  Buf: TDrawBuffer;
  C: word;
  s: string;
begin
  C:= GetColor(2);  (* Application -> "Menu normal"  *)
                    (* Window      -> "Frame active" *)
  s:= 'Date   : ';
  if assigned(Date) then
    s:= s + PString(Message(Date, evBroadCast, cmGetData, nil))^ else
    s:= s + 'not accessable';
  MoveChar(Buf, ' ', C, Size.X);
  MoveStr(Buf, s, C);
  WriteLine(0, 0, Size.X, 1, Buf);

  s:= 'Time   : ';
  if assigned(Clock) then
    s:= s + PString(Message(Clock, evBroadCast, cmGetData, nil))^ else
    s:= s + 'not accessable';
  MoveChar(Buf, ' ', C, Size.X);
  MoveStr(Buf, s, C);
  WriteLine(0, 1, Size.X, 1, Buf);

  s:= 'Memory : ';
  if assigned(Heap) then
    s:= s + PString(Message(Heap, evBroadCast, cmGetData, nil))^ else
    s:= s + 'not accessable';
  MoveChar(Buf, ' ', C, Size.X);
  MoveStr(Buf, s, C);
  WriteLine(0, 2, Size.X, 1, Buf);
end;


{***********************************************************************}
{**                           TInfoWindow                             **}
{***********************************************************************}

constructor TInfoWindow.Init(var Bounds: TRect);
var R: TRect;
begin
  { TP/BP7: inherited Init(Bounds, 'Systeminfo', 0); }
  TWindow.Init(Bounds, 'Systeminfo', 0);
  Palette:= wpCyanWindow;
  Flags:= Flags and not (wfClose + wfZoom + wfGrow);
  GetExtent(R);
  R.Grow(-2, -2);
  Insert(New(PInfoView, Init(R)));
end;


{***********************************************************************}
{**                            T7Segment                              **}
{***********************************************************************}

const              { 1  2  3  4  5  6  7  8  9  A  B  C  D }
  segm0: TSegment = (1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1);
  segm1: TSegment = (0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1);
  segm2: TSegment = (1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1);
  segm3: TSegment = (1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1);
  segm4: TSegment = (1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1);
  segm5: TSegment = (1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1);
  segm6: TSegment = (1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1);
  segm7: TSegment = (1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1);
  segm8: TSegment = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
  segm9: TSegment = (1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1);
  segmA: TSegment = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1);
  segmB: TSegment = (1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1);
  segmC: TSegment = (1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1);
  segmD: TSegment = (0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1);
  segmE: TSegment = (1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1);
  segmF: TSegment = (1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0);
  segm_: TSegment = (0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0);
  segmBlank: TSegment =
                    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);


constructor T7Segment.Init(Top: TPoint; ABackGround: boolean; ANumber: word);
var R: TRect;
begin
  R.Assign(Top.X, Top.Y, Top.X+7, Top.Y+5);
  { TP/BP7: inherited Init(R); }
  TView.Init(R);
  BackGround:= ABackGround;
  Number:= ANumber;
  UpdateSegments;
end;

procedure T7Segment.HandleEvent(var Event: TEvent);
begin
  { TP/BP7: inherited HandleEvent(Event); }
  TView.HandleEvent(Event);
  if Event.What = evBroadCast then
    case Event.Command of
      cmChange7Segment: begin
                          Number:= Word(Event.InfoPtr^);
                          UpdateSegments;
                          DrawView;
                          ClearEvent(Event);
                        end;
      cmChangeBack    : begin
                          if BackGround then BackGround:= false
                                        else BackGround:= true;
                          DrawView;
                        end;
    end;
end;

procedure T7Segment.Draw;
var
  Buf: TDrawBuffer;
  Front, Back: byte;

  function SetColor(w: word; c: byte): word;
  begin
    w:= w and $00FF;
    w:= swap(w);
    w:= w or c;
    w:= swap(w);
    SetColor:= w;
  end;

  procedure SetBufColor(var B: TDrawBuffer; C: word);
  var i: integer;
  begin
    for i:= 0 to Size.X do
      Buf[i]:= SetColor(Buf[i], C);
  end;

begin
  if BackGround then Back:= $8 else Back:= $0;
  Front:= $F;

  { Segment 1,2,3 }
  SetBufColor(Buf, $0);
  MoveStr (Buf, ' ■■■■■', Back);
  if Segment[1] = 1 then
    Buf[1]:= SetColor(Buf[1], Front);
  if Segment[2] = 1 then begin
    Buf[2]:= SetColor(Buf[2], Front);
    Buf[3]:= SetColor(Buf[3], Front);
    Buf[4]:= SetColor(Buf[4], Front); end;
  if Segment[3] = 1 then
    Buf[5]:= SetColor(Buf[5], Front);
  WriteLine(0, 0, Size.X, 1, Buf);

  { Segment 4,5 }
  SetBufColor(Buf, $0);
  MoveStr (Buf, ' █   █', Back);
  if Segment[4] = 1 then
    Buf[1]:= SetColor(Buf[1], Front);
  if Segment[5] = 1 then
    Buf[5]:= SetColor(Buf[5], Front);
  WriteLine(0, 1, Size.X, 1, Buf);

  { Segment 6,7,8 }
  SetBufColor(Buf, $0);
  MoveStr (Buf, ' ■■■■■', Back);
  if Segment[6] = 1 then
    Buf[1]:= SetColor(Buf[1], Front);
  if Segment[7] = 1 then begin
    Buf[2]:= SetColor(Buf[2], Front);
    Buf[3]:= SetColor(Buf[3], Front);
    Buf[4]:= SetColor(Buf[4], Front); end;
  if Segment[8] = 1 then
    Buf[5]:= SetColor(Buf[5], Front);
  WriteLine(0, 2, Size.X, 1, Buf);

  { Segment 9,10 }
  SetBufColor(Buf, $0);
  MoveStr (Buf, ' █   █', Back);
  if Segment[9] = 1 then
    Buf[1]:= SetColor(Buf[1], Front);
  if Segment[10] = 1 then
    Buf[5]:= SetColor(Buf[5], Front);
  WriteLine(0, 3, Size.X, 1, Buf);

  { Segment 11,12,13 }
  SetBufColor(Buf, $0);
  MoveStr (Buf, ' ■■■■■', Back);
  if Segment[11] = 1 then
    Buf[1]:= SetColor(Buf[1], Front);
  if Segment[12] = 1 then begin
    Buf[2]:= SetColor(Buf[2], Front);
    Buf[3]:= SetColor(Buf[3], Front);
    Buf[4]:= SetColor(Buf[4], Front); end;
  if Segment[13] = 1 then
    Buf[5]:= SetColor(Buf[5], Front);
  WriteLine(0, 4, Size.X, 1, Buf);
end;

procedure T7Segment.UpdateSegments;
begin
  case Number of
    0:  Segment:= segm0;
    1:  Segment:= segm1;
    2:  Segment:= segm2;
    3:  Segment:= segm3;
    4:  Segment:= segm4;
    5:  Segment:= segm5;
    6:  Segment:= segm6;
    7:  Segment:= segm7;
    8:  Segment:= segm8;
    9:  Segment:= segm9;
    10: Segment:= segmA;
    11: Segment:= segmB;
    12: Segment:= segmC;
    13: Segment:= segmD;
    14: Segment:= segmE;
    15: Segment:= segmF;
    16: Segment:= segm_;
  else
    Segment:= segmBlank;
  end;
end;


{***********************************************************************}
{**                            TBigClock                              **}
{***********************************************************************}

type
  PBlackView = ^TBlackView;    (* black background for TBigClock *)
  TBlackView = object(TView)
    procedure Draw; virtual;
  end;

procedure TBlackView.Draw;
var
  Buf  : TDrawBuffer;
  Color: word;
  i    : integer;
begin
  Color:= $0F;
  for i:= 0 to Size.Y do
  begin
    MoveChar(Buf, ' ', Color, Size.X);
    if (i = 2) or (i = 4) then
    begin
      Buf[16]:= $0FFE;
      Buf[33]:= $0FFE;
    end;
    WriteLine(0, i, Size.X, 1, Buf);
  end;
end;


constructor TBigClock.Init(Top: TPoint; BackGround: boolean);
const
  XPos : Array [1..6] of word = (1, 8, 18, 25, 35, 42);
var
  R: TRect;
  P: TPoint;
  i: integer;
begin
  R.Assign(Top.X, Top.Y, Top.X+50, Top.Y+7);
  { TP/BP7: inherited Init(R); }
  TGroup.Init(R);

  R.Assign(0, 0, Size.X, Size.Y);
  Insert(new(PBlackView, Init(R)));

  for i:= 1 to 6 do
  begin
    P.X:= XPos[i]; P.Y:= 1;
    Seg[i]:= new(P7Segment, Init(P, BackGround, 0));
    insert(Seg[i]);
  end;
end;

procedure TBigClock.HandleEvent(var Event: TEvent);
var i: integer;
begin
  { TP/BP7: inherited HandleEvent(Event); }
  TGroup.HandleEvent(Event);
  if Event.What = evBroadCast then
    if Event.Command = cmChangeBack then
    begin
      for i:= 1 to 6 do
        Message(Seg[i], evBroadCast, cmChangeBack, nil);
    end;
end;

procedure TBigClock.Update;
var
  w, h, m, s, hs: word;
begin
  GetTime(h, m, s, hs);
  w:= h div 10;
  Message(Seg[1], evBroadCast, cmChange7Segment, @w); (* Hours   - 10^1 *)
  w:= h mod 10;
  Message(Seg[2], evBroadCast, cmChange7Segment, @w); (* Hours   - 10^0 *)
  w:= m div 10;
  Message(Seg[3], evBroadCast, cmChange7Segment, @w); (* Minutes - 10^1 *)
  w:= m mod 10;
  Message(Seg[4], evBroadCast, cmChange7Segment, @w); (* Minutes - 10^0 *)
  w:= s div 10;
  Message(Seg[5], evBroadCast, cmChange7Segment, @w); (* Seconds - 10^1 *)
  w:= s mod 10;
  Message(Seg[6], evBroadCast, cmChange7Segment, @w); (* Seconds - 10^0 *)
end;


end.

{ -------------------- DEMO -------------- CUT HERE ------------ }

program XTest1;

{ usage of TDate, TClock and THeap defined in Unit XVIEWS }

uses Drivers, Objects, App, Views, Menus, XViews;

const
  cmWindow = 1000;

type
  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    constructor Init;
    procedure Idle; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Window;
    procedure InitStatusLine; virtual;
  end;

constructor TMyApp.Init;
var R: TRect;
begin
  { TP/BP7: inherited Init; }
  TApplication.Init;

  GetExtent(R);
  R.A.X:= R.B.X - 11;
  R.A.Y:= R.B.Y - 1;
  Date:= New(PDate, Init(R));
  Insert(Date);

  GetExtent(R);
  R.A.X:= R.B.X - 9;
  R.B.Y:= R.A.Y + 1;
  Clock:= New(PClock, Init(R));
  Insert(Clock);

  GetExtent(R);
  R.A.X:= R.A.X + 1;
  R.B.X:= R.A.X + 20;
  R.B.Y:= R.A.Y + 1;
  Heap:= New(PHeap, Init(R));
  Insert(Heap);
end;

procedure TMyApp.Idle;
var Event: TEvent;
begin
  { TP/BP7: inherited Idle; }
  TApplication.Idle;
  Date^.Update;
  Clock^.Update;
  Heap^.Update;
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  { TP/BP7: inherited HandleEvent(Event); }
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmWindow : Window;
      end;
  end;
end;

procedure TMyApp.Window;
var
  P: PWindow;
  R: TRect;
begin
  Desktop^.GetExtent(R);
  P:= New(PWindow, Init(R, 'Memory-Eater', 0));
  P^.Options:= P^.Options or ofTileAble;
  Desktop^.Insert(P);
  Cascade;
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y:= R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit',               kbAltX,  cmQuit,
      NewStatusKey('~F3~ Open Window',           kbF3,    cmWindow,
      NewStatusKey('',                           kbAltF3, cmClose,
      nil))),
    nil)));
end;


var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.

{ -------------------- DEMO -------------- CUT HERE ------------ }
program XTest2;

{ usage of TInfoWindow defined in Unit XVIEWS }

uses Drivers, Objects, App, Views, XViews;

type
  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
      Info: PInfoWindow;
    constructor Init;
    procedure Idle; virtual;
  end;

constructor TMyApp.Init;
var R: TRect;
begin
  { TP/BP7: inherited Init; }
  TApplication.Init;

  R.Assign(0,0,1,1);
  Date:= New(PDate, Init(R));
  Date^.Hide;
  Insert(Date);

  Clock:= New(PClock, Init(R));
  Clock^.Hide;
  Insert(Clock);

  Heap:= New(PHeap, Init(R));
  Heap^.Hide;
  Insert(Heap);

  R.Assign(1,1,35,8);
  Info:= New(PInfoWindow, Init(R));
  Info^.Options:= Info^.Options or ofCentered;
  Insert(Info);
end;

procedure TMyApp.Idle;
var Event: TEvent;
begin
  { TP/BP7: inherited Idle; }
  TApplication.Idle;
  if assigned(Date) then Date^.Update;
  if assigned(Clock) then Clock^.Update;
  if assigned(Heap) then Heap^.Update;
  Info^.Redraw;
end;

var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
{ -------------------- DEMO -------------- CUT HERE ------------ }
program XTest3;

{ usage of TBigClock defined in Unit XVIEWS }

uses Drivers, Objects, App, Menus, Views, XViews;

const
  cmToggle = 1000;

type
  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
      BigClock: PBigClock;
    constructor Init;
    procedure InitStatusLine; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
  end;


constructor TMyApp.Init;
var P: TPoint;
begin
  { TP/BP7: inherited Init; }
  TApplication.Init;
  P.X:= 15; P.Y:= 9;
  BigClock:= new(PBigClock, Init(P, true));
  Insert(BigClock);
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y:= R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit',            kbAltX, cmQuit,
      NewStatusKey('~F2~ Toggle Background',  kbF2,   cmToggle,
      nil)),
    nil)));
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  { TP/BP7: inherited HandleEvent(Event); }
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    if Event.Command = cmToggle then
      Message(BigClock, evBroadCast, cmChangeBack, nil);
end;

procedure TMyApp.Idle;
var Event: TEvent;
begin
  { TP/BP7: inherited Idle; }
  TApplication.Idle;
  if assigned(BigClock) then BigClock^.Update;
end;


var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
