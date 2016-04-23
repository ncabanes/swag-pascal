
These procedures hide and show the Win95 Taskbar. I'd like to control
whether or not all the items in the Start, like Program, Find, Help, appear
or not from my application. Reason: my custumer does not want his
employee opening other windows, only my application. My app should
make them appear when closed.

(I got them from ZD Tips)

procedure hideTaskbar;
var wndHandle : THandle;
    wndClass  : array[0..50] of Char;
begin
 StrPCopy(@wndClass[0], 'Shell_TrayWnd');
 wndHandle := FindWindow(@wndClass[0], nil);
 ShowWindow(wndHandle, SW_HIDE); // This hides the taskbar
end;

procedure showTaskbar;
var wndHandle : THandle;
    wndClass  : array[0..50] of Char;
begin
 StrPCopy(@wndClass[0], 'Shell_TrayWnd');
 wndHandle := FindWindow(@wndClass[0], nil);
 ShowWindow(wndHandle, SW_RESTORE); // This restores the taskbar
end;

