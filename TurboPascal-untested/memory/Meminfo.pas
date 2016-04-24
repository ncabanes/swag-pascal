(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0010.PAS
  Description: MEMINFO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
First of all something about Turbo Pascal memory management. A Turbo Pascal
Program Uses the upper part of the memory block it allocates as the heap.
The heap is the memory allocated when using the Procedures 'New' and
'GetMem'. The heap starts at the address location pointed to by 'Heaporg' and
grows to higher addresses as more memory is allocated. The top of the heap,
the first address of allocatable memory space above the allocated memory
space, is pointed to by 'HeapPtr'.

Memory is deallocated by the Procedures 'Dispose' and 'FreeMem'. As memory
blocks are deallocated more memory becomes available, but..... When a block
of memory, which is not the top-most block in the heap is deallocated, a gap
in the heap will appear. to keep track of these gaps Turbo Pascal maintains
a so called free list.

The Function 'MaxAvail' holds the size of the largest contiguous free block
_in_ the heap. The Function 'MemAvail' holds the sum of all free blocks in
the heap.

Thus Far nothing has changed from TP5.5 to TP6.0. But here come the
differences:

TP5.5

to keep track of the free blocks in the heap, TP5.5 maintains a free list
which grows _down_ from the top of the heap. As more free blocks become
available, this list will grow. Every item in this list, a free-list Record,
contains two four-Byte Pointers to the top and the bottom of a free block
in the heap. _FreePtr_ points to the first free-list Record (the bottom most
free-list Record).

The minimum _allowable_ distance between 'FreePtr' and 'HeapPtr' can be set
with the Variable 'FreeMin'.

TP6.0

In TP6.0 the Variables 'FreePtr' and 'FreeMin' no longer exist. The free list
as implemented in TP5.5 no longer exists either (although the TP6.0
Programmer's guide still mentions a down growing free list??)). TP6.0 keeps
track of the free blocks by writing a 'free list Record' to the first eight
Bytes of the freed memory block! A (TP6.0) free-list Record contains two four
Byte Pointers of which the first one points to the next free memory block, the
second Pointer is not a Real Pointer but contains the size of the memory block.
Summary

So instead of a list of 'free list Records', growing down from the top of the
heap, containing Pointers to individual memory blocks, TP6.0 maintains a linked
list With block sizes and Pointers to the _next_ free block.
In TP6.0 an extra heap Variable 'Heapend' designating the end of the heap is
added. When 'HeapPtr' and 'FreeList' have the same value, the free list is
empty.

The below figure pictures the memory organization of both TP5.5 and TP6.0:


  TP5.5              TP6.0     Heapend
───          ┌─────────┐                 ┌─────────┐ <────
 ^    ┌──────│         │                 │         │
 │    │      ├─────────┤                 │         │
 │    │  ┌── │         │  FreePtr        │         │
 │    │  │   ├─────────┤ <────           │         │
Heap  │  │   │         │                 │         │
 │    │  │   │         │                 │         │
 │    │  │   │         │                 │         │
 v    │  │   │         │  HeapPtr        │         │  HeapPtr
───   │  │   ├─────────┤ <────        ┌─>├─────────┤ <────
      │  │   │         │              │  │         │
      │  ├──>├─────────┤              │  ├─────────┤
      │  │   │  Free   │              └──│  Free   │
      │  └──>├─────────┤              ┌─>├─────────┤
      │      │         │              │  │         │
      ├─────>├─────────┤              │  ├─────────┤
      │      │  Free   │  Heaporg     └──│  Free   │  FreeList
      └─────>├─────────┤ <────           ├─────────┤ <────
                                         │         │  Heaporg
                                      ├─────────┤ <────





I hope this will help you modifying existing toolBox's which make use of these
disappeared Variables. In some Case a modification may be quite easy, but as
you see it might get quite quite difficult as well.

