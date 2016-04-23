{
From: horridge@ITS-MENZ.cc.monash.edu.au (Mark Horridge)

>I am using TPW 1.5, and wish to fill a huge memory
>block, allocated for DDE purposes, with relevant data. The memory block is
>first allocated wiith GlobalAlloc, and locked in memory with GlobalLock. At
>this point, I would like to access any byte in the buffer by giving an
>32-bit offset from the beginning of the memory buffer.

The process is explained in Chap 17, page 202, of the Borland Pascal Language
Guide. This book comes with BP7 and I believe will apply to TPW1.5

The memory block is first allocated wiith GlobalAlloc, and locked in memory
with GlobalLock. At this point, to access any byte in the buffer by giving
an 32-bit offset (longint) from the beginning of the memory buffer, convert
the longint back to a pointer by:
}

function GetPtr(P:Pointer; Offset: Longint):Pointer;
type Long = record lo, hi: word; end;
begin
GetPtr:= Ptr(
Long(p).Hi + Long(Offset).Hi*SelectorInc,
Long(p).Lo + Long(Offset).Lo);
end;
{
Now you can access any BYTE in the buffer by
giving a 32-bit offset. But for objects larger than a byte, you will run
into trouble if that object straddles a segment boundary.
}