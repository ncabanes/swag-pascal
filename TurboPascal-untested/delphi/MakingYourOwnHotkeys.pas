(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0107.PAS
  Description: Making your own hotkeys
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

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
