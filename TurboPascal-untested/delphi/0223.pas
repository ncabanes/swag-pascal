
{
Here is some code I found a while back that will work in D1 or D2.  It
checks for previous instance and if the program is already running, it will
activate the previous instance including pulling up an iconic program.  I
have enclosed the source in an imaginary project (.dpr) file.

----- begin code for Check.dpr -----
}
program Check;

uses  WinTypes, WinProcs, SysUtils, Forms,
  MainForm in 'MAIN.PAS' {Form1},
  SecondForm in 'SECOND.PAS' {Form2},
  ThirdForm in 'THIRD.PAS' {Form3};

{$R *.RES}
{$IFDEF Win32}
  var Mutex: THandle;
{$ENDIF}

procedure CheckPrevInst;
  var PrevWnd: HWnd;
  begin
    {$IFDEF Win32}
      Mutex:=CreateMutex(NIL, False, 'SingleInstanceProgramMutex');
      if WaitForSingleObject(Mutex, 10000)=WAIT_TIMEOUT then Halt;
    {$ELSE}
      if HPrevInst=0 then Exit;
    {$ENDIF}
    PrevWnd:=FindWindow('TOneInstanceForm1', '1-Instance Program');
    if PrevWnd<>0 then PrevWnd:=GetWindow(PrevWnd, GW_OWNER);
    if PrevWnd<>0 then begin
      if IsIconic(PrevWnd) then ShowWindow(PrevWnd, SW_SHOWNORMAL)
      else  {$IFDEF Win32}
        SetForegroundWindow(PrevWnd);
      {$ELSE}
        BringWindowToTop(PrevWnd);
      {$ENDIF}
      Halt;
      end;
    end;

begin
  try
    CheckPrevInst;
    Application.CreateForm(TOneInstanceForm1, OneInstanceForm1);
  finally
    {$IFDEF Win32}
      OneInstanceForm1.HandleNeeded;
      ReleaseMutex(Mutex);
      CloseHandle(Mutex);
    {$ENDIF}
  end;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
  end.
