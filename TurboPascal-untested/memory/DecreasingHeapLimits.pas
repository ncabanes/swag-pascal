(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0070.PAS
  Description: Decreasing Heap Limits
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:01
*)

{
> You can NOT decrease heap-limit. It does not deallocate the heap even
> if you do. What you need is swapping.

Can too. Look at the Memory unit, and use "Setmemtop" eg:
}

uses memory;
var
  oldheapend: pointer;
begin
  oldheapend := heapend;
  heapend := heapptr;
  setmemtop(heapend);
  { Do whatever since your heap is now at the minimum }

  heapend := oldheapend;
  setmemtop(heapend);
End;

