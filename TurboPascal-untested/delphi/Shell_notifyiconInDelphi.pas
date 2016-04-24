(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0433.PAS
  Description: Shell_NotifyIcon in DELPHI
  Author: NEIL CLAYTON
  Date: 01-02-98  07:34
*)


From: "Neil Clayton" <100101.602@compuserve.com>

Rainer Perl <Rainer.Perl@iddc.via.at> wrote in article

> I have a question to the Shell_NotifyIcon function:
> I can add an icon to the taskbar
> I can modify an icon
> I can delete an icon.
> What I can't do: I can't receive Messages from the Icon!!
To receive messages you must add the NIF_MESSAGE flag to your notify structure and tell it what message to send and to which window. This is the code that I use:


--------------------------------------------------------------------------------

procedure TMainForm.UpdateTaskBar;            // update the win95 taskbar icon area
var
  NotifyData: TNotifyIconData;

begin
  With NotifyData do                                            // set up the data structure
  begin
    cbSize             := SizeOf(TNotifyIconData);
    Wnd                := MyForm.Handle;
    uID                  := 0;
    uFlags             := NIF_ICON or NIF_MESSAGE or NIF_TIP;   // ... the aspects to modify ...
    uCallbackMessage := WM_MY_MESSAGE;                         // ... the message to send back to us ...
    hIcon              := hMyIcon;
    szTip              := 'Tool Tip To Display';           // ... and the tool tip
  end;
  Shell_NotifyIcon(dwMessage, @NotifyData);                     // now do the update
end;

--------------------------------------------------------------------------------

WM_MYMESSAGE is a user defined message. Usually defined as:


--------------------------------------------------------------------------------

const
  WM_MYMESSAGE = WM_USER + <some number - can be zero>;

