Animated cursors have become so popular since the good old days of
Windows 3.0, now they are a built-in part of the Windows 95 and
Windows NT operating systems. Here's how you can use them in your
Delphi program:

const
  cnCursorID1 = 1;
begin
  Screen.Cursors[ cnCursorID1 ] :=
  LoadCursorFromFile('c:\winnt\cursors\piano.ani' );
  Cursor := cnCursorID1;
end;


"c:\winnt\cursors\piano.ani" is of course the name of the animated
cursor file and cnCursorID1 (defined as 1) is the index of your newly
defined cursor. If you wanted to use more than one animated cursor,
simply use a different index number -- cnCursorID2 (or 2) for example.

{ ------------------- }

Does anyone know how to make an existing cursor available to a project?
The following example from on-line help should work if you have created a
cursor resource, but I can't seem to find how to do that.

Start Example

This example assumes you have created a cursor resource with the name
NewCursor. The code loads the new cursor into the Cursors property array
and makes the newly loaded cursor the cursor of the form:

const
  crMyCursor = 5;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'NewCursor');
  Cursor := crMyCursor;
end;

End Example

The only help I've seen on creating a cursor resource is a statement
something like:

NewCursor Cursor "C:\pathname......\filename"

