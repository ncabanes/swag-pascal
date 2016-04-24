(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0026.PAS
  Description: SORT-DLL.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
>         Now, I gotta work on sortin' em.  I believe I can 'swap' the
>         positions of the Pointers eh?
>
>         I can't figure out how to swap the Pointers.  Could you please
>         gimme a wee bit more help?  I've just started doing sorts, and
>         have only used the Bubble sort at the moment in a few Programs,
>         so I'm still a little shakey on sorts.  I understand the Bubble

  Here's an *example* on how to sort a linked list. There are more
  efficient ways to sort a list, but this gives you all the
  essential elements in doing a sort. (note that ListPtr is a doubly
  linked list)
}

Procedure SortList(Var FCL:ListPtr);
Var
  TempAnchor, TemPtr1, TemPtr2 :ListPtr;

  Procedure MoveLink(Var Anchor, Ptr1, Ptr2 :ListPtr);
  Var
    TemPtr3, TemPtr4 :ListPtr;
  begin
    TemPtr3 := Ptr1^.Next;   { temporary Pointer preserves old
                               Pointer value }
    TemPtr4 := Ptr2^.Last;   { ditto }

    Ptr2^.Last := Ptr1;          { do the Pointer swap }
    Ptr1^.Next := Ptr2;

    Ptr1^.Last^.Next := TemPtr3; { fixup secondary Pointers }
    TemPtr3^.Last := Ptr1^.Last;
    Ptr1^.Last := TemPtr4;

    if TemPtr4 <> NIL then       { if temporary Pointer is not
                                   NIL, then it has to point to
                                   swapped Pointer }
       TemPtr4^.Next := Ptr1;

    if Ptr1^.Last = NIL then     { if swapped Pointer points to
                                   preceding NIL Pointer, this
                                   Pointer is the new root. }
       Anchor := Ptr1;
  end;

begin
  TempAnchor := FCL;     { holds root of list during sort }
  TemPtr2 := TempAnchor; { TemPtr2 points to current data being
                           Compared }
  Repeat
    TemPtr1 := TemPtr2; { TemPtr1 points to the next ordered
                          data }
    FCL := TemPtr2;     { start FCL at root of UNSorTED list -
                          sorted data precede this Pointer }
    Repeat
      FCL := FCL^.Next;
      if FCL^.data < TemPtr1^.data then   { Compare data values }
        TemPtr1 := FCL;         { if necessary, reset TemPtr1 to
                                   point to the new ordered value }
    Until FCL^.Next = NIL;        { keep going Until you reach the
                                    end of the list. After Exit,
                                    the next value in order will be
                                    pointed to by TemPtr1 }
    if TemPtr1<>TemPtr2 then      { if TemPtr1 changed, a value
                                    was found out of order }
      MoveLink(TempAnchor,TemPtr1,TemPtr2) { then swap Pointers }
    else
      TemPtr2 := TemPtr2^.Next;  { else advance to the next
                                    Pointer in list }
  Until TemPtr2^.Next = NIL;      { Until we are finished sorting
                                     the list }
  FCL := TempAnchor;    { changes root Pointer to new root value }
end;


