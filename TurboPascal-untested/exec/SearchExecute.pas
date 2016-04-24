(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0008.PAS
  Description: Search Execute
  Author: MIKE DICKSON
  Date: 10-28-93  11:38
*)

{===========================================================================
Date: 09-18-93 (23:25)
From: MIKE DICKSON
Subj: EXEC ()
---------------------------------------------------------------------------
[MM]  ▒ I've written my own EXEC function that performs an FSearch() on the
[MM] Well, that's great. (Why don't you post it!).

Okay...here's an illustrative little program... }

{$M $4000,0,0 }
Program JohnMajorHadBetterResignPrettyDamnedShortly;

Uses DOS;

FUNCTION  FileExists (FileName: String):Boolean;{ Checks if file
exists  } var
   Attr : Word;
   f    : file;
begin
   Assign (f, Filename);
   GetFAttr(f, attr);
   FileExists := (DOSError = 0);
end;

FUNCTION SearchExec (ProgramName, Parameters : String) : Integer;
var
   Result : Integer;
begin
{ If the program doesn't exist then search on the %PATH for it }
   If Not FileExists(ProgramName) then
      ProgramName := FSearch(ProgramName, GetEnv('PATH'));

{ If it's a batch file then call it through the command processor }
   If Pos('.BAT', ProgramName) <> 0 then begin
      Parameters := '/C '+ProgramName+' '+Parameters;
      ProgramName := GetEnv('COMSPEC');
   end;

{ Now call the program...if it didn't exist the set DOSError to 2 }
   If ProgramName <> '' then begin
      SwapVectors;
      Exec (ProgramName, Parameters);
      Result := DOSError;
      SwapVectors;
      SearchExec := Result;
   end else SearchExec := 2;

end;

begin
   If SearchExec ('AUTOEXEC.BAT', '/?') <> 0
      then writeln ('Execution was okay!')
      else writeln ('Execution was NOT okay!');
end.

