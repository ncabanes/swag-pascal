
{I saw someone asking how to get DOS environment variables from Delphi.
The little Project attached shows how to list all the Environment
variables quite simply.}

program Getenv;

uses WinCrt,
  WinProcs;
var
 ptr: PChar;
 Done: BOOLEAN;
begin
 ptr := GetDOSEnvironment;
 Done := FALSE;
 WHILE NOT Done DO
 BEGIN
  IF ptr^ = #0 THEN
  BEGIN
   Writeln;
   INC(ptr);
   IF ptr^ = #0 THEN Done := TRUE
   ELSE Write(ptr^);
  END
  ELSE Write(ptr^);
  INC(ptr);
 END;
end.


