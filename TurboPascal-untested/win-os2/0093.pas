
{Casting my eye down the WIN-OS2 snippets of SWAG I noticed an entry:-
	Booting under Windows
submitted in November '93 by Frank Young. It seemed a rather long winded
way of performing a reboot under Windows as there is a very versatile
API call to do this job.

The program presented here demonstrates the use of ExitWindows() - do a
Topic search in the Borland Windows IDE for details, but note the comment
below.

This program doesn't do very much - compile and run it then press the
right mouse button in the main window.}

{From: M. G. Crossley, U.K. 2nd March 1997. email: mike_crossley@msn.com}

program DoReboot;
{Borland Pascal Object Windows Version 7.0}
uses
  Wintypes,
  Winprocs,
  OWindows;

type
  TRebootApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PRebootWin = ^TRebootWin;
  TRebootWin = object(TWindow)
    procedure Reboot(var Msg : TMessage);
      virtual wm_First + wm_RButtonDown;
  end;

procedure TRebootWin.Reboot(var Msg : TMessage);
const
  ew_RebootSystem : longint = $43;
begin
  if MessageBox(hWindow,'Do you want to reboot?','Reboot Now?',mb_YesNo) = 
idYes
  then
    {Please note that the BORLAND help for ExitWindows() shows the formal
     parameters transposed - well it does on mine!}

    ExitWindows(ew_RebootSystem,0) {****** This is it! ******}

end;{TRebootWin.Reboot}

procedure TRebootApp.InitMainWindow;
begin
  MainWindow := New(PRebootWin, Init(nil, 'Press the RIGHT mouse button'));
end;{TRebootApp.InitMainWindow}

var
  RebootApp : TRebootApp;

begin
  RebootApp.Init('Reboot');
  RebootApp.Run;
  RebootApp.Done
end.
