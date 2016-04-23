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