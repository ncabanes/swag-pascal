
The first point I would make is that you went to an awful lot of trouble
to implement the WinExec API call...  cleaner code would look like:

begin
  winexec('C:\Program.exe', SW_SHOWNORMAL);
end;

Delphi automatically treats this as a null-terminated string (like c).  As
to the answer to your question.  WinExec returns a handle to the
task.  Simply do the following:

procedure SomeProc;
var
  ProgramHandle : THandle;
begin
  ProgramHandle := WinExec('C:\Program.exe', SW_SHOWNORMAL);
  while GetModuleusage(ProgramHandle) <> 0 do application.processmessages;
  {The above line will loop until the program terminates}
  {continue on with program below here}
end;
