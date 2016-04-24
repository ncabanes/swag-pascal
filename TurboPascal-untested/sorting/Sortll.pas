(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0027.PAS
  Description: SORT-LL.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> I have a linked list structure that I would like to sort in one of
> four different ways.  I can sort Arrays using QuickSort, etc., but have no
> experience sorting linked lists.  Does anyone have any source code
> (preferably) or any suggestions on how to proceed?  Any help would be
> appreciated.

I got Modula-2 code I wrote about one year ago. I post an excerpt from
the Implementation MODULE. It should be no problem to convert it to
Pascal, since the languages are rather similar.
}
Procedure LISTSort(Var List     : LISTType;
                       Ascending: Boolean);

Var
  Last  : NodeTypePtr;
  Result: LISTCompareResultType;

  Procedure TailIns(    Rec  : NodeTypePtr;
                    Var First: NodeTypePtr;
                    Var Last : NodeTypePtr);

  begin
    if (First=NIL) then First := Rec else Last^.Next := Rec end;
    Last := Rec
  end TailIns;

  Procedure MergeLists(    a: NodeTypePtr;
                           b: NodeTypePtr): NodeTypePtr;

  Var
    First: NodeTypePtr;
    Last : NodeTypePtr;
    Help : NodeTypePtr;

  begin
    First := NIL;
    While (b#NIL) do
      if (a=NIL) then
        a := b; b := NIL
      else
        if (Classes[List^.ClassID].Cmp(b^.DataPtr,a^.DataPtr)=Result)
        then
          Help := a; a := a^.Next
        else
          Help := b; b := b^.Next
        end;
        Help^.Next := NIL;
        TailIns(Help,First,Last)
      end
    end;
    TailIns(a,First,Last);
    RETURN(First)
  end MergeLists;

  Procedure MergeSort(Var Root: NodeTypePtr;
                          N   : CARDinAL): NodeTypePtr;

  Var
    Help: NodeTypePtr;
    a,b : NodeTypePtr;

  begin
    if (Root=NIL) then
      RETURN(NIL)
    ELSif (N>1) then
      a := MergeSort(Root,N div 2);
      b := MergeSort(Root,(N+1) div 2);
      RETURN(MergeLists(a,b))
    else
      Help := Root;
      Root := Root^.Next;
      Help^.Next := NIL;
      RETURN(Help)
    end
  end MergeSort;

begin
  if (List^.N<2) then RETURN end;
  if (Ascending) then Result := LISTGreater else Result := LISTLess end;
  List^.top^.Next := MergeSort(List^.top^.Next,List^.N);
  Last := List^.top;
  List^.Cursor := List^.top^.Next;
  While (List^.Cursor#NIL) do
    List^.Cursor^.Prev := Last;
    Last := List^.Cursor;
    List^.Cursor := List^.Cursor^.Next
  end;
  Last^.Next := List^.Bottom;
  List^.Bottom^.Prev := Last;
  List^.CurPos := 1;
  List^.Cursor := List^.top^.Next
end LISTSort;

{
The basic data structure is defined as follows:
}

Const
  MaxClasses   = 256;

Type
  NodeTypePtr = Pointer to NodeType;

  NodeType = Record
    Prev   : NodeTypePtr;
    Next   : NodeTypePtr;
    DataPtr: ADDRESS
  end;

  LISTType = Pointer to ListType;

  ListType = Record
    top    : NodeTypePtr;
    Bottom : NodeTypePtr;
    Cursor : NodeTypePtr;
    N      : CARDinAL;
    CurPos : CARDinAL;
    ClassID: CARDinAL
  end;

  ClassType = Record
    Cmp  : LISTCompareProcType;
    Bytes: CARDinAL
  end;

Var
  Classes: Array [0..MaxClasses-1] of ClassType;

