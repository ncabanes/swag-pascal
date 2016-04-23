
Is there an easy way to get the coordinates of the desktop window area that=
is not covered by either windows 95 taskbar or windows 95 application bars?

Following is a snippet that I use to center my forms within the
screen.

var
  r : TRect;
  osv : TOSVersionInfo;
begin
  { Center the screen within the Windows95 'work area'.  If we're on Wind=
ows NT3.Ex, then just center within the screen itself. }
  osv.EdwOSVersionInfoSize := sizeof(osv);
  GetVersionEx(osv);
  if osv.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
    SystemParametersInfo(SPI_GETWORKAREA, 0, @r, 0);
    Left := ((r.right  - r.left) - Width)  div 2;
    Top  := ((r.bottom - r.top)  - Height) div 2;
  end else begin
    Left := (GetSystemMetrics(SM_CXSCREEN) - Width)  div 2;
    Top  := (GetSystemMetrics(SM_CYSCREEN) - Height) div 2;
  end;
end;

