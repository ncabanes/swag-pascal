(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0012.PAS
  Description: BASM Tutoral #1
  Author: CHRIS PRIEDE
  Date: 06-08-93  08:29
*)

===========================================================================
 BBS: The Beta Connection
Date: 06-03-93 (00:08)             Number: 680
From: CHRIS PRIEDE                 Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: BASM TUT01 (1/4)               Conf: (232) T_Pascal_R
---------------------------------------------------------------------------

    No matter what HLL you use -- Pascal, C, COBOL or some other
language -- there is still place for assembly in your programs.
Corresponding directly to the native language of your computer, it
combines unlimited control with unmatched efficiency.

    Since Borland added the built-in assembler in TP 6.0, enhancing
Pascal programs with some assembly has become much easier than before.
However, I have read many books and found the BASM sections in Turbo
Pascal books are inadequate and frequently contain errors. There are
very good assembly books available, but they focus on writing
assembly-only programs using standalone assemblers.

    Considering this, I decided to write a text file -- assembly
language lessons for TP programmers, mostly using BASM. When I asked our
host Guy for his opinion on this idea, he aproved and suggested I post
sections weekly in this conference.

    A large part of this tutorial will be dedicated not to assembly
language itself, but tasks that often require it: writing interrupt
handlers and TSRs, accessing hardware directly. I will try to post new
sections weekly, if my schedule permits. Questions, suggestions and
criticism are very welcome.

    You will need a copy of TP 6.0 or later. Turbo Debugger, TASM or
MASM could be useful, but are not required.


 - I -

    To get started, we will take a Pascal routine, convert it to
assembly (using BASM) and see if we can beat the compiler at code
generation. We will use a simple integer square root function; it is not
something you would need often (unless you are writing graphics
routines), but serves well as an example and only requires simple data
movement and arithmetic instructions.

function ISqr(I: word): word;
var Root, LRoot: word;
begin
  Root := 1;
  repeat
    LRoot := Root;
    Root := ((I div Root) + Root) div 2;
  until ((integer(Root - LRoot) <= 1) and
   (integer(Root - LRoot) >= -1));
  ISqr := Root;
end;

    It is based on a well-known formula (name has escaped my memory).
The loop usually continues until Root and LRoot are equal, but that
might never happen with integers because fraction is truncated. Our
version loops until difference is less than 1, resulting in almost
correctly rounded result. The number of iterations required to find
square root of N never exceeds (ln N) +1, which means our function will
find the square root of any valid argument in 12 or less iterations.

    Now, let's convert this to assembly. One major improvement we can
make is to place both temporary variables in registers. CPU can access
registers much faster than memory. AX and DX are needed for division, so
we will assign Root to register CX and LRoot -- to BX:

function ISqr(I: word): word; assembler;
asm
  mov   cx, 1           {  Root := 1                                  }
@@1:                    { loop start label                            }
  mov   bx, cx          {  LRoot := Root                              }
  mov   ax, I           {<                    <                       }
  sub   dx, dx          {< AX := (I div Root) <                       }
  div   cx              {<                    < Root := ((I div Root) }
  add   ax, cx          {  AX := AX + Root    <   + Root) div 2       }
  shr   ax, 1           {  AX := AX div 2     <                       }
  mov   cx, ax          {  Root := AX         <                       }
  sub   ax, bx          {  AX := Root - LRoot                         }
  cmp   ax, 1           {  Compare AX to 1...                         }
  jg    @@1             {  Greater than 1  -- continue loop           }
  cmp   ax, -1          {  Compare AX to -1...                        }
  jl    @@1             {  Less than -1 -- continue loop              }
  mov   ax, cx          {  ISqr := Root -- return result in AX        }
end;

    Simple statements translate to one instruction, while complex
expressions have to be broken down in smaller steps. Notice we compute
expression (Root - LRoot) only once, although it's result is tested
twice. As you will see shortly, Turbo Pascal is not smart enough yet to
take advantage of this: compiled Pascal code would subtract twice.

(continued in next message...)
---
 * D.W.'s TOOLBOX, Atlanta GA, 404-471-6636
 * PostLink(tm) v1.05  DWTOOLBOX (#1035) : RelayNet(tm)
===========================================================================
 BBS: The Beta Connection
Date: 06-03-93 (00:10)             Number: 681
From: CHRIS PRIEDE                 Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: BASM TUT01 (2/4)               Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
    Function result is left in AX register. TP expects function return
values in the following registers:

    Char, Byte          : AL
    Word, Integer       : AX
    LongInt, pointers   : DX:AX
    (low order word/offset in AX, high order word/segment in DX)


    Let's go through this line by line...

* function ISqr(I: word): word; assembler;

    This is a standard function declaration, except for the word
"assembler", which tells Turbo Pascal entire function is going to be in
assembly (if you try to insert some Pascal code in assembler function,
it won't work).

* asm

    "Asm" means start of assembly block, just like "begin" means start
of Pascal block. Since our function was declared assembler, it has only
asm block; without "assembler" keyword it would have to start with
"begin":

function Foo;
begin
  asm
    { some assembly code }
  end;
end;

    You can use asm blocks anywhere in your Pascal code, but conventions
for pure asm functions are somewhat different.

*  mov   cx, 1

    MOV (Move) instruction is assembly assignment statement. This line
is equivalent to CX := 1 in Pascal.

* @@1:

    This is a local label, not unlike Pascal labels, used with dreaded
GOTO statements. Unfortunately, the only means of flow control in asm is
using GOTO-like jumps (conditional or unconditional), so you would
better get used to it. Destination of such jumps can be a Pascal-style,
previously declared label or a local label, like the one above. Local
labels don't have to be previously declared, but they should start with
@ (at sign).

*  mov   bx, cx
*  mov   ax, I

    Some more MOVing. Notice we can move data between two registers or
register and memory (argument I is stored on stack -- in memory). We
can't, however, directly move one memory variable into another: most
80x86 instructions can't have two memory operands. If you ever need to
assign one memory variable to another, it should be done through a
register, like this:

    mov     ax, X
    mov     Y, ax

    The same applies to most other instructions with two operands.

*  sub   dx, dx

    SUB (Subtract) subtracts the right operand from left and leaves the
result in left operand. SUB AX, CX is equivalent to AX := AX - CX in
Pascal.

    As you may have noticed, we are subtracting DX from itself. This is
a better way of setting register to 0 (100 - 100 = 0). We could use MOV
DX, 0, but SUB instruction is one byte smaller and a few clock cycles
faster. Some programmers use XOR for the same purpose: a number XORed
with itself results in 0 too. We need DX to be 0 for division.

*  div   cx

    DIV (Divide). 80x86 divide and multiply instructions are different
from other arithmetic instructions. You only need to specify divisor;
other operands are assumed to be AL, AH or AX, DX registers. This table
summarizes both DIV variants:

Dividend       │Divisor    │Quotient       │Remainder
───────────────┼───────────┼───────────────┼
16 bit (AX)    │8 bit      │8 bit (AL)     │8 bit (AH)
32 bit (DX:AX) │16 bit     │16 bit (AX)    │16 bit (DX)

(continued in next message...)
---
 * D.W.'s TOOLBOX, Atlanta GA, 404-471-6636
 * PostLink(tm) v1.05  DWTOOLBOX (#1035) : RelayNet(tm)
===========================================================================
 BBS: The Beta Connection
Date: 06-03-93 (00:12)             Number: 682
From: CHRIS PRIEDE                 Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: BASM TUT01 (3/4)               Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
    The size of divisor selects between 16 and 32 bit divide. In our
function both dividend and divisor are 16 bit words, which is why we had
to zero DX, effectively extending word in AX to 32 bits.

    Divisor should be a register or memory variable. If you need to
divide by immediate value, first move it in a register:

    mov     bx, 320
    div     bx

    Use IDIV (Integer Divide) for signed numbers (integer, longint).
IDIV works exactly like DIV, but performs signed division.

* add   ax, cx

    ADD (Addition). Pascal equivalent: AX := AX + CX.

* shr   ax, 1

    Bitwise Shift Right. Pascal equivalent: AX := AX shr 1. As the name
implies, this instruction shifts bits right:

AX before shift:    0000101100110110    (decimal 2870)
AX after shift:     0000010110011011    (decimal 1435)

    If you look at the decimal values on the right, you will notice
shifting divided the number by 2. That is correct: shifting a binary
number N bits left/right is equivalent to multiplying/dividing it by
2^N. CPU can shift bits much faster than divide and shift instructions
are not restricted to certain register(s) like DIV -- remember this
when you need to multiply/divide by a power of 2.

    The first operand (value to be shifted) can be either register or
memory. The second operand is number of bits to shift -- immediate value
or CL register. 8086 allows _only_ immediate value of 1; to shift by more
than one bit use the following:

    mov     cl, 3   (bit count)
    shr     ax, cl

    You can also shift several times by one (I would use this method only
to shift by 2 - 3 bits, otherwise it gets too long):

    shr     ax, 1
    shr     ax, 1
    shr     ax, 1

    286+ can shift by any immediate count. If you are compiling for 286
and better ({$G+} compiler directive), you can do this:

    shr     ax, 3

*  cmp   ax, 1

    CMP (Compare) compares two operands and sets CPU flags to reflect
their relationship. Flag state are later used to decide if a conditional
jump instruction should jump or not. This two step process is used to
control program flow, like if..then statements and loops in Pascal.

*  jg    @@1

    ...and this is a conditional jump. JG (Jump if Greater) will transfer
control (GOTO) to label @@1 if the last compare found left operand to be
greater than right, otherwise it "falls through": execution continues at
the next instruction. JG assumes operands were signed (integers). Use JA
(Jump if Above) for unsigned values (words). The following is a summary
of conditional jumps for arithmetic relationships:

JA/JNBE     Jump if Above                   (">",  unsigned)
JG/JNLE     Jump if Greater                 (">",  signed)
JAE/JNB     Jump if Above or Equal          (">=", unsigned)
JGE/JNL     Jump if Greater or Equal        (">=", signed)
JE/JZ       Jump if Equal                   ("=")
JNE/JNZ     Jump if Not Equal               ("<>")
JB/JNAE     Jump if Below                   ("<",  usigned)
JL/JNGE     Jump if Less                    ("<",  signed)
JBE/JNA     Jump if Below or Equal          ("<=", unsigned)
JLE/JNG     Jump if Less or Equal           ("<=", signed)

    For ease of use, assemblers recognize two different mnemonics for
most conditional jumps. Use the one you find less cryptic.

    Since conditional jump instructions simply inspect flags set by
previous compare, there may be other instructions in between, provided
they don't alter flags -- for example, MOV. Flags are not cleared and
can be tested more than once. For example, you could do this:

(continued in next message...)
---
 * D.W.'s TOOLBOX, Atlanta GA, 404-471-6636
 * PostLink(tm) v1.05  DWTOOLBOX (#1035) : RelayNet(tm)
===========================================================================
 BBS: The Beta Connection
Date: 06-03-93 (00:29)             Number: 683
From: CHRIS PRIEDE                 Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: BASM TUT01 (4/4)               Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
    mov     ax, X
    cmp     ax, Y
    jg      @XGreater   { X > Y }
    jl      @XLess      { X < Y }
    ....                { fell through -- X = Y }

*   end;

    Like Pascal blocks, this means the end of BASM block. If you were
using a standalone assembler, you would have to add RET (Return from
subroutine) instruction and possibly some other (cleanup) code. BASM
adds this and similar purpose code at the top of the function
automatically -- it is called entry & exit code and usually amounts
to 1 - 3 instructions, depending from number of arguments and local
variables.

    Well, looks like everything is covered... Quite a bit for the first
lesson too. If you have the instruction set reference, check it for more
detailed descriptions. If you don't, I strongly recommend to obtain one.
This is just one of many sources:

    The Waite Group's "Microsoft Macro Assembler Bible" or "Turbo
Assembler Bible", ISBN 0-672-22659-6 (MASM flavor). $29.95, published
by SAMS. A very good reference book, comes in MASM and TASM flavors,
you choose.

    Finally, here is disassembly of compiled TP code. [BP+n] means
reference to function argument, [BP-n] -- to local variable. This is
provided mainly to satisfy your curiosity, but it shows we thought very
much like the compiler, only coded it better:

ISQR:
isqr1.pas#9:begin
   0000:0000 55              PUSH    BP
   0000:0001 89E5            MOV     BP,SP
   0000:0003 83EC06          SUB     SP,+06
isqr1.pas#10:  Root := 1;
   0000:0006 C746FC0100      MOV     [WORD BP-04],0001
isqr1.pas#11:  repeat
isqr1.pas#12:    LRoot := Root;
   0000:000B 8B46FC          MOV     AX,[BP-04]
   0000:000E 8946FA          MOV     [BP-06],AX
isqr1.pas#13:    Root := ((I div Root) + Root) div 2;
   0000:0011 8B4604          MOV     AX,[BP+04]
   0000:0014 31D2            XOR     DX,DX
   0000:0016 F776FC          DIV     [BP-04]
   0000:0019 0346FC          ADD     AX,[BP-04]
   0000:001C D1E8            SHR     AX,1
   0000:001E 8946FC          MOV     [BP-04],AX
isqr1.pas#14:  until ((integer(Root - LRoot) <= 1) and
isqr1.pas#15:      (integer(Root - LRoot) >= -1));
   0000:0021 8B46FC          MOV     AX,[BP-04]
   0000:0024 2B46FA          SUB     AX,[BP-06]
   0000:0027 3D0100          CMP     AX,0001
   0000:002A 7FDF            JG      isqr1.pas#12(000B)
   0000:002C 8B46FC          MOV     AX,[BP-04]
   0000:002F 2B46FA          SUB     AX,[BP-06]
   0000:0032 3DFFFF          CMP     AX,0FFFF  (-1)
   0000:0035 7CD4            JL      isqr1.pas#12(000B)
isqr1.pas#16:  ISqr := Root;
   0000:0037 8B46FC          MOV     AX,[BP-04]
   0000:003A 8946FE          MOV     [BP-02],AX
isqr1.pas#17:end;
   0000:003D 8B46FE          MOV     AX,[BP-02]
   0000:0040 89EC            MOV     SP,BP
   0000:0042 5D              POP     BP
   0000:0043 C20200          RETN    0002

    TP's code doesn't place variables in registers and does some
unnecessary work (ie, subtracts Root - Lroot twice; see above). Entry
and exit code is shown too.

    Our version is slightly faster, but I didn't pick this routine to
demonstrate optimization -- integer math is about the only area where
most compilers do well. A good optimizing compiler should be able to
generate code as good as ours. I would be curious to see what this
looks like compiled with SBP+ (Guy: consider this a strong hint :)).
Most code you would normally write in assembly will show much greater
improvement (string routines, etc.).

    What to expect: next time we will discuss how to call DOS or BIOS
interrupts using BASM; what registers are available; which have special
uses or should be preserved; how to access strings, arrays and records.
Somewhere in near future: writing object methods in BASM.

                             *  *  *
---
 * D.W.'s TOOLBOX, Atlanta GA, 404-471-6636
 * PostLink(tm) v1.05  DWTOOLBOX (#1035) : RelayNet(tm)

