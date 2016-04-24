(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0040.PAS
  Description: Line Memory
  Author: SEAN PALMER
  Date: 01-27-94  12:11
*)

{
-> All you need to access flat memory is to make sure you get two segmen
-> up against each other when you allocate them. The Windows API has
-> GlobalAllocPtr for this type of huge memory allocation, but I'm not s
-> you'd go about it in DOS (non-protected) mode except to compare the s
-> after GetMem() and see if they are linear/sequential. (and hope V86 m
-> handle translation to actual physical memory!)

> If that is the case then look up the ABSOLUTE clause in your Pascal
> manual. It will tell you how to make a second variables address be
> Absolutely relative to the firstone; no matter what. The address for
> the second one will be based on the address for the original.

Correct. Absolutely at the same address as the other variable.

At this time, BP won't let you add or subtract offsets from the address you
give to the Absolute clause. Unless possibly it's a constant address. In any
case, it's not ACCESSING memory linearly that is the problem, it's getting the
operating system or runtime library to ALLOCATE it linearly.

Protected mode has the WinAPI unit that lets you deal with huge memory blocks
and other stuff. That is what is needed.

In real mode all you can do is:
}

var p,p2,tmp:pointer;

begin  {make sure 2 memory blocks are linear}
 getmem(p,$C000);  {48K}
 getmem(p2,$C000); {96K total}
 while (seg(p2^)-seg(p^))*$1000+(ofs(p2^)-ofs(p^))<>$C000 do begin
  freeMem(p2,$C000);
  freeMem(p,$C000);
  writeln('Not linear... trying again.');
  getmem(tmp,1);
  getmem(p,$C000);
  getmem(p2,$C000);
  end;
 end;

