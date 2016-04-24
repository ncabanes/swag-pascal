(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0001.PAS
  Description: BIGARRAY.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
>Do you know if the 64k Array limit still holds True when compiling
>under protected mode in BP7?

>...The answer is yes, however the limit is 64K (or 65,521 Bytes
>to be more exact  ie: < 65,535 Bytes) per data element. (ie: You
>can create an Array of 1..N of 64K elements, using an Array of
>Pointers.)

>But you can do *that* in Real mode.

  ...Yes, but try building something like this:
}
Uses
  Crt;

Type
  ar_64K   = Array[1..65521] of Byte;
  po_ar64K = ^ar_64K;
  ar_Po64K = Array[1..200] of po_ar64K;

Var
  by_Index : Byte;
  Buffer   : ar_Po64K;

begin
  ClrScr;
  by_Index := 0;
  While (MaxAvail > SizeOf(ar_64K)) do
  begin
    Inc(by_Index);
    New(Buffer[by_Index]);
    GotoXY(1,1);
    ClrEol;
    Write('Maximum Memory Available: ', MaxAvail);
    Delay(300);
  end;
end.
{
  ...Using the DPMI HEAP (and calling the correct DPMI Function
  to use your hard disk as virtual memory, unless you do have
  16Mb in your PC) you can allocate all 200 64K chunks of memory.
  With the "Real mode" HEAP, you'd be lucky to be able to allocate
  9 of these 64K chunks.

  ...It also means that you can use this DPMI HEAP to run HUGE .EXE's,
  as it can be used For either CODE or DATA. So you can forget about
  overlays, as you won't need them anymore.
}

