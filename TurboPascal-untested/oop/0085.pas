
{ NOTE : THE remainder of the units in this package are included in the
  XX3402 file listed below.  Follow the instructions to extract.


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

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-019818-110497--72--85-44774----TVSOURCE.ZIP--1-OF--5
I2g1--E++U+6+5qNPG7zQFtXnEA++5k7+++A++++Fp7-FYF3HIwiI23HfJJVPxgq2DoS6DzV
oWyl2xh6L5R-v4JMdfW--rUCB8t-ULuFePDAFGM3YbOZ-Tjjsp4IsaE7VVMHEDbsS5n5iyQH
5oyywTbvwC+Fjj27SyvWlKpwDETrybUnbGwQlB1Md0VUdPG53vzw0bx6MRgxYGce9P8pVEvj
kjbZtOVzSE590dXOk1raiQXkNNkP7FC98GE4DgPHuTppDDrDgrpDDUhhnKO9ullVp6DFO1Ww
Q94prKlZqcDPOHmzzirnWnrHzXkFyFWypYTzKRW5EMfzwxayExD1Uo8fH0QPQ8xJWVgp6L-f
o+1LhYRkgTMz8vLwomzuDFnHfIOLxmot04vQoWvFVkQ+NRG1mUriFVeJx8f468H31DL2SwHC
kkriFVeHFznGUnYDBvUP8GADxg6X4UC9VCMtyabgdX3mawUg6AkVH6g4K46a7C4Dw1hO8qE4
Rcr+ZR8dc1yC+PLmo2dcMu3EFZWV70EmVFFLEW8h2UC+2LxVszvCK0nACqyv2fYnk0Nt61fd
AQApcVmEEZGPwFLwQ1Nl-Ec47yBwC83GYHLltG91NnaMGK2vHIYzbBJZhLe9LGw43NCwWR6P
bfC-L54RpGTqa2W5ROo0OJ0VX2wjngUwxTHl0rd4ywu6jvIsKSSX0IYHngm6jZwTaULyc457
yiy7brbyYdrinIXTzKUO0olgLSF5a7aacgO8D6TJBgwfq+YXZXZGTNjOnZMUZEKyRacXd28v
DIuvaUR6eMrOCQa10U+wAIX3BHDtGS-Ltx5sxgz5EMcUULxOgDw2xcTXcBKyNkiqbWXHY3q6
4vwNpwgJJ4fXBVcyWyjZrDRgkRPnLr5Nar5NOzampz7ZfyL9rgnr2O6YtxgwgPtvE9fMnndf
jjUo-InsCWUxU6J2RpmraVjJF94uUaVlxvbJnzRF4Q2dmF8ueOebpOEBDO-f71FDRx9gXENn
hQAKPcveyuWAWGAiEnRJxTG7AUuIjbKS8CB+4S0KYjeYNAH-mh-+JHpxcaG-obT92mI9Z+3i
83DAYufncSirPuIJCHlUJKUo-hB7rI77uW-bBo6Q5b+ZXSyeiwGiaPfFMcQOfi0MXvwgWmz9
H-lDUduRYuOBlAf7lFplsedzR5E27prW0ZztHBQgMtXhTNInDJRofnp5dpd5-CyXSpzYZic8
Ph+WhrsHTIDwtR7dpbi-jjQgXSty02TVxwFchbbBsx7csjzsYqBMDB+zALkPvfKkaAjCQLCB
+KehxDWsJzBAOHMrKGRER9i+iT4rE5hwS5s9yfxMfUlun+Cp2Csxc9nz+J-9+kEI++6+0+1n
WKwWMjLCLvI6++0Z8E++0k+++2RGEINDEYciI23HrJVjQxfA2Lzj4Ly5bPkd77UaY4YaxiCq
XYBgCfNVP76wSRCNEnfUbUURpIY4XOTTjPRv7yY+UQ0VGORYld5iRbyvhzxpHmzrzDrvyCU7
xjlNbgxrrE3QrJxwubrsVrvhxTckXhVg6XkKU-nykPpMfT7QmZYOWT2YVddLVnTjrvwxSTwC
VWYAt-GywW+EMvv8wp449CMyA+KTvXiRflTrbIfRbbCSLVGfOQ6b+MSr1LXvhhJudqJ5wHE7
zENQRStj9yuyfT-oHauN02tVPZHzisWzBrpyMBqSsRDXcxf9smC+-nbZAC7naAj6Jm-1W0R0
EF88y-HrHvPw22JfQ+81X2IVn5Q36l3ma6hs+cAY4YfcAsIyzkj600POinleEbQ2eIkUINlE
++PxDrzcknhOxJW6CpcN1Wx2e-a2xj+9wCFomY7mhNf6SEU03QsEQ7S5AEFOD7q3Aqx0Pn1L
2-l213fHaJF81+DSn+xk2EHElKWRwbUWhFoav721ooWQeNWoa946HKASkNTiEzT1HOQ7LmQw
p6dejsNXek-1VPGYK51T+76pWNQXgrvF15CK8jVoQTDE+GKpbY5e506z9TUgNheIDB+8nMJK
QQUVaTYMukrGeG+pqIFI3WOIAR9vEgo0Zb9TudgcfOrFIwIgx1X62PtO+8ZBdKpjAR+1xfUk
iDzQUJVaU0EzNu6rtIKQVoob8fWp7sS5uxtLw0AqJoj0WAx9cUWxdhoWMe2LoQ4CIyqq7kAN
vG9fijil+nsDhA3ROOB6HVpSf0YFFtLE609CfIwoEyNx5oQmoNeEr577hvoj5NX8FptmeY98
FDV4F+Cw0Ej5FPVEL9abRVIe3rbNurzH8gr2YYnh3uMRDi3FUPRe8NBX2km7oMVfYqfT1rYw
Fmo73FKU2kaZCJZgJbp7cOEDkFqbK9Z1Dd6FnsypR8+arAaM4mFfSwcx2O8B9+vayZm4Tu7M
NQC+op2wXmhZQZw4zchAaV8cgp+aMlWO6QoHnmQpYGTWSLjNMADfWvifnaLjdbRjJCR4a6ok
BlyoyodwFXY7-U+Zqm7+IJsiwecnuDQSh4dl2cJe8Skx8GBTV0lKw1iVTHAe93aOmaKV3dKb
8NdSanQoKNj-Q8XltfWdNLalpXnUxEl7Il4XBf5Kq2g03dg8Gt4XXG-4y8dB4p3No7v0tLXX
YMk3mUypOgdmYCt1xyt9hzBJKtZvroa1sdHOouAYo8ty33GjPIXPsxU2ksv034KV1zdDFCTY
zdVfawJ9mcpY22X89Yz9JeRK6zhv1STfsckEVynYXGOPAOJkrj+WOSAos0CAHtzgJeGRWpzC
O4ORfNkbfJ9CN1PHVxoigtlH4q21dzIE1EKqiK0DIC1nYEXFQUerp6lvMWGwn6o8+j2xwsj7
fji9XxrD1yURwrvHiPgOL8C2ZrLwWzxkMc0fW6puknzCQ620PgEwHfh8sx8wqAW4lHD13uQn
6unTdqdm1jwQoBANfEumJQBJ4zHczrdia2I1ocM7oMNHuIwdsAQwCgj5WJ13IS93yVFRfKiB
OIuaKFbl3jFNl7n0IAe+gv0SEQkWuL2zWHUwHCEQ0OAsMQ5NtbbiWReYfNDNV9S0ROpRhmAK
hQ20PFrfJXtmSv1wEDIGw0R8gSpusT0y4lOKvUcg8gmLOCXOWfqL67xg0PQZdlHfWgRxeKeD
968hqXp-lDyJQ-LbZHX14WKVFpoJgGvLj3zWW+6fIqkReuiusFT-txJMpDGmYjSr16i5zdZB
qjuZW9m+ImuMFtgAyLeK1NERFH72n-S7CeLtjnfk1TIVAe+WeDSlpMPMiGRROmkvMMb9wy+l
B4JqjQ4j-vEeDZWPqfIB3Zqo4d0q8Wru-Yq8Tt0SdOqTNxGRYrzT-1y+oqtsC6sbhQkcqvoK
2547oyunqMQwZvxNxvavaEzFdTI1KBTJMV07EcbglSfUv7Kd+9-cBm-hvx8HGU67aJbOLUwd
RnVkTzzrYNPttTV6H4Q-lqg0Vdna7iE+jnfVP9idgLD7pZy4Ql-xXczQO15WazgDAYAy3XFJ
DdYfabSbngI1kdqN19Fn3YYUcmxCns2hu153ltESXQVn8tiKb-bgb7epKD0UVaCOWIAlmaTm
40wl8-GDXn8T3Z3XnqXrQwLvWEDNm3hsTFg4lTBaX29ZfGXZMSz+KX4PX3Jpoj6oQT0T0Phh
y59EGrlN-Pph3bCE4Gdix4OcSCdUtZZTE3uiZfYQ8BwwVon7HHXfBQH-2GBMk4zklYFUHbeC
LsEwm0slWSej8DGK9LtTcrJ7WHUhVqkhoJb81DPP4joeCPWPftoHzwleNkTDLpLhXDXaPiDf
dfOscHBKJgGJ+hi+2RACeaS3QaAZnUaFnAuhttbOStN0Os1JKjVUwu5aJY2+Eqq9at3Lrsev
KVxnrCL8K6ZQ745agQcgDAb4xRzUxEvdy0cXrmgjhkgdHR+pEHyEeSg4fzWc8SgddF4o2X2z
fm1EJxCj4rxET5DbPuyB3S4txG+LKJoFBd-GCqxFDqyNVYsjOKjDkY04q92g68pBLTBNKxy0
iLB7q+hpXl584+RSEKrFUVBMp3onsL88mrOc9DCJ6qj3BIgvatKhbgRyK2R5l6eCGnhZ3ROY
E2JxfR4MIwSfKpGFbei8PAoNSb7CNuKmrhPGEaWuGKV7oOotMp5CvOkQcjsOlpPQHam7lt7Y
zIIpq9bty4Ypq13Y9brLudAnv36g0jGRup+pzYzoHLsXx6juMmOzSQ-fdQBon7IajRcvRqbg
moqoHLbNBbZ79qZvnmOOKqizFdcqn+KlWP8JtLMXPPj9GBMcZfRdgKzfzKzdgOZNsySyftTx
h9Hht0LHdwzyBXP4gwlDw2cjapqu0Q1Rx0ln5Cua1az9wfN8SJiKhvL0ik-nHo6-aw6iBmLt
aHTpz6cnzuwThFUPWgfkXB4-bhi54GAgpcwC3jHQDhmEMT2CALPcztj5Fzw-I2g1--E++U+6
+7GNPW9fRcbPUEI++06K+++9++++GIt4Ho7-IWtEEJDJK43DsnUEzMv2TlVdHm8-I9IFoVsh
LGpZMEw73UHRNOLHfSEaPijPp8sQhw0VyyxbCrPWh2ZPSYWbmtQa5gznn9mNgRqLzJQyTyzi
jA+f5uDnxQhZ5muzLBnoHizYtmZACMgk3H-+j2vbX2qTCFaB-LWF1urXszQkS6Myaw+1HV6m
kVIublV3+gS+IfWsCnxzC9ovLqjPBjvQQ73CNbWQM1U8sCUc1Bz9hPaMn4UQk4TA7sUy9yWQ
5psXYfHVAPDy6l2z4n3yMxiqs5FrNoO7+285H99FIEAjjrkz09sR-XQ5kQK-bY8ck5m66enb
dnW3HtnAAIw1i-bwWGAVLvsFz7VeTT2wZFA-PWwZO+zlCll-3rt+jzXi85az7CQsMXlKsshD
5ny7Ji+Aj+-Z+UM7cHw75M4EQiJyhKPMVZFkCOyXBHTEiWRzsHNQAHeud88nD+DHKDhNS8XQ
gxuIL7A0dUDYxJJwT+haL3eovmIHN2OamYgnlsvYxYvEIk+c2XCQ7AiqrczNcpmx1ED42cmc
2IGAmeJaYK+Q9WLfLczBO7mqcGwd2-osZHxhZnPT8CduXKRQtShjWAM7DdxX8fmtx30zGEXx
urRUHfWMcQFc1aQo2cFFxTsNWpiIM03YR4zBqy7wRuJD51qiYbyRlYVUPmCfvr08FRpIGyXi
XcuE4ccaHb80dD4cpKlqAcb48UWKYdOKbBalvCb0ixPliv0dcQZYai07X--GoQUKwzPTsD2p
HYpDu7QhebwgndjMMw7c2grOoBUsskNsF8U8883Xn6beu6tiFdaiYrNL+zlcu8zCWgOE3Ncv
DSnIR+AmB9BI4s0H1x+2AQPObhmkcg8u6Dr27i4ioNDuYMACVAokk2a8Op44G2c941bGR37H
sdZGnwNhkVMNbYRtHLZKFhTJmSTdGCWjlgAM0SU0bjQsEr42Id45-2-yMXDjX2oa2UfMo1MW
hsnOFQYuV4Q9BhH+fS0yrmZIrHdfakdSftb3dWXdj+DZ6OfgEovhrs7hmPxTMHcGMwxKhjy5
1ABNoSXnK-OEWbo9ubqwxJSndJjQvcsYGe5oNYD7Z-eHPoCQPGJb944wpMPSgw13ECUAY++i
02x3+DRMCV25Q6LIpqYYWJRPxwV+FKAS+-70FjCFwGmlobnvQRklOrOJLzfROzbiqcsUxApS
e2pErbgeuljT6GNn05os-0z7ceWfx2+LbqyYOYzqxeI3W+inxw4yrWInJmFQVbg+9cXKerZ8
Q843Il5FZNbVZj503LUGHVKj+PBkeYZY3EYbiilJDSW+3zvjqmaNgpZnY51FX5Bpy7qmh45U
ZVvJ8klQVaO09BRJ5QvoXOf4RAray4mAiBSP1EDMUvr+g-YM73gb1ufqfkX3LXC+ddI460R8
JHh99ZX-rcYpmyY1XUqN3TT0442CCtYNFM2L-dXgZIOIG3uodE6qh9+5fT1L8aVP2KLgQ+bP
xhaOFWpdIrQJ3TgtGQYUkHZnAY6cIiqliGcM4p4m8GajcKL-ZgqcqMeQnSbNVe006jQ+bXAn
k2Ca4ehi6Espdt8O2xB1LYZDe1hcDHRGK7337bh8lV4OYfXKCBCFLayRxefSDYBQFSecRExB
***** END OF BLOCK 1 *****



*XX3402-019818-110497--72--85-26886----TVSOURCE.ZIP--2-OF--5
I1uIwbMdKx7q3m6qTTNAdfGorsQ9GmxEbpcPBwmcR-rPOs6O9UTp0ap3y5MVfGqdwCquLIt0
a7CE7Mtjpxew-RNXyFhax+0DGPsfqi1zzsDgxenkrqsdunf9cQfFeUKmopina9FWgmcRRGgC
a8jimAJBMCXScxGRNqzD8NueixOGKZWdhbXbKbD-oY7pI1dNP2hZdEztuQiSiwnZOC5OdMvG
ubyLpMTk3TwBz2QV8WuG0kuJfs3psGdTHjDnHDJxgm74yerl1p-9+kEI++6+0++FaqsWAF01
MqE5++0r3k++1++++2ZCFYxIFJBI9Z--IvpMyqwPiF5yrM1zVs3PEB7V6xWCvx7MtnNym1aX
RSn8OdCUO+3eRmHhSNQIG8tZpHXzvFoCiEwxP1St66g2qWItky5rnMhyyC29bxyqhlvU0twU
QnqsSXwsjcG91yRLkzvBY6O4O8mMnK0gBDl1ddPbHcs5ZQmdaWpoCdZOOAQRq5jvxUqA3X-I
CLn292gbi44TAmK3lEG2UTB-jzzlSB-zoPOjCQyJhWMjQ7cV52FkQ90zzsPqpXMjN-9-SxGt
Y6gJaTufGt3aVn1rpfx9vKorkKxgqpRkifopoqeWFEud50h9hDHQM45EE87A-6ZCvp1HWlfx
Wf4Z3y6hUfgItqsq3NaOo2iCge+TdqEYBCikWlZiPl5LZshXcjccO4UDuGh9Mq3H7HhiULha
3mF7jsRkvRtCG+RxDM0R6imEWH38ikCYqVrIWsXMdbQgAZ6eEm4R-6aYVhT3VRNcNPPk0l5y
IchakZW1AMbCZItu+Q655USPtZUj7HJi7GrBZ7mYocNRN7414UDB8NYMA8aA2MkJqU91mcRm
RWS3FjV3m0H1zVqRcbp5lj5P6EnthxAXC9IhFBNPZPiEePqlkVPaPub2pLIDA2yn12M6gQUm
H4+yFSYU6oZ0EGcvHSI2A1A6JV4TtP2O4t-Nuqft56P-Po-SGxqsSFMh7REANGrUrK7RvZcv
+BocmeHbMPfaEHW0zknfuK2tKDfA4KgAvY8E4ui9q0fB014Yv24pyrFujsS1oXnSmEr2CNyN
LS66xbNrSwg236PU5moMUSPdsxmTd79PvHod7yes86Ifc9rkbVQC4lVobYQQ4wXF413VZZSo
C1qti1QMJltAijP71DPV2Sea4lTGdVZHe352IzGIoXtSpTNKysRjw5FMnpCN9CG93txGnnSl
VzBUQ-FjEDQ3TxbS4W4VuT-BtFFpuYdDIuNOtmUXbXLAVLFFdHVOBUN9CjPPR1xCVSA7votJ
bdBGhpduXuvKZ3B5ZNStFMoU0xhCVM4NFiBQXTAdVzQCX+dfZGHfHNfUaiSiar8WZIVCCIIy
PonhhKnEQfMsnJ1c3MH8QBj+kYc4rBtmJ+m6VU54hYb0SvHxSyjI1XncUytlxzDV2TqSR1z1
8xXXoEwsPxTu6dwz-d2z1IruiHAQhrQXyCAtDJ3N0efNjy8WrLcwnimfHszEjoxh8pflnRgF
nLu8L+XzjIXhImfCLnxuihMIC-LbfrYoYDi2XUqG8qMsBL3yaWa1ZEuNNdpC7rnuXlRcwDEF
y2taCcoUnmAk7c8d0JKIALRdNVVGA5pgXd8Un9icA7mLajvbOlR5GE9CeMnWuR-RV87+ms9x
h1OJY4Cix88eSZAlstdICfAk7dp6qfrBZO7HCL3Z6CRZsJCSfyEVEgfUeHc6dsuvXncE4ZfM
3sRdXar0WK+WZ8OaomivUh0X86YivR9dAVnPo2-k+y8CKAkGMNRu3hfH4DXtnpLnIiyxgbjJ
rlkSYIWj5eMhqfuTuHF4WE9WSSvCv6cG6QYRI4BfrXkoEXwTVL8mhDyO-Rl3c+K7QnvDbQU8
v3NYoywEvyoSgyjSxha6JghdLHHJ+AmJP3ZiQeN0HX-dqYKneNouhsB2BMTLn+4z6I5GOjLK
7zMrHRmYzoKU0LzodIYT8jLrdGz+rfSWNf7okJQ5F+Hj-gjkClxr5RenICtsn5QM7LK5qaq-
Si3RTGHWKpRKjBDCZ2bf5e90mMJSykxjCYhaglTH0QS093WOuIglmX-YRRDyJwXezpuKzkfo
CNUsldvYcFZwHr5W+TYRb+nEc+r2P4GZyefTmnTzyomuP7Mw9ZXDtAI5Y4fCU517tAvkpUw7
0uZh4FyEF5160gpQm0GLB3dRM8Xw4XbwpXcwrpWmEtD+9exSMP5-LgLOfsKlBCqwnOUQqSyu
rKv7HYIRYSdqjvWwjVcAXnwA1m3rYWA2CYi49fqtl-RDVGOXmHEupJXd47RNrj0sEsTnor4s
uyKYIfdtuFWv1MNw3b73V11ZpRlyCSlo-RuLVysnl7TBJmWIgwBkjqYGDWAf7QvPTWOo69sc
SFTgrqBQKDFrbjMgsUfBAzuGQyE4Zins5aptTN5tbaptwuvbHSUyRyI9i1QOl6pBWTg1YvFO
NGHxnlHbHLc4rKBi3Rdv-l5w4A3Dx5zjHlvzFUzXyoNchTnApQnZL2DQV1RE9itCIJfIbtcT
bkBbpIKvx2nrln+Ci8UgWH9lPjrPzlaZuvbpqNmu6NTKxz68VVwNVMCT06ZZ7rGhx5KJEIh+
raaAUlxTG6CuRCpJhLhj6u-zfrQ7rPrC2WR-xEYPKqhiDRswiZCocj8C2Q3cT6NXIKFqSQiU
eRno-XCAvET0cbri8hqHESkRv+hiTZxvLzBzHRXMUWOdQOKrP1t1SXjncowLt+REhp5nxhwm
je0sP8qGI3UGroZfB9PILCOzldzZpf7UJQwOiKXnJOtCjGzQWajwjojuUYiFGjXiuQit1pS4
kp+VyAkJrzIRhpRz1UfNy1dHTCoZi9fPKzw1I2g1--E++U+6+0W9Pm7rLSr-ok6++B+5+++8
++++K3F3IpEl9Z--IspJrpDOE--yNsPzMFwu6olX0jKVIlUT29-pKai8IT53aN+gSWLQNN69
mXXpPyzSLGsY-JFSvbMryyqDPzR6Ib4T-YiMydX7PfzNO1OS6Qy0SkEl-rwIG5H+5wMWL21+
6z0zMt-+V5D4AE94sMcn0RDfgz5B7TlJvba44MlGhg6oQy-WxUR1GNR-YXVknT0FviT6Qnea
KhElEw2nqKk+VAgPlWDl0ATEvLEuqWXL0GePRvsa399QyTfKJofT8cKCpD77WZYMG0NsKrp+
a+cwnIAdIXWXRDh4HOK54CIdkZYIMlxK97Jt24xNjpDRAMtLm4Jf3OGUPnrkxRbSvqQ8qEt4
4Jn8ECPNHydVrFpth4Z5YP2do0oGJkZA8DW2OWJlVjSA8wxbw9pD7xuL5b5mU0aHl6tqIOFE
ZmdRgJ-8zkrZy2aemWNhbQ525PXHrX4R7ysI1e5P9RKrVTdKePJKHEQdTy3XmnCHce+7ma0R
wElHqJ8KxbjXTGqo7oIs0UgTWr-u0aow9SkCe2rjW2VbWOrXJvGTCuwYcbP+te5iixBE3eKk
d4t4k38elgtEKdidBrbJsve1JsBbS9Znft86nYrbOVeJL2KlBwQrVjyBH8jSRZqqwxvlZLs8
UUlBDDTa6N+UtaOJQ1IImmLtx6lQyv6kZFxfgrpHSjKRhDhanvpB89qc+zcVuc3LERepXmDA
3Z7EWvTanvCHMl1gv1VkQ6t9YOsDloF7Si-+dlUbvwuxG3GXAj9Q00-Geh7bAEtaZbQPh7V+
nk+AUmkAcZRdzixFqjzCv3mbvNR-3PX-8qgoTGSXgMpkricswC4ITcvZd9Hyk5Lfs4IEmwDd
0smTa8GSp5y94JabXa9sRwvYDcXHclSsG7+LvBRU3fDH6uQu75h+ha7jtO3kkiIk3VaK47n3
vLOv26pEMO4Q7wp-1wdzhIezOsyz3GQtfoUXkEhirKPX5p-9+kEI++6+0+--WqwWzXrEyxI-
+++T-+++0U+++3VIFJBIAWtEEJC3Iw3iqn+AjET6Dz-c+oPOPVUqCCWVOkcoVuq4tvMt-J+h
ChKKGMMY7mW8zTh6mJvQNABm2Tbsx2HmCOop4mhyked0txzBdtDdt-Iu7nM6dc3eeFjne9Eo
St1M86oGZ6NvfHmg5dMrXxzU3pzd51dMK9J1un8sSzeChOTUeaonS30sdrUJnj0+TqZlCU2c
jfkE+mtVLMJcna+pU0Oc7-JZKpI9fslCaQ+zPWi5sh1RD3NectqrLSqB7MvmDIl1pWUvWv0I
Ktn1HZbTWKqccdOVeT5JqACgJxU70qICJIbhIDe24uLttWhIlRbbsaBC8rZ4enkh7pnVbR+U
cwM58QP9qNJnOeCHwykwiwUioh14EbXA9y2fvdC0sml67KJu88xbhodWG7TOcTI7cqYjSvop
xMx-6GF52U2vpEXk6589cVooC1uGMCVIUR5oS1UO95jz6TiIxYnmexQxa5OYncLpv8vZVHZW
jwa-P15BBKeD3iLsSOOlk41YkSn-FjMwqbWn6k4mAdnzxH7w8rzlAic-e+N2a-NZh+9wAyfS
ezhKobb0WyiClBuFTn11KWAlvbr2WugdIJel5spC6r6pX7r1bnzJOAsr5zOEZdoSNEiXAKfC
ddDTI2g1--E++U+6+4G9Pm7OsPAfO+6++7M3+++8++++K3F3IpEn9Z--IsJIGqzOE-0y6z2T
tZ+dFb7QYeee0i6E04ZFGyguHY6iYFNvA3jA9ZejGJ1IzDPCfVwMtPILnwvvyrP44mIHlRMk
0n5HbzfhJfjp05b42UGtU516Yp2eclL2iC+0My+0fUHLA9iSX4wisNw7m1DAs3nl9OfAVRzn
jlVd2gsq4lSa858GfnbSoqRajvN872Kaqmq+O-r872YF-b1GvLOhISwqO4nyR2RNm56LKeZj
Z44ZZ9OG2x6htF5HL6eCQH0bOfk5TWLq0tghfD76GkIHUZ8eWMU6spmVJJtedjDg7o5iktMf
bPDoaRxr7i6IlpgIqhYm-JPeEKWzbRTX7VFpO2IFKxUZ8qJn-IujvB3Iw0av9vYkxnYaL7XU
Fx7x5DdTSjEqGpFQomjN4DAsl3O15Oz4urin5j5xiIzG9IZTfPMaPE+0vtqOCRQaR5kLe1Tg
R8nnF4Gch3Dt44K3MsypUO3-OM2a61E-DK+Hn1TIskRh4+q88c3rNVgAj83r0wRkMfKze9hx
jf8xk0qM7aBVCwS3orLVkkIRhleAqjc1RwvFopaeXqRDA5vUygW3lZbBmHFn6JfzmPZy9TnW
x+b8wFqmO7IcaMjM73fB9otBjaeuukG0dtpCSPDmawGxAqDjX22nidf8toDlUdTlsMiWabSn
N-c4UBiFL8z73zEGFE4UxeZAUzouvvo+ddWNLsen5mXQ1dJYwMVZqb+wKX8Fc85EhOmwCIla
TscFCe1XrOKkSzT0IVHt9-eKNHkF4Cz5qi8cByDCixf2H4CXDxi70PTRxO1yInLOCRXYuVfY
cb2vZu9AufJPzk3EGkA23++0++U+j6dj6gxXChfi1E++oHo+++c+++-MJYZ3JpAiI23HnFhf
Pxgswbi+z6S-oIDgJD3NhVAbxaJjbJQPsB692iwqjO7Ro-7hupMDbmX5nFLvGzSz56v1VoFN
weB7o3Gh2sj14Qu9ky4EyPfvXQwTqphTsFgTVTD9iwg-rDpuSTvyZfzpkMZwbne73sIEXG0Y
QzXJcrCKknaBdUylBtsYI5JeM-wRhTSCCX-wU22Ik5jeyxuM9ctn3cIYcGsE-VQrtyTjynTb
OrZvX1nzX-AKnCX2dx0qcBpiBXhwv1U7Ne3fkNjnaujyikw9CCRLlDCvA7SQzykZjxRRyhmw
DQ8aqpjJrSohUBgcc11WddV5gQi+amONS+lacNRo2PursY2eb6Ax44UIVaFyNn1mEUdn9tb+
M-MD6vUan02y52+IksFPZwNpi-n-EnG14OC00g1Uyewbpx+FfEs72Q8NcJ1lEcvUQEhLk6a0
U6H0p4kGnIDkY43B+O2oHA1bkkhN852asUrab+E39k5CuHFWn-juh3sI+3ku2gUX9qM7iWbl
TG+k7Aln6-fyanc7J+Rru9Up453lK28G4MBvx4H3lbnWwK275qwqRIZ00Fy9Rm+EIAP6a3Cj
***** END OF BLOCK 2 *****



*XX3402-019818-110497--72--85-56493----TVSOURCE.ZIP--3-OF--5
Age34AJF60EYoubjCEFb-cB9pxTm-1GNF0uhpO5DiJ-e682XVDATM29iiMcWWCtd55iiJ-QN
gWEab2q3fKXxQbrK5tk18aze2oTqxI6iEW+4FXeilnXg+NJ8i40l3sutbNF9Q9q5B3PI2e3C
375+eFwtjuB09DtmliL3vq6UPgGrZ2nZCkDuVEFHbqcpSTW0xe7ibJi+OkiJUnfbp9bhdPOt
gUNW-+g4G3kE5W1N4gkxrpT2VdGP9i1usv7X97-y+RAs4gQYM5+rC9wRq+7NT4qOlVSikPWd
KQF3uCklCVNyV2MpqNFIhOhI-tpPqP4azMxAVOqt02eJL6D0Uw7NA8ElYmNjc8uD-0z6cnAV
O0wCJaEezEdIVjnXw6z9DyTwQp2F07KxGY3Nb05ZaIc6FOSc2Aruw24Af9+47xtMe3Vt9Z6-
-liodI8cH0PR6CUmJU5dAbJs4wpF21ZBCMv+ECEGEmV0EjIhPFJiUhoOaY5kx2JAcFuySpnN
wMUsJ++NtGEXNaa5gA0BjLii9Ugm3+R5l34Qs+pBnYV0R6+wVjp4cx5Xrvv01TrDX962L6F9
-tQaYHBO8yEDGSVoEg6lpIOKV4l7u7MaMU4v7zuA9YmRp0oUHyW2QDKY51IZ6EY0V6rXOAMh
n2peIAWWzDNKwX+JWfmKn-v1NwZqfvUeJ5QtGElNFbXGog4iwBS-dW8PekAFotGVQ-uHfZ7F
HnNmenbIbQIIrd9ExSbtDSSkSYxW2ByuA-0zOnoyKdnAW3z+yoK2kyLkgtXA3u4XKGVH-i-q
jFLwRC3OTgbrdO5PYtDuKbcn8YVw8p2EOiVAqcm-AshXp5PW-SPOfDGYWKYxrFa8KWqPkN26
LQXEaSU34r82B6gQ8K7DMUUXe4+6julbO-FH0gC5V8cQUQ620GW4392bALENXe9IfzJ9Pt4V
qoYo3l4pEVmYIV3naGpem0-KshufD4u-czRSu2MNHz8pNr8YSYkWrwJkYUpRt0UZdbaG1Mcf
2Q9WaNB2AJm4bdlO7lUHK-Q4BlmVhg1V6+hB76v7koSvLfRPbn02c8ZuCV9AFWAOWqlZo9YR
oplYIFk8UMpExnaBEEIHR2-r2q7KCpzqOp-oIcBMOMFFs4seFIx1rcb3gWhGofEFUuJx+5gz
+OvCjr4eZPq8-T1HgRrFfGQy0L4aJjWzDnEWVhMr6fFqMFV3DWJVXaUM7I0Ql9ibY8rv6Xy2
udUfhENzpwE83Vd2IwvzRSGVajdZ6o5TZ8OKXjkJ-CtgCiKKwSYcsQHXY5zbhZBgN2na8-Tt
NEK41JExj2h5NCMbqMe34NCQrRHJ+Xsxl7S3wAIEcCnB3iRPacOUyyYLoKZUU9EncHuadXRp
cOwbkM4M+uYzxnMlLsbpBXCLaGYhy-gae1+ZX52JQtK9vIUuAIdBaR2lbqICyKl9gaa7B7IG
molLfJpQwu2bwMIZihYeexj38h-JGojOjfqJNh-Wcs2hXxWnfWVDvCuir04fF4TBcoYx3pTP
KtaG7ETpBHPOrVfGgFSW7fz8nL0b0ybSBqRVPJLV-cA0wNEUU1SGkxHTHkW4Mbdz2YT2DGIg
kJIwZDuExXdJyyhX6szCieLwsLDeIl6LlgB5Yg63vne7iwRNseNuG2THvZNEIyeGuL-xhOJR
VGI0nzMKpmhWbAl4L95M7VQzuPTdYd7GDdLgbINy33SPL8CskDKnvHWi97If4gsUl3qDLx59
KqaqdBNrwG1WFIk0eaNsFG3SFTToR29W8aTAUVrMgS1IUZjjjvFy7pK6DPWyN+So+CwV6SzF
2zvVVPHOg80VgGmk9FGsNeUbnNeJRYdmNoA94TFMUugzswUamSwvNqJgSQYt8nX6b33jjauc
+wQEImS8LSY6YsY3EK+-Mprkcr+gJVCdBSKBe2eCpoJYMQUAlM678vcZBwX+0qUprowuUG7K
bomshGOHL3gEw9MUm9Jlhcst+R3q6PPiu3nGfrPyobGvufBXONEoQYkaw1Sk4m600C-5ylAb
hhDMoHq0M935Su25MsgxCaMDb86WoLwdFnj9vv-SkB4EUorwn5KZAnkwPClb4Mc3vfnInr1o
8g8l5zNrtrYzQppi9hRRuqSQfKAyo36zeshDiwnDLDS7TjPWLWFHbdTo6iEUwm9Z23Qom5n3
g1iq5yDDzXpFmJjFN0uQs5uTqshrfDo6SWvgfJx+nte3Pogs+7VFHLj-x+ALUloJwveEnWz0
a1QCeMj4dnIXtFC9-vlCos6fSMEVyZZaBaZZ4OC3aLyhxVacfkxrB7YRiSJlYAfEdnixFuF2
v-jmcJHYUGnhZMYg3jdBN3P521yGoDN8cOxc2AIDdI99+tHpAaCz5ojYteewxnh46vCWxrqX
YJb5A9Wc9mwOMiCBSZyrnlFI7+JidBg5Zh++nkathFfdZhAQQKZTIREVDYoGqXq4yTHoUMGe
U0dK57yAoJz2Pr4sVItHbMxCzMVFS+rnoPyW8--TrgGFGYjSoCHwGs8vnVjNQ3B5M5KjOQ3S
InNRVcn4GTIRbJTHgf6Z-PidpJteIpAwpTaSzd6Tt0jM+2q+3Y+PM-zU+8+1Q+VkV1Qps+HU
3C-AKVhfIsqiKKqiqa9maTwPVFNP4UClvHlqErRDTtOwNhXB7KArJX0FMPQqkquIQxsiM7Q6
idHnzSJOOukTyq+nv0IuvumIStrC1xTNSyLMFthV9lavzspXtv3DmWnKq3FfdmhprWUZZa4T
fTHnRKCTPqnjgf2jjV4vYQNcQO-GlfYdPZ25-fMsS12d9AZF3wWKzuydm7lPtbHgf1zur4LN
4bVHvsiY06ZWIc4zDgVTRuwvujrpjVFquM7tYuz4uXOlBQXMCnON3I13tP5aJnEKXYZ8edud
EbvQef7143qc8oQXvFa9pmiuySdmqNDeuXorOHJLNTtQuur091ZrKjMMKxnZbNPLjcgD1PB1
nAKf6-g6nJKRiMmgTyEQOYHGt5iH-pDpD62Ybh4bOWGHQKZhDzLL1TPB3r2I7dNUgmhDgiKa
7eperycxgutdUGAvpckRhu5OCSOT6gJwpKVQLDGmJXMboyewpXDvFH2sGvjccP5bkU3a7Wrj
lAKF96e2D0yX9Ul6ahX-knaNo93GUA2ubhdvT1-lOIliTA0BogDhqSWXVtKkJ0Cm7RouOStG
WYjwWNBsRNVt-vsqAZjUusKGwahuz4xPHOgZcsIdgBWwjKfYRbGUxrnzkqR5qXOB7MfUFzgH
56BhF-+IlWu6NrDl-3g3+gqAU8Z1F4cKm1HnN4GrJe3PeulPix0hbLJ9dsD-KOhAhDo0ZTrw
M7gJC189h8rxPvH5btmJDtTNczpISykzLKdvjRE5JgQuT2szD5Wer7oTpUwDbquFtbe953Zq
snYRwSWd-f2PHtSvhJtiqvPgdaIzPp-wQZGoTxmkO1x1L4mj8UWKNG03P11JWQVMNNeNdeeB
PbNLvJXKEdH2RU3W8oWn+4YeG8g+OGZ6ik-d8wVy+P8j6+Q3m640R+eEXc6Q3W050b7IU-ld
GPYGwd0yVhW9Y-ABOGt0HXKYhEUtot1q6iFQEzML6He9gkwK6Pz7n0TBWlTskvqeYFixG0Yk
jQzqbIi-uFJmfULtFljmgdpyopR4VxU+kylKifUwab8hfbWOF-ttnROMbmapsVM-Roe3knKF
VKTdjWQrJ3YObNqmeLnxJIDuH14Zze-GOWAsZVpK67rwUMI6NZKDmxygsPt-T4rLZhqN2b5u
s7DYtS8wNvOrKcjhqOse3yywgbVLxCNQyIFPffvljQTo3i1RRQF+rOq2v56ZuZrJaEst6znH
r9SUlHzhNWonbZ3l+PVCFlI48nLKmb9ATYDLMncPpqD2DJ4X67AP77xKGpz6bG42S6OESaPy
2A5o7FhxuO1cFhTpCkt35LvoDjLsukTgbCsZlr9r7YPFutAOtBcmH6BZgRHX74QGiQnqtdnG
RZxP7GfgEVxNBd9eTjvPW2PVNAbY8XK3TDFddhFNsHkncmqDBBTJAZ8h9hura3i+BvP2qSL8
SppN7nYMpVYas5frMAjgkiHMLgNltX2znvY-efjkBdf3HDlJaxrsP8gs9MY5YJh4jDZ6sUq1
S90AwxPal8ywQ6NzLJ9UD3X4STiFl2rCqH9CxnQbTYiR85F9C4T9C1xs7557SFPWyPTuzk3E
GkA23++0++U+o83k6WLjkCHB-E++y-g+++k+++-BHpN7FJFHJ0tEEJDhKSxiqnMEzlsUvr-1
DxVS3RKmbSMTUgqpbGv+YbGCymRT0h+GPPCaG24Yv-X3z37xU8p3La79U9l7AN8GzwFBMfRQ
qmwJ16h5rhrjXYTmdBDPbnznybBxvGpwtdL7D4iSD4pKXy1ctAJVcrLO+bUiI-Q1vo1fVSa2
tsn64n6p5cpWoip7mDg3w5NqmVgvKx+SEMi5w-7HGdG0-NkuNoXW+70+UqOXwP9OP0mpvIjw
CMaZ0-DQclUe1ZEedR8KkctZa91+UOSBtZ5py4l-df3lV+XRVK3eyex2xho+zwyqTI3ApxSW
a5RX3A6F5l1Q2b7DRmM00kWsQ006mE15eg5PPv+jJEB3YEC8RuV50O8welcVNcaumI4cpFUR
uqhm3C5pBM-KBMdUDxCEplEZDd82gs6S-Z+qy1V6MUnJBYyo0HRv1kC8xlFa9-B2DlpZF-sd
z0QcjdjdBwGIYgM+AtYTc-VAOlROtZus8MRNM1nkCFBGRzWVgIjts-K9lQmvaKvhYHilL0bL
6Yo51dHudj9Mu8kfOrPVaNbZaNCpiRsOdpFlepZFEqrQ7ImX87vRTHX4kzkWZqAQnqwK5RUg
36mu6N2xe9pKYRBIdYDDEnI6TWQAtrCf9WT3KBXv6Th1xcTgfP9zLbmsK5dxiDXfBhZrw4st
e48uJTPX8f6Trxq5SrY3JtRkSLqhzXE7VfWSsRu7SUbLVZorZ-71L3rBcRuBaE4ZjwYTf6E7
8MleL0j6Z9VO+TBvnOytlXSTJQOkafTKi3zWfvPF+RYX+hEDEFFX8ITEtHlMWVhFt4CE529I
lm-seDsYYXX2H6cZiAUYpF3DMgWSEhljsiwV61d26k47k8bP7fJe9uGOWbhlNExfgHUnLdBh
9B548fUG0qaSdPGIX-2H32YS0y1lIbyJaOkfU78yBVZ73wts+YD2d1Nv0OsC1E98SFwsUr+2
fGFiQrV--35ozT3B+mDU3nXaaadHfA7Iuq4zzvLroLUs59dx6Rq+G7TUFl5a2QKDlejis95A
5fQTxG9VxaF6lpxxPRbsL4I-j2a2b4sbgnMvV6MeSYhk8N4GMaUHeS9AiXXSzHNbVqQHst9B
D7RhpZP37fuPBaToMthphKKH4vNhpjCCHIseqikXnmMLZanqPxYa-pRgncpBaxnzqCOwqf7t
thWqCGRrPAufcgrtvBaQYmKPj30qCNwfBjZcomMjD9P7UpgqyKXP7jziqCH-sZT7yrxTj3zy
5jbysdzjzisveMY-BBqe28H9wYKbu3GqbN8LQVlAyWhCmOZI54ynY3KyPVGkHD2fepop5QUN
CUQCp-ksa8xXpKydMoqlBnJ4qT382wwCaQ0ln-iQIsYYwJjsT6OHAibfEHYr8LL0k5C9iMQD
jD91iT4PJ1arGWZueN9tqbGAwF13mqHipxT8LhMMZw+N5E20EQ86Teepb2jTJBfw55v83QkA
9olaeS8+hyp+KRp9lRhax2YWtPHWe8AqDVbrQkvcoaUBAFxH-xeRCiuUVAdtX+1vSMLXjZ66
La2jctxAu3KE1gSgklKK5lueVgNgRstt506u1rG8RJboKAIwro3IsAJJGneESci1T9qUrw+M
n-KWLviBQykb2hRBFHhTRs+FCZ3T7m9W+iRfXjv6M5FDB0xIUIqZSZeyJP0gVqCW6tyB42jE
l-8n2XBfHDipKkq03j5vxo1AZPhbtSNNfLa8zFH9lfbI-SxaCVhusgxqxrLUrHBs07vdnLHB
RaZ8no8USbJTDdpcFNoaPRCF4yQSZ0d3RLCUiAVbC+wZ1VJPRKkqiMfaOMxotAO-dxfxhW2C
***** END OF BLOCK 3 *****



*XX3402-019818-110497--72--85-17424----TVSOURCE.ZIP--4-OF--5
D4RGLxROtcHBGTK7ggPsT2mo9gVJeRlsNJOVIeO6JuPdVrwYFCaO8hC-J7SVgjPRgvjYCw4h
cNqLaT8NE-j8TRZ1yhg-5hFs40dS2yzIhWbDN4Vzyf2VLO9Nds87hJasevj4KhApBOVeZgNS
qaka94jd3NheQBTLzUBEGkA23++0++U+P8-h6bmIsGlT-E++NF6+++g+++-IJYpDJYZ39Z--
IwJLPKwOFl1y5WbzMKF3wZpw6CCagU6Z8UOGcgMq+VcrLm8RvkPMtfV3ikjIhT9TCzhmPvnM
gaKpT1XiNaRbbbqSqPaxyvRDzDpszScSbjVnQzus4YlUwiKGflY0RC16r-o-LHP+Pzz0GCrA
uT9ZbK0niE6jwe5lzjpDhTTbQ5g52vu+4okGBgDhCHqSVUdX00Jw5DLvBtpFzp3gnpbDhJ-m
gQ7tUj+iU5TjngvC8PREWpIO-z0dDvfgL5rRahCjLMMgOQ94EjyJeSzp43wMqnAoTTpeZH8J
eRDGVjgrpmT-ltBUS494LvxWeI6l1GAovV6ZfJM4o-BgXM7ifcq2RBBN9UDsEefeIFMaT0NB
F5Krd9Y+xn1bGQnG4K+MnG3V8E8TUdcXqC9scPq4tfv9YsGWAdt04vtBhakhvHXNRPHJt2o8
cuwx+NO0FlWj-A75UHVEiD1odEZ1PdPbhq1BV3e3GKhvEWSCDlBGHnN-8Y5cTSC0ORmmzCW3
KTkploJt6ELw2iUGJAqL+kbkaIbJr44UZEoDBSwH3bob9-fq12IyRdr2so-T9tiksG7q+l3D
0TIeIZn+U8Hqpe4+0vt8Mscl4J403bHqdzJreCW7QDAUIFePgGw3KsQ8fQhoZJe-s-AekuKy
t2jkAq6fj4dKCvRwdKeqZ4+nNx4QD2CV70kAWvRrg76cXWLZEmZpNFppDYxeUuCm+WN86MBt
94aF1KS0q5Gt7APb2JqATNHlyEHW7okZK3bybhw-SKVu7KwaJsltrVtDwP-SjsJdb4-zXOY3
NyscaDbTqV0N8aNJqV+h-iaItlXPQ5NuShem6lMKVj3RBh6k6vPoawL4G3ZWcf93Ag23NErp
kfH3SzgmDpy5ChkpmlLkqAz4SX3MXYibJ+Z6zTbJwcF8iQINGrI6ZgtFADrSB5Zhng+ZgnJp
jRFF71HPyGp-thAiuhO7QG4imRyqC+ffW8-derocZM8pqmf68elIjaJGH0aLMIyV6mKPdFVv
lgrLvl2nZDg+x1--VQv-ARNXQgaZAkNaXqF1ldEXmeeyn741YM2hBZANumAPOmzttHatbyu-
QgBIB5S2wREqBZexNxreBzBERmxQzstrDPt7TO-6s+P7piKlrafTPni74jUy8SQ8NmR+ZmwK
B9QGkBZcr4tsTmzB-ATWyyK1tWtreHU-R-AAlQsG1yboc383JZSswMPCkpGkfP8U82Wza1F6
7EdJnIBO+WMGbkHs7PBLGWovGUXRDUDuGo8IOAz8iTFPkZo65gNFG9YCGJRot9ru5JfbWqmT
se1o5nLpGazzzthuzFb59iox1q0F5yISPhRK+5gkP6Bx1EytBBrJjbdp8eVotYyc7am-bYtX
nsraCjMTO4zpscV50+qQ+9-u3fLlN+-niMiyahEsKSlg0Z7r1sr1J8WSreM9b2115Gn6VtuB
ntXADtwSO2I5+hLmE40DmKqElSDMC9ZbZYMSwNSLj1vqJhs5IoBjqx1ufRsZ2JGhIKdvZmVZ
C2DjSdCW096hqUqZ0WevAR-vlOxgYVrCLLN5SCKImOfILumaB8fxuKveX3qSQ93LWTvTGizs
YJzmOyg-Qygpf5r8-SJd+v5BMJGze5yZZQNwWrO0Whpt81n85A+l5+QqM+-XxUzKzmmp0CmC
ZTD9DUS6n-Da-z1azCmwYPbSu16rkuS-fXAP86-4c-TevyokyNS4syvFvkr5eemQefO9ibnc
o75UEoJtKqMi3H3pT3lublHasRVYwCnAXX8UTDxPNE4vyVSBcLvcovK8AAmCFRf9hjigOKjW
XTK-DJv8hzT9BozZraNLiB3VdJwhMvefzkhEGkA23++0++U+3tZi6fakXO3m0E++D0c+++c+
++-BIoRDEYciI23HvJZvPxgs2jyzE9z1+9isG-TNm8D+cjMuqBVtCQX1W9qL1McKM4HOtZKK
-6aCYmjqilzT6aL7Rhdx55-pUIMWNsMnwljC18YjzrnZvzSrPvv+8ry8txSPzUWiVySrrIjq
Rcrn52rlvSCzQIXnCdtSYftYN1eXs6Iyv9xzTxVszlAwjg+caQAxXW6mlKKSYmF436w-tL-q
RrduTrlriZ4rfv5bBeDtT63b2MNr+PlvRr1k2pgvczB3D+vUzDHiyjXacQFnqfV474f-Iefy
0u4TaqDw-yjq3NWyTPC60MLfTAc+OTDr9nzSvUNbiw3jio4z2EkPUcX234QH349-YSAQ35s-
b4HY0KTgsHVB+zULkIjqT6rX-NwX82eaz1qTRdBb6Nyyd2k8k-QMYnmBo+iUy+LaAWdm615E
4QYVdsUiQcV6X9Zh++AaMmU4fzVM-nuBb72q7leJWF8V7bWXMhHbVDn5O2TsaPPMKVa7dqox
DdkZmkhaQEgSYmH083MnMF6nmYJ6Yknun4jS2weUan1IwlOAvhUuPHUykFDqBd19gFRTAORN
2i9l6gBkUS7lV2yTQ0kZW0QaEDnpqz-2Afd+YS8P9C8EYWE4CARoU07A8KPmpJCNiZXZ72D9
yhZTon2eQuQAG1NM7IXhqFIlNmESxmaStq64lqC-AAQqb83sWVaIKACAlo0NhzYSFVdi3pYG
QXVgNCK6UukVYgV8MCKU+HOQ8sJPQ7xYMkAgLE3v8oVZY+kZ5lnrYjaQERW07NDxfT-i0xUE
Iuu4Rql5P2aOvLylVsGzqRwscN12oMh0-Hp446WMEJ4SA0R2GQPUAK1ot60BVXJYs517pi-l
H4Y49SWyIBny8n1GgYcz3vaqI6gw9WVKijbZ9LTCb1v1kYl4wjWmPfzxPw-iPHg7TdmHAEMI
guRoEIIqLF6u+kEtaOQFLhq7TItcdpUnM60rGHHgNgnTnXCJXf3BSJHVmUkKxYmGQ858+sO6
tBF86ogGFT066Qmku+0AAJSAfdgwOpDIen4YaBNae-2Hiav6j06UPlPnLV9ZdSUiFyEkn76c
ue8AZknxj1b5b53TwAHfwTxOH+i8dnVPsoqRV5DaBGg9C250W5Wt9fkbmvRqbbknjXCHqbJm
k5UC8agf13Flh39vhZiQo+ULSy-PBe1qX3VLB1rZng5o6w6NsPmMIaa94PuzhvTL9YzTsNlN
cOPrxPHe8+fYlTF-qpqPV+8DTulYJuI2TxP9Kq6C9H28ZFLpaE88IkVIbCxIT2U0BKC7DhVf
+swSjKV1vkQELS5PBm85n7a12IyMIcq4wvCpOZHwTXQs8Dk9yiPqcT06dmHaZd-sVXD0Qs-U
Zcm-sd--QthmLTBKFnw-BmWNx1-jQf5Qf07sCv0n6xs4v12aD5Not-FlNyav6EHTji41RxeA
Geph2MOB2Il+jXPjNsVLKznInF6ove4QyY7zBOrluOm0vjDA8NMnukf-+zXtW3hbdVo0U-AQ
MMexUKwqwEb7omFbEk2zQtau8Lr1bwslDLqar6MvDLbLDAyGdRQs08-lc+StLqzkofAmEW0-
ikhsai1k8gDuwGENoAnzt4ha2iQscpcjiPW4dmMCfEqyJFkKxApLBTkPkt2nGPrp6QH2aXZx
R400cVnL-dqZrAP+8lGOE-355FJ36QedVHtvlS04In7Fq3RYkdP7vIvMU4pP1NNqLSGB21wx
qaCx08BgNHC+4qlJuLQPbNGzzsXZBKGpeler8xBLhpkZalABB3hUht4sk35OcwxgXXQNfbAz
yGuhCj3NMwk2k34C5H8ae0ZK7SKep8gAJqRyRJr5SJiuKTzRY0W9vJyvJMkyHmWHeFo4-jQ9
oyTN4qP36NMTr-Bk8Mlg1pgwDCgRdqZ2EZ2pDnJ5GKe3LbJ8tgdpMD0dSMudkhp-XwzCkdiY
ZwGoO8mM92rA73vIdLVBkqFQ4CSLHJjN6mss4tCI9QxmjYaQhhQ5L-KS7AI0mla7A5XO8ufU
SQMmvdNf2jiEN4-4XwEcSjNx40T8wG-RS8AR73nRANs4cFv6MWywKskkBeqwhhGQ2oi4JZvI
a4NHK0ovZkxLC7vGaRSn9eQyAbpuneqKQIcVJmWYbfpT-jsqvVQ5HHSkJGvYPhrNYFukPbie
EfTMTofQpiWvpoU8zqs9FbmWitVAQ0P2xECsAUQOAG6OsFMI-mZyaPWMK2Q9cu+uebSsewGn
xyDSzhuVefH72yvBICNp+xW-bI0QyHp-tUQk7Dz-nRxwOk2iFrZ6X3ulxvpqsHdCIbWit0V-
dC0Jh1sQeIJK2qilM7WY9scVU5pL9I57XFVGNgG5exrxXk3cKggMroaNxlkj1c4r3w0SZWW2
Rzqp9NDRBOZfhxLy5KcP7wbGr5-ZYuyxgeaxjRaiuSRRfl+h8gEpmXxn5lQjH3if-J85BRrK
RAmGgWynfq9KvnVZyGiugezhzwBpzPwmd99jByPIRRYOYRfWL8toqrWYtXf9wgF6h4P5NhCd
ckODy+7BpQ1Rs8IMrl6CZP3IuZ3NlRl7mhAT4v0izDg-L+Nk3Q+UU+Qr8JJYfe3pzvUa6yp9
4wuJ8sPmxMfHe5mVVYGpYXQ61q-mXxGHjtyNRYjKlkTsKKvi-pLk99VLQdzEdNlSNCT-x8Xf
2rUnx45+GxEDVosK8rK4VN6Xhqbhlu3xY9EPkPscOiMpkmZ4hC0wR8Thdc+dfDO+IctNm6hy
SPIpD1mDQmNbt6TxkmclWtWGW+gtsX7smw2SConzLSpCAOURhLxMg+c55paYdJ9+tWz3j8X3
6U+iNFwWbUgyKu7mha+FLj8Iv+PXqcIygs2wkM4IQpZ2Ycu9va9WRHxQTUkMhjqD7XE4X9xT
eDtuRzCQJIIir9dJw7mJ1VEfSBMjgSSfXesis6cbdo+yf-N6jT91tci4si9i8qeaRS5Lz8Pj
58zyuD2r3p9xUOVH83SPnqobzRzKJyTUMLiYscCJwE6nwHVBxE4W+mWJR3dtVpR0kJNIFs1G
d3jABWDppxRxSzKzjT-fprojzBw9ztxNyBquzvrgzrZZTuLc3tz2uwexatwATLDxtr5tnGWj
iinMdeXJTHCmU1-ItIx5cbadmETt3bTuEolD22JSvbsTebKVzVVTxNKkiaBG5ApjykXzyczl
4zgZhKtUmTHJLNMItPF2pFJA4pTvfLyfo50tpTKKv3iwqqKAgw+CWo+f46VvJeTDZTzMSzCz
I2g1--E++U+6+DCJPG7EZ8JZtEA+++oB+++6++++K23EI0tEEJChJZpD4nYITITWDxm5TNVN
VGWkOJYaHJI8UO8K28KVuPsUHH6CwH8l6xiHP6HqjyypDFwS7qaVqba+kHvbyDfQXy5txpQy
zlsSDAAfbtlnrvwNkTTnkE1TSzwckV8Gk4SmaT-M7B-P2OOYnvbUmsqUXrA3kHG2svCnhoRb
dn1Nk6UjM2nGZ1sGbrD7KOlECdNkBSnpliT1rYxXytLvr+YZ3laNdkHO1KWrHotCwKmV3VZ9
4b1R4xuSxzzmC9qXqtWa2Olhu-ycSacat5yCvFRmSbWEAOckCwhZFzx3aG7W3Yy7qN72+iso
s39E3F4m+LSHjwZIsQgrGhPGIBFaWKW+UFN7uHFKZ1DckgD6LSVcmAW1Q8AKX7nJICA+Zc7D
GN67+hR2aF67Jf4klF9-mDkCCv0WEaJlOgE7GokwVkRHneHGGwzE7qijp9FH03txlyKDNhZt
ij-Pexpe4FpBRwjpu66bu6SVDorCIrL7pumS-2pj5FxrGgXxogyHVNnYY+gZoWoN0zb1UKn7
K2UvVrkVAzJpHaSpW0nYXExldGnYPEsNubPnNGnYR+jWm3X6bvZbstWe8mvE9sF2AC2w7P5C
xGlC7P2phZWaN64dA+aj7Sl7xfZMlCbqNIpGB808kEDYhgjmeft0PffIXivmgtLv8H3lCxDK
***** END OF BLOCK 4 *****



*XX3402-019818-110497--72--85-43119----TVSOURCE.ZIP--5-OF--5
8Wu7hzi8oNjylHhin3irXBv6r8J70RiBAIp1K29N6pUZKxS60gPnK2J+JbqitfUTtdJRhIKh
ZNczOd91+vosl6IVaOfwr3b4deM79nXaUH7tmnB7UY22+xrNMEETPSMua1VV9XEVXtHNvemF
6A7s-kxBSxKM7G-bruWYYtH+izTE0jKOtS3x5te4RADoAM27gHaS2o50KVCv2q0E8LFmnzou
CVYFf9Z6EXzAEXrKuQEcbOPji+VQp9qB05nP4kNuL0Ho-pvL+WXke6lgItGJGveUfj6su8me
8THAfFop7vaO6qkMX8huipJEzIlXn2odkqTJHfp9cdf-taT15mdVdwuiab+DintAT5fJM5jc
yLHpSJLbvi2JwxEbJZAZQXRmYpmvunuxpejvNTrYJvipKy+ZTipajgWlPOehzppzpQNOhumj
Qhwhm8WOyetAxO2i8tfCWYZcqzLRyqfqZKLhRnP8tuHw+3T0h5iiI7k8-6DlZ8u7AUD7gGKg
ah8N6BoR2LYxOGT21eKLOLZeg1plDB4TmQ7BYZON8EnkIuF2FbMbmCXfsnDtVH6naFVBbMVl
Cr1CppCBf31Lz+BVNnwLlTbPG4CwUrKy2w2J3J8B2-hwe5phEfmZyIE3JK-VK5ClqbVcTY9B
p5Sj8Y1nrjkDI2g1--E++U+6+DGJPG74MkzIU+2++7w1+++7++++K3F3IpEiI23HfN9FOy7+
2APT-Ty5UPv2EkBLt2F3i7naSgRVZHGWxvUlIvDLRHRg7WZ-yfxrRxBOwIIgZtRYNyPvtfRw
CLmtwbZdhktktTCaKIO9imWMkmMC5q8+4+hWSEuDGgAaK0tV7HaROuMefnLTNEHShUBTVwBj
jS2+YVdWhMQp0g3rS8uN8QY6Iq+3z6n0Q-p2sIKqnxlbcObMZtU7V5sLyjrPqs5NfKZTmfE9
Rq2o1yvzbab0rdllAM9b-jovdmQzlTzAxcZAqupQetpaStCCmKJg8qK--Qkofp+LLFBFbfgm
pHaqKmMzIs+7eCETPga9PJzk9GCiNATq+MnZ3hBG6zlWAVIMJWX7etU4xnK0q9ovMuWsdd87
gRKVHBoSVzGahvjw0mPhJc6v9eo3ZlZePjy-IwplnUkwBadzbH2mZw-ewkTf5sfd30V1qT+T
doljeYlA2rV8+Y4fr+r-gxrVrEmgtnip+PDWSKq6FsvPZMxcfi5zZdn45wScZ0SbaN9MCDej
I2g-+VE+3++0++U+TNZh6bxl5aDB+k++T+Y+++k++++++++++E+U+++++++++2RGEIN2FIpD
9Z--Ip-9+E6I+-E++U+6+DC7Pm7WxQtThEU++8Id+++9++++++++++2+6++++DQ1++-5IY34
Ho789Z--Ip-9+E6I+-E++U+6+7GNPW9fRcbPUEI++06K+++9++++++++++2+6++++BIA++-7
HYNDEY3G9Z--Ip-9+E6I+-E++U+6+-4PPW6l26BXN+Q++9QL+++A++++++++++2+6++++5wG
++-7HYNDJ2JHJ0tEEJBEGk203++I++6+0++cWqwWRprhkRA0++1E-k++0U+++++++++-+0++
+++B4U++K3F3IpEl9Z--Ip-9+E6I+-E++U+6+249Pm9yDR1vpE2++-w2+++8++++++++++2+
6+++++UR++-MJ2JHJ16iI23HI2g-+VE+3++0++U+N6hj6ZfVgmhc+U++ZUI+++c+++++++++
+E+U++++-Fw++3VIFJBIAmtEEJBEGk203++I++6+0+0wWawWnqAuqisB++1FDE++0U++++++
+++-+0++++0J6E++K3N7FJRH9Z--Ip-9+E6I+-E++U+6+B0VQ06Zvw1YnEI++DUP+++A++++
++++++2+6++++8gj++-BHpN7FJFHJ0tEEJBEGk203++I++6+0+-gc4oWT7HV93w3++-Z2U++
0k+++++++++-+0++++0WBE++J3NBHpN7FGtEEJBEGk203++I++6+0++LaKsWiP0BcL67+++w
8U++0U+++++++++-+0+++++eCk++HJB5Ho789Z--Ip-9+E6I+-E++U+6+DCJPG7EZ8JZtEA+
++oB+++6++++++++++2+6++++AF2++-MEJ-E9Z--Ip-9+E6I+-E++U+6+DGJPG74MkzIU+2+
+7w1+++7++++++++++2+6++++Ax6++-MJ2JHJ0tEEJBEGkI4++++++o+1E1S+U++RYc+++++
***** END OF BLOCK 5 *****

