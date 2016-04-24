(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0146.PAS
  Description: Status Bar Component
  Author: CRAIG WARD
  Date: 08-30-96  09:35
*)

{
 Author:    Craig Ward
 Copyright: none - public domain

 Date:      20/5/96

 Version:   1.0

 Overview:  Status bar

 Notes:     The captions for each panel (stored within the wrapper component),
            can be accessed via their index. The indices are:
             [0] status panel
             [1] caps-lock panel
             [2] num-lock panel
             [3] scroll-lock panel
             [4] time panel

            The component will automatically check for the state of the caps-lock,
            num-lock, and scroll-lock keys, plus, it will also display the current
            time (all achieved through a private TTimer). Furthermore, the
            component will also automatically display any application hint, by
            setting the application's OnHint method to the custom method that
            is used by the TTimer.
*******************************************************************************}
unit Cwstatus;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type

  {container object for panels}
  TStatusPanel = class(TPanel)
  private
    { Private declarations }
    FStatusPanel: TPanel;            {the comment panel}
    FCapsPanel: TPanel;              {the caps-lock panel}
    FNumPanel: TPanel;               {the num-lock panel}
    FScrollPanel: TPanel;            {the scroll-lock panel}
    FTimePanel: TPanel;              {the time panel}
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

  {wrapper for component}
  TcwStatusBar = Class(TWinControl)
    StatusPanel: TStatusPanel;
    FTimer: TTimer;
  private
    function GetCaption(Index: Integer): string;
    procedure SetCaption(Index: Integer; Cap: string);
    procedure mTimer(sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Captions[Index: Integer]: string read GetCaption write SetCaption;
  published
    property Font;
    property ParentFont;
    property Align;
  end;

procedure Register;

implementation

{***VCL Preferences************************************************************}

{constructor -
 note: panels created in reverse order}
constructor TStatusPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
   Align := alBottom;            {default to bottom of form}

  {create time panel}
  FTimePanel := TPanel.Create(self);
  with FTimePanel do
  begin
    Parent := self;              {set parent to self}
    width := 65;
    Align := alRight;            {set alignment to right}
    BevelOuter := bvLowered;     {set bevel appearances}
    BevelInner := bvLowered;
    Caption := 'Time';           {set caption text}
    Alignment := taLeftJustify;  {left-justify caption}
    ParentFont := true;          {assume the parent's font}
  end;

  {create scroll-lock panel}
  FScrollPanel := TPanel.Create(self);
  with FScrollPanel do
  begin
    Parent := self;              {set parent to self}
    width := 40;
    Align := alRight;            {set alignment to right}
    BevelOuter := bvLowered;     {set bevel appearances}
    BevelInner := bvLowered;
    Caption := 'Scroll';         {set caption text}
    Alignment := taLeftJustify;  {left-justify caption}
    ParentFont := true;          {assume the parent's font}
  end;

  {create num-lock panel}
  FNumPanel := TPanel.Create(self);
  with FNumPanel do
  begin
    Parent := self;              {set parent to self}
    width := 40;
    Align := alRight;            {set alignment to right}
    BevelOuter := bvLowered;     {set bevel appearances}
    BevelInner := bvLowered;
    Caption := 'Num';            {set caption text}
    Alignment := taLeftJustify;  {left-justify caption}
    ParentFont := true;          {assume the parent's font}
  end;

  {create caps-lock panel}
  FCapsPanel := TPanel.Create(self);
  with FCapsPanel do
  begin
    Parent := self;              {set parent to self}
    width := 40;
    Align := alRight;            {set alignment to right}
    BevelOuter := bvLowered;     {set bevel appearances}
    BevelInner := bvLowered;
    Caption := 'Caps';           {set caption text}
    Alignment := taLeftJustify;  {left-justify caption}
    ParentFont := true;          {assume the parent's font}
  end;

  {create comment panel}
  FStatusPanel := TPanel.Create(self);
  with FStatusPanel do
  begin
    Parent := self;              {set parent to self}
    Align := alClient;           {set alignment to client}
    BevelOuter := bvLowered;     {set bevel appearances}
    BevelInner := bvLowered;
    Caption := 'Status Panel';   {set caption text}
    Alignment := taLeftJustify;  {left-justify caption}
    ParentFont := true;          {assume the parent's font}
  end;

end;

{constructor - for wrapper}
constructor TcwStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

   {create status-panel}
   Align := alBottom;                        {default to alBottom}
   StatusPanel := TStatusPanel.Create(self); {create a TStatusPanel instance}
   with StatusPanel do
   begin
     Parent := self;                         {set parent to self}
     Align := alClient;                      {set alignment to client}
   end;
   Height := 25;

   {create TTimer}
   FTimer := TTimer.create(self);
   with FTimer do
    begin
     OnTimer := mTimer;
     interval := 250;                        {update panels quarter of a second}
     enabled := true;
    end;

   {set application's OnHint to the custom method, used by the TTimer. This will
    force the application, when a hint is encountered, to be displayed in the
    panel.}
   application.onHint := mTimer;

   {call timer method - this ensures that the application will open with a
    status-bar that is configured and running}
   mTimer(self);

end;

{destructor - for wrapper}
destructor TcwStatusBar.Destroy;
begin
  inherited Destroy;
end;

{return caption (of panel in index)}
function TcwStatusBar.GetCaption(Index: Integer): string;
begin
  case Index of
    0: result := StatusPanel.FStatusPanel.caption;
    1: result := StatusPanel.FCapsPanel.caption;
    2: result := StatusPanel.FNumPanel.caption;
    3: result := StatusPanel.FScrollPanel.caption;
    4: result := StatusPanel.FTimePanel.caption;
    { Show error if any other Index was entered }
    else MessageDlg('Invalid Index Value', mtWarning, [mbOk], 0);
  end;
end;

{set caption (of panel in index)}
procedure TcwStatusBar.SetCaption(Index: Integer; Cap: string);
begin
  case Index of
    0: StatusPanel.FStatusPanel.Caption := cap;
    1: StatusPanel.FCapsPanel.Caption := cap;
    2: StatusPanel.FNumPanel.caption := cap;
    3: StatusPanel.FScrollPanel.caption := cap;
    4: StatusPanel.FTimePanel.caption := cap;
    { Show an error if any other Index was entered }
    else MessageDlg('Invalid Index Value', mtWarning, [mbOk], 0);
  end;
end;

{register}
procedure Register;
begin
  RegisterComponents('cw_apps', [TcwStatusBar]);
end;

{***custom routines************************************************************}

{on timer, update captions}
procedure TcwStatusBar.mTimer(sender: TObject);
begin

 {set hint}
 Captions[0] := ' '+application.hint;

 {set caps lock}
 if GetKeyState(VK_CAPITAL) <> 0 then
  Captions[1] := ' CAP'
 else
  Captions[1] := '';

 {set num lock}
 if GetKeyState(VK_NUMLOCK) <> 0 then
  Captions[2] := ' NUM'
 else
  Captions[2] := '';

 {set scroll lock}
 if GetKeyState(VK_SCROLL) <> 0 then
  Captions[3] := ' SCRL'
 else
  Captions[3] := '';

 {set time}
 Captions[4] := ' '+TimeToStr(now);

end;

{}
end.

