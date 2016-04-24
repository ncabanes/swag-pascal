(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0252.PAS
  Description: Windows directory
  Author: VARIOUS
  Date: 05-30-97  18:17
*)


From : Keith Anderson

> I have searched all my Tip collections etc. and not found an answer for a
> very simple question: how can I find out the Windows directory from Delphi1/2?

Here's code for Delphi 2.x:  (don't know about delphi 1.x)

  Function WindowsPath:String;
  {returns the directory of C:\WINDOWS\ on the current machine}
  var d:integer;
    begin
      setlength(result,500);
      d:=getwindowsdirectory(pchar(result),500);
      setlength(result,d);
      result:=fixpath(result,result);
    end;


*************************************
Keith Anderson
mailto:keith@purescience.com
http://www.purescience.com
*************************************

< from : Igor Ilutkin, More about Windows directory

function TMainFM.GetWinDir: string;
var
  wd: PChar;
begin
  wd := StrAlloc(256);
  GetWindowsDirectory(wd, 255);
  GetWinDir := StrPas(wd) + '\';
end;

function TMainFM.GetRunDir: string;
begin
  GetRunDir := ExtractFilePath(ParamStr(0));
end;


