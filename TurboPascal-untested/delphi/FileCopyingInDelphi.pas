(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0027.PAS
  Description: File Copying in DELPHI
  Author: DAVID STIDOLPH
  Date: 11-22-95  15:49
*)


I wrote the following function to copy a file and keep the 
attributes/date-time the same on the copied file.  Hope this helps!

function FileCopy(source,dest: String): Boolean;
var
  fSrc,fDst,len: Integer;
  size: Longint;
  buffer: packed array [0..2047] of Byte;
begin
  Result := False; { Assume that it WONT work }
  if source <> dest then begin
    fSrc := FileOpen(source,fmOpenRead);
    if fSrc >= 0 then begin
      size := FileSeek(fSrc,0,2);
      FileSeek(fSrc,0,0);
      fDst := FileCreate(dest);
      if fDst >= 0 then begin
        while size > 0 do begin
          len := FileRead(fSrc,buffer,sizeof(buffer));
          FileWrite(fDst,buffer,len);
          size := size - len;
        end;
        FileSetDate(fDst,FileGetDate(fSrc));
        FileClose(fDst);
        FileSetAttr(dest,FileGetAttr(source));
        Result := True;
      end;
      FileClose(fSrc);
    end;
  end;
end;

