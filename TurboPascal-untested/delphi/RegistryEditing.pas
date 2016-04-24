(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0226.PAS
  Description: Re: Registry Editing
  Author: MARK OGIER
  Date: 03-04-97  13:18
*)


procedure AddSourceToRegistry;

var
  NTReg           : TRegIniFile;
  dwData          : DWord;
begin
  NTReg := TRegIniFile.Create('');
try
  NTReg.RootKey := HKEY_LOCAL_MACHINE;
  NTReg.OpenKey('SYSTEM\CurrentControlSet\Services\EventLog\Application\MyLog',true);
  NTReg.LazyWrite := false;
  TRegistry(NTReg).WriteString('EventMessageFile',Application.ExeName);
  dwData := EVENTLOG_ERROR_TYPE or EVENTLOG_WARNING_TYPE or
            EVENTLOG_INFORMATION_TYPE;
  TRegistry(NTReg).WriteInteger('TypesSupported', dwData);

finally
  NTReg.Free;
end;
end;

