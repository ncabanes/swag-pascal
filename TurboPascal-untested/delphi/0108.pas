{
Q.   How can you do scrolling functions in a TForm component
using  keyboard commands?  For example, scrolling up and down
when a  PgUp or PgDown is pressed.  Is there some simple way to
do this or does it have to be programmed by capturing the
keystrokes and manually responding to them?

A.    Form scrolling is accomplished by modifying the
VertScrollbar  or HorzScrollbar Postion properties of the
form.  The following code demonstrates how to do this:
}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
Shift: TShiftState);
const
  PageDelta = 10;
begin
  With VertScrollbar do
    if Key = VK_NEXT then
      Position := Position + PageDelta
    else if Key = VK_PRIOR then
      Position := Position - PageDelta;
end;
