
This code does it, but it's not included in the ShowMessage displays.
This is for Delphi 2.

function TForm1.ShowDiskData(Drive: string): string;
var
  VolSer : DWord;
  SysFlags : DWord;
  DSize, DFree : integer;
  NamLen, SysLen : integer;
  Buf : string;
  VolNameAry: array[0..255] of char;
  VolNameStr: String;
  LW : byte;
begin
  { get Disk name (volume id) and serial number }
  if (Length(Drive) >= 3) then
     Buf := Copy(Drive, 1, 3)
  else
     Buf := '';
  NamLen:=255;
  SysLen:=255;
  (*
  function GetVolumeInformation(lpRootPathName: PChar;
    lpVolumeNameBuffer: PChar;
    nVolumeNameSize: DWORD;
    lpVolumeSerialNumber: PDWORD;
    var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
    lpFileSystemNameBuffer: PChar;
    nFileSystemNameSize: DWORD): BOOL; stdcall;
  *)
  if GetVolumeInformation(pChar(Buf), VolNameAry, NamLen,
                      @VolSer, SysLen, SysFlags, nil, 0) then
     VolNameStr := StrPas(VolNameAry)
  else
     VolNameStr := '<no name>';
  ShowMessage('Volume name is: ' + VolNameStr);

  { get free disk space and size}
  LW := ord(upcase(Drive[1])) - 64;
  DSize := DiskSize(LW);
  if (DSize <> -1) then
  begin
    DSize := disksize(LW) DIV 1024;
    DFree := diskfree(LW) DIV 1024;
    ShowMessage('Disk size = ' + IntToStr(DSize) + ' K');
    ShowMessage('Disk free = ' + IntToStr(DFree) + ' K');
  end;
end;


