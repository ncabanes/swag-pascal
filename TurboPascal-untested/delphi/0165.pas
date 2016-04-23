{******** unit1.pas  ********}
unit unit1;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FileCtrl, MPlayer, MMSystem, Spin, ComCtrls;
type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    GroupBox2: TGroupBox;
    TrackBar1: TTrackBar;
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
      var DoDefault: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    function GetTrackBar: integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  pCurrentVolumeLevel: PDWord;
  CurrentVolumeLevel: DWord;
  VolumeControlHandle: hWnd;
implementation
{$R *.DFM}
procedure TForm1.FileListBox1DblClick(Sender: TObject);
begin
  if checkbox1.checked then
     mediaplayer1.DisplayRect := Rect(0,0, Panel1.Width, Panel1.Height);
  mediaplayer1.play;
end;
procedure TForm1.FileListBox1Click(Sender: TObject);
begin
  mediaplayer1.filename := FileListBox1.items[filelistbox1.itemindex];
  mediaplayer1.open;
end;
procedure TForm1.MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
  var DoDefault: Boolean);
begin
  case Button of
    btPlay :
    if checkbox1.checked then
       mediaplayer1.DisplayRect := Rect(0,0, Panel1.Width, Panel1.Height);
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  DirectoryListBox1.Directory := 'd:\sound';
  mediaplayer1.notify := true;
  New(pCurrentVolumeLevel);
end;
procedure TForm1.MediaPlayer1Notify(Sender: TObject);
begin
  Panel1.refresh;
  with Mediaplayer1 do
    if NotifyValue = nvAborted then begin
       filename := FileListBox1.items[filelistbox1.itemindex];
       open;
    end;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  dispose(pCurrentVolumeLevel);
end;
function TForm1.GetTrackBar: integer;
begin
  result := 65535 div Trackbar1.max;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
  VolumeControlHandle := FindWindow('Volume Control', nil);
  WaveOutGetVolume(VolumeControlHandle, pCurrentVolumeLevel);
  CurrentVolumeLevel := pCurrentVolumeLevel^;
  Trackbar1.position := LoWord(CurrentVolumeLevel) DIV GetTrackBar;
end;
procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  CurrentVolumeLevel := Trackbar1.position * GetTrackBar shl 16;
  CurrentVolumeLevel := CurrentVolumeLevel + (Trackbar1.position * GetTrackBar);
  if WaveOutSetVolume(VolumeControlHandle, CurrentVolumeLevel) <> 0 then
    ShowMessage('Cannot adjust Volume.');
end;
end.
{********** unit1.dfm  *********}
object Form1: TForm1
  Left = 202
  Top = 109
  Width = 402
  Height = 321
  ActiveControl = DriveComboBox1
  BorderIcons = [biSystemMenu]
  Caption = 'Mediaplayer Example - Created using Delphi 2.0'
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF008888
    888888888888888888888888888888888888888888880000FEEFEFF000088888
    8888888888880000FEEFEFF0000888888888888888880770EFFEFEE070088888
    8888888888880000FEEFEFF00008888888888888888807700000000070088888
    888888888888077000000000700888888888888888880000FFFFFFF000088888
    8888888888880770EFFEFEE0700888888888888888880000FEEFEFF000088888
    8888888888880000FEEFEFF0000888888888888888880770EFFEFEE070088888
    888888888888000000000000000888808888888888880770FFFFFFF070088880
    8888888888880770FFFFFFF0700880000888888088880000FEEFEFF000088880
    0008800008880770EFFEFEE0700888888008888000080000FEEFEFF000088888
    8008888000080000FEEFEFF00008888880088888800807700000000070088888
    8008888880080000FFFFFFF0000888888008888880080770EFFEFEE070088888
    8008888880080770EFFEFEE0700888888008888880080000FEEFEFF000088888
    8008888880088888888888888888888880000000000888888888888888888888
    8000000000088888888888888888888880033333300888888888888888888888
    8000000000088888888888888888888888888888888888888888888888888888
    8888888888888888888888888888888888888888888888888888888888880000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MediaPlayer1: TMediaPlayer
    Left = 152
    Top = 240
    Width = 141
    Height = 33
    VisibleButtons = [btPlay, btPause, btStop, btPrev, btBack]
    Display = Panel1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = MediaPlayer1Click
    OnNotify = MediaPlayer1Notify
  end
  object DriveComboBox1: TDriveComboBox
    Left = 0
    Top = 0
    Width = 145
    Height = 19
    DirList = DirectoryListBox1
    TabOrder = 1
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 0
    Top = 22
    Width = 145
    Height = 114
    FileList = FileListBox1
    ItemHeight = 16
    TabOrder = 2
  end
  object FileListBox1: TFileListBox
    Left = 0
    Top = 139
    Width = 145
    Height = 141
    ItemHeight = 13
    Mask = '*.wav;*.avi'
    MultiSelect = True
    TabOrder = 3
    OnClick = FileListBox1Click
    OnDblClick = FileListBox1DblClick
  end
  object Panel1: TPanel
    Left = 152
    Top = 8
    Width = 241
    Height = 225
    TabOrder = 4
  end
  object CheckBox1: TCheckBox
    Left = 218
    Top = 275
    Width = 76
    Height = 17
    Caption = 'Stretch AVI'
    State = cbChecked
    TabOrder = 5
  end
  object GroupBox2: TGroupBox
    Left = 296
    Top = 234
    Width = 97
    Height = 53
    Caption = 'Volume'
    TabOrder = 6
    object TrackBar1: TTrackBar
      Left = 2
      Top = 11
      Width = 93
      Height = 34
      Max = 26
      Orientation = trHorizontal
      ParentShowHint = False
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      ShowHint = True
      TabOrder = 0
      TickMarks = tmBoth
      TickStyle = tsAuto
      OnChange = TrackBar1Change
    end
  end
end
