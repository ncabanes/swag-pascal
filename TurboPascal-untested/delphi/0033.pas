
{If you wan't to use LZ compression from inside Delphi there is a couple of API function calls that
you can use to do the trick.  But they only let you Uncompress the file! And not Compress it!
Well that is what I have foud anyway.
Here is an extract example from a program that I have written a while ago:}

procedure TForm1.Decomp;
var
  StringFIName, StringFOName : String;
  FIStruct, FOStruct         : TOFStruct;
  HandleFOpen, HandleFWrite  : Integer;
  success                    : LongInt;
begin
  {Open the Input File that is Compressed}
  StringFIName  := FileListBox1.Filename + #0;
  PIFileName    := @StringFIName;
  HandleFOpen   := LZOpenFile(@StringFIName[1], FIStruct, OF_READ or OF_PROMPT);
  if HandleFOpen < 0 then
    MessageDlg('Error Opening Input File : '+ StringFIName, mtInformation,
    [mbOk], 0);
  {Open the Output File that is Uncompressed!}
  StringFOName  := 'c:\WallP.bmp' + #0;
  POFileName    := @StringFOName;
  HandleFWrite  := LZOpenFile(@StringFOName[1], FOStruct, OF_CREATE);
  if HandleFWrite < 0 then
    MessageDlg('Error Creating Output File' + StringFOName, mtInformation, [mbOk], 0);
  {Now we can copy/Uncompress the file}
  success := LZCopy(HandleFOpen, HandleFWrite);
  if success < 0 then
    MessageDlg('Error Copying Input File to Output File', mtInformation, [mbOk], 0);
  {All finished, so lets Close the Input File}
  LZClose(HandleFOpen);
  LZClose(HandleFWrite);
end;

You will need to add LZEXPAND in the Uses clause as well.

