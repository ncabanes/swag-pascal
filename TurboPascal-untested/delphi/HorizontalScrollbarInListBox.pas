(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0063.PAS
  Description: Horizontal Scrollbar in List box
  Author: RAILTON FRITH
  Date: 11-24-95  10:16
*)


>>Can someone describe how to activate the horizontal scrollbar in a
>>listbox. I need to do this programatically.

try this:

  sendmessage(ListBox.Handle, LB_SetHorizontalExtent, PixelWidth , 0);

