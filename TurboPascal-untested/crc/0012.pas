{
SEAN PALMER

>> (more than I thought I would have).  There were 190 collisions
>> out of 572 names.

>The solution would be to use a better hashing algorythm, simply
>adding up the ascii characters is not unique enough.  You best
>approach would be to generate a CRC value for your hashing table
>rather then the checksum approach.

Or try this xorsum method (my own invention, have to plug for it... 8)

Lots faster than a crc with no table, with similar results.

NOT compatible with a crc.

This xorsum algorithm is hereby standardized and if anyone wants to use
it you should make sure your xorsum routines give the same results.
}

function XorSum16(var data; size : word; prevSum : word) : word; assembler;
asm
  push ds
  lds  si, data
  mov  cx, size
  mov  bx, prevSum
  mov  dx, $ABCD
  cld
  jcxz @X
 @L:
  lodsb
  rol  bx, 1
  xor  bx, dx
  xor  bl, al
  loop @L
 @X:
  mov  ax, bx
  pop  ds
end;

{ to use on a string, for instance: }

const
  s : string = 'this is a test';

begin
  writeln(xorsum16(s, length(s) + 1, 0));
end.
{
send 0 as prevSum if you're not accumulating a result...otherwise send
the result from the previous buffer.
}

