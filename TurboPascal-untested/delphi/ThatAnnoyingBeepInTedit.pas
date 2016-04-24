(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0155.PAS
  Description: Re: That annoying Beep in TEdit
  Author: MARK VAUGHAN
  Date: 08-30-96  09:35
*)


{
-Does anybody know how I can supress the BEEP in a TEdit component while
-pressing the RETURN key?

Trap the <Enter> key in the TEdit's OnKeyPress handler.
Here's the sort of thing I've been using to make the
<Enter> key behave like the <Tab> key in a TEdit...
}

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
  BEGIN
    if (Key = #13) then    {= gotcha! =}
      BEGIN
        Key := #0;         {= kill the beep =}
        PostMessage(Handle, WM_NEXTDLGCTL, 0, 0);   {= move to next tab stop =}
      END;
  END;


