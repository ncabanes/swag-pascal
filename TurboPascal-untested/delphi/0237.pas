{ Windows95/NT Toolbar registering example }
{ 2/13/97 by Brandon Sneed (Nivenh)}
{ If you use this, don't give me credit }


{ Add ShellAPI to your Uses clause }

{ This code was pulled from an app i wrote and has been modified to make
	it a little more understandable for those 'not-so-fluent' delphi coders }

{ I put it in the OnShow event, but it probably could go in the create event
	too maybe.. or anywhere else for that matter }
procedure TForm1.OnShow(Sender: TObject);
var Result : integer;
		BarData : TAppBarData;
begin

with BarData do
  begin
  cbSize := SizeOf(BarData);  { Size of the struct }
  hwnd := OWForm.Handle;      { Window handle to register as app bar }
  uCallBackMessage := WM_USER;{ Message used for APPBAR specific messages }
  uEdge := ABE_LEFT;          { Side of screen to bind with }
  rc := Rect(0, 0, OWForm.Width+1, OWForm.Height);
                              {^^ Rectangle being requested to use }
  lParam := 0;                { Only used for ABM_AUTOHIDEBAR }
  end;

Result := SHAppBarMessage(ABM_NEW, BarData);  { Register with explorer }
if Result = 0 then
  begin
  ShowMessage('Unable to register AppBar.');
  exit;
  end;

SHAppBarMessage(ABM_QUERYPOS, BarData); { Can we use BarData.RC ?? }
																				{ API wasn't clear on what this returned }
SHAppBarMessage(ABM_SETPOS, BarData);   { Set the position to be the same as in RC }
{ ^^ this is what makes everything fall into place }

with OWForm do
  begin
  Application.ProcessMessages; { Without this, it places in the wrong spot, could
																 be an error on my part somewhere }
  SetWindowPos(Handle, HWND_BOTTOM, left-width, top, width, height, SWP_NOREDRAW);
  { ^^ this sets the window where we want it.  at the very left edge of the screen }
	{ modify this line to suit }
  end;
end;

{ NOTE:  This ONLY reigsters it as a toolbar and places it in the appropriate
	spot.  You still need to make handlers for the other ABE/ABM messages.
	See the documentation in Delphi 2.0 and up for more info.  Look up
	SHAppBarMessage }
