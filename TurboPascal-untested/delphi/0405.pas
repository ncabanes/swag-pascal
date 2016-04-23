

No screen savers for me please.

If your program needs all the attention of the computer, you might want
to temporarily turn off screen savers -- at lease while your program
is running. Rather than actually disabling and enabling the Windows
screen saver, you can simply tell Windows that you've already handled
the call for the default screen saver -- SC_SCREENSAVE.

Insert the following code into the "Public declarations" section of
your main form:

    procedure AppMessage(
      var Msg : TMsg;
      var bHandled : boolean ); 


In the "implementation" section, insert the following code (don't forget to change TForm1 to the [type] name of your form): 

procedure TForm1.AppMessage(
  var Msg : TMsg;
  var bHandled : boolean );
begin
  if((WM_SYSCOMMAND = Msg.Message) and
     (SC_SCREENSAVE = Msg.wParam) )then
    bHandled := True;
end; 


