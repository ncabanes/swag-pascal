(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0073.PAS
  Description: EMS Heaps
  Author: DJ MURDOCH
  Date: 05-26-95  23:04
*)

{
> Actually, there is 2 ways I know.. One way, is to extend
> the HEAP to UMBs. Another way is to extend it to EMS/XMS...

> You can't extend a TP heap like that. Maybe with DOS calls to memory
> allocation you can do that with DOS heap memory. TP actually takes 1
> large DOS heap block and does its own allocation and heap tracking within
> that for its own heap management. TP can't do what you want it to do,
> this time.

It can use UMBs or the EMS page frame; that's no problem at all.  Just allocate
them to your program using DOS services, then fiddle with the heap manager
variables so that it thinks it's got a fragmented heap.  Here's some code I
wrote a long time ago to use the EMS page frame this way; you'll need to
provide some EMS control routines yourself if you don't have the Object
Professional library.  It was written for TP 6, but should work fine in TP/BP 7
real mode, because the heap manager is the same.
}
unit EMSHeap;

{ This unit adds up to 64K of EMS memory to the Turbo Pascal heap.  Compatible
  with TP 6.0. }

{ Version 0.0.
  Copyright (1992) D.J. Murdoch.  This unit may be freely used
  provided credit is given to the author. }

interface

const
  init_alloc : boolean = true;   { Whether to allocate during initialization }
  pages      : word    = 0;      { The number of pages currently allocated   }

procedure UseEMSHeap;
{ Attempt to allocate EMS memory and attach it to the heap.  Pages will be
  set to the number of allocated pages if it succeeds. }

function ReleaseEMSHeap:boolean;
{ Attempt to release the EMS pages, and restore the heap to normal.  Will
  fail and return false if any variables are allocated in the EMS portion of
  the heap. }

implementation

uses
  opinline, opems;     { These routines from Object Professional provide
                         the EMS management routines, and the pointer
                         manipulation }

var
  handle : word;       { The handle of the allocated pages }
  SaveExitProc,
  SaveHeapEnd : Pointer; { Saved values of the System variables }

type
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    Next : PFreeRec;
    Size : Pointer;
  end;

procedure UseEMSHeap;
var
  page : word;
  FreeRec : PFreeRec;  { PFreeRec is described in the Programmer's Guide }
begin
  if pages > 0 then    { Already got EMS, so exit }
    exit;
  if EMSInstalled then
  begin
    pages := EMSPagesAvail;
    if (pages <> 0) and (pages <> EMSErrorCode) then
    begin
      if pages > 4 then
        pages := 4;
      handle := AllocateEMSPages(pages);
      if handle <> EMSErrorCode then
      begin
        for page:=0 to pages-1 do
          if not MapEMSPage(handle,page,page) then { Shouldn't fail? };

        { Now we've got the pages allocated, let's set up the heap manager. }

        { First, set up a free list record at the old HeapPtr }
        FreeRec := HeapPtr;
        with FreeRec^ do
        begin
          Next := EMSPageFramePtr;
          if ofs(HeapEnd^) >= ofs(HeapPtr^) then
            Size := Ptr(seg(HeapEnd^) - Seg(HeapPtr^),
                        ofs(HeapEnd^) - Ofs(HeapPtr^))
          else
            Size := Ptr(seg(HeapEnd^) - Seg(HeapPtr^) - 1,
                        ofs(HeapEnd^) - Ofs(HeapPtr^) + 16);
        end;

        { Now adjust HeapPtr and HeapEnd }
        HeapPtr := Normalized(EMSPageFramePtr);
        SaveHeapEnd := HeapEnd;
        HeapEnd := Ptr(seg(HeapPtr^) + pages*$400,ofs(HeapPtr^));

        { Success! - so exit. }
        exit;
      end;
      { If we're here, we failed somehow. }
    end;
  end;
  pages := 0;    { Signal failure }
end;

function ReleaseEMSHeap:boolean;
{ Shrinks back to original allocation, if nothing is allocated in the EMS
  part. }
var
  FreeRec : PFreeRec;
  FreeEnd  : Pointer;
begin
  if pages > 0 then
  begin
    if PtrToLong(HeapPtr) > PtrToLong(EMSPageFramePtr) then
    begin
      ReleaseEMSHeap := false;
      exit;
    end;
    FreeRec := FreeList;
    while FreeRec^.Next <> HeapPtr do
      FreeRec := FreeRec^.Next;

    { Now FreeRec points to the last free block in regular memory }
    with FreeRec^ do
    begin
      FreeEnd := Ptr(Seg(FreeRec^) + Seg(Size^),
                        Ofs(FreeRec^) + Ofs(Size^));  { The end of the last
                                                        free block }
      if PtrToLong(FreeEnd) < PtrToLong(SaveHeapEnd) then
        HeapPtr := SaveHeapEnd        {  Memory allocated to the end of
                                         normal ram }
      else if PtrToLong(FreeEnd) = PtrToLong(SaveHeapEnd) then
        HeapPtr := FreeRec        {  A free block at the top of memory }
      else
      begin
        { This has got to be an error condition, so bail out.  }
        ReleaseEMSHeap := false;
        exit;
      end;
      HeapEnd := SaveHeapEnd;
      if not DeallocateEMSHandle(handle) then { Error we can't handle };
      pages := 0;
    end;
  end;
  ReleaseEMSHeap := true;
end;

procedure EMSExitProc; far;    { On exit, release our EMS pages }
begin
  ExitProc := SaveExitProc;
  if pages > 0 then
    if not DeallocateEMSHandle(handle) then  { Error, but nothing
                                               we can do about it };
end;

begin
  SaveExitProc := ExitProc;
  ExitProc := @EMSExitProc;
  UseEMSHeap;
end.

