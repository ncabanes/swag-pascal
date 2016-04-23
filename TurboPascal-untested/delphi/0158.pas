
{Here's an implementation (based on Pat's WinExecAndWait32) that uses a thread, so that your application can continue to process windows messages (and do something else) while it waits for the launched application to finish.}

unit WinExec;
interface
uses
  Classes, SysUtils, Windows;
type
  TWinExec = class(TThread)
  private
    FFileName, FArguments: String;
    FProcessActive: boolean;
    FOnProcessIdle: TNotifyEvent;
  public
    constructor Create(AppName, Args : String; OnExit, OnIdle : TNotifyEvent);
  protected
    procedure Execute; override;
    function StartApp(AppName, ArgStr :String; Visibility : integer):integer;
  end;
type
  FileSpec = array [0..MAX_PATH] of char;
implementation
{ TWinExec }
constructor TWinExec.Create(AppName, Args: String; OnExit, OnIdle: TNotifyEvent);
begin
  inherited Create(False);
  FOnProcessIdle := OnIdle;
  FFileName := AppName;
  FArguments := Args;
  FProcessActive := False;
  FreeOnTerminate := False;  // Note that this implementation requires you 
  OnTerminate := OnExit;     // to explicitly Free the TWinExec object.    
end;
procedure TWinExec.Execute;
begin
  FProcessActive := True;
  StartApp(FFileName, FArguments, SW_NORMAL);
  FProcessActive := False;
end;
function TWinExec.StartApp(AppName, ArgStr :String; Visibility : integer):integer;
var
  zAppName : FileSpec;
  zCurDir : FileSpec;
  WorkDir : String;
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
begin
  if ArgStr <> '' then
     AppName := AppName + ' ' + ArgStr;
  StrPCopy(zAppName, AppName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(
    nil,                           { pointer to executable}
    zAppName,                      { pointer to command line string }
    nil,                           { pointer to process security attributes }
    nil,                           { pointer to thread security attributes }
    false,                         { handle inheritance flag }
    CREATE_NEW_CONSOLE or          { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,                           { pointer to new environment block }
    zCurDir,                       { pointer to current directory name }
    StartupInfo,                   { pointer to STARTUPINFO }
    ProcessInfo) then Result := -1 { pointer to PROCESS_INF }
  else
  begin
    if Assigned(FOnProcessIdle) then
    begin
      WaitForInputIdle(ProcessInfo.dwProcessId, INFINITE);
      FOnProcessIdle(Self);
    end;
    WaitforSingleObject(ProcessInfo.hProcess,INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess,Result);
    CloseHandle(ProcessInfo.hProcess );
    CloseHandle(ProcessInfo.hThread );
  end;
end;
end. // Winexec.pas

Here's a simple example that uses TWinExec.

unit Unit1;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, WinExec;
type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    Process : TWinExec;
    procedure ProcessDone(Sender: TObject);
    procedure ProcessReady(Sender: TObject);
  public
  end;
var
  Form1: TForm1;
implementation
{$R *.DFM}
procedure TForm1.Button1Click(Sender: TObject);
begin
   Process := TWinExec.Create(Edit1.Text, Edit2.Text, ProcessDone, ProcessReady);
   Button1.Enabled := False;
   Button1.Caption := 'Waiting for Launched Application to Finish';
   Label3.Caption := 'Waiting for Idle Message';
end;
procedure TForm1.ProcessDone(Sender: TObject);
begin
  Process.Free;
  Button1.Enabled := True;
  Button1.Caption := 'Click to Start the Application';
end;
procedure TForm1.ProcessReady(Sender: TObject);
begin
  Label3.Caption := 'Application OnIdle received.';
end;
procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Enabled := FileExists(Edit1.Text);
end;
end.
// =============  UNIT1.TXT ======================
object Form1: TForm1
  Left = 200
  Top = 200
  Width = 435
  Height = 177
  Caption = 'Form1'
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 53
    Height = 13
    Caption = 'Executable'
  end
  object Label2: TLabel
    Left = 24
    Top = 44
    Width = 53
    Height = 13
    Caption = 'Arguments:'
  end
  object Label3: TLabel
    Left = 26
    Top = 76
    Width = 17
    Height = 13
    Caption = 'Idle'
  end
  object Edit1: TEdit
    Left = 83
    Top = 12
    Width = 309
    Height = 21
    TabOrder = 0
    OnChange = Edit1Change
  end
  object Button1: TButton
    Left = 20
    Top = 104
    Width = 373
    Height = 25
    Caption = 'Click to Start Application'
    Enabled = False
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 83
    Top = 44
    Width = 309
    Height = 21
    TabOrder = 2
  end
end
