
> "EWin32Error in Module VCL30.DPL at address 00010B8F. Problems Calling
> Win32 API"
>
> After this error the UI for Win95 gets all screwed up.

This is the routine of interest from SYSUTILS.PAS...

   procedure RaiseLastWin32Error;
   var
     LastError: DWORD;
     Error: EWin32Error;
   begin
     LastError := GetLastError;
     if LastError <> ERROR_SUCCESS then
       Error := EWin32Error.CreateFmt(SWin32Error, [LastError,
         SysErrorMessage(LastError)])
     else
       Error := EWin32Error.Create(SUnkWin32Error);
     Error.ErrorCode := LastError;
     raise Error;
   end;

If the message does not include an error code, GetLastError returned
ERROR_SUCCESS. From what I can tell, this can occur in these places...

   - Controls.TWinControl.CreateWnd; the call to Windows.RegisterClass fails

   - Controls.TWinControl.CreateWnd; the call to Windows.CreateWindow or
Windows.CreateWindowEx fails

   - Classes.THandleStream.SetSize; the call to SetEndOfFile fails with no
error code

   - ComObj.RegisterComServer; a procedure named DllRegisterServer does not
exist in the DLL

   - ComObj.CreateRemoteComObject; the call to GetModuleHandle('ole32.dll')
fails with no error code

>From the symptoms you've described, the first two seem to be the most
likely. I suspect that you are running out of some resource (not memory;
probably GDI or USER heap space). Does the problem persist if you remove a
few of the 40 controls? What other programs are running on the computer?
What video driver are you using? It wouldn't happen to be a Diamond product?

- Brian
