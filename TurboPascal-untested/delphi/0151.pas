
Row := SendMessage(MyMemo.Handle, EM_LINEFROMCHAR, $FFFF, 0);

will return the line number of the caret position in variable Row.

RowStart := SendMessage(MyMemo.Handle, EM_LINEINDEX, $FFFF, 0);

will return the character index of the start of the line.
Subtract RowStart from MyMemo.SelStart to get the column position.

MyRow := SendMessage(MyMemo.Handle, EM_LINEFROMCHAR, $FFFF, 0);
MyRowStart := SendMessage(MyMemo.Handle, EM_LINEINDEX, $FFFF, 0);
MyCol := MyMemo.SelStart - MyRowStart;

