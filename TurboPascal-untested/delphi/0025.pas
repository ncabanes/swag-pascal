
How do you figure out what line number you are currently 
on with a TMemo control?

The trick is to use the em_LineFromChar message.  Try this:

procedure TMyForm.BitBtn1Click(Sender: TObject);
var
  iLine : Integer ;
begin
   iLine := Memo1.Perform(em_LineFromChar, $FFFF, 0);
   { Note: First line is zero }
   messageDlg('Line Number: ' + IntToStr(iLine), mtInformation, 
              [mbOK], 0 ) ;
end;


