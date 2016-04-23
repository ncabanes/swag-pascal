
Q: When I select the "Run Minimized" option in Program Manager
   to attempt to make my Delphi application execute in a minimized
   state, the Delphi application seems to ignore the setting and
   run normally. Why is this, and how to I fix it?

A: Delphi's Application object creates a hidden "application
   window," and it is that window, rather than your main form,
   that is being sent the command to show minimized. To fix this,
   make your main form's OnCreate event handler look like this:

      procedure TForm1.FormCreate(Sender: TObject);
      {$IFDEF WIN32}           { Delphi 2.0 (32 bit) }
      var
        MyInfo: TStartUpInfo;
      {$ENDIF}
      begin
      {$IFDEF WIN32}           { Delphi 2.0 (32 bit) }
        GetStartUpInfo(MyInfo);
        ShowWindow(Handle, MyInfo.wShowWindow);
      {$ENDIF}
      {$IFDEF WINDOWS}         { Delphi 1.0 (16 bit) }
        ShowWindow(Handle, cmdShow);
      {$ENDIF}
      end;

   In other words, for 16 bits, just pass cmdShow to ShowWindow.
   For 32 bits you need to obtain the start up info by calling the
   GetStartUpInfo procedure, which fills in a TStartUpInfo record,
   and then pass TStartUpInfo.wShowWindow to ShowWindow.
