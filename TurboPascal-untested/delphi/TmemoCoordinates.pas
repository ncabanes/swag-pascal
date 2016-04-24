(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0217.PAS
  Description: Re: tMemo co-ordinates
  Author: R.F.P. VAN RIET
  Date: 03-04-97  13:18
*)


unit Memos;

interface

uses WinProcs, SysUtils, StdCtrls, Dialogs, Message;

{ Get the line number and column number the cursor is positioned at in the
memo}

Procedure GetMemoLineCol (Memo: TCustomMemo; var MemoLine, MemoCol:
Integer);

{ Set the cursor position in a memo to the specified line and column }

Procedure MemoCursorTo (Memo: TCustomMemo; MemoLine, MemoCol: Integer);

Implementation

Procedure GetMemoLineCol;
begin
   WITH Memo DO
      BEGIN
         MemoLine := SendMessage (Handle, EM_LINEFROMCHAR, SelStart, 0);
         MemoCol  := SelStart - SendMessage (Handle, EM_LINEINDEX, MemoLine,
                      0) + 1;
      END;
end;

Procedure MemoCursorTo;
begin
   Memo.SelStart := SendMessage (Memo.Handle, EM_LINEINDEX, MemoLine, 0) +
                   MemoCol - 1;
end;


Ronan van Riet

Graaf Florishof 4
3632 BS Loenen a/d Vecht
The Netherlands
0294-233563


