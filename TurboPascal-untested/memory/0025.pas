{
KENT BRIGGS

Here is what I came up with regarding my problem of needing a large
heap (temporarily) and needing memory for an EXEC routine:
}

procedure heap_shrink;    {free up all unused heap}
begin
  reg.bx := memw[seg(heapptr) : ofs(heapptr) + 2] - prefixseg;
  reg.es := prefixseg;
  reg.ah := $4a;            {dos memory alloc. interrupt}
  msdos(reg);
end;

procedure heap_expand;    {reclaim unused heap}
begin
  reg.bx := memw[seg(heapend) : ofs(heapend) + 2] - prefixseg;
  reg.es := prefixseg;
  reg.ah := $4a;
  msdos(reg);
end;

{
Leave the default heapmax at 655360.  Dispose of all temporary pointers
and call heap_shrink right before exec(my_prgm) and heap_expand right
after.  The memw's get the segment addresses for the heapend and heapptr
variables (see memory map in manual).  Subtract the PSP segment and that
gets you the number of paragraphs (16 byte blocks) to allocate.

Anyone see any dangers with this scheme?  I instantly freed up 110K for
DOS shells in my application.  No problems so far.
}