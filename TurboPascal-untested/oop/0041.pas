
{
Buttons are best done in TurboVision or ObjectWindows.  Re-read the
sections dealing with the above in your manual and/or references.

If you want to use TurboVision (for the DOS environment), this is a unit
for a derived object type I created to ease creation of dialog boxes.
You might want to use it in addition to the TurboVision units:
}

Unit XBoxes;

Interface

Uses Dialogs, Objects, Menus, Views;

Type
  XDialog = Object(TDialog)
     Procedure TxtEntry(x,y : Byte; txt : string; max : Byte);
     Procedure MakeButton(x,y,w: Byte; Txt: string; cmd,mode: Word)
     Procedure OKButton(x,y : Byte);
     Procedure CancelButton(x,y : Byte);
     Procedure Static(x,y : Byte; txt : string);
     Procedure CheckBoxes(x,y,w,z : Byte; Items : PSItem);
  End;
  PXDialog = ^XDialog;

Implementation

Procedure XDialog.MakeButton(x,y,w: Byte; Txt: string; cmd, mode: Word)
{ Insert a button with the specified text, command, width, and mode at
  the x,y coordinates in the dialog box }
   R : TRect;
   Temp : PButton;
Begin;
   R.Assign(x,y,x+w,y+2);
   Temp := New(PButton,Init(R,Txt,cmd,mode));
   Insert(Temp);
End;

Procedure XDialog.OKButton(x,y : Byte);
{ Create and insert an 'OK' Button at x,y coordinates }
Begin;
   MakeButton(x,y,10,'~O~K',cmOK,bfDefault);
End;

Procedure XDialog.CancelButton(x,y : Byte);
{ Create and insert a 'Cancel' button }
Begin;
   MakeButton(x,y,10,'Cancel',cmCancel,bfNormal);
End;

Procedure XDialog.TxtEntry(x,y : Byte; txt : string; max : Byte);
{ Create a text entry line and label starting at x,y and expanding to
  fill the rest of the line in the box. }
Var
   w : Byte;
   ID : PView;
   R : TRect;
Begin;
   GetExtent(R);
   R.Assign(x+Length(txt)+2,y,R.B.X-2,y+1);
   ID := New(PInputLine,Init(R,max));
   Insert(ID);
   R.Assign(x,y,x+Length(txt)+1,y+1);
   Insert(New(PLabel,Init(R,txt,ID)));
End;

Procedure XDialog.Static(x,y : Byte; txt : string);
{ Static text at x,y }
Var
   R : TRect;
Begin;
   R.Assign(x,y,x+Length(txt)+1,y+1);
   Insert(New(PStaticText,Init(R,txt)));
End;

Procedure XDialog.CheckBoxes(x,y,w,z : Byte; Items : PSItem);
{ Insert check boxes for cluster 'Items' at x,y with a maximum width of
  w and a total of z items. }
Var
   R : TRect;
Begin;
   R.Assign(x,y,x+(w+3)+1,y+z+1);
   Insert(New(PCheckBoxes,Init(R,Items)));
End;

End.
