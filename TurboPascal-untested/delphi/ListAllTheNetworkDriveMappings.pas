(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0406.PAS
  Description: List all the network drive mappings
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)


Function to list all the network drive mappings.

It is very easy to get a list of all the network drive mappings using
the following function. Please note that you must create and free
the string list that you pass to it. The return value indicates
the number of network mappings GetNetworkDriveMappings() was able to find.

function GetNetworkDriveMappings(
  sl : TStrings ) : integer;
var
  i               : integer;
  sNetPath        : string;
  dwMaxNetPathLen : DWord;
begin
  sl.Clear;
  dwMaxNetPathLen := MAX_PATH;
  SetLength( sNetPath,
    dwMaxNetPathLen );
  for i := 0 to 25 do
  begin
    if( NO_ERROR =
      Windows.WNetGetConnection(
        PChar(
          '' + Chr( 65 + i ) + ':' ),
        PChar( sNetPath ),
        dwMaxNetPathLen ) )then
    begin
      sl.Add( Chr( 65 + i ) + ': ' +
              sNetPath );
    end;
  end;
  Result := sl.Count;
end;

//
// here's how to call GetNetworkDriveMappings():
//
var
  sl : TStrings;
  nMappingsCount,
  i  : integer;
begin
  sl := TStringList.Create;
  nMappingsCount :=
    GetNetworkDriveMappings( sl );
  for i := 0 to nMappingsCount-1 do
  begin
    //
    // do your thing here...
    // for now, we'll just display the mapping
    //
    MessageBox( 0,
      PChar( sl.Strings[ i ] ),
      'Network drive mappings',
      MB_OK );
  end;
  sl.Free;
end;


If you need to programmatically map and delete network drives, look
up WNetAddConnection(), WNetAddConnection2(), WNetAddConnection3(),
WNetCancelConnection(), and WNetCancelConnection2() in your
"Win32 Programmer's Reference."


