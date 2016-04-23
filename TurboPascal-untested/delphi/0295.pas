
> Does anyone know a way to change the font in the dialog displayed by
> the MessageDlg function?

The Dialogs unit contains the MessageDlg function which in turn calls a
function called MessageDlgPos. MessageDlgPos calls CreateMessageDialog
which actually creates the message dialog and returns it. If you alter
MessgeDlgPos (or create a new one) you can change the font of the
dialog.

ex. of a new MessageDlgPos to set font name, size and style:

function MessageDlgPosSetFont(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer; sFontName:
string;
  iFontSize: Integer; fsStyle: TFontStyles): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons) do
    try
      HelpContext := HelpCtx;
      if X >= 0 then Left := X;
      if Y >= 0 then Top := Y;
      // set the font name, size and style
      Font.Name:=sFontName;
      Font.Size:=iFontSize;
      Font.Style:=fsStyle;
      Result := ShowModal;
    finally
      Free;
    end;
end;
