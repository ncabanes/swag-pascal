(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0151.PAS
  Description: Re: Find the row/col in TMemo objects
  Author: JOHN ATKINS
  Date: 08-30-96  09:35
*)


Row := SendMessage(MyMemo.Handle, EM_LINEFROMCHAR, $FFFF, 0);

will return the line number of the caret position in variable Row.

RowStart := SendMessage(MyMemo.Handle, EM_LINEINDEX, $FFFF, 0);

will return the character index of the start of the line.
Subtract RowStart from MyMemo.SelStart to get the column position.

MyRow := SendMessage(MyMemo.Handle, EM_LINEFROMCHAR, $FFFF, 0);
MyRowStart := SendMessage(MyMemo.Handle, EM_LINEINDEX, $FFFF, 0);
MyCol := MyMemo.SelStart - MyRowStart;


