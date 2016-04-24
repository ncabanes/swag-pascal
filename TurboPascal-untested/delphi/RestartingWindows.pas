(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0014.PAS
  Description: Restarting Windows
  Author: J. STEPHEN SILBER
  Date: 11-22-95  13:26
*)

{
There are two documented functions in the Windows API for restarting
Windows: ExitWindows(), and ExitWindowsExec().  (See the Windows API help
for details on both.) A common misconception is that the Program Manager DDE
macro call "[Reload()]" is for restarting Windows; it is not!

The call ExitWindows( 0, EW_RESTARTWINDOWS ) is _supposed_ to shut down
Windows, then bring it back up.  I've had no luck, though, from inside a
Delphi app.  It just shuts down Windows and gives me a DOS prompt.

ExitWindowsExec was built so that you could shut down Windows, execute a DOS
app (to replace Windows-critical DLL's, for example), and then bring Windows
hack up.  I have discovered that you simply need to pass a bad executable
name, and ExitWindowsExec performs exactly as ExitWindows was supposed to!

For example, the last few lines of an installation application may be:

        if (MessageDlg( 'The installation was successful!  You must now ' +
                       'restart Windows.  Do this now?', mtInformation,
                       [mbYes, mbNo], 0) = mrYes) then begin
           ExitWindowsExec( BOGUS_EXE, Nil );
        end;

where BOGUS_EXE is declared something like

        const
           BOGUS_EXE = 'zyxwvuts.exe';

-JSRS

-------------------------------------------------------------------------------

This should replace (or be appended to) the tip sheet entry about restarting
windows.

There is a documentation error  (probably due to the bad habits of 'C'
programmers) for the ExitWindows() API call... the parameters are reversed!

This code DOES WORK... (I've tested it. ;-) )

procedure TForm1.Button1Click(Sender: TObject);
begin
  ExitWindows(EW_RESTARTWINDOWS,0);
end;

