(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0019.PAS
  Description: 'navigating' a TMemo
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  13:28
*)


to determine position of cursor in edit field try this:

Lpos := SendMessage(memo1.Handle,EM_LINEFROMCHAR,Memo1.SelStart,0);
Cpos := SendMessage(memo1.Handle,EM_LINEINDEX,Lpos,0);
LineLength := SendMessage(memo1.handle, EM_LINELENGTH, Cpos, 0);
CPos := Memo1.SelStart-CPos;

Lpos=line position
Cpos=Cposition
LineLength = number of chacters in currentline

