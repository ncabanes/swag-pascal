
> I'd like to have my Delphi Program  dial up my ISP (using the WIN95)

Hi Scott

    To start your Dial Up Connection, you can use something like this:
WinExec('rundll32.exe rnaui.dll,RnaDial NAME',SW_SHOWNORMAL);
where NAME is the exact title of your connectoid in dial up networking.
To automatic press button "Connect" you can use this:

procedure TForm1.Timer1Timer(Sender: TObject);
var buf,buf1 : array [0..100] of char;
    hnd,hnd1 : hWnd;
    ln  : integer;
begin
     Try
       hnd := GetForegroundWindow;
       ln:=GetWindowTextLength(hnd);
       GetMem(lpStr,ln+1);
       GetWindowText(hnd,lpStr,ln+1);
       Edit1.Text := StrPas(lpStr);
       if lpstr='Connect with' then
       begin
         hnd1 := GetWindow(hnd,GW_child);
         getwindowtext(hnd1,buf1,sizeof(buf1));
         while (buf1<>'Connect') do
         begin
           hnd1 := GetWindow(hnd1,GW_hwndnext);
           getwindowtext(hnd1,buf1,sizeof(buf1));
         end;
         beep;
         PostMessage(hnd1,BM_CLICK,0,0);
       end;
     Finally
       FreeMem(lpStr,ln);
     end;
end;
