(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0026.PAS
  Description: Writing Data to HiMem
  Author: MAX MAISCHEIN
  Date: 08-27-93  21:28
*)

{
MAX MAISCHEIN

> Yes, but my question deals with storage in the Heap - I want to load
> and manipulate as much data in memory as possible.  Hence, I am looking
> for 1 byte improvements, if possible.  The actual file content size is
> not an issue...

For the case that some of your machines have UMBs available, I have a unit
that extends the heap into these UMB blocks completely transparent.
THe unit seems to work, I'd like to see any comments about bugs etc. on it.

    Max Maischein                                          2:249/6.17

    This unit was created to use the  high  memory  under  DOS  where
    LoadHi loads the TSRs etc. as extra heap. This was  possible  due
    to the revamped heap manager of Turbo  Pascal,  which  now  again
    uses MCBs to control its freelist instead of  an  array  of  8192
    pointers. I used this technique just like Himem / Quemm to insert
    a huge used block, the high DOS / BIOS area in the heap and  then
    to add the free RAN behind it. Now I have a maximum heap  size of
    700K, which is nicer than the old 640K  limit.  Note  that  using
    UseHi will not pay attention to the compiler $M settings in  your
    source. The memory is freed automatically by DOS, but  I  had  to
    adjust the MaxHeapxxx variable in the Memory unit, this is a word
    that contains the maximum heap size,  which  increased  by  using
    UseHi. If you don't need Turbo Vision, you can  remove  the  Uses
    Memory line and also remove the MaxHeapxxx adjustment.  But  with
    TVision, it will only work, if you have this line in it.

    The text variable HeapWalk is for debugging purposes, if you want
    to see a dump of the free blocks in the heap, you need to  assign
    and reset / rewrite the HeapWalk variable and then call ListWalk.
    Don't forget to close the HeapWalk variable again. It  will  dump
    the whole freelist into the file.

    This piece of code is donated to the public domain, but I request
    that, if you use this code, you mention me in the DOCs somewhere.

                                                                 -max
}

Unit UseHi;
Interface

Type
  PFreeRec = ^TFreeRec;
  TFreeRec = Record
    Next   : Pointer;
    Remain : Word;
    Paras  : Word;
  End;

Var
  HeapWalk : ^Text;

Procedure ListWalk;

Var
  NewHeap : Pointer;
  NewSize : Word;

Implementation
Uses
  MemAlloc,
  Memory,
  Objects,
  Strings2;

Const
  MemStrategy : Word = 0;
  UMBState    : Boolean = False;

Procedure himem_Init; Assembler;
Asm
  mov  ax, 5800h
  int  21h
  mov  MemStrategy, ax
  mov  ax, 5802h
  int  21h
  mov  UMBState, al
  mov  ax, 5803h
  mov  bx, 1
  int  21h
  mov  ax, 5801h
  mov  bx, 0040h
  int  21h
End;

Procedure himem_Done; Assembler;
Asm
  mov  ax, 5801h
  mov  bx, MemStrategy
  int  21h
  mov  ax, 5803h
  mov  bl, UMBState
  xor  bh, bh
  int  21h
  mov  ax, 1
End;

Procedure MakeFreeList;
Var
  Mem : LongInt;      { size of last block between heapPtr / HeapEnd }
  P   : PFreeRec;
Begin
  If (NewHeap = nil) then
    Exit;

  P := HeapPtr;

  Mem := LongInt(PtrRec(HeapEnd).Seg) shl 4 + PtrRec(HeapEnd).Ofs;
  Dec(Mem, LongInt(PtrRec(HeapPtr).Seg) shl 4 + PtrRec(HeapPtr).Ofs);

  If (Mem < 8) then
    RunError(203);

  With P^ do
  Begin
    Next   := NewHeap;
    Paras  := Mem shr 4;
    Remain := Mem and $0F;
  End;

  HeapPtr := NewHeap;
  HeapEnd := NewHeap;
  With PtrRec(HeapEnd) do
    Inc(Seg, Pred(NewSize));
  MaxHeapSize := PtrRec(HeapEnd).Seg - PtrRec(HeapOrg).Seg;
End;

Function BlockSize(P : PFreeRec) : LongInt;
Begin
  With P^ do
    BlockSize := LongInt(Paras) * 16 + LongInt(Remain);
End;

Procedure ListWalk;
Var
  P   : PFreeRec;
  Mem : LongInt;
Begin
  WriteLn(HeapWalk^, 'Free list    :', WPointer(FreeList));
  WriteLn(HeapWalk^, 'Heap end     :', WPointer(HeapEnd));
  WriteLn(HeapWalk^, 'Heap pointer :', WPointer(HeapPtr));
  WriteLn(HeapWalk^, 'New heap     :', WPointer(NewHeap));
  WriteLn(HeapWalk^, 'Walk of freelist :' );
  P := FreeList;
  If P <> HeapPtr then
    While P <> HeapPtr do
    Begin
      Write(HeapWalk^, WPointer(Addr(P^)), ' -- ');
      With PtrRec(P), P^ do
        Write(HeapWalk^, WPointer(Ptr(Seg + Paras, Ofs + Remain)));
      WriteLn(HeapWalk^, ', ', BlockSize(P) : 7, ' bytes.');
      P := P^.Next;
    End;
  Mem := LongInt(PtrRec(HeapEnd).Seg) shl 4 + PtrRec(HeapEnd).Ofs;
  Dec(Mem, LongInt(PtrRec(HeapPtr).Seg) shl 4 + PtrRec(HeapPtr).Ofs);
  WriteLn(HeapWalk^, WPointer(HeapPtr), ' -- ', WPointer(HeapEnd), ', ',
                     Mem : 7, ' bytes left on top of heap.');
End;

Begin
  NewHeap  := nil;
  HeapWalk := @Output;

  himem_Init;
  NewSize := DOSMemAvail shr 4;
  MAlloc(NewHeap, DosMemAvail);
  himem_Done;

  MakeFreeList;
End.

