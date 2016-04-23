
Here, I've thrown together two routines from code I wrote for an   
application that keeps track of certain network files to make sure that   
they don't grow too big.

Yehah! I finally get to help someone!!!


function ReturnFileSize(TheFileName:string):LongInt;
var
  Srec : TSearchRec;
begin
  // TheFileName must include the full path
  if findfirst(TheFileName, faanyfile, srec) = 0 then
    Result := SRec.Size
  else
    Result := 0;
end;

or return the MB (megabyte) size with:

function ReturnMBFileSize(TheFileName:string):Real;
var
  Srec : TSearchRec;
begin
  // TheFileName must include the full path
  if findfirst(TheFileName, faanyfile, srec) = 0 then
    Result := SRec.Size / 1048576
  else
    Result := 0;
end;

