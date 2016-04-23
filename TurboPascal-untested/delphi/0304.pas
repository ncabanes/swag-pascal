
This is a control for playing avi files.

unit AVICtrl;

interface

{                           TAVIControl V 0.9b
                              Programmed by
                              Andrea Molino
                           easytarg@mbox.vol.it
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, CommCtrl;

Type
  TAVIControlState = (acsClose, acsOpen, acsPlay);
  TAVIControlError = (acrOK, acrOpenFailed, acrPlayFailed, acsSeekFailed);

  TAVIControl = class(TWinControl)
  private
    FAVIState: TAVIControlState;
    FAVIName: String;
    FFrameFrom: SmallInt;
    FFrameTo: SmallInt;
    FFrameSeek: SmallInt;
    FAutoSize: Boolean;
    FAutoRepeat: Boolean;
    FLastOpStatus: TAVIControlError;
    FAux: String;
    Procedure SetAVIState(Val: TAVIControlState);
    Procedure SetAVIName(Val: String);
    Procedure SetFrameFrom(Val: SmallInt);
    Procedure SetFrameTo(Val: SmallInt);
    Procedure SetFrameSeek(Val: SmallInt);
    Procedure SetAutoSize(Val: Boolean);
    Procedure SetAutoRepeat(Val: Boolean);
    Function  GetLastOpStatus: String;
  protected
    procedure CreateParams(var Params: TCreateParams); Override;
    procedure CreateWnd; Override;
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    Function  Open(FileName: String): Boolean;
    Procedure Close;
    Function  Play(FName: String; RepCount: SmallInt): Boolean;
    Function  Seek(Frame: SmallInt): Boolean;
    Procedure Stop;
  published
    Property AVIState: TAVIControlState Read FAVIState Write SetAVIState Default acsClose;
    Property AVIName: String Read FAVIName Write SetAVIName;
    Property FrameFrom: SmallInt Read FFrameFrom Write SetFrameFrom Default 0;
    Property FrameTo: SmallInt Read FFrameTo Write SetFrameTo Default -1;
    Property FrameSeek: SmallInt Read FFrameSeek Write SetFrameSeek Default 0;
    Property AutoSize: Boolean Read FAutoSize Write SetAutoSize Default False;
    Property AutoRepeat: Boolean Read FAutoRepeat Write SetAutoRepeat Default True;
    Property ZStatus: String Read GetLastOpStatus Write FAux;
    property Align;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

Constructor TAVIControl.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle -[csSetCaption];
  FAVIState := acsClose;
  FFrameFrom := 0;
  FFrameTo := -1;
  FAutoSize := False;
  FAutoRepeat := True;
  FLastOpStatus := acrOK;
  Width := 30;
  Height := 30;
End;

Destructor TAVIControl.Destroy;
Begin
  Inherited Destroy;
End;

procedure TAVIControl.CreateParams(var Params: TCreateParams);
begin
{ACS_AUTOPLAY    - Starts playing the animation as soon as the animation clip is opened.
 ACS_CENTER      - Centers the animation in the animation control's window.
 ACS_TRANSPARENT - Draws the animation using a transparent background rather than
                   the background color specified in the animation clip.}
  InitCommonControls;
  Inherited CreateParams(Params);
  CreateSubClass(Params, 'SysAnimate32');
  With Params do
  Begin
    Style := Style Or ACS_TRANSPARENT;
    If Not FAutoSize Then Style := Style Or ACS_CENTER;
  End;
end;

procedure TAVIControl.CreateWnd;
begin
  Inherited CreateWnd;
  If FAVIState = acsOpen Then Open(FAVIName);
  If FAVIState = acsPlay Then
  Begin
    Open(FAVIName);
    Play('', 0);
  End;
end;

Procedure TAVIControl.SetAVIState(Val: TAVIControlState);
Begin
  If Val <> FAVIState Then
  Begin
    FAVIState := Val;
    Case FAVIState Of
      acsOpen : Begin
                  Open(FAVIName)
                End;
      acsPlay : Begin
                  Open(FAVIName);
                  Play('', 0);
                End;
      acsClose: Close;
    End;
  End;
End;

Procedure TAVIControl.SetAVIName(Val: String);
Var
  FTmpState: TAVIControlState;
Begin
  If Val <> FAVIName Then
  Begin
    FAVIName := Val;
    FTmpState := FAVIState;
    Close;
    If FTmpState = acsOpen Then Open(FAVIName);
    If FTmpState = acsPlay Then Play('', 0);
  End;
End;

Procedure TAVIControl.SetFrameFrom(Val: SmallInt);
Begin
  If Val <> FFrameFrom Then
  Begin
    FFrameFrom := Val;
    If FAVIState = acsPlay Then Play('', 0);
  End;
End;

Procedure TAVIControl.SetFrameTo(Val: SmallInt);
Begin
  If Val <> FFrameTo Then
  Begin
    FFrameTo := Val;
    If FAVIState = acsPlay Then Play('', 0);
  End;
End;

Procedure TAVIControl.SetFrameSeek(Val: SmallInt);
Begin
  If Val <> FFrameSeek Then
  Begin
    FFrameSeek := Val;
    Seek(FrameSeek);
  End;
End;

Procedure TAVIControl.SetAutoSize(Val: Boolean);
Begin
  If Val <> FAutoSize Then
  Begin
    FAutoSize := Val;
    RecreateWnd;
  End;
End;

Procedure TAVIControl.SetAutoRepeat(Val: Boolean);
Begin
  If Val <> FAutoRepeat Then
  Begin
    FAutoRepeat := Val;
    If FAVIState = acsPlay Then Play('', 0);
  End;
End;

Function TAVIControl.GetLastOpStatus: String;
Begin
  Case FLastOpStatus Of
    acrOK        : Result := 'OK';
    acrOpenFailed: Result := 'Open Failed';
    acrPlayFailed: Result := 'Play Failed';
  End;
End;

Function TAVIControl.Open(FileName: String): Boolean;
Var
  Res: LongInt;
Begin
  FLastOpStatus := acrOK;
  If FAVIState <> acsClose Then Close;
  Res := SendMessage(Handle, ACM_OPEN, 0, LongInt(PChar(FileName)));
  FAVIName := FileName;
  If Res <> 0 Then FAVIState := acsOpen
  Else FLastOpStatus := acrOpenFailed;
  Result := (Res <> 0);
End;

Procedure TAVIControl.Close;
Var
  Res: LongInt;
Begin
  FLastOpStatus := acrOK;
  Res := SendMessage(Handle, ACM_OPEN, 0, 0);
  FAVIState := acsClose;
  Repaint;
End;

Function TAVIControl.Seek(Frame: SmallInt): Boolean;
Var
  Res: LongInt;
Begin
  FLastOpStatus := acrOK;
  If FAVIState = acsClose Then Open(FAVIName)
  Else If FAVIState = acsPlay Then Stop;
  If FAVIState <> acsClose Then
  Begin
    Res := SendMessage(Handle, ACM_PLAY, 1, MAKELONG(Frame, Frame));
    If Res = 0 Then FLastOpStatus := acsSeekFailed;
    Result := (Res <> 0);
  End
  Else Result := False;
End;

Function TAVIControl.Play(FName: String; RepCount: SmallInt): Boolean;
Var
  Res: LongInt;
  Rep: SmallInt;
Begin
  FLastOpStatus := acrOK;
  If FName = '' Then Open(FAVIName)
  Else Open(FName);
  If FAVIState <> acsClose Then
  Begin
    If FAutoRepeat And (RepCount = 0) Then Rep := -1
    Else If RepCount = 0 Then Rep := 1
    Else Rep := RepCount;
    Res := SendMessage(Handle, ACM_PLAY, Rep, MAKELONG(FFrameFrom, FFrameTo));
    If (Res <> 0) And FAutoRepeat Then FAVIState := acsPlay
    Else FLastOpStatus := acrPlayFailed;
    Result := (Res <> 0);
  End
  Else Result := False;
End;

Procedure TAVIControl.Stop;
Var
  Res: LongInt;
Begin
  FLastOpStatus := acrOK;
  If FAVIState <> acsClose Then
  Begin
    Res := SendMessage(Handle, ACM_PLAY, 0, MAKELONG(0, 0));
    If FAVIState = acsPlay Then FAVIState := acsOpen;
  End;
End;

procedure Register;
begin
  RegisterComponents('MyGold', [TAVIControl]);
end;

end.
