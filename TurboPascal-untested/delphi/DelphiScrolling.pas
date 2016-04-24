(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0075.PAS
  Description: Re: Delphi:  Scrolling
  Author: THE NOMAD
  Date: 11-24-95  10:16
*)


My response before was "Look into SendMessage, WM_VSCROLL and
SB_PAGEDOWN".  I am happy to provide this code fragment in hopes that you
really *did* look into my suggestion but couldn't figure out how to make it
work.


procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F8 then
    SendMessage(Memo1.Handle,  { HWND of the Memo Control }
                WM_VSCROLL,    { Windows Message }
                SB_PAGEDOWN,   { Scroll Command }
                0)             { Not Used }
  else if Key = VK_F7 then
    SendMessage(Memo1.Handle,  { HWND of the Memo Control }
                WM_VSCROLL,    { Windows Message }
                SB_PAGEUP,     { Scroll Command }
                0);            { Not Used }
end;

