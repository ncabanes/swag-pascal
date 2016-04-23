

Want to change file date/time stamps (D2) ?
The following should be self-explanatory....


Angus Johnson
ajohnson@rpi.net.au
----------------------------------------------8<----------------------------
-------------------

function GetFileDateTimeModified(const FileName: string;
                                       var yyyy,mm,dd,h,m,s: word):
boolean;
var
  dt,tm: word;
  DateTime: integer;
begin
  result := false;

  DateTime := FileAge(FileName);
  if DateTime = -1 then exit else result := true;

  tm := DateTime and $FFFF; {lower word}
  dt := DateTime shr 16; {upper word}

  h := tm shr 11;
  m := (tm shr 5) and $3F;
  s := (tm and $1F) * 2;

  dd := dt and $1F;
  mm := (dt shr 5) and $F;
  yyyy := (dt shr 9)+1980;

end;

function SetFileDateTime(const FileName: string;
                                       var yyyy,mm,dd,h,m,s: word):
boolean;
{sets Created, Modified & LastAccessed file date/times}
var
  SrchHdl: THandle;
  FileHdl: HFile;
  FindData: TWin32FindData;
  wDate,wTime: word;
  LocalFileTime, NewFileTime: TFileTime;
begin
  result := false;
  SrchHdl := FindFirstFile(PChar(FileName), FindData);
  if SrchHdl <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(SrchHdl);
    {if not a directory then ...}
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
begin
      wTime := (h shl 11) + (m shl 5) + (m div 2);
      wDate := (dd) + (mm shl 5)+ ((yyyy-1980) shl 9);

      DosDateTimeToFileTime(wDate,wTime,LocalFileTime);
      LocalFileTimeToFileTime(LocalFileTime, NewFileTime);
      FileHdl := _lopen(PChar(FileName), OF_WRITE);
      if FileHdl <> HFILE_ERROR then begin
        if SetFileTime(FileHdl,@NewFileTime,@NewFileTime,@NewFileTime) then
            result := true;
        _lclose(FileHdl);
      end;
    end;
  end;
end;
