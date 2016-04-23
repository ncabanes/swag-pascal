
From: "James D. Rofkar" <jim_rofkar%lotusnotes1@instinet.com>

Robert Copier wrote:
> Is there a way to hide the Windows 95 statusbar when i start my
application made in delphi 2.01. When the user close the application
the statusbar must become visible again.

I'm guessing you're referring to the Windows 95 taskbar and system
tray window, and not a statusbar. The answer: Sure you can! And
what a cool idea! Here's how:

First declare a variable of type HWND to store the Window handle of
the Windows 95 taskbar.
--------------------------------------------------------------------------------

      TForm1 = class(TForm)
         ...
      private
         hTaskBar: HWND;
         ...
      end;

--------------------------------------------------------------------------------

In  your  main  form's  OnCreate()  event  handler,  place  some  code that
resembles:
--------------------------------------------------------------------------------

      hTaskBar := FindWindow('Shell_TrayWnd', nil);
      ShowWindow(hTaskBar, SW_HIDE);

--------------------------------------------------------------------------------

Finally,  in your  main form's  OnDestroy() event  handler, code  something
like:

--------------------------------------------------------------------------------

      ShowWindow(hTaskBar, SW_SHOW);

--------------------------------------------------------------------------------

