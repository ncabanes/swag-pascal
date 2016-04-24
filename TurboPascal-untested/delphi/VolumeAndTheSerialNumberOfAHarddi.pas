(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0249.PAS
  Description: Volume and the serial number of a harddi
  Author: PAUL SOBOLIK
  Date: 05-30-97  18:17
*)


3.01 How does one retrieve the volume and the serial number of a harddisk
or floppy with Delphi?


The following source code was provided to DELPHI-L by Paul Sobolik
<psobolik@aol.com>


---
unit VolInfo;

interface

uses Windows;

type
  TFSFlag = (FSCaseIsPreserved, FSCaseSensitive, FSUnicodeStoredOnDisk,
      FSPersistentACLS, FSVolIsCompressed, FSFileCompression);
  TFSFlags = set of TFSFlag;
  TVolumeInfo = record
    VolumeName: String;
    VolumeSN: DWord;
    MaxComponent: DWord;
    FSFlags: TFSFlags;
    FSName: String;
  end;

function GetVolumeInfo(rootPath: String; var vi: TVolumeInfo): Boolean;

implementation
{
function GetVolumeInformation(
  lpRootPathName: PChar;
  lpVolumeNameBuffer: PChar;
  nVolumeNameSize: DWORD;
  lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength,
  lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PChar;
  nFileSystemNameSize: DWORD): BOOL; stdcall;
}
function GetVolumeInfo(rootPath: String; var vi: TVolumeInfo): Boolean;
type
  TCharBuffer = array[0..255] of Char;
var
  flags, sn, mc: DWord;
  bufVolumeName, bufFSName: TCharBuffer;
begin
  with vi do begin
    result := GetVolumeInformation(PChar(rootPath),
        @bufVolumeName, sizeof(bufVolumeName),
        @sn, mc, flags,
        @bufFSName, sizeof(bufFSName));
    FSFlags := [];
    if result then begin
      VolumeName := bufVolumeName;
      VolumeSN := sn;
      MaxComponent := mc;
      FSName := bufFSName;
      if flags and FS_CASE_IS_PRESERVED <> 0 then FSFlags := FSFlags +
[FSCaseIsPreserved];
      if flags and FS_CASE_SENSITIVE <> 0  then FSFlags := FSFlags +
[FSCaseSensitive];
      if flags and FS_UNICODE_STORED_ON_DISK <> 0  then FSFlags := FSFlags
+
[FSUnicodeStoredOnDisk];
      if flags and FS_PERSISTENT_ACLS <> 0  then FSFlags := FSFlags +
[FSPersistentACLS];
      if flags and FS_VOL_IS_COMPRESSED <> 0  then FSFlags := FSFlags +
[FSVolIsCompressed];
      if flags and FS_FILE_COMPRESSION <> 0 then FSFlags := FSFlags +
[FSFileCompression];
    end else begin
      VolumeName := '';
      VolumeSN := 0;
      MaxComponent := 0;
      FSName := '';
    end;
  end;
end;

end.

