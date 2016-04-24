(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0028.PAS
  Description: File Manager Drag/Drop
  Author: MARK JOHNSON
  Date: 11-22-95  15:49
*)


To use File Manager Drag & Drop, add a method to your form that
handles the WM_DROPFILES message.  For example, the following
would be placed in the TForm1 declaration in the protected
section:

    ...
    procedure WMDropFiles(var msg : TMessage); message WM_DROPFILES;
    ...

You would typically activate file drag & drop by calling
DragAcceptFiles() in the OnCreate event, and turn it off
with a subsequent call to DragAcceptFiles() in the OnClose
or OnDestroy events.  The code follows:

procedure TForm1.WMDropFiles(var msg : TMessage);
var
  i, n  : word;
  size  : word;
  fname : string;
  hdrop : word;
begin
  {1. Get the drop handle.}
  hdrop := msg.WParam;
  {2. Find out how many files were dropped by passing $ffff in arg #2.}
  n := DragQueryFile(hdrop, $ffff, nil, 0);
  {3. Loop through, reading in the filenames (w/full paths).}
  for i := 0 to (n - 1) do begin
    {4. Get the size of the filename string by passing 0 in arg #4.}
    size := DragQueryFile(hdrop, i, nil, 0);
    {5. Make sure it won't overflow our string (255 char. limit)}
    if size < 255 then begin
      fname[0] := Chr(size);
      {6. Get the dropped filename.}
      DragQueryFile(hdrop, i, @fname[1], size + 1);
      {-- Do whatever you want to do with fname. --}
    end;
  end;
  {7. Return zero.}
  msg.Result := 0;
  {8. Let the inherited message handler (if there is one) go at it.}
  inherited;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, true);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DragAcceptFiles(Handle, false);
end;

Keep in mind that you don't have to put all of this stuff
on a form.  Any windowed control that has an HWnd handle
(descendants of TWinControl) should be able to accept
dropped files.

I hope this answers your question.
--Mark Johnson

