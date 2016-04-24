(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0177.PAS
  Description: Floating toolbar with no title bar
  Author: ANDERS OHLSSON
  Date: 08-30-96  09:36
*)


Someone asked for some code to make a form with no title bar moveable, kind of like a
floating toolbar, for example FreeDock. Actually, for some of the stuff in here I
spied on the FreeDock sources...

This requires the use of some WinAPI functions. All WinAPI functions are however
available at a touch of a key (F1 - OnLine Help)...

Here's some code that does this (about 100 lines)...

To make this work like intended:

Cut out the DFM, DPR and PAS files below :

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    OldX,
    OldY,
    OldLeft,
    OldTop   : Integer;
    ScreenDC : HDC;
    MoveRect : TRect;
    Moving   : Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    SetCapture(Panel1.Handle);
    ScreenDC := GetDC(0);
    OldX := X;
    OldY := Y;
    OldLeft := X;
    OldTop := Y;
    MoveRect := BoundsRect;
    DrawFocusRect(ScreenDC,MoveRect);
    Moving := True;
  end;
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Moving then begin
    DrawFocusRect(ScreenDC,MoveRect);
    OldX := X;
    OldY := Y;
    MoveRect := Rect(Left+OldX-OldLeft,Top+OldY-OldTop,
                     Left+Width+OldX-OldLeft,Top+Height+OldY-OldTop);
    DrawFocusRect(ScreenDC,MoveRect);
  end;
end;

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    ReleaseCapture;
    DrawFocusRect(ScreenDC,MoveRect);
    Left := Left+X-OldLeft;
    Top := Top+Y-OldTop;
    ReleaseDC(0,ScreenDC);
    Moving := False;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  TitleHeight,
  BorderWidth,
  BorderHeight : Integer;
begin
  TitleHeight := GetSystemMetrics(SM_CYCAPTION);
  BorderWidth := GetSystemMetrics(SM_CXBORDER)+GetSystemMetrics(SM_CXFRAME)-1;
  BorderHeight := GetSystemMetrics(SM_CYBORDER)+GetSystemMetrics(SM_CYFRAME)-2;
  if BorderStyle = bsNone then begin
    BorderStyle := bsSizeable;
    Top := Top-TitleHeight-BorderHeight;
    Height := Height+TitleHeight+2*BorderHeight;
    Left := Left-BorderWidth;
    Width := Width+2*BorderWidth;
  end
  else begin
    BorderStyle := bsNone;
    Top := Top+TitleHeight+BorderHeight;
    Height := Height-TitleHeight-2*BorderHeight;
    Left := Left+BorderWidth;
    Width := Width-2*BorderWidth;
  end;
end;

end.

{ DFM FILE - form file}

object Form1: TForm1
  Left = 245
  Top = 137
  BorderStyle = bsNone
  Caption = 'Form1'
  ClientHeight = 101
  ClientWidth = 198
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 185
    Height = 41
    BorderStyle = bsSingle
    Caption = 'Panel1'
    TabOrder = 0
    OnMouseDown = Panel1MouseDown
    OnMouseMove = Panel1MouseMove
    OnMouseUp = Panel1MouseUp
  end
  object Panel2: TPanel
    Left = 8
    Top = 56
    Width = 185
    Height = 41
    Caption = 'Come Caption'
    TabOrder = 1
    object Button1: TButton
      Left = 52
      Top = 8
      Width = 87
      Height = 25
      Caption = 'Toggle Title Bar'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end

{ DPR FILE }

program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

