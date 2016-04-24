(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0050.PAS
  Description: Alternative Sorts in TVISON
  Author: DJ MURDOCH
  Date: 11-26-94  05:04
*)

{
 DC> I'm setting up a directory list with some extra bells and whistles,
 DC> including descriptions. I want to be able to have different sort criteria
 DC> for the list, and the list should be in a
 DC> TSortedCollection.

 DC> 1. The most simple-minded. instantiate four different lists, and use just
 DC> one,

 DC> 2. Alternate procedures for each type of sort, calling common routines, or
 DC> passing the current collection type.

 DC> 3. A variant record to save the collection in.

 DC> The Question: Would this idea work, and do you think it's the best way to
 DC> do it?

I have one program with the same problem, and I can suggest two more ways to do
what you want:
4.  A field in the collection saying which kind of sort you want, and a Resort
method.  The KeyOf and/or Compare methods look at this field to decide how two
records compare, and the Resort method re-inserts everything after you change
the field, so it ends up in the correct order.
5.  A non-method SortCollection function, that takes a Compare function as a
procedural parameter.  You can use a TCollection if you're not interested in
the search functions, or some variation on 4 if you are.

I don't know which you'll find best.  Depends on your taste.  Here's some code
that I use; you may want to borrow from it.
  {$N-,Q-}
  unit sorts;

  interface

  uses objects,base3;  { base3 can also be found in the SWAG collection !! }

  type
    comparison = function(a,b:pointer):boolean;
    { Returns true if a^ > b^ }

    local_comparison = function(a,b:pointer;frame:word):boolean;
    { A far local version of a comparison }

  procedure list_sort(var start:pointer; greater:comparison);
  { Procedure to do list insertion sort on the linked list pointed to by start.
    Greater points to the entry for a far function with declaration
      function greater^(i,j:pointer):boolean which returns true if i^ > j^
      and false otherwise.
    Assumes that pointers point to pointers, i.e. links should be the first
    element of records in the list.
    N.B.  If enough memory is available, it seems to be faster to make the list
    into an array, use arr_sort, and then un_make the array when there are
    more than about 100 records.
    }

  procedure arr_sort(var arr;size:word;greater:comparison);
  { Procedure to do a Quicksort on the array of pointers pointed to by arr.
    Greater is as in list_sort.  Makes no assumptions about what pointers
    point to.
    Based on Quicksort as given in Steal This Code, by F.D. Boswell, Watcom
1986.  }

  procedure SortCollection(var Coll:TCollection;GreaterP:pointer);
  { Sorts a collection's pointers.  Greater should be a pointer to
    a local_comparison }

  function count_list(list:pointer):longint;
  { Counts the number of elements in the list}

  function make_array(list:pointer;size:longint;var arr:pointer):boolean;
  { Attempts to make an array of pointers from the list.  Returns true on
    success, false if it failed because not enough memory is available.  Always
    creates an array with size elements, but only fills those up to the
    smaller of the actual size of the list or size. }

  procedure un_make_array(var list:pointer;size:integer;var arr);
  { Adjusts the pointers in the list to reflect the ordering in the array.
    Doesn't check that they are all valid - be sure size reflects the
    true number of pointers in the array. }

  type
    PSortableCollection = ^TSortableCollection;
    TSortableCollection = object(TSortedCollection)
      procedure Sort;
      { Puts the elements of the collection in order.  This is only necessary
        if something about the sort order has changed, or elements were
inserted        out of order. }
    end;

  implementation

  type
    list_ptr = ^list_rec;
    list_rec = record
      next : list_ptr;
    end;
    ptr_array = array[1..16380] of pointer;

  procedure list_sort(var start:pointer; greater:comparison);
  var
    first,rest,current,next:list_ptr;
  begin
    rest := list_ptr(start)^.next;     { Rest points to the uninserted part of
the list }    first := start;          { first is a fake first entry in the new
list }    first^.next := nil;
    start := @first;
    while rest <> nil do
    begin
      current := start;
      next := current^.next;
      while (next <> nil) and (not greater(next,rest)) do
      begin
        current := next;
        next := current^.next;
      end;
      current^.next := rest;
      current := rest;
      rest := rest^.next;
      current^.next := next;
    end;
    start := first;
  end;

  procedure arr_sort(var arr;size:word;greater:comparison);
  { Procedure to do a Quicksort on the array of pointers pointed to by arr.
    Greater is as in list_sort.  Makes no assumptions about what pointers
    point to.
    Based on Quicksort as given in Steal This Code, by F.D. Boswell, Watcom
1986.  }
  var
    a:ptr_array absolute arr;

    procedure quick(first,last : word);
    var
      pivot : pointer;
      temp : pointer;
      scanright, scanleft : word;
    begin
      if (first < last) then
      begin
        pivot := a[first];
        scanright := first;
        scanleft := last;
        while scanright < scanleft do
        begin
          if greater(a[scanright+1], pivot) then
          begin
            if not greater(a[scanleft], pivot) then
            begin
              temp := a[scanleft];
              inc(scanright);
              a[scanleft] := a[scanright];
              a[scanright] := temp;
              dec(scanleft);
            end
            else
              dec(scanleft);
          end
          else
            inc(scanright);
        end;
        temp := a[scanright];
        a[scanright] := a[first];
        a[first] := temp;
        quick(first, scanright-1);
        quick(scanright+1, last);
      end;
    end;
  begin  {arr_sort}
    quick(1, size);
  end;


  function count_list(list:pointer):longint;
  { Counts the number of elements in a list }
  var
    l:list_ptr absolute list;
    size:longint;
  begin
    size := 0;
    while l <> nil do
    begin
      inc(size);
      l := l^.next;
    end;
    count_list := size;
  end;

  function make_array(list:pointer;size:longint;var arr:pointer):boolean;
  { Attempts to make an array of pointers from the list.  Returns true on
    success, false if it failed because not enough memory is available }
  var
    l:list_ptr absolute list;
    mem_needed:longint;
    a:^ptr_array absolute arr;
    i:integer;
  begin
    mem_needed := size*sizeof(pointer);
    if (mem_needed > 65520) or (mem_needed > MemAvail) then
    begin
      make_array := false;
      exit;
    end;
    GetMem(a,mem_needed);
    i := 0;
    while (i<size) and (l <> nil) do
    begin
      inc(i);
      a^[i] := l;
      l := l^.next;
    end;
    make_array := true;
  end;

  procedure un_make_array(var list:pointer;size:integer;var arr);
  { Adjusts the pointers in the list to reflect the ordering in the array.
    Doesn't check that they are all valid - be sure size reflects the
    true number of pointers in the array. }
  var
    l:list_ptr absolute list;
    current,next:list_ptr;
    a:ptr_array absolute arr;
    i:integer;
  begin
    l := a[1];
    current := l;
    for i := 2 to size do
    begin
      next := a[i];
      current^.next := next;
      current := next;
    end;
    current^.next := nil;
  end;

  procedure TSortableCollection.Sort;
  { Procedure to do a Quicksort on the collection elements.
    Based on Quicksort as given in Steal This Code, by F.D. Boswell, Watcom
1986.  }
    procedure quick(first,last : word);
    var
      pivot : pointer;
      temp : pointer;
      scanright, scanleft, tielimit : word;
      direction : integer;
    begin
      if (first+1) < (last+1) then  { This allows for last=-1 }
      begin
        { First, choose a random pivot }
        scanright := first+random(last-first);
        pivot := items^[scanright];
        items^[scanright] := items^[first];
        items^[first] := pivot;

        scanright := first;
        scanleft := last;
        tielimit := (first+last) div 2;
        while scanright < scanleft do
        begin
          direction := compare(items^[scanright+1], pivot);
          if (direction>0) or ((direction = 0) and (scanright > tielimit)) then
          begin
            if compare(items^[scanleft], pivot)<=0 then
            begin
              temp := items^[scanleft];
              inc(scanright);
              items^[scanleft] := items^[scanright];
              items^[scanright] := temp;
              dec(scanleft);
            end
            else
              dec(scanleft);
          end
          else
            inc(scanright);
        end;
        temp := items^[scanright];
        items^[scanright] := items^[first];
        items^[first] := temp;
        quick(first, scanright-1);
        quick(scanright+1, last);
      end;
    end;
  begin  {sort}
    quick(0, pred(count));
  end;

  procedure SortCollection(var Coll:TCollection;GreaterP:pointer);
  { Procedure to do a Quicksort on the collection elements.
    Based on Quicksort as given in Steal This Code, by F.D. Boswell, Watcom
1986.  }
  var
    Greater : local_comparison absolute GreaterP;
    Frame : word;

    procedure quick(first,last : word);
    var
      pivot : pointer;
      temp : pointer;
      scanright, scanleft : word;
    begin
      with Coll do
      begin
        if (first+1) < (last+1) then  { This allows for last=-1 }
        begin
          pivot := items^[first];
          scanright := first;
          scanleft := last;
          while scanright < scanleft do
          begin
            if greater(items^[scanright+1], pivot, Frame) then
            begin
              if not greater(items^[scanleft], pivot, Frame) then
              begin
                temp := items^[scanleft];
                inc(scanright);
                items^[scanleft] := items^[scanright];
                items^[scanright] := temp;
                dec(scanleft);
              end
              else
                dec(scanleft);
            end
            else
              inc(scanright);
          end;
          temp := items^[scanright];
          items^[scanright] := items^[first];
          items^[first] := temp;
          quick(first, scanright-1);
          quick(scanright+1, last);
        end;
      end;
    end;
  begin  {sort}
    frame := CallerFrame;
    quick(0, pred(coll.count));
  end;

  end.

