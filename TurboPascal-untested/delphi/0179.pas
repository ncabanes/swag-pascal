(*
  DESCRIPTION A simple component with some methods to control windows
  AUTHOR      Harm van Zoest, email 4923559@hsu1.fnt.hvu.nl
  VERSION     0.95 (beta), 07-05-96
  REMARK      If you have comments, found bugs or you add some interestig new features,
              please mail me!
*)

unit WinUtil;

interface

uses
  Classes, ExtCtrls;

type
  TWinUtil = class(TComponent)
  private
    FTimer: TTimer;
    Expired: Boolean;
    procedure Expire(Sender: TObject);
    function GetInterval: LongInt;
    procedure SetInterval(AInterval: LongInt);
    procedure Sleep;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Restart;
    procedure Reboot;
    procedure ShutDown;
    procedure CopyFile( source, dest : string);
    procedure SleepFor(AInterval: LongInt);
    function GetEnvironvar(const VariableName: string): string;
    function GetWindir: string;
    function GetCompanyName: string;
    function GetUserName : string;
  published
    property Interval: LongInt read GetInterval write SetInterval;
  end;

procedure Register;

implementation

uses
  WinTypes, WinProcs,LZexpand, sysutils,Forms;

constructor TWinUtil.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
end;

destructor TWinUtil.Destroy;
begin
  FTimer.Free;
  FTimer := nil;
  inherited Destroy;
end;

procedure TWinUtil.Expire(Sender: TObject);
begin
   Expired := True;
end;

function TWinUtil.GetInterval: LongInt;
begin
if Assigned(FTimer) then
  Result := FTimer.Interval
else Result := 0;
end;

procedure TWinUtil.SetInterval(AInterval: LongInt);
begin
  if Assigned(FTimer) then
    FTimer.Interval := AInterval;
end;

procedure TWinUtil.Sleep;
begin
  if Assigned(FTimer) then
  begin
    Expired := False;
    FTimer.OnTimer := Expire;
    FTimer.Enabled := True;
  repeat
      Application.ProcessMessages;
  until Expired;
  FTimer.Enabled := False;
  end;
end;

procedure TWinUtil.SleepFor(AInterval: LongInt);
begin
  if Assigned(FTimer) then
  begin
    if FTimer.Interval <> AInterval then
      FTimer.Interval := AInterval;
    Sleep;
    end;
end;

function TWinUtil.GetEnvironVar(const VariableName: string): string;
var
  APChar, VPChar: PChar;
begin
  GetMem(VPChar, Length(VariableName) + 1);
  { place the pascal-style string in a null-terminated one}
  StrPCopy(VPChar, VariableName);
  APChar:=GetDOSEnvironment;
  while not ((APChar^ = #1) or
             (StrLIComp(APChar, VPChar, (StrScan(APChar, '=') - APChar)) = 0)) do
       Inc(APChar, StrLen(APChar) + 1);
  FreeMem(VPChar, Length(VariableName) + 1);
  if APChar^ = #1 then
    Result:=''
  else
    Result:=Copy(StrPas(APChar), (StrScan(APChar, '=') - APChar) + 2, 255);
end;{GetEnviron}


{ get the windows dir}
function TWinUtil.GetWindir: string;
var
  x : word;
  buf : Pchar;
begin
  { get memory}
  Getmem(buf , 500);
  { call api funtion}
  x := GetWindowsDirectory(buf,500);
  GetWindir := StrPas(buf);
  Freemem(buf,500);
end;{GetWindir}



procedure TWinUtil.Restart;
var
  rc : boolean;
begin
  rc := ExitWindows(ew_restartwindows, 0);
end;

procedure TWinUtil.Reboot;
var
  rc : boolean;
begin
  rc := ExitWindows(ew_rebootsystem, 0);
end;

procedure TWinUtil.Shutdown;
var
  rc : boolean;
begin
  rc := ExitWindows(0, 0);
end;

procedure TWinUtil.CopyFile( source, dest : string);
var
  fil : Pchar;
  HandleSource, HandleDest : integer;
  rec : TOFStruct;
  x : longint;
begin
  { get the handle voor de source file}
  Getmem(fil, (length(source)+1));
  strPcopy(fil, source);
  { get the handle which identifies the source file}
  HandleSource := LZOpenfile(fil,rec, OF_READWRITE);
  FreeMem(fil,length(source)+1);
  { create a desination file}
  Getmem(fil, (length(dest)+1));
  strPcopy(fil, dest);
  _lcreat(fil, 0);
  { get the handle which identifies the destination file}
  HandleDest := LZOpenfile(fil, rec, OF_READWRITE);
  { now, we are ready to copy the file}
  x:= LZCopy(HandleSource, HandleDest);
  Freemem(fil,( length(dest) +1));
end;

function TWinUtil.GetUserName: string;
var
  fileHandle : Thandle ;
  fileBuffer: Array [0..29] of Char;
begin
  fileHandle := LoadLibrary('USER');
  if fileHandle >= HINSTANCE_ERROR then begin
       If LoadString(fileHandle, 514, @fileBuffer, 30) <> 0 Then
	  GetUserName := fileBuffer;
  FreeLibrary(fileHandle);
  end;{if}
end;{GetUserName}

function TWinUtil.GetCompanyName: string;
var
  fileHandle : Thandle;
  fileBuffer: Array [0..29] of Char;
begin
  fileHandle := LoadLibrary('USER');
  if fileHandle >= HINSTANCE_ERROR then begin
       If LoadString(fileHandle, 515, @fileBuffer, 30) <> 0 Then
	  GetCompanyName := fileBuffer;
  FreeLibrary(fileHandle);
  end;{if}
end;{GetCompanyName}


procedure Register;
begin
RegisterComponents('System', [TWinUtil]);
end;

end.
