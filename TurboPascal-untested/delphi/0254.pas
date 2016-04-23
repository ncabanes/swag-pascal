--------------------------------------------------------------------------------
Windows will not let the user or your program undo file delete operations
that your perform using low-level functions such as DeleteFile() from
your program. Following function, however, will delete a file with the
ability to undo (recycle) by sending the file to the "Recycle Bin."

uses ShellAPI;

function DeleteFileWithUndo(
  sFileName : string )
    : boolean;
var
  fos : TSHFileOpStruct;
begin
  FillChar( fos, SizeOf( fos ), 0 );
  with fos do
  begin
    wFunc  := FO_DELETE;
    pFrom  := PChar( sFileName );
    fFlags := FOF_ALLOWUNDO
              or FOF_NOCONFIRMATION
              or FOF_SILENT;
  end;
  Result := ( 0 = ShFileOperation( fos ) );
end;


To delete a file, simply pass the file name to DeleteFileWithUndo() and
it will return True if the operation was successful