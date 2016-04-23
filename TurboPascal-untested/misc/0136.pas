
{ Updated MISC.SWG on May 26, 1995 }

{
> I've seen a message where some guys were talking about 32 bits graphics
> programming. It was something like this
> db $66; MOVSW
> When you use this it will move four bytes instead of 2. My problem is were
> to put those 4 bytes which should be stord. I know the first 2 bytes should
> be put in AX but were should you put the next 2. The trouble is that you
> can't use EAX because it's a 386 instruction.

You are confused about MOVS and STOS/LODS

    { optional segment override, i.e. }
    { SEGES }
    MOVS(B|W|D)
{
copies 1,2 or 4 bytes pointed to by SegReg:SI to the memory location pointed to
by ES:DI and in/decreases DI and SI accordingly. AL, AX, EAX are _not_
involved.
}
    { optional segment override, i.e. }
    { SEGES }
    LODS(B|W|D)
{
loads 1,2 or four bytes pointed to by SegReg:SI to AL, AX, or EAX
}
    STOS(B|W|D)
{
stores 1,2 or 4 bytes from AL, AX, EAX to the location pointed to by ES:DI.

386-only instructions and are not supported by BASM and you have to fake them
using inline machine code.
The usual technique is to use the WORD-oriented instructions and emit a
}
    db $66
{
before.
}
    db $66
    MOV AX, BX
{
will be assembled to
}
    MOV EAX, EBX
{
If you have a longint variable declared by
}
var
  l:longint;
{
you may load it to EAX by
}
    db $66
    MOV AX, word ptr l
{
This does will be assembled to
}
    MOV EAX, dword ptr l
{
So there is no problem, if you want to load EAX from another 32-bit-register
or from a memory location. The only problem may be to load eax with a
constant or to transfer 16-bit register values to an extended register.
Lets say you want to emulate a
}
    MOV  EAX, $ffff1234
{
The appropriate fake code is
}
    db $66
    MOV AX, $1234    { low word }
    dw $ffff         { high word }
{
for
}
    MOV EAX, 1
{
it is
}
    db $66
    MOV AX,1
    dw $0

{
There is a general technique to copy a word register to the high word of an
extended register.
If you want to copy DX:AX to EBX (DX to the high word and AX to the low word of
EBX) you may say
}
    MOV BX, DX      { DX to low word }
    db $66          { shift it up by one word }
    SHL BX, 16      { -> SHL EBX, 16 }
    MOV BX, AX      { AX to low word }
{
another way would be
}
    PUSH DX
    PUSH AX
    db $66
    POP  BX     { -> POPD EBX: pops _double_ word to EBX }
