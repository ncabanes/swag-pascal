(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0049.PAS
  Description: Clear ALL Memory
  Author: DJ MURDOCH
  Date: 02-03-94  09:24
*)

(*

CLEARMEM - A Turbo Pascal unit to automatically initialize the heap, stack, or
data segment to a fixed value.

Written by D.J. Murdoch for the public domain.

Interface:

  const
    filler : byte = 0;

This byte is used as the initial value.  A good choice for turning up
uninitialized variables is $FF - this will often cause a range check, and will
cause runtime error 207 if you try to use an uninitialized single, double or
extended.

  procedure clear_heap;

This procedure fills the heap with filler bytes.  Automatically called in the
initialization section.

  procedure clear_globals;

This procedure fills all global variables (except those in the system unit) with
filler bytes.  Very dangerous!  *Not* called in the initialization section
(unless you change it).  Written for TP 6.0; the source code gives hints on how
to change it for other versions.

  procedure clear_stack;

This procedure fills the unused part of the stack with filler bytes.

SAFETY

It's safe to call clear_heap any time; it'll fill all free blocks of 6 bytes or
more on the heap with the filler byte.  It won't necessarily do a perfect fill
if the heap is fragmented, because the free list will overwrite the filler.

It's also safe to call clear_stack any time, but is a bit less effective.  Any
interrupts that happen after your call will mess up the stack that you've just
cleared, so local variables won't necessarily be properly initialized.  It
doesn't touch anything already allocated.

It's definitely *NOT* safe to call clear_globals any time except at the very
beginning of your program, and only then from the initialization section of this
unit, and only if this is the very first unit that you Use in the main program.

*)

  unit clearmem;

  { Unit to clear all memory to a fixed value at the start of the program }
  { Written by D.J. Murdoch for the public domain. }

  interface

  const
    filler : byte = 0;

  procedure clear_heap;

  procedure clear_globals;

  procedure clear_stack;

  implementation

  type
    block_rec_ptr = ^block_rec;
    block_rec = record
      next : block_rec_ptr;
      size : word;
    end;

  procedure clear_heap;
  var
    prev,
    current : block_rec_ptr;
    howmuch : word;
  begin
    { First grab as much as possible and link it into a list }
    prev := nil;
    while maxavail >= sizeof(block_rec)  do
    begin
      if maxavail < 65520 then
        howmuch := maxavail
      else
        howmuch := 65520;
      getmem(current,howmuch);
      current^.next := prev;
      current^.size := howmuch;
      prev := current;
    end;

    { Now fill all those blocks with filler }
    while prev <> nil do
    begin
      current := prev;
      prev := current^.next;
      howmuch := current^.size;
      fillchar(current^,howmuch,filler);
      freemem(current,howmuch);
    end;
  end;

  procedure clear_globals;
  var
    where : pointer;
    howmuch : word;
  begin
    where := @test8087;                { The last const in the system unit }
    inc(word(where),sizeof(test8087)); { Just past that }
    howmuch := ofs(input)              { The first var in the system unit }
               - ofs(where^);
    fillchar(where^,howmuch,filler);
  end;

  procedure clear_stack;
  var
    where : pointer;
    howmuch : word;
  begin
    where := ptr(sseg,stacklimit);
    howmuch := sptr-stacklimit-14;   { leave room for the fillchar parameters
                                       and return address }
    fillchar(where^,howmuch,filler);
  end;

  begin
    clear_heap;
    clear_stack;
    {  clear_globals;  }  { Uncomment this only if this unit is the first one
                            in the main program's Uses list!!! }
  end.

