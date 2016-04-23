
program Demo_Doubly_Linked_List_Sort;

const
  co_MaxNode = 1000;

type
  T_St15   = string[15];

  T_PoNode = ^T_Node;

  T_Node   = record
               Data : T_St15;
               Next,
               Prev : T_PoNode
             end;

  T_PoArNodes  = ^T_ArNodePtrs;
  T_ArNodePtrs = array[1..succ(co_MaxNode)] of T_PoNode;


  function RandomString : {output}
                           T_St15;
  var
    by_Index : byte;
    st_Temp  : T_St15;
  begin
    st_Temp[0] := chr(succ(random(15)));
    for by_Index := 1 to length(st_Temp) do
      st_Temp[by_Index] := chr(random(26) + 65);
    RandomString := st_Temp
  end;

  procedure AddNode({update}
                     var
                       po_Node : T_PoNode);
  begin
    if (maxavail > sizeof(T_Node)) then
      begin
        new(po_Node^.Next);
        po_Node^.Next^.Next := nil;
        po_Node^.Next^.Prev := po_Node;
        po_Node^.Next^.Data := RandomString
      end
  end;

  procedure DisplayList({input}
                         po_Node : T_PoNode);
  var
    po_Temp : T_PoNode;
  begin
    po_Temp := po_Node;
    repeat
      write(po_Temp^.Data:20);
      po_Temp := po_Temp^.Next
    until (po_Temp^.Next = nil);
    write(po_Temp^.Data:20)
  end;

  procedure ShellSortNodes ({update}
                             var
                               ar_Nodes   : T_ArNodePtrs;
                            {input }
                             wo_NodeTotal : word);
  var
    Temp   : T_PoNode;
    Index1,
    Index2,
    Index3 : word;
  begin
    Index3 := 1;
    repeat
      Index3 := succ(3 * Index3)
    until (Index3 > wo_NodeTotal);
    repeat
      Index3 := (Index3 div 3);
      for Index1 := succ(Index3) to wo_NodeTotal do
        begin
          Temp := ar_Nodes[Index1];
          Index2 := Index1;
          while (ar_Nodes[(Index2 - Index3)]^.Data > Temp^.Data) do
            begin
              ar_Nodes[Index2] := ar_Nodes[(Index2 - Index3)];
              Index2 := (Index2 - Index3);
              if (Index2 <= Index3) then
                break
            end;
          ar_Nodes[Index2] := Temp
        end
    until (Index3 = 1)
  end;        (* ShellSortNodes.                                      *)

  procedure RebuildList({input }
                         var
                           ar_Nodes : T_ArNodePtrs;
                        {update}
                         var
                           po_Head  : T_PoNode);
  var
    wo_Index   : word;
    po_Current : T_PoNode;
  begin
    wo_Index := 1;
    po_Head := ar_Nodes[wo_Index];
    po_Head^.Prev := nil;
    po_Head^.Next := ar_Nodes[succ(wo_Index)];
    po_Current := po_Head;
    repeat
      inc(wo_Index);
      po_Current := po_Current^.Next;
      po_Current^.Next := ar_Nodes[succ(wo_Index)];
      po_Current^.Prev := ar_Nodes[pred(wo_Index)]
    until (ar_Nodes[succ(wo_Index)] = nil)
  end;

var
  wo_Index    : word;

  po_Heap     : pointer;

  po_Head,
  po_Current   : T_PoNode;

  po_NodeArray : T_PoArNodes;

BEGIN
              (* Initialize pseudo-random number generator.           *)
  randomize;

              (* Mark initial HEAP state.                             *)
  mark(po_Heap);

              (* Initialize list head node.                           *)
  new(po_Head);
  with po_Head^ do
    begin
      Next := nil;
      Prev := nil;
      Data := RandomString
    end;

              (* Create doubly linked list of random strings.         *)
  po_Current := po_Head;
  for wo_Index := 1 to co_MaxNode do
    begin
      AddNode(po_Current);
      if (wo_Index < co_MaxNode) then
        po_Current := po_Current^.Next
    end;

  writeln('Total Nodes = ', wo_Index);
  readln;

  DisplayList(po_Head);
  writeln;
  writeln;

              (* Allocate array of node pointers on the HEAP.         *)
  if (maxavail > sizeof(T_ArNodePtrs)) then
    new(po_NodeArray);

              (* Set them all to NIL.                                 *)
  fillchar(po_NodeArray^, sizeof(po_NodeArray^), 0);

              (* Assign pointer in array to nodes.                    *)
  wo_Index := 0;
  po_Current := po_Head;
  repeat
    inc(wo_Index);
    po_NodeArray^[wo_Index] := po_Current;
    po_Current := po_Current^.Next
  until (po_Current^.Next = nil);

              (* ShellSort the array of nodes.                        *)
  ShellSortNodes(po_NodeArray^, wo_Index);

              (* Re-build the doubly linked-list from array of nodes. *)
  RebuildList(po_NodeArray^, po_Head);

              (* Deallocate array of nodes.                           *)
  dispose(po_NodeArray);

  writeln;
  writeln;
  DisplayList(po_Head);

              (* Release HEAP memory used.                            *)
  release(po_Heap)

END.

