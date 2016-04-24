(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0039.PAS
  Description: DPMI Memory in WinAPI
  Author: DJ MURDOCH
  Date: 01-27-94  12:08
*)

{
> Protected mode has the WinAPI unit that lets you deal with
> huge memory blocks and other stuff. That is what is needed.

> In real mode all you can do is:

Here's some stuff from a huge memory block unit I'm working on.  It isn't fully
debugged yet, but I think these parts work.  However, use at your own risk.
There are a few routines called which I don't include; you should be able to
figure those ones out, or pull them out of a standard library.  "LH" is a
record with fields L and H for pulling the low and high words out of a pointer
or longint.

 { This part works in both real and protected mode. }

 procedure IncPtr(var p:pointer;count:word);
 { Increments pointer }
 begin
   inc(LH(p).L,count);
   if LH(p).L < count then
     inc(LH(p).H,SelectorInc);
 end;

 procedure DecPtr(var p:pointer;count:word);
 { decrements pointer }
 begin
   if count > LH(p).L then
     dec(LH(p).H,SelectorInc);
   dec(LH(p).L,Count);
 end;

 procedure IncPtrLong(var p:pointer;count:longint);
 { Increments pointer; assumes count > 0 }
 begin
   inc(LH(p).H,SelectorInc*LH(count).H);
   inc(LH(p).L,LH(Count).L);
   if LH(p).L < LH(count).L then
     inc(LH(p).H,SelectorInc);
 end;

 procedure DecPtrLong(var p:pointer;count:longint);
 { Decrements pointer; assumes count > 0 }
 begin
   if LH(count).L > LH(p).L then
     dec(LH(p).H,SelectorInc);
   dec(LH(p).L,LH(Count).L);
   dec(LH(p).H,SelectorInc*LH(Count).H);
 end;
 { The next section is for real mode only }

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

     { Now free points to a region with enough space; make it the first one and
       multiple allocations will be contiguous. }

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
     IncPtr(p,block);
     p := Normalized(p);
   end;
 end;

{ The next section is the protected mode part }

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


