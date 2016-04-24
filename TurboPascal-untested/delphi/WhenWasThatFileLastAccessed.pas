(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0259.PAS
  Description: When was that file last accessed?
  Author: CHAMI
  Date: 05-30-97  18:17
*)


http://www.chami.com/
When was that file last accessed?

--------------------------------------------------------------------------------
Here's an example of how to write a function that'll return a file's last
access time (not to be confused with the last modified time).

function GetFileLastAccessTime(
  sFileName : string ) : TDateTime;
var
  ffd : TWin32FindData;
  dft : DWord;
  lft : TFileTime;
  h   : THandle;
begin
  //
  // get file information
  h := Windows.FindFirstFile(
         PChar(sFileName), ffd);
  if(INVALID_HANDLE_VALUE <> h)then
  begin
    //
    // we're looking for just one file,
    // so close our "find"
    Windows.FindClose( h );
    //
    // convert the FILETIME to
    // local FILETIME
    FileTimeToLocalFileTime(
      ffd.ftLastAccessTime, lft );
    //
    // convert FILETIME to
    // DOS time
    FileTimeToDosDateTime(lft,
    LongRec(dft).Hi, LongRec(dft).Lo);
    //
    // finally, convert DOS time to
    // TDateTime for use in Delphi's
    // native date/time functions
    Result := FileDateToDateTime(dft);
  end;
end;


"GetFileLastAccessTime()" will simply return the file's last access time
as a Delphi's TDateTime type which you can convert to a string by using
the "DateTimeToStr()" function.

