
Hi

> From:          Ahmad Rosadi Djarkasih <djar@arjuna.telkom.net.id> I
> need to exec an app and wait until that particular app is terminated
> ? How can I do it in 32 bit environment ? Since function
> GetModuleUsage is obsolete in Win32 API.

WinExec and WinExecAndWait follow:

---------------------------------------------------
 Following are two examples which I've used to launch other 
applications. They have both come in handy. Source edited from public 
newsgroup postings. 100% FreeWare. All I asked is: nothing!! It's 
free, do what you want with it.

 -Nick Webster
 nwebster@circle.net
 Some Guy On The Net
 Asheville, North Carolina. USA

{------= Launch Another Program Method One =-----------------------}

 // Path and filename are hard coded  

procedure TForm1.Button2Click(Sender: TObject);
Var
  Fn : String;
 TSI : TStartupInfo;
 TPI : TProcessInformation;
begin
      Fn := 'C:\TEST.EXE';
      WndHandle := 0;
      FillChar(TSI, SizeOf(TSI), 0);
      TSI.CB := SizeOf(TSI);
       If CreateProcess (PChar(Fn), NIL, NIL, NIL, False,
       DETACHED_PROCESS, NIL,   NIL, TSI, TPI) Then
     Begin
      ShowMessage('Look I started another program!');
     End;
end;
{------= End Method One---------------------------------------------}


{-----= Launch Another Program Method Two =-------------------------}

// aCmdLine  Path and filename of file to launch            : String
// aHide     Hide this program while the launched one runs  : Boolean
// aWait     Wait for the launched program to finish        : Boolean 

Function TForm1.FileExec(const aCmdLine: String; aHide, aWait: Boolean):
Boolean;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
begin
  {setup the startup information for the application }
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do
  Begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
     If aHide Then wShowWindow := SW_HIDE
      else wShowWindow := SW_SHOWNORMAL;
  End;

  Result := CreateProcess(nil,PChar(aCmdLine), nil, nil, False,
               NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);

  If aWait Then
   If Result Then
    Begin
     WaitForInputIdle(ProcessInfo.hProcess, INFINITE);
     WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    End;
end;
{-----= End Method Two =--------------------------------------------}



--
Daniel J. Wojcik
Help prevent forest fires...chop down a tree today!
--
