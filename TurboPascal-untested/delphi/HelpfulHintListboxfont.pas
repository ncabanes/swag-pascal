(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0442.PAS
  Description: Helpful Hint: Listbox-Font
  Author: NORBERT HARTKAMP
  Date: 01-02-98  07:34
*)


From: hartkamp@uni-duesseldorf.de (Norbert Hartkamp)

Sometimes it might be useful to have fixed-pitch font in your Listbox.

One way to accomplish this is to use the System-Fixed-Font (at least
with Windows 3.11 -- what about Windows 95?) The only thing you have to
do is to set the font programmatically in your form-create-routine.

Here's an example (where LB is the ListBox), where the font is set
after some strings have been added to the ListBox:


--------------------------------------------------------------------------------


  LB.Items.Clear;

  for i := 0 to (SL.Count)-1 do
  begin
    LB.Items.Add(Copy(SL.Strings[i], 1, j-1));
  end;

  { !!!!! NOW SET THE DESIRED FONT !!!!! }
  { System_Fixed_Font or ANSI_Fixed_Font }
  SendMessage(LB.handle, wm_SetFont, GetStockObject(System_Fixed_Font), 1);


--------------------------------------------------------------------------------


