{
 BB> Question: How can I make sure that my data for DMA transfer
 BB> (yes: SB-stuff) isn't going beyond "page-boundaries"?
 BB> (And what the h@#$ is a page-boudarie (?) anyway)

The DMA controller has only 16 address bits, and to use it in 20-bits PC's and
24-bits AT's (address bits), they added a page register, to hold the other 4/8
bits. Bit the DMA controller knows nothing about it, so it can't increment it.
This is all about absolute addresses, i.e. seg*16+ofs in real mode.
Example: you want to 'DMA' 32768 bytes from $1234:0. Absolute address is
$1234*16+0=$12340. The lower 16 bits go to the dma ($2340), and the other bit
s to the page register ($1). After the DMA the offset is $2340+$8000=$A340, so
no problems here. But if you use $7890:0 the absolute address is $78900, and
if you add $8000 to the lower 16 bits ($8900), it becomes $10900, so larger
than 16 bits, and the transfer can't be completed (it halts after
$8000-$0900=$7700 bytes). That's why you need to keep the page of the 'end'
absolute address the same as from the start address.

I've written some pascal code to do that, but it assumes the heap is not
fragmented (i.e. it assumes if it allocates two blocks the second starts were
the first ends) (not sure it works always too, haven't tested it much).

===}

function Alloc64kBound(Size:word):pointer;
{ Allocate a <Size> bytes buffer so that you can do a DMA transfer from/to it
}{ Assumes the heap is not fragmented }
{ Arne de Bruijn, 1995, PD }
{$ifopt Q+}{$define Temp}{$Q-}{$endif}
{ overflow checking should be off for word(seg shl 4), to avoid }
{ word(seg and $0fff shl 4). }
type
 TPointer=record
  Ofs,Seg:word;
 end;
var
 P,P2:pointer;
 NewSize:word;
begin
 Alloc64kBound:=NIL;
 if MaxAvail<Size then exit;
 GetMem(P,Size);
 if word(TPointer(P).Seg shl 4)+TPointer(P).Ofs>word(-Size) then
  begin
   NewSize:=((longint((TPointer(P).Seg and $F000)+$1000) shl 4)-
    (longint(longint(TPointer(P).Seg) shl 4)+TPointer(P).Ofs));
   FreeMem(P,Size);
   if MaxAvail<NewSize then exit;
   GetMem(P2,NewSize);
   if MaxAvail<Size then P:=NIL else GetMem(P,Size);
   FreeMem(P2,NewSize);
  end;
 Alloc64kBound:=P;
end;
{$ifdef Temp}{$undef Temp}{$Q+}{$endif}
