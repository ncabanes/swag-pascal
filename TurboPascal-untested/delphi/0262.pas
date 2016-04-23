--------------------------------------------------------------------------------
Some programs require Windows to be restarted once it is installed on
the system for the first time. If your program has a similar need,
you could use the following function -- WinExit() -- to shut down
Windows, restart Windows, or log off the current user from Windows.

function SetPrivilege(
  sPrivilegeName : string;
  bEnabled : boolean )
    : boolean;
var
  TPPrev,
  TP         : TTokenPrivileges;
  Token      : THandle;
  dwRetLen   : DWord;
begin
  Result := False;

  OpenProcessToken(
    GetCurrentProcess,
    TOKEN_ADJUST_PRIVILEGES
    or TOKEN_QUERY,
    @Token );

  TP.PrivilegeCount := 1;
  if( LookupPrivilegeValue(
        Nil,
        PChar( sPrivilegeName ),
        TP.Privileges[ 0 ].LUID ) )then
  begin
    if( bEnabled )then
    begin
      TP.Privileges[ 0 ].Attributes  :=
        SE_PRIVILEGE_ENABLED;
    end else
    begin
      TP.Privileges[ 0 ].Attributes  :=
        0;
    end;

    dwRetLen := 0;
    Result := AdjustTokenPrivileges(
                Token,
                False,
                TP,
                SizeOf( TPPrev ),
                TPPrev,
                dwRetLen );
  end;

  CloseHandle( Token );
end;

//
// iFlags:
//
//  one of the following must be
//  specified
//
//   EWX_LOGOFF
//   EWX_REBOOT
//   EWX_SHUTDOWN
//
//  following attributes may be
//  combined with above flags
//
//   EWX_POWEROFF
//   EWX_FORCE    : terminate processes
//
function WinExit( iFlags : integer ) : boolean;
begin
  Result := True;
  if( SetPrivilege( 'SeShutdownPrivilege', True ) )then
  begin
    if( not ExitWindowsEx( iFlags, 0 ) )then
    begin
      // handle errors...
      Result := False;
    end;
    SetPrivilege( 'SeShutdownPrivilege', False )
  end else
  begin
    // handle errors...
    Result := False;
  end;
end;


WinExit() function was desinged to be used with 32 bit Windows programs
(Win32) and it does not support restarting Windows without rebooting or
logging off. If you're writing a program that will be run under
Windows 3.x or Windows 95 and you want to restart windows without
rebooting the machine (after installing device drivers, for example),
you can use ExitWindows() Win16 function (don't forget to add WinProcs
and WinTypes units to your uses section):


ExitWindows( EW_RESTARTWINDOWS, 0 );
