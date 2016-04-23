unit App_prop;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TDuplicateError = class(Exception);
  TMainFormError = class(Exception);
  TApplicationProperties = class(TComponent)
  private
    { Private declarations }
    fHint : String;
    fHintColor : TColor;
    fHintPause : Integer;
    fShowHint : Boolean;

    fOnActivate : TNotifyEvent;
    fOnDeactivate : TNotifyEvent;
    fOnException : TExceptionEvent;
    fOnHelp : THelpEvent;
    fOnHint : TNotifyEvent;
    fOnIdle : TIdleEvent;
    fOnMessage : TMessageEvent;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
      override;
    destructor Destroy;
      override;
    procedure Loaded;
      override;
  published
    { Published declarations }
    property Hint : String
      read fHint write fHint;
    property HintColor : TColor
      read fHintColor write fHintColor;
    property HintPause : Integer
      read fHintPause write fHintPause;
    property ShowHint : Boolean
      read fShowHint write fShowHint;

    property OnActivate : TNotifyEvent
      read fOnActivate write fOnActivate;
    property OnDeactivate : TNotifyEvent
      read fOnDeactivate write fOnDeactivate;
    property OnException : TExceptionEvent
      read fOnException write fOnException;
    property OnHelp : THelpEvent
      read fOnHelp write fOnHelp;
    property OnHint : TNotifyEvent
      read fOnHint write fOnHint;
    property OnIdle : TIdleEvent
      read fOnIdle write fOnIdle;
    property OnMessage : TMessageEvent
      read fOnMessage write fOnMessage;
  end;

procedure Register;

implementation

var
  ComponentCounter : Integer;

constructor TApplicationProperties.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Inc(ComponentCounter);
  if ComponentCounter > 1 then
    raise TDuplicateError.Create('You can have only ' +
      'one ApplicationProperties component in a project');

  fHintColor := Application.HintColor;
  fHintPause := Application.HintPause;
  fShowHint := Application.ShowHint;
end;

destructor TApplicationProperties.Destroy;
begin
  inherited Destroy;
  Dec(ComponentCounter);
end;

procedure TApplicationProperties.Loaded;
begin
  if fHint <> '' then
    Application.Hint := fHint;
  if fHintColor <> Application.HintColor then
    Application.HintColor := fHintColor;
  if fHintPause <> Application.HintPause then
    Application.HintPause := fHintPause;
  if fShowHint <> Application.ShowHint then
    Application.ShowHint := fShowHint;

  if Assigned(fOnActivate) then
    Application.OnActivate := fOnActivate;
  if Assigned(fOnDeactivate) then
    Application.OnDeactivate := fOnDeactivate;
  if Assigned(fOnException) then
    Application.OnException := fOnException;
  if Assigned(fOnHelp) then
    Application.OnHelp := fOnHelp;
  if Assigned(fOnHint) then
    Application.OnHint := fOnHint;
  if Assigned(fOnIdle) then
    Application.OnIdle := fOnIdle;
  if Assigned(fOnMessage) then
    Application.OnMessage := fOnMessage;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TApplicationProperties]);
end;

initialization
  ComponentCounter := 0;
end.
