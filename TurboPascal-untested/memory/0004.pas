Hello All,

Again, interrupts from protected mode. This is an updated version of my
previous article, which, by the way, generated much less respons (none)
than I expected. Where are the BTrieve Programmers, the DesqView API
Writers, the fossil Writers, the .... Maybe they know everything
already. Well then, what has been changed?

* little bugs fixed (memory not freed, SEG does not work, etc.)
* I stated that if you want to pass parameters on the stack you had to
  do low level stuff. This is not necessary. I do everything in high
  level(?) pascal now.
* Point 5 of the first Type of unsupported interrupts was inComplete.
  There's sometimes much more work involved :-(
* A simple Unit is presented, which helps to cut down code size. See
  Appendix A

Compiling Real to protected mode has been very simple For most of us.
Just Compile and go ahead. 99.5% of your code works fine. But the other
0.5% is going to give you some hard, hard work.
   In this article I describe first how I first stuck on the protected
stone. Than I try to give a general overview of problems one might
encounter when using interrupts. Next I describe the solutions or give
at least some hints, and I give a solution to the original Program which
made me aware of protected mode conversion problems. Appendix A lists
the code For a Unit I found usefull when porting my DesqView API to
protected mode.
    References can be found at the end of this article. of course, all
disclaimers you can come up With apply!


When Compiling a big Program, which supported DesqView, a GP fault
occurred. It was simple to trace the bug down: TDX would show me the
offending code. You can get the same error if you try to run the
following Program in protected mode:

========cut here==========================
Program Test;

Function  dv_win_me : LongInt;  Assembler;
Asm
  mov    bx,0001h
  mov    ah,12h
  int    15h       {* push dWord handle on stack *}
  pop    ax        {* pop it *}
  pop    dx        {* and return it *}
end;

begin
  Writeln(dv_win_me);
end.
========cut here==========================

This little Program must be run under DesqView. When run under DesqView
it returns the current Window handle on the stack. BUT: when Compiled
under protected mode NO dWord handle is returned on the stack. So a
stack fault occurs.

What happened? I stuck on one of those unsupported interrupts. Only
supported interupts guarantee to return correct results. You can find a
list of all supported interrupts in the Borland Open Architecture
Handboek For Pascal, Chapter 2 (seperate sold by Borland, not included
in your BP7 package). Supported are the general Dos and Bios interrupts.

BeFore eleborating on supported and unsupported interrupts, I have to
explain a few issues which are probably new to us Pascal Programmers.
Whenever a user interrupt occurs in protected mode (you issue a int xx
call) Borlands DPMI Extender switches to Real mode, issues the
interrupt, and switches back to protected mode.

This works find For most Cases: interrupts which only pass register
parameters work fine. But what happens if you, For example, called the
Print String Function? (int 21h, ah=09h). You pass as parameters ds:dx
pointing to the String to be printed. But, be aware: in protected mode
ds contains not a segment but a selector! and the selector in ds
probably points to an area above the 1MB boundary. These two things are
going to give Real mode Dos big, big problems. Don't even try it!
    So Borland's DPMI Extender does more than just switching from
protected to Real mode when an interrupt occurs: it translates selectors
to segments when appropriate. But, it can only do so For interrupts it
KNOWS that they need a translation. Such interrupts are called
supported. Interrupts about which Borland's DPMI Extender does not know
about are unsupported. and they are going to give you Real problems!

So you see, when only data is passed in Registers, everything works
fine. But if you need to pass Pointers, there is a problem. But why did
the above Program not work? It didn't use selectors you might ask. Well,
there is another set of interrupts that are unsupported: those that
expect or return values on the stack. This is the Case With the above
Program.

So, to conclude:
* supported interrupts
  - simple parameter passing using Registers, no segments/selectors
    or stacks included
  - interrupts which Borland's DPMI Extender knows about (too few For
    most of us)
* unsupported interrupts
  - using segments/selectors
  - involving stacks

In the next two sections I will fix both Types of problems. I make use
of the DPMI Unit, which comes With the Open Architecture Handbook. You
do not need this Unit. As this DPMI Unit is just a wrapper around the
DPMI interrupt 31h, simply looking the interrupts up in Ralph Brown's
interrupts list and writing Functions/Procedures For them, works fine.


Unsupported interrupts which need segments
------------------------------------------

Because the data segment and stack segment reside in protected mode, you
need to allocate memory in Real mode, copy your data (which resides
above 1MB) and issue the interrupt by calling the DPMI Simulate Real
Interrupt. So our to-do list is:
1) allocate Real mode memory
2) copy data from protected mode to Real mode
3) set up the Real mode Registers
4) issue interrupt
5) examine results

1) You can allocate Real mode memory by issueing a GlobalDosAlloc (not
   referenced in the online help, but you can look it up in the
   Programmer's refercence manual) request. The GlobalDosAlloc is in the
   WinApi Unit. For example:

     Uses WinAPI;
     Var
       Return : LongInt;
       MemSize : LongInt;
     begin
       MemSize := 1024;
       Return := GlobalDosAlloc(MemSize);
     end;

   This call allocates a block of memory, 1K in size, below the 1MB
   boundary. The value in Return should be split in LongRec(Return).Lo
   and LongRec(Return).Hi. The Hi-order Word contains the segment base
   address of the block. The low-order Word contains the selector For
   the block.

2) You use the selector to acces the block from protected mode and you
   use the segment of the block to acces the block within Real mode (your
   interrupt).
       For example: we want to exchange messages With some interrupt. The
   code For this would be:
     Uses WinAPI;
     Var
       Return : LongInt;
       MemSize : LongInt;
       RealModeSel : Pointer;
       RealModeSeg : Pointer;
       Message : String;
     begin
       MemSize := 256;
       Return := GlobalDosAlloc(MemSize);
       PtrRec(RealModeSel).seg := LongRec(Return).Lo;
       PtrRec(RealModeSel).ofs := 0;
       PtrRec(RealModeSeg).seg := LongRec(Return).Hi;
       PtrRec(RealModeSeg).ofs := 0;

     {* Both RealModeSel(ector) and RealModeSeg(ment) point to the same

        physical address now. *}

     {* move message from protected mode memory to the allocated selector *}
       Message := 'How are your?';
       Move(Message, RealModeSel^, Sizeof(Message));

     {* issue interupt, explained below *}
     { <..code..> }
     {* the interrupt returns a message *}

     {* move interrupt's message below 1MB to protected mode *}
       Move(RealModeSel^, Message, Sizeof(Message));
       Writeln(Message);     {* "yes, I'm fine. Thank you!" *}
     end;

3) We will now examine how to setup an interrupt For Real mode. Most of
   the time this is transparantly done by Borland's DPMI Extender, but
   we are on our own now. to interrupt Dos, we use the DPMI Function
   31h, 0300h. This interrupt simulates an interrupt in Real mode.

   The Simulate Real Mode Interrupt Function needs a Real mode register
   data structure. We pass the interrupt and the Real mode register data
   structure to this Function, which will than start to simulate the
   interrupt.
       This Function switches to Real mode, copies the contents of the
   data structure into the Registers, makes the interrupt, copies the
   Registers back into the supplied data structure, switches the
   processor back to protected mode and returns. Voila: you are in
   control again.
       Maybe you ask: why need I to setup such a data structure? Why can
   I not simply pass Registers? Several reasons exist, but take For
   example the RealModeSeg of the previous example. You cannot simply
   load a RealModeSeg in a register. Most likely a segment violation
   would occur (referring to a non existing segment or you do not have
   enough rights etc.). ThereFore only in Real mode can Real mode
   segments be loaded.

       The data structure to pass Registers between protected and Real
   mode can be found in the DPMI Unit which I Repeat here:

     Type
       TRealModeRegs = Record
         Case Integer of
           0: (
               EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: LongInt;
               Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
           1: (
               DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
               Case Integer of
                 0: (
                     BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);

                 1: (
                     BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                     CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
         end;

   This looks reasonably Complex, doesn't it! More simply is the
   following structure (found in, For example, "Extending Dos" by Ray
   Duncan e.a.)
   offset  Lenght Contents
   00h     4      DI or EDI
   04h     4      SI or ESI
   08h     4      BP or EBP
   0Ch     4      reserved, should be zero
   10h     4      BX or EBX
   14h     4      DX or EDX
   18h     4      CX or ECX
   1Ch     4      AX or EAX
   20h     2      CPU status flags
   22h     2      ES
   24h     2      DS
   26h     2      FS
   28h     2      GS
   2Ah     2      IP (reserved, ignored)
   2Ch     2      CS (reserved, ignored)
   2Eh     2      SP (ignored when zero)
   30h     2      SS (ignored when zero)

   In the following example, I set the Registers For the above message
   exchanging Function. It's best to clear all Registers (or at least
   the SS:SP Registers) beFore calling the Simulate Real Mode Interrupt.

     Uses DPMI;
     Var
       Regs : TRealModeRegs;
     begin
       FillChar(Regs, Sizeof(TRealModeRegs), #0); {* clear all Registers *}

       With Regs do  begin
         ah := $xx;
         es := PtrRec(RealModeSeg).Seg;
         di := PtrRec(RealModeSeg).ofs
       end;  { of With }
     end;

   All this is fairly standard. Just set up the Registers you interrupts
   expect, very much like the Intr Procedure.

4) We can now issue the interrupt in Real mode using the RealModeInt
   Procedure (in the DPMI Unit). Its definition is

     Procedure RealModeInt(Int: Byte; Var Regs: TRealModeRegs);

   or you can call int 31h, Function 0300h, see Ralph Brown's interrupt
   list.
   For our message exchanging Program it would simply be:
     RealModeInt(xx, Regs);

5) Examine the results. Modified Registers are passed in the Regs data
   structure so you can check the results.
       It is necessary to discriminate between to Types of returned
   segments. In the example above, I assumed that the Interrupt returned
   data in the allocated memory block. I already have a selector For
   that block, so I can examine the results.
   Another Type of interrupt returns Pointers to segments it has
   allocated itself. As we don't have a selector For that memory block
   we have to create one. We need the following Functions:
   - AllocSelectors, to allocate a selector
   - SetSelectorBase, to let it point to a physical address
   - SetSelectorLimit, to set the size
   An example For this situation: Assume that a certain interrupt
   returns a Pointer to a memory area. This Pointer is in es:di.
   Register cs contains the size of that memorya rea. I show you how to
   acces that segment.

     Uses DPMI;
     Var
       Regs : TRealModeRegs;
       p : Pointer;
     begin
     {* setup  Regs *}
     {* issue interrupt, returning es:di *}

     {* as we don't have a selector, create one *}
       PtrRec(p).Seg := AllocSelectors(1);
       PtrRec(p).ofs := 0;

     {* this selector points to no physical address and has size 0 *}
     {* so let the selector point to es:di *}
       SetSelectorBase(PtrRec(p).Seg, Regs.es*16+Regs.di);

     {* Forgive me! This was a joke. The last statement does not work   *}
     {* of course. Regs.es*16+Regs.di will in the best Cases ({$R+,Q+}) *}
     {* result in an overflow error. You have to Write:                 *}
       SetSelectorBase(PtrRec(p).Seg, Regs.es*LongInt(16)+Regs.di);

     {* the selector now points to a memory area of size 0 *}
       SetSelectorLimit(PtrRec(p).Seg, Regs.cx);

     {* we don't have to set the accesrights (code/data, read/Write, etc. *}
     {* as they are almost ok *}

     {* we can now acces this memory using selector p *}
     { <acces block> }

     {* after using it, free selector *}
       FreeSelector(PtrRec(p).Seg);
     end;


Are there any questions? No? Let's go ahead than to the next Type of
interrupts.

Unsupported interrupts which use the stack
------------------------------------------
The second Type of unsupported interrupts are the ones which make use of
the stack. We can distinguish between:
1. interrupts which need parameters on the stack
2. interrupts which return parameters on the stack

1) For the first Type we need to setup a stack. There is an extra
   Compilication, which I had not told yet. As the stack in protected
   mode resides in a protected mode segment it is unusable For the Real
   mode interrups. So Borland's DPMI Extender switches from the
   protected to a Real mode stack (and back). We can supply a default
   Real mode stack if we set the stack Registers (ss and sp) in the Real
   mode register data structure to zero. else it is assumed that ss:sp
   points to a Real mode stack. Failure to set them up properly could
   have disastrous results!

   We will have to do:
   1) create a Real mode stack using GlobalDosAlloc
   2) fill this stack With values
   3) set ss and sp properly
   4) issue interrupt

   All in one example Program. The following Program sets DesqView's
   mouse on a given location on the screen. The supplied handle is the
   handle of the mouse. As DesqView needs dWord values on the stack I
   allocated a LongIntArray stack which is defined as:

     Const
       MaxLongIntArray = 1000;
     Type
       PLongIntArray = ^TLongIntArray;
       TLongIntArray = Array [0..MaxLongIntArray] of LongInt;

   The example Program:

     Procedure SetMouse(Handle, x, y : LongInt);
     Const
       StackSize = 3*Sizeof(LongInt);
     Var
       Regs : TRealModeRegs;
       Stack : PLongIntArray;
       l : LongInt;
     begin
     {* clear all Registers *}
       FillChar(Regs, Sizeof(TRealModeRegs), 0);

     {* setup the Registers *}
       Regs.ax := $1200;
       Regs.bx := $0500;

     {* allocate the stack *}
       l := GlobalDosAlloc(StackSize);

     {* set stacksegment register sp. ss should be set to the bottom of *}
     {* the stack = 0 *}
       Regs.sp := LongRec(l).Hi;
       Stack := Ptr(LongRec(l).Lo, 0);

     {* fill the stack *}
       Stack^[0] := Handle;
       Stack^[1] := y;
       Stack^[2] := x;

     {* issue the interrupt *}
       RealModeInt($15, Regs);

     {* free the stack *}
       GlobalDosFree(PtrRec(Stack).Seg);
     end;

2) Looks much like solution above. if only values are returned on the
   stack. Don't Forget to set sp to the top of the stack. In the above
   example settings Regs.sp := StackSize;
       An example is given below, where a solution to my original
   problem is given.


Solution For the dv_win_me Procedure:

  Uses DVAPI, Objects, WinApi, WinTypes, DPMI;

  Function dv_win_me : LongInt;
  Const
    StackSize = Sizeof(LongInt);
  Var
    Regs : TRealModeRegs;
    RealStackSeg : Word;
    RealStackSel : Word;
    l : LongInt;
  begin
  {* clear all Registers *}
    FillChar(Regs, Sizeof(TRealModeRegs), #0);

  {* allocate a 1 dWord stack *}
    l := GlobalDosAlloc(StackSize);
    RealStackSeg := LongRec(l).Hi;
    RealStackSel := LongRec(l).Lo;

  {* clear the stack (not necessary) *}
    FillChar(Ptr(RealStackSel, 0)^, StackSize, #0);

  {* set Registers *}
    With Regs do  begin
      bx := $0001;
      ah := $12;
      ss := RealStackSeg;
      sp := StackSize;
    end;  { of With }

  {* perForm Real mode interrupt *}
    RealModeInt($15, Regs);
    dv_win_me := PLongInt(Ptr(RealStackSel, 0))^;

  {* free the stack *}
    GlobalDosFree(PtrRec(RealStackSel).Seg);
  end;

  begin
    Writeln(dv_win_me);
  end.


You see, code size bloats in protected mode! (ThereFore Borland gave us
16MB....)


Appendix A.
-----------

As promised, some routines I found usefull when working With Real mode
segments.

====================cut here====================
Unit DPMIUtil;

Interface

Uses Objects, DPMI;

Const
  MaxLongIntArray = 1000;
Type
{* this Type is usefull For DesqView stacks *}
  PLongIntArray = ^TLongIntArray;
  TLongIntArray = Array [0..MaxLongIntArray] of LongInt;


{* clear all Registers to zero *}

Procedure ClearRegs(Var Regs : TRealModeRegs);

{* allocate memory using GlobalDosAlloc and split the returned *}
{* LongInt into a protected mode Pointer and a Real mode segment *}

Function  XGlobalDosAlloc(Size : LongInt; Var RealSeg : Word) : Pointer;

{* free memory *}

Procedure XGlobalDosFree(p : Pointer);


Implementation

Uses WinAPI;

Procedure ClearRegs(Var Regs : TRealModeRegs);
begin
  FillChar(Regs, Sizeof(TRealModeRegs), 0);
end;

Function  XGlobalDosAlloc(Size : LongInt; Var RealSeg : Word) : Pointer;
Var
  l : LongInt;
begin
  l := GlobalDosAlloc(Size);
  RealSeg := LongRec(l).Hi;
  XGlobalDosAlloc := Ptr(LongRec(l).Lo, 0);
end;

Procedure XGlobalDosFree(p : Pointer);
begin
  GlobalDosFree(PtrRec(p).Seg);
end;

end.  { of Unit DPMIUtil }
====================cut here====================


Example code how to use it. The above dv_win_me routine would look like:

  Uses DVAPI, Objects, WinApi, WinTypes, DPMI;

  Function dv_win_me : LongInt;
  Const
    StackSize = Sizeof(LongInt);
  Var
    Regs : TRealModeRegs;
    Stack : PLongIntArray;
  begin
  {* clear all Registers *}
    ClearReges(Regs);

  {* allocate a 1 dWord stack *}
    Stack := XGlobalDosAlloc(StackSize, Regs.ss);

  {* set Registers *}
    Regs.bx := $0001;
    Regs.ah := $12;
    Regs.sp := StackSize;

  {* perForm Real mode interrupt *}
    RealModeInt($15, Regs);
    dv_win_me := Stack^[0];

  {* free the stack *}
    XGlobalDosFree(Stack);
  end;

  begin
    Writeln(dv_win_me);
  end.

Compare this to the previous code. It just looks a bit prettier
according to my honest opininion.


Conclusion
----------

As you saw, the switch from Real to protected mode may be rather
painfull. I hope With the above examples and explanations you can make
it a bit more enjoyable. One question remains: why did Borland not
clearly told us so? Why not present a few examples, warnings, etc.?
Maybe RiChard Nelson can answer this questions For us. Everything he
says is his private opinion of course, but a look in the kitchen could
be worthWhile.

if you still have questions, I'm willing to answer them in either
usenet's Comp.LANG.PASCAL or fidonet's PASCAL.028 or PASCAL. I can't
port your library of course but if the inFormation presented here is not
enough, just ask.



References
----------
- The usual Borland set of handbooks

- "Borland Open Architecture Handbook For Pascal", sold separately by
Borland,
  184 pages.

- "Extending Dos, a Programmer's Guide to protected-mode Dos", Ray
  Duncan, Charles Petzold, andrew Schulman, M. Steven Baker, Ross P.
  Nelson, Stephen R. Davis and Robert Moote. Addison-Wesly, 1992.
  ISBN: 0-201-56798-9

- "PC Magazine Programmer's Technical Reference: The Processor and
   Coprocessor", Robert L. Hummel. Ziff-Davis Press, 1992.
  ISBN: 1-56276-016-5


  { Dunno if this came before or after this message :) }

Hello Protectors,

of course, a few hours after my message has been released to the net,
bugfixes seem necessary )-:

Some minor bugfixes:

* In the example about allocating memory below the 1MB, memory is
  allocated but not released. As we have only 1MB down their, this can
  become a problem ;-)
  Fix:  adding the statement
    GlobalDosFree(RealModeSel);
  will clean things up

 * The solution to interrupts which requires parameters passed on the
  stack has a bug. The
    les  di,Regs
  statement does not work of course. Replace by
    mov  di,ofFSET Regs
    mov  dx,SEG Regs
    mov  es,dx
  This does not work when Regs is declared in the stack segment (well
  done Borland....), you encounter bug number 16, just as I did.... (see
  next message)


