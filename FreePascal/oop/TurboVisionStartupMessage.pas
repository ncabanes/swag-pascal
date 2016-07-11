(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0067.PAS
  Description: Turbo Vision Startup Message
  Author: DARREN OTGAAR
  Date: 05-26-95  23:30
*)

{
>Can anyone please tell me if and how it would be possible to have a "WE
>dialog box appear as soon as the desktop is displayed.

I presume you are taking about the desktop in BP7.0, ie OOP.  In that case
it is very easy.  All you have to do is create a virtual procedure in your
application instance, and call it in the main program loop like this:

From: darren.otgaar@leclub.co.za (Darren Otgaar)
}

PROGRAM Dialog;

USES MsgBox, App;

TYPE TDialog = OBJECT(TApplication)
     PROCEDURE DisplayBox; VIRTUAL;
     END;

PROCEDURE TDialog.DisplayBox;
BEGIN
   MessageBox(#3'Welcome to this Program'#13 +
              #3'Hope you love it!'#13, NIL, mfInformation OR mfOkButton);
END;

VAR TDialogApp : TDialog;

BEGIN
   TDialogApp.Init;
   TDialogApp.DisplayBox;
   TDialogApp.Run;
   TDialogApp.Done;
END.

{
That will ensure that the user has to deal with the message box before the
program continues.  If you want a fancier message box, all you do is create
a dialog box and do exactly the same.
}
