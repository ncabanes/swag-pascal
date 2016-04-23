
I need to emulate the color selection options of control panel... I looked
up the setsyscolor procedure, but though it seems to cause a global repaint,
it seems to have no effect... is it no longer supported? should I instead
change the win.ini (or is it system.ini - sorry - can't remember right now.)
If I change these values will programs update - or do they have to be
notified in some way?

A:
procedure TMainForm.Button4Click(Sender: TObject);
var
nColorIndex: array [1..2] of integer;
nColorValue: array [1..2] of longint;
begin
    nColorIndex[1]:=COLOR_ACTIVECAPTION;
    nColorIndex[2]:=COLOR_BTNFACE;
    nColorValue[1]:=clBlue;
    nColorValue[2]:=clRed;
    SetSysColors(2,nColorIndex,nColorValue);
    PostMessage(HWND_BROADCAST,WM_SYSCOLORCHANGE,0,0);
end;
