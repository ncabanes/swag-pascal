{ This function deletes a file in Windows 95 and moves it to the recycle bin.
  It returns True if the operation is successful, and False otherwise

  Syntax:

          x := RecycleFile(Filename);

          *** Distribute this file freely

          This unit written by John Ruzicka 75160.2376@compuserve.com
          based on code from Dennis Passmore and Steve Schafer on the
          BDELPHI forum

  }

unit Recycle;

interface

uses Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ShellAPI;

function RecycleFile(FileToRecycle: string): boolean;

implementation

function RecycleFile(FileToRecycle: TFilename): boolean;
var Struct: TSHFileOpStruct;
    pFromc: array[0..255] of char;
    Resultval: integer;
begin
   if not FileExists(FileToRecycle) then begin
      RecycleFile := False;
      exit;
   end
   else begin
      fillchar(pfromc,sizeof(pfromc),0);
      StrPcopy(pfromc,expandfilename(FileToRecycle)+#0#0);
      Struct.wnd := 0;
      Struct.wFunc := FO_DELETE;
      Struct.pFrom := pFromC;
      Struct.pTo   := nil;
      Struct.fFlags:= FOF_ALLOWUNDO;
      Struct.fAnyOperationsAborted := false;
      Struct.hNameMappings := nil;
      Resultval := ShFileOperation(Struct);
      RecycleFile := (Resultval = 0);
   end;
end;

end.
