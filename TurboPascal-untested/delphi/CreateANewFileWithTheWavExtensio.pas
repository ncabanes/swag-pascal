(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0201.PAS
  Description: Create a new file with the .wav extensio
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)


This document describes the process for creating added
functionality ,that many Delphi users have requested,
to the TMediaPlayer. The new functionality is the ability
to create a new file with the .wav format when recording.
The procedure "SaveMedia" creates a record type that is
passed to the MCISend command. There is an appexception
that calls close media if any error occurs while attempting
to open the specified file. The application consists two
buttons. Button1 calls the OpenMedia and RecordMedia
procedures in that order.The CloseMedia procedure is called
whenever an exception is generated in this application.
Button2 calls the StopMedia,SaveMedia, and CloseMedia
procedures.


unit utestrec;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
 Forms, Dialogs,MPlayer,MMSystem,StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
  private
    FDeviceID: Word;
    { Private declarations }
  public
    procedure OpenMedia;
    procedure RecordMedia;
    procedure StopMedia;
    procedure SaveMedia;
    procedure CloseMedia;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

var
  MyError,Flags: Longint;

  procedure TForm1.OpenMedia;
  var
    MyOpenParms: TMCI_Open_Parms;
    MyPChar: PChar;
    TextLen: Longint;
  begin
    Flags:=mci_Wait or mci_Open_Element or mci_Open_Type;
  with MyOpenParms do
    begin
      dwCallback:=Handle; // TForm1.Handle
      lpstrDeviceType:=PChar('WaveAudio');
      lpstrElementName:=PChar('');
    end;
  MyError:=mciSendCommand(0, mci_Open, Flags,
 	 Longint(@MyOpenParms));
  if MyError = 0 then
    FDeviceID:=MyOpenParms.wDeviceID;
  end;

  procedure TForm1.RecordMedia;
  var
    MyRecordParms: TMCI_Record_Parms;
    TextLen: Longint;
  begin
    Flags:=mci_Notify;
    with MyRecordParms do
    begin
      dwCallback:=Handle;  // TForm1.Handle
      dwFrom:=0;
      dwTo:=10000;
    end;
    MyError:=mciSendCommand(FDeviceID, mci_Record, Flags,
    Longint(@MyRecordParms));
  end;

  procedure TForm1.StopMedia;
  var
    MyGenParms: TMCI_Generic_Parms;
  begin
  if FDeviceID <> 0 then
    begin
      Flags:=mci_Wait;
      MyGenParms.dwCallback:=Handle;  // TForm1.Handle
      MyError:=mciSendCommand(FDeviceID, mci_Stop, Flags,
      Longint(@MyGenParms));
    end;
  end;

  procedure TForm1.SaveMedia;
    type    // not implemented by Delphi 
      PMCI_Save_Parms = ^TMCI_Save_Parms;
      TMCI_Save_Parms = record
      dwCallback: DWord;
      lpstrFileName: PAnsiChar;  // name of file to save
    end;
  var
    MySaveParms: TMCI_Save_Parms;
  begin
    if FDeviceID <> 0 then
    begin
        // save the file...
      Flags:=mci_Save_File or mci_Wait;
      with MySaveParms do
        begin
          dwCallback:=Handle;
          lpstrFileName:=PChar('c:\message.wav');
        end;
      MyError:=mciSendCommand(FDeviceID, mci_Save, Flags,
      Longint(@MySaveParms));
    end;
  end;

  procedure TForm1.CloseMedia;
  var
    MyGenParms: TMCI_Generic_Parms;
  begin
    if FDeviceID <> 0 then
    begin
      Flags:=0;
      MyGenParms.dwCallback:=Handle; // TForm1.Handle
      MyError:=mciSendCommand(FDeviceID, mci_Close, Flags,
      Longint(@MyGenParms));
      if MyError = 0 then
        FDeviceID:=0;
    end;
  end;

  procedure TForm1.Button1Click(Sender: TObject);
  begin
    OpenMedia;
    RecordMedia;
  end;

  procedure TForm1.Button2Click(Sender: TObject);
  begin
    StopMedia;
    SaveMedia;
    CloseMedia;
  end;

  procedure TForm1.FormCreate(Sender: TObject);
  begin
    Application.OnException := AppException;
  end;

  procedure TForm1.AppException(Sender: TObject; E: Exception);
  begin
    CloseMedia;
  end;

end.

