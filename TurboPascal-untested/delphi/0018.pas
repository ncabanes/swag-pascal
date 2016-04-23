
>1.  Does anyone know how to determine if Delphi is running or not?

I cannot answer the VBX question, but I have done the first one.  When
Delphi is running, there are several windows open, not just Delphi.
Therefore, your app should check for more than one Delphi window, making it
very difficult for another app to simulate being Delphi.  For example:

function DelphiIsRunning : boolean;
var
  H1, H2, H3, H4 : Hwnd;
const
  A1 : array[0..12] of char = 'TApplication'#0;
  A2 : array[0..15] of char = 'TAlignPalette'#0;
  A3 : array[0..18] of char = 'TPropertyInspector'#0;
  A4 : array[0..11] of char = 'TAppBuilder'#0;
  T1 : array[0..6] of char = 'Delphi'#0;
begin
  H1 := FindWindow(A1, T1);
  H2 := FindWindow(A2, nil);
  H3 := FindWindow(A3, nil);
  H4 := FindWindow(A4, nil);
  Result := (H1 <> 0) and (H2 <> 0) and
            (H3 <> 0) and (H4 <> 0);
end;

initialization
  if not DelphiIsRunning then
  begin
    AboutBox := TAboutBox.Create(nil);
    AboutBox.ShowModal;
    AboutBox.Free;
    Halt;
  end;
end.

The biggest problem with this approach that I've found is that when you
create a program using this code, it will run from within Delphi (which is
what you want), but it will also run as a standalone app as long as Delphi
is currently running.  I guess that's not too big a problem :).  This is the
approach used by TurboPower Software in the Orpheus Trial-Run.  I haven't
seen their code, so I don't know which window(s) they are checking for, but
programs created using the Trial-Run components exhibit the behaviour
created by this technique.

To see the windows an app creates so you can get the list of constants
above, use WinSight.

BTW, I just thought of this.  If Delphi has a DDE or OLE interface (I don't
know), you could first look for an app named Delphi then try to start a
conversation with any app that matches.  If it responds properly you can
run, otherwise halt.  Just an idea.  This could work for other apps that do
have DDE or OLE.

Hope this helps.

-Wade Tatman
