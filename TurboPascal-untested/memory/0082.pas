
{$S-,R-,V-,I-,B-,F+,O+,A-}

unit DumpHeap;
  {-Dump the list of free memory blocks on the heap}

interface

uses
  OpInline, OpString;

  procedure DumpFreeList;

implementation

type
  FreeListRecPtr = ^FreeListRec;
  FreeListRec =              {structure of a free list entry}
    record
      {$IFDEF Ver60}
      Next : FreeListRecPtr; {pointer to next free list record}
      Size : Pointer;        {"normalized pointer" representing size}
      {$ELSE}
      OrgPtr : Pointer;      {pointer to the start of the block}
      EndPtr : Pointer;      {pointer to the end of the block}
      {$ENDIF}
    end;

{$IFDEF Ver60}
  procedure DumpFreeList;
  var
    P : FreeListRecPtr;
  begin
    {scan the free list}
    P := FreeList;
    while P <> HeapPtr do begin
      {show its size}
      WriteLn(HexPtr(P), '  ', PtrToLong(P^.Size));

      {next free list record}
      P := P^.Next;
    end;

    {check block at HeapPtr^}
    WriteLn(HexPtr(HeapPtr), '  ', PtrDiff(HeapEnd, HeapPtr));
  end;
{$ELSE}
  procedure DumpFreeList;
  var
    P : FreeListRecPtr;
    Top : Pointer;
    ThisBlock : LongInt;
  begin
    {point to end of free list}
    P := FreePtr;
    if OS(P).O = 0 then
      Inc(OS(P).S, $1000);

    {point to top of free memory}
    if FreeMin = 0 then
      Top := Ptr(OS(FreePtr).S+$1000, 0)
    else
      Top := Ptr(OS(FreePtr).S, -FreeMin);
    if PtrToLong(P) < PtrToLong(Top) then
      Top := P;

    while OS(P).O <> 0 do begin
      {search the free list for a memory block that is big enough}
      with P^ do
        {calculate the size of the block}
        WriteLn(HexPtr(P), '  ', PtrDiff(EndPtr, OrgPtr));

      {point to next record on free list}
      Inc(OS(P).O, SizeOf(FreeListRec));
    end;

    {check block at HeapPtr^}
    WriteLn(HexPtr(HeapPtr), '  ', PtrDiff(Top, HeapPtr));
  end;
{$ENDIF}

end.
