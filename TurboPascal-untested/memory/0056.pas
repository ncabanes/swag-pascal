
{
 SM> I have a bit of a problem with pascal 7 protected mode,
 SM> I have a TSR (assembly) that does my comms work for me.
 SM> I use intr(regs) with various settings to the registers to collect
 SM> data from the TSR. However when in protected mode my TSR seems
 SM> to be unavailable.

I had the same problem, it seems that the DOS unit does not support protected
mode interrupt handling. I solved it by looking though some documentation I
found on protected mode, below is a simple unit to set and get protected
mode interrupts.

In my case the interrupt goes about 22Khz so it kept switching into real mode
and back just to handle the interrupt, the result it crashed.

 SM> Do I need to switch to real mode from the app.
 SM> (if so how, I can't find it in the manual).

No, see above.

 SM> Do I need to modify my TSR.
 SM> I presume not because I'm sure that the mouse drivers can be got
 SM> to work.

The MOUSE is handled by the DOS extender.

Cheers
  Rob

P.S. I noticed that you use the same BBS, if you have any problems drop
me a note.
}

Unit DPMIDos;  { This code was a quick hack job to solve my problem }
               { don't expect it to be neat!                        }

INTERFACE

Function RealMode : Boolean;
Function AllocateLDT(NumberDescriptors : Word) : Word;
Function FreeLDT(Selector : Word) : Boolean;
Function SegmentToDescriptor(Segment : Word) : Word;
Function GetNextSelectorInc : Word;
Function GetDPMIntVec(IntNumber : Byte) : Pointer;
Procedure SetDPMIntVec(IntNumber : Byte; IntVec : Pointer);

IMPLEMENTATION

Function RealMode : Boolean; assembler;
asm
  mov     ax, 01686h
  int     02Fh
end;

Function AllocateLDT(NumberDescriptors : Word) : Word; assembler;
asm
   mov     ax, 0000h
   mov     ax, NumberDescriptors
   int     031h
   jnc     @Ok
   mov     ax, 0
 @Ok:
end;

Function FreeLDT(Selector : Word) : Boolean; assembler;
asm
   mov     ax, 0001h
   mov     bx, Selector
   int     031h
   mov     ax, 1
   jnc     @Ok
   mov     ax, 0
 @Ok:
end;

Function SegmentToDescriptor(Segment : Word) : Word; assembler;
asm
   mov     ax, 0002h
   mov     bx, Segment
   int     31h
   jnc     @Ok
   mov     ax, 0
 @Ok:
end;

Function GetNextSelectorInc : Word; assembler;
asm
   mov     ax, 0003h
   int     031h
end;


Function GetDPMIntVec(IntNumber : Byte) : Pointer; {assembler;}
Var S, O : Word;    { Too lazy to look in the manual! }
Begin
  asm
     mov    ax, 0204h
     mov    bl, IntNumber
     int    031h
     mov    S, cx
     mov    O, dx
  end;
  GetDPMIntVec := Ptr(S, O);
End;


Procedure SetDPMIntVec(IntNumber : Byte; IntVec : Pointer); assembler;
asm
   mov    ax, 0205h
   mov    bl, IntNumber

   les    dx, IntVec
   mov    cx, es

   int    031h
end;

begin
end.
