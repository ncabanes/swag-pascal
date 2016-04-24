(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0235.PAS
  Description: Changing Wallpaper
  Author: SWAG SUPPORT GROUP
  Date: 03-04-97  13:18
*)

program wallpapr;

uses
Registry, WinProcs;

procedure SetWallpaper(
sWallpaperBMPPath : String;
bTile : boolean );
var
reg : TRegIniFile;
begin
//
// change registry
//
// HKEY_CURRENT_USER
//   Control Panel\Desktop
//     TileWallpaper (REG_SZ)
//     Wallpaper (REG_SZ)
//
reg := TRegIniFile.Create(
'Control Panel\Desktop' );
with reg do
begin
WriteString( '', 'Wallpaper',
sWallpaperBMPPath );
if( bTile )then
begin
WriteString( '', 'TileWallpaper', '1' );
end else
begin
WriteString( '', 'TileWallpaper', '0' );
end;
end;
reg.Free;
//
// let everyone know that we changed
// a system parameter
//
SystemParametersInfo( SPI_SETDESKWALLPAPER,
0, Nil, SPIF_SENDWININICHANGE );
end;
begin
SetWallpaper( 'c:\winnt\winnt.bmp', False );
end.

