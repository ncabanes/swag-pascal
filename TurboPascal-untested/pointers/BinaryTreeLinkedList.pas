(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0010.PAS
  Description: Binary Tree - Linked List
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:39
*)

Unit BinTree;

Interface

Const TOTAL_NODES = 100;

Type BTreeStr = String[40];
  ShiftSet = (TiltL_Tilt, neutral, TiltR_Tilt);
  BinData  = Record
    Key : BTreeStr;
  End;
  BinPtr = ^Bin_Tree_Rec;
  Bin_Tree_Rec = Record
    BTreeData    : BinData;
    Shift        : ShiftSet;
    TiltL, TiltR : BinPtr;
  End;
  BTreeRec = Array[1..TOTAL_NODES] of BinData;

Procedure Ins_BinTree
  (Var Rt   : BinPtr;
       Node : BinData);

Function Srch_BinTree
  (Rt     : BinPtr;
   Node   : BinData;
   Index1 : Word) : Word;

Procedure BSortArray
  (Var Rt       : BinPtr;
   Var SortNode : BTreeRec;
   Var Index    : Word);

Procedure Del_BinTree
  (Var Rt      : BinPtr;
       Node    : BinData;
       Var DelFlag : Boolean);

Implementation

Procedure Move_TiltR(Var Rt : BinPtr);

  Var
    Ptr1, Ptr2 : BinPtr;

  Begin
    Ptr1 := Rt^.TiltR;
    If Ptr1^.Shift = TiltR_Tilt Then Begin
      Rt^.TiltR := Ptr1^.TiltL;
      Ptr1^.TiltL := Rt;
      Rt^.Shift := neutral;
      Rt := Ptr1
    End
    Else Begin
      Ptr2 := Ptr1^.TiltL;
      Ptr1^.TiltL := Ptr2^.TiltR;
      Ptr2^.TiltR := Ptr1;
      Rt^.TiltR := Ptr2^.TiltL;
      Ptr2^.TiltL := Rt;
      If Ptr2^.Shift = TiltL_Tilt
        Then Ptr1^.Shift := TiltR_Tilt
        Else Ptr1^.Shift := neutral;
      If Ptr2^.Shift = TiltR_Tilt
        Then Rt^.Shift := TiltL_Tilt
        Else Rt^.Shift := neutral;
      Rt := Ptr2
    End;
    Rt^.Shift := neutral
  End;

Procedure Move_TiltL(Var Rt : BinPtr);

  Var
    Ptr1, Ptr2 : BinPtr;

  Begin
    Ptr1 := Rt^.TiltL;
    If Ptr1^.Shift = TiltL_Tilt Then Begin
      Rt^.TiltL := Ptr1^.TiltR;
      Ptr1^.TiltR := Rt;
      Rt^.Shift := neutral;
      Rt := Ptr1
    End
    Else Begin
      Ptr2 := Ptr1^.TiltR;
      Ptr1^.TiltR := Ptr2^.TiltL;
      Ptr2^.TiltL := Ptr1;
      Rt^.TiltL := Ptr2^.TiltR;
      Ptr2^.TiltR := Rt;
      If Ptr2^.Shift = TiltR_Tilt
        Then Ptr1^.Shift := TiltL_Tilt
        Else Ptr1^.Shift := neutral;
      If Ptr2^.Shift = TiltL_Tilt
        Then Rt^.Shift := TiltR_Tilt
        Else Rt^.Shift := neutral;
      Rt := Ptr2;
    End;
    Rt^.Shift := neutral
  End;

Procedure Ins_Bin(Var Rt    : BinPtr;
                      Node  : BinData;
                  Var InsOK : Boolean);

  Begin
    If Rt = NIL Then Begin
      New(Rt);
      With Rt^ Do Begin
        BTreeData := Node;
        TiltL := NIL;
        TiltR := NIL;
        Shift := neutral
      End;
      InsOK := TRUE
    End
    Else If Node.Key <= Rt^.BTreeData.Key Then Begin
      Ins_Bin(Rt^.TiltL, Node, InsOK);
      If InsOK Then
        Case Rt^.Shift Of
          TiltL_Tilt : Begin
                        Move_TiltL(Rt);
                        InsOK := FALSE
                       End;
          neutral    : Rt^.Shift := TiltL_Tilt;
          TiltR_Tilt : Begin
                        Rt^.Shift := neutral;
                        InsOK := FALSE
                       End;
        End;
      End
      Else Begin
        Ins_Bin(Rt^.TiltR, Node, InsOK);
        If InsOK Then
          Case Rt^.Shift Of
            TiltL_Tilt : Begin
                          Rt^.Shift := neutral;
                          InsOK := FALSE
                         End;
            neutral    : Rt^.Shift := TiltR_Tilt;
            TiltR_Tilt : Begin
                          Move_TiltR(Rt);
                          InsOK := FALSE
                         End;
          End;
        End;
  End;

Procedure Ins_BinTree(Var Rt   : BinPtr;
                        Node : BinData);

  Var Ins_ok : Boolean;

  Begin
    Ins_ok := FALSE;
    Ins_Bin(Rt, Node, Ins_ok)
  End;

Function Srch_BinTree(Rt     : BinPtr;
                      Node   : BinData;
                      Index1 : Word)
                      : Word;

  Var
    Index : Word;

  Begin
    Index := 0;
    While (Rt <> NIL) AND (Index < Index1) Do
      If Node.Key > Rt^.BTreeData.Key Then Rt := Rt^.TiltR
      Else if Node.Key < Rt^.BTreeData.Key Then Rt := Rt^.TiltL
      Else Begin
        Inc(Index);
        Rt := Rt^.TiltL
      End;
    Srch_BinTree := Index
  End;

Procedure Tvrs_Tree
  (Var Rt       : BinPtr;
   Var SortNode : BTreeRec;
   Var Index    : Word);

  Begin
    If Rt <> NIL Then Begin
      Tvrs_Tree(Rt^.TiltL, SortNode, Index);
      Inc(Index);
      If Index <= TOTAL_NODES Then
        SortNode[Index].Key := Rt^.BTreeData.Key;
      Tvrs_Tree(Rt^.TiltR, SortNode, Index);
    End;
  End;

Procedure BSortArray
  (Var Rt       : BinPtr;
   Var SortNode : BTreeRec;
   Var Index    : Word);

  Begin
    Index := 0;
    Tvrs_Tree(Rt, SortNode, Index);
  End;

Procedure Shift_TiltR
  (Var Rt      : BinPtr;
   Var DelFlag : Boolean);

  Var
    Ptr1, Ptr2 : BinPtr;
    balnc2, balnc3 : ShiftSet;

  Begin
    Case Rt^.Shift Of
      TiltL_Tilt : Rt^.Shift := neutral;
      neutral    : Begin
                     Rt^.Shift := TiltR_Tilt;
                     DelFlag := FALSE
                   End;
      TiltR_Tilt : Begin
           Ptr1 := Rt^.TiltR;
           balnc2 := Ptr1^.Shift;
           If NOT (balnc2 = TiltL_Tilt) Then Begin
             Rt^.TiltR := Ptr1^.TiltL;
             Ptr1^.TiltL := Rt;
             If balnc2 = neutral Then Begin
               Rt^.Shift := TiltR_Tilt;
               Ptr1^.Shift := TiltL_Tilt;
               DelFlag := FALSE
             End
             Else Begin
               Rt^.Shift := neutral;
               Ptr1^.Shift := neutral;
             End;
             Rt := Ptr1
           End
           Else Begin
             Ptr2 := Ptr1^.TiltL;
             balnc3 := Ptr2^.Shift;
             Ptr1^.TiltL := Ptr2^.TiltR;
             Ptr2^.TiltR := Ptr1;
             Rt^.TiltR := Ptr2^.TiltL;
             Ptr2^.TiltL := Rt;
             If balnc3 = TiltL_Tilt Then
               Ptr1^.Shift := TiltR_Tilt
             Else
               Ptr1^.Shift := neutral;
             If balnc3 = TiltR_Tilt Then
               Rt^.Shift := TiltL_Tilt
             Else
               Rt^.Shift := neutral;
             Rt := Ptr2;
             Ptr2^.Shift := neutral;
           End;
         End;
      End;
    End;

Procedure Shift_TiltL
  (Var Rt      : BinPtr;
   Var DelFlag : Boolean);

  Var
    Ptr1, Ptr2 : BinPtr;
    balnc2, balnc3 : ShiftSet;

  Begin
    Case Rt^.Shift Of
      TiltR_Tilt : Rt^.Shift := neutral;
      neutral    : Begin
                     Rt^.Shift := TiltL_Tilt;
                     DelFlag := False
                   End;
      TiltL_Tilt : Begin
           Ptr1 := Rt^.TiltL;
           balnc2 := Ptr1^.Shift;
           If NOT (balnc2 = TiltR_Tilt) Then Begin
             Rt^.TiltL := Ptr1^.TiltR;
             Ptr1^.TiltR := Rt;
             If balnc2 = neutral Then Begin
               Rt^.Shift := TiltL_Tilt;
               Ptr1^.Shift := TiltR_Tilt;
               DelFlag := FALSE
             End
             Else Begin
               Rt^.Shift := neutral;
               Ptr1^.Shift := neutral;
             End;
             Rt := Ptr1
           End
           Else Begin
             Ptr2 := Ptr1^.TiltR;
             balnc3 := Ptr2^.Shift;
             Ptr1^.TiltR := Ptr2^.TiltL;
             Ptr2^.TiltL := Ptr1;
             Rt^.TiltL := Ptr2^.TiltR;
             Ptr2^.TiltR := Rt;
             If balnc3 = TiltR_Tilt Then
               Ptr1^.Shift := TiltL_Tilt
             Else
               Ptr1^.Shift := neutral;
             If balnc3 = TiltL_Tilt Then
               Rt^.Shift := TiltR_Tilt
             Else
               Rt^.Shift := neutral;
             Rt := Ptr2;
             Ptr2^.Shift := neutral;
           End;
         End;
    End;
  End;

Procedure Kill_Lo_Nodes
  (Var Rt,
       Ptr     : BinPtr;
   Var DelFlag : Boolean);

  Begin
    If Ptr^.TiltR = NIL Then Begin
      Rt^.BTreeData := Ptr^.BTreeData;
      Ptr := Ptr^.TiltL;
      DelFlag := TRUE
    End
    Else Begin
      Kill_Lo_Nodes(Rt, Ptr^.TiltR, DelFlag);
      If DelFlag Then Shift_TiltL(Ptr,DelFlag);
    End;
  End;

Procedure Del_Bin(Var Rt      : BinPtr;
                      Node    : BinData;
                  Var DelFlag : Boolean);

  Var
    Ptr : BinPtr;

  Begin
    If Rt = NIL Then
       DelFlag := False
    Else
      If Node.Key < Rt^.BTreeData.Key Then Begin
        Del_Bin(Rt^.TiltL, Node, DelFlag);
        If DelFlag Then Shift_TiltR(Rt, DelFlag);
      End
      Else Begin
        If Node.Key > Rt^.BTreeData.Key Then Begin
          Del_Bin(Rt^.TiltR, Node, DelFlag);
          If DelFlag Then Shift_TiltL(Rt, DelFlag);
        End
        Else Begin
          Ptr := Rt;
          If Rt^.TiltR = NIL Then Begin
            Rt := Rt^.TiltL;
            DelFlag := TRUE;
            Dispose(Ptr);
          End
          Else If Rt^.TiltL = NIL Then Begin
            Rt := Rt^.TiltR;
            DelFlag := TRUE;
            Dispose(Ptr);
          End
          Else Begin
            Kill_Lo_Nodes(Rt, Rt^.TiltL, DelFlag);
            If DelFlag Then Shift_TiltR(Rt, DelFlag);
            Dispose(Rt^.TiltL);
          End;
        End;
      End;
  End;

Procedure Del_BinTree
  (Var Rt      : BinPtr;
       Node    : BinData;
   Var DelFlag : Boolean);

  Begin
    DelFlag := FALSE;
    Del_Bin(Rt, Node, DelFlag)
  End;
End.
