{
This answer involves opening an existing Word file that has a bookmark already saved.  This code will select and replace the text at the bookmark with our own text, and then it will print.
Note:  The ExecuteMacro() commands are separated into different buttons because of a timing issue.  If you want everything to work from the same procedure, change the TRUE to FALSE.
}
unit Unit1;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DdeMan, StdCtrls;
type
  TForm1 = class(TForm)
    Button1: TButton;
    DCC: TDdeClientConv;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
implementation
{$R *.DFM}
procedure TForm1.Button1Click(Sender: TObject);
var
  P: PChar;
begin
  WinExec('e:\winapps\winword\winword.exe', sw_ShowNormal);
  with DCC do begin
    SetLink('winword', '');
    if not OpenLink then
      ShowMessage('Link not established')
    else
      ExecuteMacro('[FileOpen("c:\temp\foobar.doc")]', True);
  end;
end;
procedure TForm1.Button2Click(Sender: TObject);
begin
  DCC.ExecuteMacro('[EditGoTo("TheBookmarkName")]', True);
end;
procedure TForm1.Button3Click(Sender: TObject);
begin
  DCC.ExecuteMacro('[Insert("This is the new text that is inserted.")]', True);
end;
procedure TForm1.Button4Click(Sender: TObject);
begin
  DCC.ExecuteMacro('[FilePrint]', True);
end;
end.
{****************************************************}
object Form1: TForm1
  Left = 202
  Top = 102
  Width = 403
  Height = 89
  Caption = 'Form1'
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 16
  object Button1: TButton
    Left = 8
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Open'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 104
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Find Bkmk'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 200
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Replace'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 296
    Top = 16
    Width = 89
    Height = 33
    Caption = 'Print'
    TabOrder = 3
    OnClick = Button4Click
  end
  object DCC: TDdeClientConv
    ConnectMode = ddeManual
  end
end
