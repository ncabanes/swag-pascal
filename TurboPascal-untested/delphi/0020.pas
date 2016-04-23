
procedure AddPage(nbk : TNotebook; tabset : TTabSet; const pagename : string);
{ Adds a new page to nbk and a new tab to tabset with pagename for the text,   }
{ places a memo on the page, and brings the new page to the top.               }
{ Assumes the tabset has exactly one tab for each notebook page in same order. }
var
  memo : TMemo;
  page : TPage;
begin
  if nbk <> nil then begin
    nbk.Pages.Add(pagename);                       {add a page to the TNotebook}
    nbk.PageIndex := nbk.Pages.Count - 1;       {make new page the current page}
    if tabset <> nil then begin
      tabset.Tabs.Add(pagename);                            {add a matching tab}
      tabset.TabIndex := nbk.PageIndex;           {make new tab the current tab}
    end;
    if nbk.PageIndex > -1 then begin                   {make sure a page exists}
      page := TPage(nbk.Pages.Objects[nbk.PageIndex]);         {get page object}
      memo := TMemo.Create(page);                  {create memo (owned by page)}
      try
        memo.Parent := page;                                {set page as Parent}
        memo.Align  := alClient;             {set alignment to fill client area}
      except
        memo.Free;                           {free memo if something goes wrong}
      end;
      page.Visible := true;                  {make sure the page gets displayed}
    end;
  end;
end;

procedure DeletePage(nbk : TNotebook; tabset : TTabSet; index : integer);
{ Deletes the page whose PageIndex = index from nbk and tabset. }
{ Assumes the tabset has exactly one tab for each notebook page in same order. }
var
  switchto : integer;
begin
  if nbk <> nil then begin
    if (index >= 0) and (index < nbk.Pages.Count) then begin
      if index = nbk.PageIndex then begin
        if index < nbk.Pages.Count - 1 then begin  {if page is not last in list}
          switchto := nbk.PageIndex;     {show page behind current after delete}
          if (index = 0) and (nbk.Pages.Count > 1) then          {if first page}
            nbk.PageIndex := 1;                           {show second page now}
        end else
          switchto := nbk.PageIndex - 1;        {else, show page before current}
      end;
      nbk.Pages.Delete(index);          {free's the page & all controls it owns}
      if tabset <> nil then begin
        if index < tabset.Tabs.Count then
          tabset.Tabs.Delete(index);                  {delete corresponding tab}
      end;
      nbk.PageIndex := switchto;
    end;
  end;
end;
