{
From: bobs@dragons.nest.nl (Bob Swart)

> I need some advice on managing the stack.
Read The Pascal Magazine issue #4 (Borland Pascal Efficiency on speed vs.
size) - a long excerpt will follow to make up for this plug:

> I was taught that it is good form to use locally declared variables
> in a procedure rather than manipulating global variables from
> within a procedure. Well, this seems to be causing some problems for
> me.

Yes, this eats up stack. Your string handling routine will probably eat up
stack also, as I'll point out a little further down...

>   What are some good strategies to use to manage the stack? How can
>   prevent these stack overflow errors without having to increase the
>   size of the stack...

The stack is often a soft spot of many applications. Generally, it's best to
specify a large stack size (like 32Kbytes) unless you have specific reasons not
to do so. The most annoying thing about the stack it that it's often hard to
see how much is actually used by a specific "run" of your program (and hence,
how much was still free). The following unit can be used to check for the
minimum value of the Stack Pointer:
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
unit stack;
interface
Const
  MinStack: Word = $FFFF;
  NumProbe: Word = $0000;

  procedure StackProbe;

implementation
uses Dos;

  procedure StackProbe; Assembler;
  ASM
        inc   NumProbe { only count REAL probes }
        cmp   SP,MinStack
        jnb   @Exit
        mov   MinStack,SP
 @Exit:
  end {StackProbe};

Const
  OurOwnSS: Word = 0;
  SaveExit: pointer = nil;
  OldInt08: pointer = nil;

  procedure NewInt08; interrupt; Assembler;
  ASM
        mov   AX,SS
        cmp   OurOwnSS,AX
        jne   @Exit
        inc   NumProbe { only count REAL probes }
        cmp   SP,MinStack
        jnb   @Exit
        mov   MinStack,SP
 @Exit:
        pushF
        call  DWORD PTR [OldInt08] { goto original int $08 handler }
  end {NewInt8};

  procedure NewExit; far;
  begin
    ExitProc := SaveExit;
    SetIntVec($08, OldInt08) {get old int from code segment}
  end {NewExit};

begin
  ASM
        mov   AX,SS
        mov   OurOwnSS,AX
  end { TurboSS := SSeg };
  SaveExit := ExitProc;
  GetIntVec($08, OldInt08);  {store old int in code segment}
  SetIntVec($08, @NewInt08); {set int $08 to our ISR}
  ExitProc := @NewExit
end.

{
>   what can I do that would allow me to use locally declared variables
>   from within a procedure without having to worry about stack overflow??
Stack space is used by calls to routines and their local variables. Stack space
is also used for the variables to procedures and functions. If you want to
preserve stack space, you should take care when using recursive calls.
Recursion may be a very elegant way to implement a solution, it is also
dangerous as it eats your stack. Make sure you always know the maximum depth of
a recursive call!

Furthermore, you should try to avoid passing large structures (like Strings) as
Value parameters to procedures and functions. This will use a lot of stack
space, and will slow down your program as the variable must be copied onto the
stack (and removed from the stack again). Since version 7.0, we can pass
arguments not only by value (which uses a lot of stack space) and by reference
(var parameter) but also by 'constant value', which actually is by reference
but means that you get an error if you try to modify the contents.

Functions returning strings are especially space wasters. For example, suppose
you have a

  Function UpCaseStr(Str: String): String;
  begin
    UpCaseStr := ...
  end;

If you're implementing it in plain Pascal, you'll need 1024 bytes of data at a
minimum:
- 256 bytes are allocated for "Str", the formal parameter
- 256 bytes for a local copy of "Str" since it was passed as a value parameter
- 256 bytes for a local variable of the type String, working storage to build
the function result
- 256 bytes for assigning the result to the function result (as in: "UpCaseStr
:= Result").

You can cut this figure by 50% by taking changing the parameter header into
"Function UpCaseStr(Const Str: String): String". Provided you don't change
"Str", no local copy of the string will be created. An alternative could be to
implement the routine as a procedure (no result) or in BASM, as BASM routines
always pass String arguments by reference only.

For more information I suggest my regular Pascal Efficiency column in The
Pascal Magazine...
}