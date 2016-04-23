
{ Updated MISC.SWG on May 26, 1995 }

{
From: anders@hk.super.net (Mr Anders Lee)

:>When I use a function like this:
:>Function GetMode: Byte; Assembler;

:>Pascal doesn't want to let me assign a register to "GetMode" !
:>i.e:
:> ASM
:>  Move GetMode, Al
:> End;

You don't need to assign it to the function name as you does with
standard pascal function.  SImply leave the value in AL (or AX, or
DX:AX depending on the size) and the one calling it will pick up
the value.
For string result, you store the value to a pre-defined variable called
Result, like this:

    LES DI,@Result   ; getting the address
    MOV ES:[DI],AX   ; to put data to it
    STOS is another method.
}