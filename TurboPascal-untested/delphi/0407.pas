unit DosEnv01;
{ Class to read the DOS Environment variables }

interface

uses SysUtils, WinProcs, Classes;

type
  TDOSEnvironment = class
  private
    FKeys: TStringList;
    FValues: TStringList;
    function GetCount: Integer;
    function GetKey(Index: Integer): string;
    function GetValue(Index: Integer): string;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function ValueForKey(const Key: string): string;
    property Count: Integer read GetCount;
    property Key[Index: Integer]: string read GetKey;
    property Value[Index: Integer]: string read GetValue;
  end;

implementation

{ TDOSEnvironment }

constructor TDOSEnvironment.Create;
var
  EnvStrings: PChar;
  S: string;

begin
  FKeys := TStringList.Create;
  FValues := TStringList.Create;

  {$IFDEF WIN32}
    EnvStrings := GetEnvironmentStrings;
  {$ELSE}
    EnvStrings := GetDosEnvironment;
  {$ENDIF}

  while EnvStrings[0] <> #0 do
    begin
      S := StrPas(EnvStrings);
      FKeys.Add(Copy(S,1,Pos('=',S)-1));
      FValues.Add(Copy(S,Pos('=',S)+1,255));
      Inc(EnvStrings,StrLen(EnvStrings)+1);
    end;
end;

destructor TDOSEnvironment.Destroy;
begin
  FKeys.Free;
  FValues.Free;
end;

function TDOSEnvironment.ValueForKey(const Key: string): string;
var
  I: Integer;

begin
  I := FKeys.IndexOf(Key);
  if I >= 0 then
    Result := FValues.Strings[I]
  else
    Result := '';
end;

function TDOSEnvironment.GetCount: Integer;
begin
  Result := FKeys.Count;
end;

function TDOSEnvironment.GetKey(Index: Integer): string;
begin
  Result := FKeys.Strings[Index];
end;

function TDOSEnvironment.GetValue(Index: Integer): string;
begin
  Result := FValues.Strings[Index];
end;

end.
