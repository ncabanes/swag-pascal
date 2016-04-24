(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0076.PAS
  Description: Turbo Vision
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:51
*)


program TV132;

{ this program shows how to put a Turbo Vision application in
  132 column mode.  it is written specifically for an ATI VGA
  card but can be modified for other cards.  also your mouse
  drive must be able to support 132 columns. }

{$X+}
uses
   objects, drivers, views, app, dialogs , menus, dos;
const
  cm_DoIt = 100;

type
   PMyApp = ^TMyApp;
   TMyApp = object(TApplication)
     procedure InitMenuBar; virtual;
     procedure InitScreen; virtual;

     procedure HandleEvent(var Event: TEvent); virtual;
     procedure CMDoIt;
   end;

   PMyDialog = ^TMyDialog;
   TMyDialog = object(TDialog)
     procedure InitFrame; virtual;
     procedure HandleEvent(var Event: TEvent); virtual;
   end;

   PMyFrame = ^TMyFrame;
   TMyFrame = object(TFrame)
     procedure Draw; virtual;
   end;

procedure TMyFrame.Draw;
begin
end;

procedure TMyDialog.InitFrame;
var
  R: TRect;
begin
  TDialog.InitFrame;
(*

  R.Assign(0, 0, Size.X, Size.Y);
  Frame := new(PMyFrame, init(R));
*)
end;

procedure TMyApp.CMDoIt;
var
  D: PMyDialog;
  ILine : PInputLine;
  R: TRect;
begin
  R.Assign(5, 5, 25, 12);
  new(D, init(R, 'Do It'));
  D^.SetState(sfShadow, false);
  R.Assign(1, 1, 19, 2);
  new(ILine, init(R, 20));
  R.Assign(1, 3, 19, 4);
  D^.Insert(Iline);
  D^.Insert(new(PInputline, init(R, 20)));
  R.Assign(1, 5, 11, 7);
  D^.Insert(new(PButton, Init(R, '~O~k', cmOk, bfDefault)));

  Iline^.Select;
  Desktop^.ExecView(D);
end;

procedure TMyDialog.HandleEvent(var Event: TEvent);
begin
  if Event.What = evKeyDown then
    if Event.KeyCode = kbEnter then
      Event.KeyCode := kbTab;
  TDialog.HandleEvent(Event);
end;

procedure TMyApp.InitMenuBar;
var R:TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewItem('~D~o it', '', kbNoKey, cm_DoIt, hcNoContext,
    nil)
  )));
end;

procedure TMyApp.HandleEvent(var Event: TEvent);

begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    if Event.Command = cm_DoIt then
    begin
      CMDoIt;
    end;
end;

procedure TMyApp.InitScreen;
{ this procedure is specific to an ATI VGA Card, you may need to
  modify if you have a different video card. }
begin
  TApplication.InitScreen;
  asm
    mov ah, 0
    mov al, 23H
    int 10H
  end;
  ScreenMode := $23;
  ScreenHeight := 25;
  ScreenWidth := 132;
end;

var

  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.



