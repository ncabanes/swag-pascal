(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0045.PAS
  Description: 64k TPW/OWL 64k Edit Control
  Author: BRAD MILLARD
  Date: 11-26-94  04:56
*)

{
From: jmillard@nmsu.edu (James B. Millard)
I'll post this again.  This is my TPW/OWL version of the 64k edit control.
I had to override the Create procedure (I also had to bring the
AttachProperties procedure out of odialogs...).  I have put slightly more
than 64k in this edit control.
}

Function TEditEx.Create: Boolean;
Var HParent            : HWnd;
    EditDS, AInstance  : THandle;
    EditDSPtr          : Pointer;
Begin
   DisableAutoCreate;
   If (Parent=NIL) Then HParent:=0 Else HParent:=Parent^.HWindow;
   EditDS:=GlobalAlloc(GMEM_DDEShare OR GMEM_Moveable OR GMEM_ZeroInit, 4096);
   If (EditDS=0) Then AInstance:=HInstance
   Else Begin
      EditDSPtr:=GlobalLock(EditDS);
      LocalInit(HiWord(LongInt(EditDSPtr)), 16, Word(GlobalSize(EditDS)-16));
      UnlockSegment(HiWord(LongInt(EditDSPtr)));
      AInstance:=HiWord(LongInt(EditDSPtr));
   End;
   If Register Then With Attr Do CreateWindowEx(ExStyle, GetClassName, Title,
    Style, X, Y, W, H, HParent, Id, AInstance, Param);
   HWindow:=GetDlgItem(HParent, Attr.ID);
   If (HWindow=0) Then Status:=em_InvalidWindow
   Else If (GetObjectPtr(HWindow)=NIL) Then Begin
      AttachProperties(HWindow, @Self);
      DefaultProc:=TFarProc(SetWindowLong(HWindow, gwl_WndProc,
LongInt(Instance)));
      SetupWindow;
   End;
   Create:=(Status=0);
   SendMessage(HWindow, em_LimitText, 0, 0);
End;



