{
From: dmurdoch@mast.queensu.ca (Duncan Murdoch)
>
>Anyhow, what this program is doing (among other things) is reading data from
>an ASCII file when commanded to, one line at a time, and plotting it on the
>screen.  My problem is, when you return to the main menu, a bit of the RAM
>has been used.  If you call up a couple of plots in a row, eventually you
>run out of RAM and crash.  And I'm having a devil of a time trying to figure
>where the memory is going.

This is one of the harder kinds of error to track down.  The way I do it is
as follows:

1.  Throughout program development, I use a debugging unit that warns me if
anything is left on the heap when the program terminates. If there is, I
immediately track it down and fix it.  The error is probably in the new
part, and that helps to find it.

2.  To prevent errors, I program in a very structured way:  every allocation
has a matching de-allocation, preferable within a dozen or two lines of
it so they're both on screen at once and I can see that they match.

3.  If the preventive methods don't work, I have to track down the bugs. I
have a routine that can print heap usage when I want.  I print all the heap
that's used at the end of the program (should be none!), and try to
recognize where the stuff came from.  If it's strings, it's easy, but if
it's binary data, it's hard.  If necessary I trace through the program until
I see one of those parts get allocated.

I've attached my heap routine below, but it won't compile for you without a
few utility routines from TurboPower's Object Professional library (and
some others of mine).  Hopefully it'll still be useful for you and you can
write the other parts yourself.

Duncan Murdoch
}
unit heap;
{ This unit does integrity checks on the TP 6.0 heap }

interface

uses standard,opinline,opstring,dump;

function heapokay:boolean;

procedure showfreelist(var where:text;msg:string);
{ Prints the free list }

procedure showheapused(var where:text;msg:string);
{ Prints the heap usage }

type
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    next: PFreeRec;
    size: Pointer;
  end;


implementation

function Ordered(p1,p2:pointer):boolean;
{ Tests whether p1 <= p2 }
begin
  Ordered := PtrToLong(p1) <= PtrToLong(p2);
end;

function Normed(p:pointer):boolean;
{ Checks whether p is a normalized pointer }
begin
  case ofs(p^) of
  0..$F : Normed := true;
  else    Normed := false;
  end;
end;

function heapokay:boolean;

procedure error(msg:string);
begin
  writeln(stderr,msg);
  heapokay := false;
  halt(99);
end;

type
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    next: PFreeRec;
    size: Pointer;
  end;
var
  FreeRec : PFreeRec;
begin
  if not Normed(HeapOrg) then
    error('HeapOrg bad!');
  if not Normed(FreeList) then
    error('FreeList bad!');
  if not Normed(HeapPtr) then
    error('HeapPtr bad!');
  if not Normed(HeapEnd) then
    error('HeapEnd bad!');

  if not Ordered(HeapOrg,FreeList) then
    error('HeapOrg > FreeList');
  if not Ordered(FreeList,HeapPtr) then
    error('FreeList > HeapPtr');
  if not Ordered(HeapPtr,HeapEnd) then
    error('HeapPtr > HeapEnd');

  FreeRec := FreeList;
  while PtrToLong(FreeRec) < PtrToLong(HeapPtr) do   { Walk the free list }
  begin
    if not Normed(FreeRec^.next) then
      error('Bad next in free record '+HexPtr(FreeRec));
    if not ordered(FreeRec,FreeRec^.next) then
      error('self > next in free record '+HexPtr(FreeRec));
    if not ordered(AddLongToPtr(FreeRec,PtrToLong(FreeRec^.size)),
                   FreeRec^.next) then
      error('Bad size in free record '+HexPtr(FreeRec));
    if FreeRec = FreeRec^.Next then
      error('Self pointer in free record '+HexPtr(FreeRec));
    FreeRec := FreeRec^.Next;
  end;
  if FreeRec <> HeapPtr then
    error('Bad last free block');

  heapokay := true;
end;

function addtopointer(p:pointer;incr:longint):pointer;
{  Adds increment to pointer, only normalizes if necessary }
begin
  if ofs(p^) + incr > 65535 then
    addtopointer := AddLongToPtr(p,incr)
  else
    addtopointer := AddWordToPtr(p,incr);
end;

procedure showfreelist(var where:text;msg:string);
{ Prints the free list }
var
  FreePtr : PFreerec;
  Free,Total:longint;
begin
  writeln(where,msg);
  writeln(where,'  Start      Stop    Size free');

  FreePtr := PFreeRec(@FreeList);
  Total := 0;
  repeat
    Free:=PtrToLong(Freeptr^.Size);
    inc(Total,Free);
    if Free <> 0 then
      writeln(where, HexPtr(FreePtr), '  ', HexPtr(AddToPointer(FreePtr,Free)),
                     '  ',Free:6);
    FreePtr := FreePtr^.next;
  until FreePtr = HeapPtr;
  Free := PtrDiff(HeapEnd,HeapPtr);
  inc(Total,Free);
  writeln(where, HexPtr(HeapPtr), '  ', HexPtr(HeapEnd),
                 '  ',Free:6);
  writeln(where, 'Total':8,'':14, Total:6);
end;

procedure showheapused(var where:text;msg:string);
{ Prints what's been used on the heap }
var
  FreePtr : PFreerec;
  UsedPtr : Pointer;
  Used : longint;
  Total: longint;
begin
  writeln(where,msg);
  writeln(where,'  Start      Stop    Size used     Data');

  FreePtr := FreeList;
  UsedPtr := HeapOrg;
  total := 0;
  while FreePtr <> HeapPtr do
  begin
    Used := PtrDiff(UsedPtr,FreePtr);
    inc(Total,Used);
    if used <> 0 then
    begin
      write(where, HexPtr(UsedPtr), '  ', HexPtr(AddToPointer(UsedPtr,Used)),
                     '  ',Used:6,'   ');
      dumpbothshort(where, UsedPtr^, 0, 8);
    end;

    UsedPtr := AddLongToPtr(FreePtr,PtrToLong(FreePtr^.size));
    if FreePtr <> HeapPtr then
      FreePtr := FreePtr^.next;
  end;
  Used := PtrDiff(HeapPtr,UsedPtr);
  inc(Total,used);
  if used <> 0 then
  begin
    write(where, HexPtr(UsedPtr), '  ', HexPtr(AddToPointer(UsedPtr,Used)),
                     '  ',Used:6,'   ');
    dumpbothshort(where, UsedPtr^, 0,8);
  end;
  writeln(where, 'Total':8,'':14, Total:6);
end;


end.

