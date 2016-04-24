(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0336.PAS
  Description: An interface to the IDE's text buffer
  Author: MARTIN WALDENBURG
  Date: 08-30-97  10:09
*)

{+--------------------------------------------------------------------------+
 | Class:       TIDEStream
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: A simple and effective interface to the IDE's text buffer
 | Version:     1.0
 | Status:      FreeWare
 | Disclaimer:
 | This is provided as is, expressly without a warranty of any kind.
 | You use it at your own risc.
 +--------------------------------------------------------------------------+}
unit mwIDEStream;  { demo program below !! }

interface

uses
  Windows, 
  SysUtils, 
  Messages, 
  Classes,
  ToolIntf,
  EditIntf,
  ExptIntf;

type
  TIDEStream = class(TMemoryStream)
  private
    fStreamTextLen:Longint;
    function GetAsPChar:PChar;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure WriteText(Text: PChar);
    property Capacity;
    property AsPChar:PChar read GetAsPChar;
    function GetText:PChar;
    property StreamTextLen:Longint read fStreamTextLen;
  published
  end;

var
  fToolServices : TIToolServices;
  fModuleInterface: TIModuleInterface;
  fEditorInterface: TIEditorInterface;
  ActualReader: TIEditReader;
  ActualWriter: TIEditWriter;

implementation

function GetProjectName: String;
begin
  Result:= fToolServices.GetProjectName;
end;  { GetProjectName }

function GetCurrentFile: String;
begin
  Result:= fToolServices.GetCurrentFile;
end;   { GetCurrentFile }

function GetToolServieces:TIToolServices;
var
  FileExt: String;
begin
  fToolServices:= ExptIntf.ToolServices;
 if GetProjectName = '' then raise exception.create('Sorry, a project must be open');
   FileExt:= ExtractFileExt(GetCurrentFile);
  if FileExt = '.dfm' then raise exception.create('Sorry, must be a PAS or DPR file');

end;  { GetToolServieces }

procedure GetEditReader;
begin
  GetToolServieces;
  fModuleInterface:= fToolServices.GetModuleInterface(GetCurrentFile);
  fEditorInterface:= fModuleInterface.GetEditorInterface;
  ActualReader:= fEditorInterface.CreateReader;
end;  { GetEditReader }

procedure GetEditWriter;
begin
  GetToolServieces;
  fModuleInterface:= fToolServices.GetModuleInterface(GetCurrentFile);
  fEditorInterface:= fModuleInterface.GetEditorInterface;
  ActualWriter:= fEditorInterface.CreateWriter;
end;  { GetEditWriter }

procedure FreeEditReader;
begin
  ActualReader.Free;
  fEditorInterface.Free;
  fModuleInterface.Free;
end;  { GetEditorInterface }

procedure FreeEditWriter;
begin
  ActualWriter.Free;
  fEditorInterface.Free;
  fModuleInterface.Free;
end;  { GetEditorInterface }

destructor TIDEStream.Destroy;
begin
  inherited Destroy;
end;  { Destroy }

constructor TIDEStream.Create;
begin
  inherited Create;
  fStreamTextLen:= 0;
end;  { Create }

function TIDEStream.GetAsPChar:PChar;
const
  TheEnd: Char = #0;
begin
  Position:= Size;
  Write(TheEnd, 1);
  SetPointer(Memory, Size -1);
  Result:= Memory;
end;  { GetAsPChar }

function TIDEStream.GetText:PChar;
const
  BuffLen = 16383;
var
  TextBuffer: PChar;
  Readed, BuffPos: LongInt;
begin
  Clear;
  GetMem(TextBuffer, BuffLen +1);
  BuffPos:= 0;
  GetEditReader;
  try
    repeat
      Readed:= ActualReader.GetText(BuffPos, TextBuffer, Bufflen);
      Write(TextBuffer^, Readed);
      inc(BuffPos, Readed);
    until Readed < BuffLen;
  finally
  FreeEditReader;
  FreeMem(TextBuffer, BuffLen +1);
  end;
  fStreamTextLen:= Size;
  Result:= AsPchar;
end;

procedure TIDEStream.WriteText(Text: PChar);
begin
  GetEditWriter;
  try
    ActualWriter.CopyTo(0);
    ActualWriter.DeleteTo(fStreamTextLen -1);
    ActualWriter.Insert(Text);
  finally
    FreeEditWriter;
  end;
end;

end.

unit mwIDEExpert;
{+--------------------------------------------------------------------------+
 | Unit:        mwIDEExpert
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: A simple demo for TIDEStream
 | Version:     1.0
 | Status:      FreeWare
 | Disclaimer:
 | This is provided as is, expressly without a warranty of any kind.
 | You use it at your own risc.
 +--------------------------------------------------------------------------+}

interface  { DFM file is included below - use XX34 to extract it }

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExptIntf, ToolIntf, mwIDEStream, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  TMyIDEExpertExpert = class(TIExpert)
  private
    MenuItem: TIMenuItemIntf;
  protected
    procedure OnClick( Sender: TIMenuItemIntf); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function GetName: string; override;
    function GetAuthor: string; override;
    function GetStyle: TExpertStyle; override;
    function GetIDString: string; override;
  end;

procedure Register;

implementation

{$R *.DFM}

procedure Register;
begin
  RegisterLibraryExpert(TMyIDEExpertExpert.Create);
end;

{ TMyIDEExpertExpert code }
function TMyIDEExpertExpert.GetName: String;
begin
  Result := 'MyIDEExpertExpert'
end;

function TMyIDEExpertExpert.GetAuthor: String;
begin
  Result := 'Martin_Waldenburg'; { author }
end;

function TMyIDEExpertExpert.GetStyle: TExpertStyle;
begin
  Result := esAddIn;
end;

function TMyIDEExpertExpert.GetIDString: String;
begin
  Result := 'private.MyIDEExpertExpert';
end;

constructor TMyIDEExpertExpert.Create;
var
  Main: TIMainMenuIntf;
  ReferenceMenuItem: TIMenuItemIntf;
  Menu: TIMenuItemIntf;
begin
  inherited Create;
  MenuItem := nil;
  if ToolServices <> nil then begin { I'm an expert! }
    Main := ToolServices.GetMainMenu;
    if Main <> nil then begin { we've got the main menu! }
      try 
        { add the menu of your choice }
        ReferenceMenuItem := Main.FindMenuItem('ToolsOptionsItem');
        if ReferenceMenuItem <> nil then
        try
          Menu := ReferenceMenuItem.GetParent;
          if Menu <> nil then
          try
            MenuItem := Menu.InsertItem(ReferenceMenuItem.GetIndex+1,
                              'MyIDEExpert',
                              'MyIDEExpertExpertItem','',
                              0,0,0,
                              [mfEnabled, mfVisible], OnClick);
          finally
            Menu.DestroyMenuItem;
          end;
        finally
          ReferenceMenuItem.DestroyMenuItem;
        end;
      finally
        Main.Free;
      end;
    end;
  end;
end;

destructor TMyIDEExpertExpert.Destroy;
begin
  if MenuItem <> nil then
    MenuItem.DestroyMenuItem;
  inherited Destroy;
end;{Destroy}

procedure TMyIDEExpertExpert.OnClick( Sender: TIMenuItemIntf);
begin
  with TForm1.Create(Application) do
    try
      { do your processing here }
      ShowModal;
    finally
      Free;
    end;
end;

{ TForm1 code }

procedure TForm1.Button1Click(Sender: TObject);
var
  IDEStream: TIDEStream;
  StreamText, UText, UFind, fReplace: String;
  FindLen, P: LongInt;
begin
  IDEStream:= TIDEStream.Create;
  StreamText:= IDEStream.GetText;
  UText:= UpperCase(StreamText);
  UFind:= UpperCase(Trim(Edit1.Text));
  fReplace:= Trim(Edit2.Text);
  FindLen:= Length(UFind);
  P:= Pos(UFind, UText);
  if P <> 0 then
  begin
    Delete(StreamText, P, FindLen);
    Insert(fReplace, StreamText, P);
    IDEStream.WriteText(PChar(StreamText));
  end;
  IDEStream.Free;
end;

end.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000564-150897--72--85-59531----MWIDEEXP.DFM--1-OF--1
zkc+J2NDIYol+1+E7+6++3FEFX+4J2NjQaol-INjQaol-2lZNbE1m++1J4xk+ak3JqZYR4U1
Fk24G4JdNqVo+vA+-oBVQ5FdPqs42IFZPKwUPqMUJ2Z2FJBmNK3h12NjPbEiEqVVQbBZR+QD
F2J4EJJAJ3x1G23GIoJI0YNjPbEiEqxgPr6514BgJqZiN4xrJ4JsR+h4Pqto9YVZOKRcR+9p
0INjPbEiHa3hNEMBHJAUIq3iQm-HNL7dNUd4Pqto9ZBoSKlZ0k+BI4ZsNKlnI4JmGKtXO+7U
0ZFZS5F6NKZbO5E01E+4J2lVMaJg-YlVMaJgAEFANKNo+W+1J4xk+VU3JqZYR4U03+N6NKZb
O5E01ER1ML-oOKxi-UF4OKtY+++4J2lVMaJg-YlVMaJgAUFANKNo+W+1J4xk+Y+3JqZYR4U0
8+N6NKZbO5E01ER1ML-oOKxi-URGNL-gMKBZ+++5J27pR5FjPUR0RLFoPqsl-2lZNbE0S+BI
Pr+0M+JLOKFoO+79-YVZOKRcR+6N-oBVQ5FdPqs4-o7pR5FjPX26J43WHr7YNL60++RDPYBg
OKBf-kl0RLFoPqslEqldMqg+++JIFKFdR+J3N4ZoAEFANKNo+Z+1J4xk+V+3JqZYR4U1kE+4
G4JdNqVo+VI6J43WHr7YNL60+E++-JF3N4Zo-IJYOLEm-2lZNbE0I+BIPr+0C+JLOKFoO+D-
++N6NKZbO5E03EVIMK7DQaFZQU60++++
***** END OF BLOCK 1 *****


