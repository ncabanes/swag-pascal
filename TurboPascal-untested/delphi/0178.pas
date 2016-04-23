unit WinExc32;

// This unit is based upon the well-known and largely used WinExecAndWait function
// The former WinexecAndWait function doesn't compile under Delphi 2.0 because the
// GetModuleUsage function is no longer supported under Win95.
// I have simply updated the previous code so that it works with Delphi 2.0
// under Windows 95. With this function you can call Windows-based applications
// as well as Dos-based commands. That is 'c:\myapp\app32.exe' as well as
// 'command.com /c del *.bak'.
// This new WinexecAndWait32 is intended for Delphi 2.0 Win95 only,
// it works for me but you use it at your own risk.

// Updated : July 31, 1996.
// Author : Francis PARLANT CIS : 100113,3015.

interface

function WinExecAndWait32(Path: PChar; Visibility: Word): integer;

implementation

function WinExecAndWait32(Path: PChar; Visibility: Word): integer;
var
	 Msg: TMsg;
	 lpExitCode : integer;
	 StartupInfo: TStartupInfo;
	 ProcessInfo: TProcessInformation;
begin
	FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
	with StartupInfo do
	begin
		cb := SizeOf(TStartupInfo);
		dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
		wShowWindow := visibility; {you could pass sw_show or sw_hide as parameter}
	end;
	if CreateProcess(nil,path,nil, nil, False,
		NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then begin
		repeat
			while PeekMessage(Msg, 0, 0, 0, pm_Remove) do
				begin
					if Msg.Message = wm_Quit then Halt(Msg.WParam);
					TranslateMessage(Msg);
					DispatchMessage(Msg);
				end;
				GetExitCodeProcess(ProcessInfo.hProcess,lpExitCode);
		until lpExitCode<>Still_Active;
		with ProcessInfo do {not sure this is necessary but seen in in some code elsewhere}
		begin
			CloseHandle(hThread);
			CloseHandle(hProcess);
		end;
		result := 0; {sucess}
	end
	else
		result:=GetLastError;{error occurs during CreateProcess see help for details}
end;

end.
