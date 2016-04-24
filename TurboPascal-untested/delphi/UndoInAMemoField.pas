(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0035.PAS
  Description: Undo in a Memo field
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:49
*)


Doing an UnDo in a Memo Field:

  If you have a pop-up menu in a TMemo, and put shortcuts 
on it for the Cut,Copy, Paste, then you can handle those 
events, and call CuttoClipBoard, CopytoClipBoard, etc.

  However, if you put an Undo option onto your pop-up menu 
(normally Ctrl-Z) how do you instruct the TMemo to do the Undo?
If the built-in undo is sufficient, you can get it easier than
a Ctrl+Z:

    Memo1.Perform(EM_UNDO, 0, 0);

 To check whether undo is available so as to enable/disable 

an undo menu item:

    Undo1.Enabled := Memo1.Perform(EM_CANUNDO, 0, 0) <> 0;

               



