(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0033.PAS
  Description: Alpha Sorting
  Author: GREGORY P. SMITH
  Date: 08-27-93  19:59
*)

{
GREGORY P. SMITH

> Well, that's easier said than done !  So far I've accomplished a
> selection sort which takes about 10-15 minutes For 1000 Records, and I'm
> gonna be needin to sort about 5000 For the Programz intended application
> !!! Also the place that I'm writing this For has an 8088 With 640K RAM
> <chuckle> !!! Could you pleez tell me how to do a merge sort <is that
> easier than quicksort

Here is an example followed by an exlpanation.
}

Type
  ListPtr = ^List;
  List = Record
    next : ListPtr; { next node }
    str  : String;  { data to sort }
  end;

{ Splits List l into two half lists, h1 & h2 }
Procedure SplitList(l : ListPtr; Var h1, h2 :  ListPtr);
Var
  listone : Boolean;
  tmp : ListPtr;
begin
  h1 := nil;
  h2 := nil;
  listone := True;            { start With first list }
  While l <> nil do
  begin
    tmp := l^.next;           { save next node to split }
    if listone then
    begin                     { insert a node in the first list }
      l^.next := h1;
      h1 := l;                { keep h1 at head }
    end
    else
    begin                     { insert a node in the second list }
      l^.next := h2;
      h2 := l;                { keep h2 at head }
    end;
    l := tmp;                 { move to next node }
    listone := not listone;   { alternate lists to insert into }
  end;
end; { SplitList }

{----------------- Merge Sort -------------------}

{ merges sorted l1 & l2 into one sorted list (alphabetically) }
Function MergeAlphaLists(l1, l2 : ListPtr) : ListPtr;
Var
  tmp : ListPtr;  { resulting list }
begin
  if (l1 = nil) then
    tmp := l2
  else
  if (l2 = nil) then
    tmp := l1
  else
  if l1^.str < l2^.str then
  begin { lesser node first }
    tmp := l1;
    l1 := l1^.next;
  end
  else
  begin
    tmp := l2;
    l2 := l2^.next;
  end;
  MergeAlphaLists := tmp;               { return head of merged sorted list }
  While (l1 <> nil) and (l2 <> nil) do  { traverse lists }
  if l1^.str < l2^.str then
  begin
    tmp^.next := l1; { add the lesser node }
    tmp := l1;       { move ahead }
    l1 := l1^.next;  { next node }
  end
  else
  begin
    tmp^.next := l2; { add the lesser node }
    tmp := l2;       { ahead 1 }
    l2 := l2^.next;  { next node }
  end;
  if (l1 <> nil) then
    tmp^.next := l1   { append remaining nodes }
  else
    tmp^.next := l2;
end; { MergeAlphaLists }

{ Sorts list l alphabetically }
Function MergeSortAlpha(l : ListPtr) : ListPtr;
Var
  sl1,
  sl2 : ListPtr;
begin
  if l <> nil then                 { empty list? }
    if l^.next <> nil then
    begin   { single node list? }
      inc(progress);
      SplitList(l, sl1, sl2);      { split list into two halves }
      sl1 := MergeSortAlpha(sl1);  { sort the first half }
      sl2 := MergeSortAlpha(sl2);  { sort the second half }
      MergeSortAlpha := MergeAlphaLists(sl1, sl2)  { combine sorted lists }
    end
    else
      MergeSortAlpha := l   { single node is already sorted }
  else
    MergeSortAlpha := nil
end;

{
What mergesort does is to split the list into two equal halves.  It then
mergesorts each of these halves, and merges them back together.  The Real work
is done in the merging step.  When the lists are split down to the level of
single node lists they are merged together again in the correct order.  As it
pops out of the recursion the larger lists are sorted so that merging will
still keep them in order because each node is > than the previous one.  This is
probably the most widely used sorting algorithm (don't quote me) because it is
simple but delivers n*log(n) performance like any good algorithm would.
}

