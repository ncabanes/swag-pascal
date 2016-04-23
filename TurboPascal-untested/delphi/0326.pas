
>Is there an easy way to do multi-line
>captions on a TButton?

var
 btn:Longint


  btn:=GetWindowLong(Button1.Handle,GWL_STYLE);
  SetWindowLong(Button1.Handle,GWL_STYLE,btn or BS_MULTILINE);
  Button1.Caption := 'This is a multi-line Button';

 -or-

  SendMessage(Button1.Handle, BM_SETSTYLE, BS_MULTILINE,1);
  Button1.Caption := 'This is a multi-line Button';


But the second didn't seem to want to re-draw the button with
the Multiline Caption.  Any ideas?
