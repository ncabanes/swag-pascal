{
Q:  How can I trap for my own hotkeys?

A:  First: set the form's KeyPreview := true;

Then, you do something like this:
}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (chr(Key) in ['A', 'a']) then
    ShowMessage('Ctrl-A');
end;
