> I made a Program in Turbo-Pascal that rotates the bits in one Byte so I can
> encrypt/decrypt a File, however the routine is slow. I then made the same
> Program in turbo-C using _RotLeft and _RotRight, the speed of execution was
> Really faster than Turbo-Pascal. Does anybody know of a way to rotate the
> bits of one Byte in turbo-Pascal and FAST !!!!


        Since 80xxx CPUs have bit rotate instructions (ROL, ROR), it would
be a shame to use some clumsy HLL Construct. BTW, I'm sure _RotLeft and
_RotRight use rotate instructions too, possibly insert them Inline. If
you are using TP 6.0+, try something like this:

{ to rotate left }
Function RotLeft(B, Count: Byte): Byte; Assembler;
Asm
  mov   al, B
  mov   cl, Count
  rol   al, cl
end;

{ to rotate right }
Function RotRight(B, Count: Byte): Byte; Assembler;
Asm
  mov   al, B
  mov   cl, Count
  ror   al, cl
end;


        Of course, if you need to do this in only a few places it would
be better not to define Functions, but insert Asm blocks in your code
directly.

        The fastest Pascal way to rotate Byte would be something like
this:

Function RotLeft(B, Count: Byte): Byte;
Var
  W : Word;
  A : Array[0..1] of Byte Absolute W;
begin
  A[0] := B;
  A[1] := B;
  W := W shl Count;
  RotLeft := A[1];
end;

        To rotate right With this method, you would shift right and
return A[0]. I would like to think this is as fast as it gets in TP
without assembly, but one can never be sure <g>. Anyway, I recommend
the assembly solution over this one, it is faster and more elegant.
