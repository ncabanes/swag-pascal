{
>> Is there a faster way to find the GCD of two numbers than
>> Euclid's algorithm?

> Euclid's algorithm isn't fast enough for you?

Oh yes, I gather it is, but I'm interested in whether there are faster
ways or not.

> quick div or mod.  The following should be fast enough.
> function GCD( u, v : LongInt) : LongInt;

Here's my implementation:
}

function gcd(a, b : word) : word; assembler;
asm
  mov     ax,a
  mov     bx,b
@start:
  or      bx,bx
  jz      @endgcd
  xor     dx,dx
  div     bx
  mov     ax,bx
  mov     bx,dx
  jmp     @start
@endgcd:
end;

