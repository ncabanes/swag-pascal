
Procedure TYourFormName.HideTitlebar;
Var
  Save : LongInt;
Begin
  If BorderStyle=bsNone then Exit;
  Save:=GetWindowLong(Handle,gwl_Style);
  If (Save and ws_Caption)=ws_Caption then Begin
    Case BorderStyle of
      bsSingle,
      bsSizeable : SetWindowLong(Handle,gwl_Style,Save and
        (Not(ws_Caption)) or ws_border);
      bsDialog : SetWindowLong(Handle,gwl_Style,Save and
        (Not(ws_Caption)) or ds_modalframe or ws_dlgframe);
    End;
    Height:=Height-getSystemMetrics(sm_cyCaption);
    Refresh;
  End;
end;

Procedure TYourFormName.ShowTitlebar;
Var
  Save : LongInt;
begin
  If BorderStyle=bsNone then Exit;
  Save:=GetWindowLong(Handle,gwl_Style);
  If (Save and ws_Caption)<>ws_Caption then Begin
    Case BorderStyle of
      bsSingle,
      bsSizeable : SetWindowLong(Handle,gwl_Style,Save or ws_Caption or
        ws_border);
      bsDialog : SetWindowLong(Handle,gwl_Style,Save or ws_Caption or
        ds_modalframe or ws_dlgframe);
    End;
    Height:=Height+getSystemMetrics(sm_cyCaption);
    Refresh;
  End;
end;

