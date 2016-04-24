(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0136.PAS
  Description: ShellExecute in Delphi2/NT
  Author: STEVE TEIXEIRA
  Date: 05-31-96  09:17
*)

(*
> David Swaddle <100657.155@CompuServe.COM> wrote:
>
> >Can anyone suggest a method of running an MS DOS applications
> >(yuck) from within Delphi 2 where the program can be forced to
> >wait for the DOS process to finish before resuming??
>
> >I know that this sounds like an odd request, but I have a legacy
> >EXE file without the source and it runs a vital part of a system
> >that I'm writing.  Previously I used the TExecFile component, but
> >I don't have the source for this.  I have tried using the
> >ShellExecute API call and this works fine, except that I can't
> >find a way of waiting to see if the new process has terminated.
>
> >I'm not very au fait with the Win32 API yet, so any help
> >appreciated.
> This works in 1.0 and should work in 2.0


> var
>    AppHandle : THandle;
> 
> begin
>    AppHandle := ShellExecute(Application.MainForm.Handlle, 'OPEN',
> EXEName, Params, 'C:\PROGRAMS', SW_SHOWNORMAL);
> 
>    if AppHandle <= 32 then { Error Running Program}
>       raise Exception.Create('There was a problem Running the App');
> 
>    while (GetModuleUsage(AppHandle) = 0) do
>       Application.ProcessMessages;
> end;
>
> Brad Huggins

That code will not work in Delphi 2.0 because the GetModuleUsage function
doesn't exist under Win32.  You can get this behavior, however, using the
Win32 CreateProcess function.  Here is a function I use to wait for another
program to finish execution:
*)

function CreateProcessAndWait(const AppPath, AppParams: String;
                              Visibility: word): DWord;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  Proc: THandle;
begin
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.wShowWindow := Visibility;
  if not CreateProcess(PChar(AppPath), PChar(AppParams), Nil, Nil, False,
                   Normal_Priority_Class, Nil, Nil, SI, PI) then
    raise Exception.CreateFmt('Failed to execute program.  Error Code %d',
                              [GetLastError]);
  Proc := PI.hProcess;
  CloseHandle(PI.hThread);
  if WaitForSingleObject(Proc, Infinite) <> Wait_Failed then
    GetExitCodeProcess(Proc, Result);
  CloseHandle(Proc);
end;

