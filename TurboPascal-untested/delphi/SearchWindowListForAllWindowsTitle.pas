(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0145.PAS
  Description: Search window list for all Windows title
  Author: FERDINAND SOETHE
  Date: 08-30-96  09:35
*)


function FindMatchingWindows(SearchFor: string; AtBeginning: boolean; var FoundWindows: TStringList): longint;

{Search window list for all Windows where the title contains or begins
 with (AtBeginning) SearchFor. Returns a TStringList with the title of the
 found windows as string and the window-Handle as Object.
 It is up to you to create and free the TStringList}

var
  hWndFirst, hWndCurWin, hWndDesk: HWnd;
  szWinText: pChar;
  WinText: string;
  foundAt: byte;
begin
  hWndDesk:= GetDesktopWindow;
  {This ist the parent of alle top-level windows}
  if hWndDesk <> 0 then
        hWndCurWin := GetWindow(hWndDesk,GW_CHILD)
  else
        {place error handling here}
        exit;
  if not assigned(FoundWindows) then
        {you have to create Stringlist before passing the
         variable to this function}
        exit;
  getMem(szWinText,256);
  hWndFirst:= hWndCurWin;
  while (hWndCurWin <> 0) do
  begin
    GetWindowText(hWndCurWin, szWinText,255);
    WinText:= strpas(szWinText);
    if SearchFor = '' then
    begin
        if WinText = '' then Wintext := format ('Fenster Nr. %d (Ohne Titel)',[hWndCurWin]);
        FoundWindows.addObject(WinText,TObject(hWndCurWin))
    end
    else
    begin
      foundAt:= pos(SearchFor, WinText);
      if (not atBeginning and (foundAt > 0)) or (foundAt = 1) then
      begin
        FoundWindows.addObject(WinText,TObject(hWndCurWin));
      end;
    end;
    hWndCurWin := GetWindow(hWndCurWin,GW_HWNDNEXT);
  end;
  freeMem(szWinText,256);
  result := FoundWindows.count;
end;



