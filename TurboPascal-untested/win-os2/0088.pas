unit LFN_ALT;

interface

// This unit provides two functions that conver
// filenames from the long format to the 8.3
// format, and from the 8.3 format to the long
// format.

function AlternateToLFN(alternateName: String): String;
function LFNToAlternate(LongName: String): String;

implementation

uses Windows;

function AlternateToLFN(alternateName: String): String;
var temp: TWIN32FindData;
    searchHandle: THandle;
begin
  searchHandle := FindFirstFile(PChar(alternateName), temp);
  if searchHandle <> ERROR_INVALID_HANDLE then
    result := String(temp.cFileName)
  else
    result := '';
  Windows.FindClose(searchHandle);
end;

function LFNToAlternate(LongName: String): String;
var temp: TWIN32FindData;
    searchHandle: THandle;
begin
  searchHandle := FindFirstFile(PChar(LongName), temp);
  if searchHandle <> ERROR_INVALID_HANDLE then
    result := String(temp.cALternateFileName)
  else
    result := '';
  Windows.FindClose(searchHandle);
end;

end.
 