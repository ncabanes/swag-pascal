{
> I only have TASM 2.2 or something and can't get to to compile CPUID and
> don't know the opcodes to code it with a couple of DB statements in
> Pascal's BASM...

 DB $F,$A2
 EAX must be set to 0 or 1 to request 2 modes of CPUID. Try looking in

Interrupt List for more info...

> Oh, and finally, I notice CPUID is being INCLUDED in the latest mask of

 [...]

> As CPUID is accepted as being the pentium detector code, some software out
> there may be getting it wrong! CPUID does (correctly) report a 4 for
> family type (logical as a pentium reports 5) but even so, I didn't know
> intel had started doing this!
> Oh, and checking for ability to toggle the appropriate bit in eflags to
> test for CPUID ability works too...

A lot of software recognizes Pentium only by this bit...

> Finally, if you know any way to identify a 386DX from a 386SX, please let
> me know!

 By timing memory transfers. 386sx and 486slc have 16 bit access while 386dx
and 486dlc do 32 bits at a time. Below is my procedure, mostly BASM :-( It may
get wrong if there are interrupts occuring while test.
}

function dx386 : boolean;
{
 Checks whether CPU is 386SX or DX. This is done by timing memory transfers:
 - on SX, there is very small difference between 32 bit moves and double
   16 bit moves, because SX does them 16 bit at a time anyway
 - on DX, dbl 16 bit moves are slower than 32 bit ones, because it does them
   at 32 bits anyway, so half of them is misaligned (requiring two movs).
 On SX, mov32/2*mov16 gives about 1.0-1.1 (with loop/timer int overhead)
 On DX, mov32/2*mov16 gives about 1.5     (ditto)

}
label
   notest;
const
   r1    : word = 1;
   r2    : word = 1;
   ratio : byte = 1;
const
   block = $1000;
   dx    : byte = 7; {value is stored to avoid multiple runs of (slow) test
code}begin
     if processor<7 then exit; {must be 386 or better}
     if dx<>7 then goto notest;
     asm
        in   al,$21
        sti
        push ax
        mov  al,$FE
        out  $21,al
        push ds
        mov  bx,0
        mov  es,Seg0040
        mov  ds,Seg0040
        mov  ax,es:[$6c]
      @1:
        cmp  ax,es:[$6c]
        je   @1
        mov  ax,es:[$6c]
      @2:
        mov  di,0
        mov  si,di
        mov  cx,block
        db $f3,$66,$a5 {rep movsd}
        inc  bx
        cmp  ax,es:[$6c]
        je   @2
        pop ds
        mov  r1,bx
        mov  bx,0
        push ds
        mov  ds,Seg0040
        mov  ax,es:[$6c]
      @3:
        cmp  ax,es:[$6c]
        je   @3
        mov  ax,es:[$6c]
      @4:
        mov  di,0
        mov  si,di
        mov  cx,block*2
        rep  movsw
        inc  bx
        cmp  ax,es:[$6c]
        je   @4
        pop  ds
        pop  ax
        out  $21,al
        mov  r2,bx
     end;
     ratio:=10*r1 div r2;
     dx:=ord(ratio>=13);
{     writeln('r=',ratio,' t1=',r1,' t2=',r2);}
notest:
     dx386:=(dx=1);
end;
