(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0087.PAS
  Description: OOP percent bar TurboVision
  Author: TOM WELLIGE
  Date: 08-30-97  10:08
*)

{ see test program at the end of this unit !! }
{************************************************}
{                                                }
{   UNIT INFOBAR   A procent bar                 }
{   Copyright (c) 1997 by Tom Wellige            }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, Germany        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

unit infobar;

{$X+,V-,O+,F+}

interface

uses Drivers, Objects, Views;

type
  PInfoBarRec = ^ TInfoBarRec;
  TInfoBarRec = record
                  Text1,           { not blinking text }
                  Text2: string;   { blinking text }
                  Size: LongInt;
                end;

  PInfoBar = ^TInfoBar;
  TInfoBar = object(TView)
      Text1, Text2: string;  { Text1 blinks not, Text2 blinks }
      max, actuell: LongInt;
      ShowBar: boolean;
    constructor Init(Bounds: TRect; ARec: PInfoBarRec);
    procedure   HandleEvent(var Event: TEvent); virtual;
    function    GetPalette: PPalette; virtual;
    procedure   Draw; virtual;
    procedure   Update(ARec: PInfoBarRec);
    procedure   Reset(ARec: PInfoBarRec);
  end;


const
  cmInfoBarRec   = 4100;
  cmResetInfoBar = 4101;
  CInfoBar       = #19#20;

implementation


(********************************************************************)
(**                       TInfoBar                                 **)
(********************************************************************)

constructor TInfoBar.Init(Bounds: TRect; ARec: PInfoBarRec);
begin
  inherited Init(Bounds);
  Text1:= ARec^.Text1;  { not blinking text }
  Text2:= ARec^.Text2;  { blinking text }
  if ARec^.Size <> 0 then
  begin
    ShowBar:= true;
    Max    :=  ARec^.Size;
  end else
  begin
    ShowBar:= false;
    Max:= 0;
  end;
  Actuell:= 0;
end;

procedure TInfoBar.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
    case Event.Command of
      cmInfoBarRec:   Update(PInfoBarRec(Event.InfoPtr));
      cmResetInfoBar: Reset(PInfoBarRec(Event.InfoPtr));
    end;
end;


function TInfoBar.GetPalette: PPalette;
const
  P : string[Length(CInfoBar)] = CInfoBar;
begin
  GetPalette := PPalette(@P);
end;

procedure TInfoBar.Draw;
var
  Buf: TDrawBuffer;
  Color1: Byte;
  Color2: Byte;
  i, First, Second, Last, Act: integer;
  chr, attr: word;
  s: string;
begin
  Color1:= GetColor(1);
  Color2:= GetColor(2);

  First := (Size.X div 2) - (length(Text1+Text2) div 2);   (* start Text1  *)
  Second:= First + length(Text1);                          (* start Text2  *)
  Last  := Second + length(Text2);                         (* end Text2    *)
  if Actuell < Max then Act:= (Size.X * Actuell) div Max   (* current pos. *)
                   else Act:= Size.X;

  if not ShowBar then
  begin
    MoveChar(Buf, ' ', Color1, Size.X);
    WriteLine(0, 0, Size.X, 1, Buf);
    if length(Text1+Text2)<= Size.X then
    begin
      MoveStr(Buf, Text1, Color1);
      WriteLine(First, 0, length(Text1), 1, Buf);
      MoveStr(Buf, Text2, Color1+128);
      WriteLine(Second, 0, length(Text2), 1, Buf);
    end;
  end else
  begin
    (* bar not visible *)
    if act = 0 then
    begin
      MoveChar(Buf, ' ', Color1, Size.X);
      WriteLine(0, 0, Size.X, 1, Buf);
      if length(Text1+Text2)<= Size.X then
      begin
        MoveStr(Buf, Text1, Color1);
        WriteLine(First, 0, length(Text1), 1, Buf);
        MoveStr(Buf, Text2, Color1+128);
        WriteLine(Second, 0, length(Text2), 1, Buf);
      end;
    end;

    (* bar before Text1 *)
    if Act < First then
    begin
      MoveChar(Buf, ' ', Color2, Act);
      WriteLine(0, 0, Act, 1, Buf);
    end else

    (* bar inside Text1 *)
    if Act < Second then
    begin
      MoveChar(Buf, ' ', Color2, First);
      WriteLine(0, 0, First, 1, Buf);
      if Act - First > 0 then
      begin
        s:= copy(Text1, 1, Act-First);
        MoveStr(Buf, s, Color2);
        WriteLine(First, 0, length(s), 1, Buf);
      end;
    end else

    (* bar inside Text2 *)
    if Act < Last then
    begin
      MoveChar(Buf, ' ', Color2, First);
      WriteLine(0, 0, First, 1, Buf);
      MoveStr(Buf, Text1, Color2);
      WriteLine(First, 0, length(Text1), 1, Buf);
      MoveStr(Buf, copy(Text2, 1, Act-Second), Color2+128);
      WriteLine(Second, 0, length(copy(Text2, 1, Act-Second)), 1, Buf);
    end else

    (* bar behind Text2 *)
    begin
      MoveChar(Buf, ' ', Color2, First);
      WriteLine(0, 0, First, 1, Buf);
      MoveStr(Buf, Text1, Color2);
      WriteLine(First, 0, length(Text1), 1, Buf);
      MoveStr(Buf, Text2, Color2+128);
      WriteLine(Second, 0, length(Text2), 1, Buf);
      MoveChar(Buf, ' ', Color2, Act-Last);
      WriteLine(Last, 0, Act-Last, 1, Buf);
    end;
  end;
end;


procedure TInfoBar.Update(ARec: PInfoBarRec);
begin
  if ARec^.Text1 <> '' then
    Text1:= ARec^.Text1;
  if ARec^.Text2 <> '' then
    Text2:= ARec^.Text2;
  if ARec^.Size <> 0 then
    if Max <> 0 then
      if ARec^.Size > Actuell then Actuell:= ARec^.Size;
  DrawView;
end;

procedure TInfoBar.Reset(ARec: PInfoBarRec);
begin
  if ARec^.Text1 <> '' then
    Text1:= ARec^.Text1;
  if ARec^.Text2 <> '' then
    Text2:= ARec^.Text2;
  Max    := ARec^.Size;
  Actuell:= 0;
  if Max <> 0 then
    ShowBar:= true else
    ShowBar:= false;
  DrawView;
end;


end.

{************************************************}
{                                                }
{   PROGRAM INFOTEST   Testapp for Unit INFOBAR  }
{   Copyright (c) 1997 by Tom Wellige            }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, Germany        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

program infotest;

uses dos, drivers, objects, app, views, dialogs, menus, infobar;

type
  TMyApp = object(TApplication)
      pInfo   : PInfoBar;   { the "procent" bar }
      activ   : boolean;    { is bar curretnly active ? }
      lastsec : word;       { last time }
      cursec  : longint;    { num of seconds since start }

    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitStatusLine; virtual;
    { will be called when there is nothing else to do }
    procedure Idle; virtual;
    { starts the bar }
    procedure StartIdle;
    { opens the bar dialog }
    procedure Print;
  end;

  PPrint = ^TPrint;
  TPrint = object(TDialog)
    constructor Init(var pInfo: PInfoBar);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const
  cmStart     = 100;    { will be used by the dialog }
  cmPrint     = 1000;   { will be used by the application }
  cmStartIdle = 1001;   { dialog sends this message to application }

  maxsec: longint = 20; { number of seconds until bar reaches the end }


(********************************************************************)
(**                        TMyApp                                  **)
(********************************************************************)

procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  { user wants to open the bar dialog }
  if Event.What = evCommand then
    if Event.Command = cmPrint then Print;
  { user has pressed the "start" button inside the dialog }
  if Event.What = evBroadCast then
    if Event.Command = cmStartIdle then StartIdle;
  ClearEvent(Event);
end;


procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y:= R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit',               kbAltX,  cmQuit,
      NewStatusKey('~F3~ Print',                 kbF3,    cmPrint,
      NewStatusKey('',                           kbAltF3, cmClose,
      nil))),
    nil)));
end;


procedure TMyApp.Idle;
var
  hh, mm, ss, hs: word;
  Rec: TInfoBarRec;
begin
  inherited Idle;

  { as long the dialog is not opend and so the infobar object is
    not in memory nothing happens }
  if assigned (pInfo) then
  begin
    { was the start button pressed ? }
    if activ then
    begin
      GetTime(hh,mm,ss,hs);

      { is one secnd left since last bar update ? }
      if ss <> lastsec then
      begin
        lastsec:= ss;
        inc(cursec);
        { are we still in time ? }
        if cursec <= maxsec then
        begin
          { set new bar value. as long as Text1 and Text2 are '' they
            won't be changed }
          with Rec do
          begin
            Text1:= '';
            Text2:= '';
            Size := cursec;
          end;
          Message(pInfo, evBroadCast, cmInfoBarRec, @Rec);
        end else
        begin
          { "maxsec" are over, everything back to start position }
          write(#7);
          activ:= false;
          EnableCommands([cmStart]);
          with Rec do
          begin
            Text1:= 'press the ';
            Text2:= 'start button';
            Size := maxsec;
          end;
          Message(pInfo, evBroadCast, cmResetInfoBar, @Rec);
        end;
      end;
    end;
  end;
end;


procedure TMyApp.StartIdle;
var Rec: TInfoBarRec;
begin
  { now the Idle will know that it's time to update the infobar }
  activ:= true;
  { reset number of seconds }
  cursec:= 0;
  with Rec do
  begin
    Text1:= 'just doing something...';
    Text2:= ' ';  { IMPORTANT: must be at least one character to force
                               the update of this value }
    Size := 0;
  end;
  { send all values to inforbar }
  Message(pInfo, evBroadCast, cmInfoBarRec, @Rec);
end;


procedure TMyApp.Print;
var
  p: PPrint;
begin
  p:= new(PPrint, Init(pInfo));
  ExecuteDialog(p, nil);
  pInfo:= nil;
end;


(********************************************************************)
(**                        TPrint                                  **)
(********************************************************************)

constructor TPrint.Init(var pInfo: PInfoBar);
var
  R: TRect;
  Rec: TInfoBarRec;
  Control: PView;
begin
  R.Assign(14, 5, 65, 18);
  inherited Init(R, '');
  Options:= Options or ofCenterX or ofCenterY;


  { start values for Text1, Text2 and Size }
  with Rec do
  begin
    Text1:= 'press the ';
    Text2:= 'start button';
    Size := maxsec;
  end;

  R.Assign(5, 5, 46, 6);
  pInfo:= New(PInfoBar, Init(R, @rec));
  Insert(pInfo);

  R.Assign(19, 9, 30, 11);
  Control:= New(PButton, Init(R, '~S~tart', cmStart, bfDefault));
  Insert(Control);

  SelectNext(False);
end;


procedure TPrint.HandleEvent(var Event: TEvent);
begin
  if Event.What = evCommand then
    if Event.Command = cmStart then
  begin
    { disable button }
    DisableCommands([cmStart]);
    { ok, application's Idle methode will do the rest }
    Message(Application, evBroadCast, cmStartIdle, nil);
    ClearEvent(Event);
  end;
  inherited HandleEvent(Event);
end;



(********************************************************************)
(**                         Main                                   **)
(********************************************************************)

var MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.

