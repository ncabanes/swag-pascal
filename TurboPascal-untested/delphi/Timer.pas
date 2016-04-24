(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0339.PAS
  Description: Timer
  Author: APOGEE INFORMATION SYSTEMS
  Date: 08-30-97  10:09
*)


Delphi Timer Component
Created by : Adam Chace, Apogee Information Systems, Inc.

Description :
  This component enhances the Delphi timer component by allowing easier control over the interval function. Instead of having to provide the user with three separate edit boxes to control hours, minutes and seconds, developers can drop this visual component on their form. The user is provided with spin buttons that can be used by mouse or keyboard to set the integer. The developer can then call the "GetTotalSec" and get the total number of seconds represented by the time the user entered. No time conversion is necessary.

Using the Component :
  The hours, minutes, or seconds can be set by clicking the spin button 
to increment/decrement, or by tabbing into the individual box and pressing 
either the up or down arrow key.  Values can be manually entered as well 
by highlighting the proper box and typing the desired value. The developer can then call the "GetTotalSec" and get the total number of seconds represented in this visual component.  You can then just set the timer's "interval" to this value, as the interval property for a ttimer needs to be in seconds.  The component performs conversion for the number of hours, minutes and seconds into seconds.

It could also be used to allow users to easily enter any time, like the time a specific event occurred, the time a record was entered etc.  Simply drop this component onto the form and grab the data the user enters in it by accessing the hour, minute and second properties or by calling the GetTime method which returns the time the user entered as a TDateTime type.
  
Key Properties :
    		Hour
                ----
                  Integer value of the hour represented in the TaisHMSBox.
                Minute
                ------
                  Integer value of the minute represented in the TaisHMSBox.
                Second
                ------
                  Integer value of the second represented in the TaisHMSBox.

      Methods
      =======
                GetHour: Integer;
                ----------------
                  Returns the integer value of the hour(s) selected.

                GetMinute: Integer;
                -------------------
                  Returns the integer value of the minute(s) selected.

                GetSecond: Integer;
                ------------------
                  Returns the integer value of the second(s) selected.

                GetTime: TDateTime;
                -------------------
                  Returns the time chosen as a TDateTime;

                GetTotalSec: longint;
                ---------------------
                  Especially useful for setting timers, converts the
                  time to seconds and returns this value as a longint.

Any feedback, comments, etc. are welcome.  Please reply to achace@apogeeis.com

About Apogee Information Systems, Inc.

Apogee is an elite consulting and development firm specializing exclusively in Delphi, IntraBuilder and Paradox.  We assist clients by creating scalable desktop, Client/Server and data-driven Web applications that meet critical business needs.  For more information on our services, contact us at:

Phone: 	(508) 481-1400
FAX:	(508) 481-3343
Email:	dpainter@apogeeis.com

Apogee Information Systems, Inc.
5 Mount Royal Avenue
Marlboro, MA 01752

Visit Apogee Online at http://www.apogeeis.com

________________________ Copy From Here ________________________________
{Copyright (c) 1996 Apogee Information Systems, Inc.}

unit Aishms;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Spin;

type
  TaisHMSBox = class(TCustomPanel)
  private
    FHourEdit: TEdit;
    FMinuteEdit: TEdit;
    FSecondEdit: TEdit;
    FSpin: TSpinButton;
    FTheOne: Char;
    function CreateEdit : TEdit;
    function CreateSpin: TSpinButton;
    function CreateLabel : TLabel;
    procedure SpinUp(Sender: TObject);
    procedure SpinDown(Sender: TObject);
    procedure EditOnEnter(Sender: TObject);
    procedure EditOnExit(Sender: TObject);
    procedure EditOnKeyDown(Sender: TOBject; var Key: Word; Shift: TShiftState);
    procedure IncHour;
    procedure IncMinute;
    procedure IncSecond;
    procedure DecSecond;
    procedure DecHour;
    procedure DecMinute;
    property IsTheOne : Char read FTheOne write FTheOne;
    { Private declarations }
  protected
    { Protected declarations }
  public
    fHour: Integer;
    fMinute : Integer;
    fSecond: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure SetHour(Value: Integer);
    procedure SetMinute(Value: Integer);
    procedure SetSecond(Value: Integer);
    function GetHour: Integer;
    function GetMinute: Integer;
    function GetSecond: Integer;
    function GetTotalSec: longint;
    function GetTime: TDateTime;
    { Public declarations }
  published
    property Color;
    property BorderStyle;
    property TabStop;
    property TabOrder;
    property Hour : Integer
      read GetHour write SetHour;
    property Minute: Integer
      read GetMinute write SetMinute;
    property Second : Integer
      read GetSecond write SetSecond;
    { Published declarations }
  end;

procedure Register;

implementation

{Return the total seconds represented by the values in hour, minute and second}
{Especially useful for use with timer components}
function TaisHMSBox.GetTotalSec :longint;
var
  tmp : longint;
begin
  tmp := (fHour * 3600);
  tmp := tmp + (fMinute * 60);
  tmp := tmp + Second;
  Result := tmp;
end;

{Return the time represented in the aisHMSBox}
function TaisHMSBox.GetTime: TDateTime;
begin
  Result := EncodeTime(fHour, fMinute, fSecond, 0);
end;

procedure TaisHMSBox.EditOnEnter(Sender: TObject);
begin
  If TEdit(Sender).Name = 'Hour' then
    begin
      TEdit(Sender).Color := clYellow;
      IsTheOne := 'H';
    end;
  If TEdit(Sender).Name = 'Minute' then
    begin
      TEdit(Sender).Color := clYellow;
      IsTheOne := 'M';
    end;
  If TEdit(Sender).Name = 'Second' then
    begin
      TEdit(Sender).Color := clYellow;
      IsTheOne := 'S';
    end;
end;

procedure TaisHMSBox.EditOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Ord(Key) = VK_UP) then
    begin
      Case IsTheOne of
       'H':     IncHour;
       'M':     IncMinute;
       'S':     IncSecond;
      end; {case}
    end;
  if (Ord(Key) = VK_DOWN) then
    begin
      Case IsTheOne of
       'H':     DecHour;
       'M':     DecMinute;
       'S':     DecSecond;
      end; {case}
    end;
end;


procedure TaisHMSBox.EditOnExit(Sender: TObject);
var
 newval: integer;
begin
  If TEdit(Sender).Name = 'Hour' then
    begin
      try
        newval :=StrToInt(TEdit(Sender).Text);
        SetHour(newval);
      except
        SetHour(fHour);
      end;
      TEdit(Sender).Color := clWhite;
      IsTheOne := 'N';
    end;
  If TEdit(Sender).Name = 'Minute' then
    begin
      try
        newval :=StrToInt(TEdit(Sender).Text);
        SetMinute(newval);
      except
       SetMinute(fMinute);
      end;
      TEdit(Sender).Color := clWhite;
      IsTheOne := 'N';
    end;
  If TEdit(Sender).Name = 'Second' then
    begin
      try
        newval := StrToInt(TEdit(Sender).Text);
        SetSecond(newval);
      except
        SetSecond(fSecond);
      end;
      TEdit(Sender).Color := clWhite;
      IsTheOne := 'N';
    end;
end;

procedure TaisHMSBox.IncHour;
begin
  if (fHour > 23) then
    SetHour(0)
  else
    SetHour(fHour + 1);
end;

procedure TaisHMSBox.DecHour;
begin
  if (fHour < 1) then
    SetHour(23)
  else
    SetHour(fHour - 1);
end;

procedure TaisHMSBox.IncMinute;
begin
  if (fMinute > 58) then
    SetMinute(0)
  else
    SetMinute(fMinute + 1);
end;

procedure TaisHMSBox.DecMinute;
begin
  if (fMinute < 1) then
    SetMinute(59)
  else
    SetMinute(fMinute - 1);
end;

procedure TaisHMSBox.IncSecond;
begin
  if (fSecond > 58) then
    SetSecond(0)
  else
    SetSecond(fSecond + 1);
end;

procedure TaisHMSBox.DecSecond;
begin
  if (fSecond < 1) then
    SetSecond(59)
  else
    SetSecond(fSecond - 1);
end;


procedure TaisHMSBox.SpinUp(Sender: TObject);
begin
  Case IsTheOne of
       'H':     IncHour;
       'M':     IncMinute;
       'S':     IncSecond;
  end;
end;

procedure TaisHMSBox.SpinDown(Sender: TObject);
begin
  Case IsTheOne of
       'H':     DecHour;
       'M':     DecMinute;
       'S':     DecSecond;
  end;
end;

procedure TaisHMSBox.SetHour(Value: Integer);
begin
  fHour := Value;
  FHourEdit.Text := IntToStr(Value);
  FHourEdit.Repaint;
end;

function TaisHMSBox.GetHour: Integer;
begin
  Result := fHour;
end;

function TaisHMSBox.GetMinute: Integer;
begin
  Result := fMinute;
end;

function TaisHMSBox.GetSecond: Integer;
begin
  Result := fSecond;
end;

procedure TaisHMSBox.SetMinute(Value: Integer);
begin
  fMinute := Value;
  FMinuteEdit.Text := IntToStr(Value);
end;

procedure TaisHMSBox.SetSecond(Value: Integer);
begin
  fSecond := Value;
  FSecondEdit.Text := IntToStr(Value);
end;

function TaisHMSBox.CreateLabel: TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := self;
  Result.Alignment := taCenter;
  Result.Font.Name := 'MS Sans Serif';
  Result.Visible := True;
end;

function TaisHMSBox.CreateEdit: TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Color := clWhite;
  Result.Parent := Self;
  Result.Visible := True;
  Result.OnKeyDown := EditOnKeyDown;
  Result.OnEnter := EditOnEnter;
  Result.OnExit := EditOnExit;
end;

function TaisHMSBox.CreateSpin: TSpinButton;
begin
  Result := TSpinButton.Create(Self);
  Result.Parent := Self;
  Result.OnDownClick := SpinDown;
  Result.OnUpClick := SpinUp;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TaisHMSBox]);
end;

constructor TaisHMSBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BorderStyle := bsSingle;
  FHourEdit := CreateEdit;
  FMinuteEdit := CreateEdit;
  FSecondEdit := CreateEdit;
  FHourEdit.Name :='Hour';
  FMinuteEdit.Name :='Minute';
  FSecondEdit.Name := 'Second';
  FSpin := CreateSpin;
  fHour := 0;
  fMinute := 0;
  fSecond := 0;
end;

procedure TaisHMSBox.Paint;
begin
  {inherited Paint;}
  self.caption := '';
  if self.width > 125 then self.width := 125;
  if self.height >40 then self.height := 40;
  FHourEdit.Width := (self.width div 5);
  FMinuteEdit.Width := (self.width div 5);
  FSecondEdit.Width := (self.width div 5);
  FHourEdit.Height := ((self.height * 4) div 6);
  FMinuteEdit.Height:= FHourEdit.Height;
  FSecondEdit.Height:= FHourEdit.Height;
  FHourEdit.Top := ((self.height div 2) - (FHourEdit.Height div 2));
  FMinuteEdit.Top := FHourEdit.Top;
  FSecondEdit.Top := FHourEdit.Top;
  FHourEdit.Left := 2;
  FMinuteEdit.Left := FHourEdit.Left + FMinuteEdit.Width + 4;
  FSecondEdit.Left := FMinuteEdit.Left + FSecondEdit.Width + 4;
  FHourEdit.Font.Name := 'MS Sans Serif';
  FMinuteEdit.Font.Name := 'MS Sans Serif';
  FSecondEdit.Font.Name := 'MS Sans Serif';
  FHourEdit.Font.Size := (FHourEdit.Height - (FHourEdit.Height * 2) div 3);
  FSecondEdit.Font.Size := FHourEdit.Font.Size;
  FMinuteEdit.Font.Size := FHourEdit.Font.Size;
  with FSpin do
    begin
      Width := FHourEdit.Width;
      Height := self.Height;
      Left := self.width - FSpin.Width;
      Align := alTop;
      Font.Size := FHourEdit.Font.Size;
      Visible := True;
    end;
end;
end.



