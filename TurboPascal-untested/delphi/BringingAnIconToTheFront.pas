(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0016.PAS
  Description: Bringing an icon to the front
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  13:27
*)


>How can you bring an icon to the front (set focus), without actually
>restoring the mainwindow?

Michael--

  If the form/app is already minimized, this should do what you want:

  ShowWindow(Form1.Handle, SW_MINIMIZED);

  NB: I have not actually tried this, although I see no reason why it
wouldn't work.


