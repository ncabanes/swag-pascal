(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0079.PAS
  Description: Windows SOUND routines
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  11:03
*)


program SoundProg;
uses WinTypes, WinProcs, WObjects;
const
  ButtonID= 100;

type
  TMyApp = object(TApplication)
   procedure InitMainWindow; virtual;
  end;

  PMyWindow = ^TMyWindow;
  TMyWindow = object(TWindow)
      But: PButton;
      DurationCount: integer;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure MakeNoise(var Msg: TMessage); virtual id_First + ButtonID;
    procedure WMKillFocus(var Msg: TMessage); virtual wm_First + wm_KillFocus;
  end;

procedure TMyApp.InitMainWindow;
begin
  MainWindow:= new(PMyWindow,init(nil,'Sound Window'));
end;

constructor TMyWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  DurationCount:= 0;
  TWindow.Init(AParent, ATitle);
  but:= New(PButton,init(@self,ButtonId,'&Make Noise',10,10,100,50,false));
end;

procedure TMyWindow.MakeNoise(var Msg: TMessage);
const
  Duration = 100;
var
  err: integer;
  Pitch: integer;
begin
  OpenSound;
  for Pitch:= 1 to 84 do
    begin                 
      SetVoiceNote(1, Pitch, 10, 1);
    end;
  StartSound;
  WaitSoundState(S_QueueEmpty);
  StopSound;
  CloseSound;
end;


procedure TMyWindow.WMKillFocus(var Msg: TMEssage);
begin
  messageBeep(0);
end;


var
  x: TMyApp;
begin
  x.Init('Test');
  x.Run;
  x.Done;
end.
