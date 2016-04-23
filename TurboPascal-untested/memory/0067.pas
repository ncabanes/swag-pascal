{
Here are the routines I wrote.  The PtrToLong routine is from TurboPower's
OPINLINE unit; it just converts a pointer to a linear address, using
16*seg + ofs (in longint arithmetic, of course).  Other than that, I think
everything should be obvious.

From: dmurdoch@mast.queensu.ca (Duncan Murdoch)
}

{$ifndef dpmi}

type
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    next: PFreeRec;
    size: Pointer;
  end;

procedure GetMemHuge(var p:HugePtr;size:Longint);
const
  blocksize = $FFF0;
var
  prev,free : PFreeRec;
  save,temp : pointer;
  block : word;
begin
  { Handle the easy cases first }
  if size > maxavail then
    p := nil
  else if size < 65521 then
    getmem(p,size)
  else
  begin
{$ifndef ver60}
   {$ifndef ver70}
    The code below is extremely version specific to the TP 6/7 heap manager!!
   {$endif}
{$endif}
    { Find the block that has enough space }
    prev := PFreeRec(@freeList);
    free := prev^.next;
    while (free <> heapptr) and (PtrToLong(free^.size) < size) do
    begin
      prev := free;
      free := prev^.next;
    end;

    { Now free points to a region with enough space; make it the first one
      and multiple allocations will be contiguous. }

    save := freelist;
    freelist := free;
    { In TP 6, this works; check against other heap managers }
    while size > 0 do
    begin
      block := minlong(blocksize,size);
      dec(size,block);
      getmem(temp,block);
    end;

    { We've got what we want now; just sort things out and restore the
      free list to normal }

    p := free;
    if prev^.next <> freelist then
    begin
      prev^.next := freelist;
      freelist := save;
    end;
  end;
end;

procedure FreeMemHuge(var p:HugePtr;size : longint);
const
  blocksize = $FFF0;
var
  block : word;
begin
  while size > 0 do
  begin
    block := minlong(blocksize,size);
    dec(size,block);
    freemem(p,block);
    p := Normalized(AddWordToPtr(p,block));
  end;
end;
{$else}

Procedure GetMemHuge(var p : HugePtr; Size: LongInt);
begin
  if Size < 65521 then
    GetMem(p,size)
  else
    p := GlobalAllocPtr(gmem_moveable,Size);
end;

Procedure FreeMemHuge(var p : HugePtr; Size: Longint);
var
  h : THandle;
begin
  if Size < 65521 then
    Freemem(p,size)
  else
    h := GlobalFreePtr(p);
end;

{$endif}
