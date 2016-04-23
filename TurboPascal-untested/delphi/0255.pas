
Why does everyone want to make things so difficult?  Doing it this
way, the Splash pops up and stays up until the rest of the app is
initialized (with a minimum time set in the Splash form's
CloseQueary).  No muss, no fuss, no bother.

In the Splash form's unit ->
{----------------------------------------------------------}
PROCEDURE TSplash.FormCloseQuery(Sender: TObject;
                                 VAR CanClose: Boolean);
Begin
  REPEAT UNTIL GetTickCount-Start > 5000; {minimum time 5 seconds}
  CanClose := True;
end;

PROCEDURE TSplash.FormShow(Sender: TObject);
Begin
  Start := GetTickCount;  {Start is a CARDINAL variable in the
                           Private section of the Splash form}
End;

{---------------------------------------------------}

And in the .DPR ->

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSplash, Splash);
  Splash.Show;
  Splash.Refresh;
  {any other forms to be created and other initialization
   stuff goes here}
  Splash.Close;
  Application.Run;
end.
{--------------------------------------------------}

This is the way I do it, and it works just fine.  My Splash form is
also my About Box, so I like it to be available throughout the life
of the app.

HTH

--
Daniel J. Wojcik
It looked so nice out this morning...
...I decided to leave it out all day!
--

