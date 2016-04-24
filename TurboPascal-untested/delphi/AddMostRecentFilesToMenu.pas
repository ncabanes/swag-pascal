(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0225.PAS
  Description: Re: Add most recent files to menu
  Author: PAUL SOBOLIK
  Date: 03-04-97  13:18
*)

{
> How do you add the most recent files accessed to the file menu?

Of course, there's no one answer to this question, but here are some
excerpts from my implementation of that feature, clipped from a text
editor I wrote.

First, I subclassed TStringList to hold the list of recent files.
}

type
  TRecentFileList = class(TStringList)
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: String): Integer; override;
    procedure Remove(const s: String);
  end;

Create and Destoy mostly involve reading and writing the list to the
registry, so that the recent file list will be persistent. Add and
Remove are shown below.

function TRecentFileList.Add(const S: String): Integer;
begin
  Result := IndexOf(s);
  if (Result = -1) then begin
    if Count >= MAX_RECENT_FILES then Delete(MAX_RECENT_FILES - 1);
    Insert(0, s); Result := 0;
  end;
end;

procedure TRecentFileList.Remove(const s: String);
var
  i: Integer;
begin
  i := IndexOf(s);
  if i >= 0 then Delete(i);
end;

The main form contains a TRecentFileList called recentFileList. When
the program closes a file it adds it to this list; When it opens
one, it removes it. (As shown, the TRecentFileList is smart
enough not to add a file twice, or to try and delete a non-existant
file.) The OnClick handler for the main menu's "File" menu item,
FileMenuClick, creates a TMenuItem for each recent file in the
list and adds it to the TMenuItem named FileReopenItem before it
opens the menu. Thus the names of the recent files appear in a
submenu to a menu item captioned "Reopen".

procedure TMainForm.FileMenuClick(Sender: TObject);
var
  i: Integer;
  mi: TMenuItem;
begin
  if recentFileList.Count = 0 then FileReopenItem.Enabled := False
  else begin
    FileReopenItem.Enabled := True;
    for i := FileReopenItem.Count - 1 downto 0 do
      FileReopenItem.Delete(i);
    for i := 0 to recentFileList.Count - 1
    do begin
      mi := TMenuItem.Create(Self);
      mi.Caption := recentFileList[i];
      mi.OnClick := FileReopen;
      FileReopenItem.Add(mi);
    end;
  end;
end;

The recent file menu items each have the procedure FileReopen as
their OnClick handler. When the user clicks one of the recent file
menu items, this procedure uses the caption of the clicked item to
determine what file to reopen.

procedure TMainForm.FileReopen(Sender: TObject);
var
  fileName: String;
begin
  fileName := (Sender as TMenuItem).Caption;
  CreateMemoPage.LoadFromFile(fileName);
  recentFileList.Remove(fileName);
end;

