{
> Does anyone know how to access memory linearly as to do away with the
> Segment:Offset standard? I've seen it done in a program called VOC 386
> yet it doesn't switch to protected mode(at least I'm pretty sure...)

> I need to load digital samples >64k and have a means of addressing them
> with having to worry about crossing segment boundries and conventional
> memory just won't suffice... Any help would be appreciated...

You just need to trick GetMem into allocating the memory sequentially, and as
long as you're in v86 mode it should wrap your indexes on to the next chunk of
memory if you use 32-bit addressing
}
getMem(p1,32768);
getMem(p2,32768);
getMem(p3,32768);
if (seg(p2^)-seg(p1^)<>$800)or(seg(p3^)-seg(p2^)<>$800) then exit;
                           {not seqential! They must be sequential!!} if
(ofs(p1^)<>0)or(ofs(p2^)<>0)or(ofs(p3^)<>0) then exit;
                           {keep them at zero offset also} {all that is a
little drastic (exiting and such) but you must somehow make sure they're truly
linear, at least according to your virtual 8086 machine.}
{
Now you need 386 assembly which pascal's BASM can't handle, but I'll post some
here anyway.
}
asm
 db $66; xor si,si           {xor esi,esi}
 push ds
 mov ds,word ptr p1+2
 db $66; mov cx,32768; dw 1  {mov ecx,$18000}
 db $67; rep lodsb         {get bytes using extended 32-addressing (ds:esi)}
 pop ds
 end;
{
although this doesn't actually do anything with the data, it does access it.
(or should, this hasn't been tested yet)
}

