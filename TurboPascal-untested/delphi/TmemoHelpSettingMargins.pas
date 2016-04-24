(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0099.PAS
  Description: Re: TMemo Help >>  Setting Margins
  Author: RAY CRAMER
  Date: 02-21-96  21:04
*)

{
In article 25@mailhost.primenet.com, rkr@primenet.com writes:
>Is there a way in a TMemo object to set the text margin from the left and or t
op??
>
>Meaning , all the text going down the left side of the memo would start let's
say,
>10 pixels over instead of right up against the side of the Memo ??
>
}
 
procedure TEditForm.SetEditRect;
Var
  R : TRect;
begin
  R := DisplayMemo.ClientRect;
  R.Left:=R.Left + kMemoIndent;
  R.Top:=R.Top + 2;
  R.Bottom:=R.Bottom - 2;
  R.Right:=R.Right - kMemoIndent;
  SendMessage(DisplayMemo.Handle, EM_SETRECT, 0, Longint(@R));
end;

