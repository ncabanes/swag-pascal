
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