(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0053.PAS
  Description: TV Broadcast Message
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  09:53
*)

{
   This program will create two modaless dialog boxes and will
   allow only one Dialog2 dialog to be created at any time.

   Additionally, it will demonstrate how to broadcast messages to
   background windows and update information without changing
   the selected dialog.

}
{$X+}

Program DialogCommunication;

uses Objects, Drivers, Views, Menus, Dialogs, App, Crt;
const
  cmDialog1 = 100;
  cmDialog2 = 101;
  cmDialog1Button = 200;
  cmDialog2Button = 201;

type

 PHelloApp = ^THelloApp;
  THelloApp = object(TApplication)
    procedure MakeDialog;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

  PMyDialog1 = ^TMyDialog1;
  TMyDialog1 = object(TDialog)
    procedure MakeDialog2;
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

  PMyDialog2 = ^TMyDialog2;
  TMyDialog2 = object(TMyDialog1)
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

procedure TMyDialog1.HandleEvent(var Event: TEvent);
var
  AreYouThere: PView;
begin
  TDialog.HandleEvent(Event);
  if Event.What = evCommand then
    begin
      case Event.Command of
         cmDialog1Button:
           begin
             AreYouThere:= Message(DeskTop, evBroadcast, cmDialog2, nil);
             if AreYouThere = nil then
                MakeDialog2
              else
                ClearEvent(Event);
           end
      else
        Exit;
      end;
        ClearEvent(Event);
    end;
end;

procedure TMyDialog1.MakeDialog2;
var
  Dialog2: PMyDialog2;
  R: TRect;
  Button: PButton;
begin
  R.Assign(1,1,40,20);
  Dialog2:= New(PMyDialog2, init(R,'Dialog2'));
  R.Assign(10,10,20,12);
  Button:= New(PButton,Init(R,'Beep', cmDialog2Button, bfdefault));
  Dialog2^.Insert(Button);
  DeskTop^.Insert(Dialog2);
end;

procedure TMyDialog2.HandleEvent(var Event: TEvent);
begin
  case Event.Command of
    cmDialog2: begin
                 sound(2000); delay(10); nosound;
                 Title:=newstr('Hello world');
                 ReDraw;
                 ClearEvent(Event);
               end;
  end;
  TDialog.HandleEvent(Event);
  if Event.What = evCommand then
    begin
      case Event.Command of
         cmDialog2Button: begin
                            Sound(1000); delay(100); NoSound;
                          end;
      else
        Exit;
      end;
        ClearEvent(Event);
    end;
end;

{ THelloApp }

procedure THelloApp.MakeDialog;
var
  R:TRect;
  Button1: PButton;
  Dialog1: PMyDialog1;
begin
  R.Assign(25, 5, 65, 16);
  Dialog1:= New(PMyDialog1, init(R,'Dialog1'));
  R.Assign(16, 8, 38, 10);
  Button1:= New(PButton, Init(R,'Call Dialog2', cmDialog1Button, bfDefault));
  Dialog1^.Insert(Button1);
  DeskTop^.Insert(Dialog1);
end;

procedure THelloApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    begin
      case Event.Command of
         cmDialog1:begin
                     MakeDialog;
                   end;
      else
        Exit;
      end;
        ClearEvent(Event);
     end;
end;

procedure THelloApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~O~pen Dialogs', hcNoContext, NewMenu(
      NewItem('~D~ialog1','', 0, cmDialog1, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit,
        hcNoContext, nil)))), nil))));
end;

procedure THelloApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit, nil)), nil)));
end;

var
  HelloWorld: THelloApp;

begin
  HelloWorld.Init;
  HelloWorld.Run;
  HelloWorld.Done;
end.

