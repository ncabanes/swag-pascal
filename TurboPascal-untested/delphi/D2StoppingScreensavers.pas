(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0380.PAS
  Description: D2 Stopping Screensavers
  Author: AHTO TANNER
  Date: 01-02-98  07:33
*)

>Can I prevent any screensaver to kick in as long as my application is
>running ?


Hi Lee,

Try the following:

Assign the following handler to Application.OnMessage:

procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if Msg.Message = WM_SYSCOMMAND then
    if (Msg.wParam = SC_SCREENSAVE) or (Msg.wParam = SC_MONITORPOWER) then
      Handled := true; // prevent screensaver
end;

This will prevent starting screensaver or monitor power saving.

Regards,

Ahto

