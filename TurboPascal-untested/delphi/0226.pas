
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