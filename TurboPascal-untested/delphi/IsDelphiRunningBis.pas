(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0409.PAS
  Description: Is Delphi running ??
  Author: LANNY GRIM
  Date: 01-02-98  07:34
*)

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{ The following functions are written for Delphi 1.x }
  They should be easily adaptable for use with Delphi 2 & 3 }

function  ExtractFileRootName( FileName: string): string;
var p: integer;
begin   { extracts the 8-character file name only }
  Result := ExtractFileName(FileName);
  p := pos('.',Result);
  if p>0 then Result := Copy(Result,1,p-1);
end;

function  DelphiRunning: boolean;
begin   { returns true if running within the IDE/compiler }
  Result :=
    (FindWindow('TApplication','Delphi') > 0) OR
    (FindWindow('TPropertyInspector',nil) > 0) OR
    (FindWindow('TAppBuilder',nil) > 0);
end;

function ProjectInDelphi( EXEName: string ): boolean;
var Hnd: HWnd;
    buf: array[0..80] of char;
    tmpS: string[80];
begin
  Result := False;
  if (DelphiRunning) then
    begin
      EXEName := UpperCase(ExtractFileRootName(EXEName));
      Hnd := FindWindow('TAppBuilder',nil);
      GetWindowText(Hnd, buf, SizeOf(buf)); { get window caption }
      tmpS := UpperCase(StrPas(buf));
      Result := (Pos(EXEName,tmpS) > 0)  { does it contain EXEName ? }
                and (Pos('RUNNING',tmpS) > 0);  { is it running ? }
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if ProjectInDelphi('Project1.Exe')
    then Label1.Caption := 'TRUE'
    else Label1.Caption := 'False';
end;



