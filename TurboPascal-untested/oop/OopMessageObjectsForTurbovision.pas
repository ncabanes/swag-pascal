(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0090.PAS
  Description: OOP Message objects for TurboVision
  Author: TOM WELLIGE
  Date: 08-30-97  10:08
*)

{************************************************}
{                                                }
{   UNIT MSGOBJ   MessageObjects                 }
{   Copyright (c) 1993-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

unit MsgObj;

{$O+,F+,X+,I-,S-}

interface

uses Objects, Drivers, App, Views, Menus, Dialogs, MsgBox;

type
  { display any messages in this status line }
  PMsgStatusLine = ^TMsgStatusLine;
  TMsgStatusLine = object (TStatusLine)
      MsgText: string;
      ShowHint: boolean;
    constructor Init(var Bounds: TRect; ADefs: PStatusDef);
    procedure HandleEvent(var Event: TEvent); virtual;
    function  GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure Update; virtual;
  private
    procedure DrawMessage;
    procedure FindItems;
  end;

  { change the displayed text by a message }
  PMsgStaticText = ^TMsgStaticText;
  TMsgStaticText = object(TStaticText)
      cmMessage: Word;
      txt: string;
    constructor Init(var Bounds: TRect; AText: String; ACommand: word);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
    procedure SetText(AText: string); virtual;
  end;

  { this text is not only changeable it is also colored }
  PMsgColoredText = ^TMsgColoredText;
  TMsgColoredText = object(TStaticText)
      Attr : Byte;
      cmMessage: Word;
      txt: string;
    constructor Init(var Bounds: TRect; AText: String;
                     ACommand: word; Attribute : Byte);
    function GetTheColor : byte; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
    procedure SetText(AText: string); virtual;
  end;

  { change the text inside an inputline with a simple message }
  PMsgInputLine = ^TMsgInputLine;
  TMsgInputLine = object(TInputLine)
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

  { by changing the focus in the list a message will be created }
  PMsgListBox = ^TMsgListBox;
  TMsgListBox = object(TListBox)
      Command: word;
    constructor Init(var Bounds: TRect; ANumCols: Word;
                     AScrollBar: PScrollBar; ACommand: word);
    procedure FocusItem(Item: Integer); virtual;
  end;

  { displayes a changeable text inside a dialog }
  PMsgDialog = ^TMsgDialog;
  TMsgDialog = object(TDialog)
       Text: string;
       P: PStaticText;
    constructor Init(var Bounds: TRect; ATitle: string);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const

{ TMsgStatusLine messages }
  cmStatusLineMessage = 1000;
  cmStatusLineRestore = 1001;
  cmShowHint          = 1002;

{ TMsgStatictext & TMsgColoredText }
  cmTextMessage       = 1003;

{ TMsgDialog messages }
  cmShowMessageText   = 1004;

  cmShowText          = 1020;   { Message - Command }


implementation

{ -------------- TMsgDialog --------------------}

constructor TMsgDialog.Init(var Bounds: TRect; ATitle: string);
begin
  inherited Init(Bounds, ATitle);
  Options:= Options and ofCentered;
  Text:= '';
  P:= nil;
end;

procedure TMsgDialog.HandleEvent(var Event: TEvent);
var R: TRect;
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadCast) and (Event.Command = cmShowMessageText) then
  begin
    if P <> nil then
    begin
      Delete(P);
      Dispose(P, Done);
    end;
    GetExtent(R);
    R.Grow(-2, -2);
    P:= New(PStaticText, Init(R, PString(Event.InfoPtr)^));
    insert(P);
  end;
end;


{ -------------- TMsgStatusLine ----------------}

constructor TMsgStatusLine.Init(var Bounds: TRect; ADefs: PStatusDef);
begin
  inherited Init(Bounds, ADefs);
  MsgText:= '';
  ShowHint:= false;
end;

procedure TMsgStatusLine.HandleEvent(var Event: TEvent);
begin
  if Event.What=evBroadcast then
    case Event.Command of
     cmStatusLineMessage:
       begin
         MsgText:= PString(Event.InfoPtr)^;
         DrawView;
         ClearEvent(Event);
       end;
     cmStatusLineRestore:
       begin
         MsgText:= '';
         DrawView;
         ClearEvent(Event);
       end;
     cmShowHint:
       begin
         if Event.InfoPtr <> nil then
         begin
           ShowHint:= true;
           HelpCtx:= Word(Event.InfoPtr^);
           Update;
         end else
           if ShowHint then
           begin
             ShowHint:= false;
             Update;
           end;
         ClearEvent(Event);
       end;
  end;
  inherited HandleEvent(Event);
end;


procedure TMsgStatusLine.Update;
var
  P: PView;
  H: word;
begin
  if ShowHint then
  begin
    FindItems;
    DrawView;
  end else
  begin
    P:= Application^.TopView;
    if P <> nil then
      H:= P^.GetHelpCtx else
      H:= hcNoContext;
    if HelpCtx <> H then
    begin
      HelpCtx := H;
      FindItems;
      DrawView;
    end;
  end;
end;

procedure TMsgStatusLine.FindItems;
var
  P: PStatusDef;
begin
  P := Defs;
  while (P <> nil) and ((HelpCtx < P^.Min) or (HelpCtx > P^.Max)) do
    P := P^.Next;
  if P = nil then Items := nil else Items := P^.Items;
end;

function TMsgStatusLine.GetPalette: PPalette;
const
  P: string[Length(CStatusLine)] = CStatusLine;
begin
  GetPalette := PPalette(@P);
end;

procedure TMsgStatusLine.Draw;
begin
  if MsgText <> '' then DrawMessage else
  begin
    inherited Draw;
  end;
end;

procedure TMsgStatusLine.DrawMessage;
var
  B: TDrawBuffer;
  I, L: Integer;
  Color:  Word;
  MsgBuf: string;
begin
  Color := GetColor($0103);
  MoveChar(B, ' ', Byte(Color), Size.X);
  MsgBuf := MsgText;
  L:= 0;
  if MsgBuf <> '' then
  begin
      if Length(MsgBuf) > Size.X then
           MsgBuf := copy(MsgBuf, 1, Size.X);
      MoveCStr(B[L+1], MsgBuf, Byte(Color));
  end;
  WriteLine(0, 0, Size.X, 1, B);
end;


{ ----------------- TMsgStaticText ------------------ }

constructor TMsgStaticText.Init(var Bounds: TRect; AText: string;
                                ACommand: word);
begin
  inherited Init(Bounds, AText);
  EventMask := EventMask or evBroadcast;
  cmMessage:= ACommand;
  SetText(AText);
end;

procedure TMsgStaticText.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmMessage) then
  begin
     SetText(PString(Event.InfoPtr)^);
     ClearEvent(Event);
     DrawView;
  end;
end;

procedure TMsgStaticText.SetText(AText: string);
begin
  Txt:= AText;
  DisposeStr(Text);
  Text:= NewStr(Txt);
end;

procedure TMsgStaticText.Draw;
var
  Color: Byte;
  Center: Boolean;
  I, J, L, P, Y: Integer;
  B: TDrawBuffer;
  S: String;
begin
  Color := GetColor(1);
  GetText(S);
  L := Length(S);
  P := 1;
  Y := 0;
  Center := False;
  while Y < Size.Y do
  begin
    MoveChar(B, ' ', Color, Size.X);
    if P <= L then
    begin
      if S[P] = #3 then
      begin
        Center := True;
        Inc(P);
      end;
      I := P;
      repeat
        J := P;
        while (P <= L) and (S[P] = ' ') do Inc(P);
        while (P <= L) and (S[P] <> ' ') and (S[P] <> #13) do Inc(P);
      until (P > L) or (P >= I + Size.X) or (S[P] = #13);
      if P > I + Size.X then
        if J > I then P := J else P := I + Size.X;
      if Center then J := (Size.X - P + I) div 2 else J := 0;
      MoveBuf(B[J], S[I], Color, P - I);
      while (P <= L) and (S[P] = ' ') do Inc(P);
      if (P <= L) and (S[P] = #13) then
      begin
        Center := False;
        Inc(P);
        if (P <= L) and (S[P] = #10) then Inc(P);
      end;
    end;
    WriteLine(0, Y, Size.X, 1, B);
    Inc(Y);
  end;
end;


{ ---------- TMsgColorStaticText ------------------ }

constructor TMsgColoredText.Init(var Bounds: TRect; AText: String;
                                  ACommand: word; Attribute : Byte);
begin
  inherited Init(Bounds, AText);
  EventMask := EventMask or evBroadcast;
  cmMessage:= ACommand;
  SetText(AText);
  Attr := Attribute;
end;

procedure TMsgColoredText.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmMessage) then
  begin
     SetText(PString(Event.InfoPtr)^);
     ClearEvent(Event);
     DrawView;
  end;
end;

function TMsgColoredText.GetTheColor : byte;
begin
if AppPalette = apColor then
  GetTheColor := Attr
else
  GetTheColor := GetColor(1);
end;

procedure TMsgColoredText.SetText(AText: string);
begin
  Txt:= AText;
  DisposeStr(Text);
  Text:= NewStr(Txt);
end;

procedure TMsgColoredText.Draw;
var
  Color: Byte;
  Center: Boolean;
  I, J, L, P, Y: Integer;
  B: TDrawBuffer;
  S: String;
begin
  Color := GetTheColor;
  GetText(S);
  L := Length(S);
  P := 1;
  Y := 0;
  Center := False;
  while Y < Size.Y do
  begin
    MoveChar(B, ' ', Color, Size.X);
    if P <= L then
    begin
      if S[P] = #3 then
      begin
        Center := True;
        Inc(P);
      end;
      I := P;
      repeat
        J := P;
        while (P <= L) and (S[P] = ' ') do Inc(P);
        while (P <= L) and (S[P] <> ' ') and (S[P] <> #13) do Inc(P);
      until (P > L) or (P >= I + Size.X) or (S[P] = #13);
      if P > I + Size.X then
        if J > I then P := J else P := I + Size.X;
      if Center then J := Size.X - P + I div 2 else J := 0;
      MoveBuf(B[J], S[I], Color, P - I);
      while (P <= L) and (S[P] = ' ') do Inc(P);
      if (P <= L) and (S[P] = #13) then
      begin
        Center := False;
        Inc(P);
        if (P <= L) and (S[P] = #10) then Inc(P);
      end;
    end;
    WriteLine(0, Y, Size.X, 1, B);
    Inc(Y);
  end;
end;

{ ---------- TMsgInputLine ------------------ }

procedure TMsgInputLine.HandleEvent(var Event:TEvent);
var s: string;
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadCast then
    if Event.Command = cmShowText then
    begin
      s:= PString(Event.InfoPtr)^;
      SetData(s);
    end;
end;

{ ---------- TMsgListBox -------------------- }

constructor TMsgListBox.Init(var Bounds: TRect; ANumCols: Word;
                             AScrollBar: PScrollBar; ACommand: word);
begin
  inherited Init(Bounds, ANumCols, AScrollBar);
  Command:= ACommand;
end;

procedure TMsgListBox.FocusItem(Item: Integer);
var s: string;
begin
  inherited FocusItem(Item);
  Message(Owner, evBroadCast, Command, nil);
end;





end.

