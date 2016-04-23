
BOOL GetUserName(
  // address of name buffer
  LPTSTR lpBuffer,
  // address of size of name buffer
  LPDWORD nSize
  );

You can retrieve the current user name by calling the above Win32 API
function. "GetCurrentUserName" function is a wraparound to simplify
calling "GetUserName()" in Delphi:

function GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName     : string;
  dwUserNameLen : DWord;
begin
  dwUserNameLen := cnMaxUserNameLen-1;
  SetLength( sUserName, cnMaxUserNameLen );
  GetUserName(
    PChar( sUserName ),
    dwUserNameLen );
  SetLength( sUserName, dwUserNameLen );
  Result := sUserName;
end;


