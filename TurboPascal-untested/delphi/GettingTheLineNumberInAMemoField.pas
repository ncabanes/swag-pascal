(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0025.PAS
  Description: Getting the Line number in a memo Field
  Author: SWAG SUPPORT GROUP
  Date: 11-22-95  13:33
*)


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
