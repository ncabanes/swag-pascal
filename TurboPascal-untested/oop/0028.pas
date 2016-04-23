{
From: BRIAN PAPE
Subj: Picklist in TV
}

{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program PickList;

uses Objects, Views, Dialogs, App, Drivers,editors;
const
  cmPickClicked = 1001;
type
  PCityColl = ^TCityColl;
  TCityColl = object(TStringCollection)
    constructor Init;
  end;

  PPickLine = ^TPickLine;
  TPickLine = object(TMemo)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PPickWindow = ^TPickWindow;
  TPickWindow = object(TDialog)
    constructor Init;
  end;

  TPickApp = object(TApplication)
    PickWindow: PPickWindow;
    constructor Init;
  end;

VAR Lijst:PCityColl;
    GControl: PView;
    S  : String[30];


constructor TCityColl.Init;
begin
  inherited Init(10, 10);
  Insert(NewStr('Scotts Valley'));
  Insert(NewStr('Sydney'));
  Insert(NewStr('Copenhagen'));
  Insert(NewStr('London'));
  Insert(NewStr('Paris'));
  Insert(NewStr('Munich'));
  Insert(NewStr('Milan'));
  Insert(NewStr('Tokyo'));
  Insert(NewStr('Stockholm'));
end;

procedure TPickLine.HandleEvent(var Event: TEvent);
VAR
  Count:Integer;
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.command=cmListItemSelected) then
    begin
      S:=PListBox(Event.InfoPtr)^.GetText(PListBox(Event.InfoPtr)^.Focused,
                                          high(s));
      with PListBox(Event.InfoPtr)^ do
      begin
        s := s + #13;
        InsertText(@s[1],length(s),false);
      end;
      DrawView;
      ClearEvent(Event);
    end;
end;

constructor TPickWindow.Init;
var
  R: TRect;
  Control: PView;
  ScrollBar: PScrollBar;
begin
  R.Assign(0, 0, 40, 15);
  inherited Init(R, 'Pick List Window');
  Options := Options or ofCentered;
  R.Assign(5, 2, 35, 4);
  Control := New(Ppickline, Init(R,NIL,NIL,NIL, 130));
  Control^.EventMask := Control^.EventMask or evBroadcast;
  Insert(Control);
  R.Assign(4, 1, 13, 2);
  Insert(New(PLabel, Init(R, 'Picked:', Control)));
  R.Assign(34, 5, 35, 11);
  New(ScrollBar, Init(R));
  Insert(ScrollBar);
  R.Assign(5, 5, 34, 11);
  gControl := New(PListBox, Init(R, 1, ScrollBar));
  Insert(gControl);
  PListBox(gControl)^.NewList(Lijst);
  R.Assign(4, 4, 12, 5);
  Insert(New(PLabel, Init(R, 'Items:', Control)));
  R.Assign(15, 12, 25, 14);
  Insert(New(PButton, Init(R, '~Q~uit', cmQuit, bfDefault)));
end;

constructor TPickApp.Init;
begin
  inherited Init;
  Lijst:=New(PCityColl,Init);
  PickWindow := New(PPickWindow, Init);
  InsertWindow(PickWindow);
end;

var
  PickApp: TPickApp;
begin
  PickApp.Init;
  PickApp.Run;
  PickApp.Done;
end.

