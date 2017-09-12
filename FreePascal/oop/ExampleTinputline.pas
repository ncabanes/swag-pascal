(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0051.PAS
  Description: Example TInputline
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  09:47
*)

{
This program will create a record structure of two strings
and initialize them with data then read them into a
TInputLine.  The program will use the SetData and GetData
procedures to load and store from the TInputLine Object.

}
{$X+}
program Example;

uses Objects, Drivers, Views, Menus, Dialogs, App;

const
  cmNewDialog     = 100;
  hcMyDialog      = 300;

type
  MyData = record
    Mystr1:String[10];                       { Create a Record Structure }
    MyStr2:String[10];
    end;

var
 RMyData:MyData;                             { Declare it }

type
  TMyApp = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure NewDialog;
  end;

  PDemoDialog = ^TDemoDialog;
  TDemoDialog = object(TDialog)
   Procedure HandleEvent(var Event:TEvent);virtual;
  end;

constructor TMyApp.Init;
var
  R : TRect;
begin
  TApplication.Init;                              {Initialize it }
  RMydata.MYstr1:='What';
  RMydata.MYstr2:='Cheese';
  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
end;
{ TMyApp }

Procedure TDemoDialog.HandleEvent(var Event:TEvent);
begin
 TDialog.HandleEvent(Event);
  if Event.What = EvCommand then
    begin
     if event.what = EvCommand then
     case Event.Command of
       cmOK:begin
              GetData(RMyData);    {Get The Data in Declaration Order}
              TDialog.Done;
            end;
       cmCancel:Tdialog.done;
      end
       else
       Exit;
     end;
 clearEvent(Event);
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewDialog: NewDialog;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil)),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
       NewItem('~D~ialog','F2', kbF2, cmNewDialog, hcmyDialog,
      nil)),
    nil))
  )));
end;

procedure TMyApp.NewDialog;
var
  Borland: PView;
  Dialog: PDemoDialog;
  R: TRect;
  {C: Word;}
begin
  R.Assign(20, 6, 60, 19);
  Dialog := New(PDemoDialog, Init(R, 'Demo Dialog'));
  with Dialog^ do
  begin
    R.Assign(3, 3, 18, 4);
    Borland := New(PInputLine, Init(R,10));
    Insert(Borland);
    R.Assign(3, 4, 18, 5);
    Borland := New(PInputLine, Init(R,10));
    Insert(Borland);
    R.Assign(2, 2, 10, 3);
    Insert(New(PLabel, Init(R, 'Cheeses', Borland)));
    R.Assign(22, 3, 34, 5);
    Borland := New(PRadioButtons, Init(R,
      NewSItem('~R~unny',
      NewSItem('~M~elted',
      nil)))
    );
    Insert(Borland);
    R.Assign(21, 2, 33, 3);
    Insert(New(PLabel, Init(R, 'Consistency', Borland)));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOk, bfDefault)));
    R.Assign(28, 8, 38, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(RMyData);        {Dialog Setdata with Record Structure}
  DeskTop^.Insert(Dialog);
end;
var
  MyApp: TMyApp;

begin

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
