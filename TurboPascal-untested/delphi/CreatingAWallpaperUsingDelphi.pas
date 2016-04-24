(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0197.PAS
  Description: Creating a Wallpaper Using Delphi
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)


To the wallpaper in Windows 95 you must use the Win32 
API function SystemParametersInfo. SystemParametersInfo retrieves
and sets system wide parameters including the wallpaper. The 
code below illustrates setting the wallpaper to the Athena bitmap.

procedure TForm1.Button1Click(Sender: TObject);
var
  s: string;
begin
   s := 'c:\windows\athena.bmp';
   SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(s), 0)
end;

