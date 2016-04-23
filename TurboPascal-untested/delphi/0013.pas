
Code to make the <Enter>key act as the tab key while inside a grid.

This code also includes the processing of the <Enter> key for the entire
application - including fields, etc.  The grid part is handled in the
ELSE portion of the code.  The provided code does not mimic the behavior
of the <Tab> key stepping down to the next record when it reaches the last 
column in the grid - it moves back to the first column - .

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);

{ This is the event handler for the FORM's OnKeyPress event! }
{ You should also set the Form's KeyPreview property to True }
begin
  if Key = #13 then                              { if it's an enter key }
    if not (ActiveControl is TDBGrid) then begin { if not on a TDBGrid }
      Key := #0;                                 { eat enter key }
      Perform(WM_NEXTDLGCTL, 0, 0);              { move to next control }
    end
    else if (ActiveControl is TDBGrid) then      { if it is a TDBGrid }

      with TDBGrid(ActiveControl) do
        if selectedindex < (fieldcount -1) then  { increment the field }
          selectedindex := selectedindex +1
        else
          selectedindex := 0;
end;

