{
> I saw a message from someone that said you had compiled a list of all the
> bugs with BP 7.0... is it possible I could get a copy?

Look around for BP7BUGS2.ZIP.  That's the currently released version.  It's
available for Internet ftp from garbo.uwasa.fi:/pc/turbopas; it's also on
Compuserve, but in the CLMFORUM in the PC Techniques area, because Borland
didn't want it on BPASCAL.  It should also be available on a lot of BBS
systems.
That version isn't quite up to date; here are the newer entries:

54.  SetVisualPage doesn't take effect immediately, so writes to the old page
after the page change may show up on the screen.  Put in a delay or a wait for
the retrace if you intend to draw to the hidden page.

55.  In protected mode when using BGI with linked in fonts, repeated font
changes eventually cause the BGI driver to get messed up and abort.  There's no
problem if the .CHR files are available in the directory given to InitGraph.

56.  In BASM, "dw @variable" will not assemble properly.  BP and BPC abort,
while TURBO and TPC give a wrong answer.
58.  An array of zero length records (e.g. array[boolean] of record end;) gives
a spurious "structure too large error".
59.  Real numbers aren't parsed as the manual describes -- the decimal part and
number part of the scale factor are sometimes optional.  For example, "(1. )"
is a legal expression, but "(1.)" is not; both "1e +1" and "1e+1" are legal,
but have different values (2 and 10).
60.  Hardware interrupts during memory allocations in protected mode can cause
general protection faults.  For details and a patch, see PROTINT.FIX.

61.  Inline procedures are treated like forward declarations:  you can have a
duplicate definition of the same identifier later, and the compiler won't
declare an error unless the form of the declaration is different.  It's the
inline definition that will be used.
62.  The TEMSStream.Done destructor doesn't reset EMSCurhandle to $FFFF, so
that the next TEMSStream may work on the wrong page frame at first.  Fix: After
calling Done, manually set EMSCurhandle to $FFFF.

63.  OutText and OutTextXY don't update the current pointer properly in all
justification modes.  Use MoveTo(GetX,GetY) after a call if you want to be sure
to have CP act properly.
64.  For certain very rare pairs x and y, a $N+ division x/y will only be
accurate to about 4 decimal digits when calculated on a Pentium produced before
Fall 1994.  (This is the famous Pentium FDIV bug, not a BP bug.)

And here's the PROTINT.FIX file:


 #: 252543 S7/DOS Programming  [BPASCAL]
     14-Mar-94  04:01:44
 Sb: #252502-Increment Bug in BP7
 Fm: Peter Petersen 100120,1363
 To: DJ Murdoch 71631,122

DJ,

A protected mode program will crash when the first access to a newly allocated
segment is interrupted by a hardware interrupt. The following test program
demonstrates the bug within a few seconds:
}
   PROGRAM DPMIBug;
   USES
      DOS, CRT;
   CONST
      COM = 1;  { may be set to 1..4 }
      IRQ : ARRAY [1..4] OF byte = (4, 3, 4, 3);
      RXB  = $00; TXB  = $00; IER  = $01; IIR  = $02; LCR  = $03;
      MCR  = $04; LSR  = $05; MSR  = $06; DLL  = $00; DLM  = $01;
   VAR
      Base: Word;
      Count: LongInt;
      OrgHandler: Pointer;

      {$S- ------------------------------}
      PROCEDURE IntCOM; INTERRUPT;
      VAR
         Dummy: Byte;
      BEGIN
         Inc(Count);
         WHILE Port[Base+IIR] <> 1 DO
         BEGIN
            Dummy:=Port[Base+LSR];
            Dummy:=Port[Base+RXB];
            Port[Base+TXB]:=Ord(' ')
         END;
         Port[$20]:=$20
      END;

      {----------------------------------}
      PROCEDURE InitPort(P: Byte; Baud: LongInt);
      CONST
         MaxBaudRate = 115200;
      VAR
         Divider  : Word;
      BEGIN
         Base:=MemW[Seg0040:SizeOf(Word) * (P-1)];
         IF Base = 0 THEN
         BEGIN
            WriteLn('Port COM', P, ' not installed.');
            Halt(1)
         END;
         Port[Base + LCR]:=$80;
         Divider:=(MaxBaudRate + MaxBaudRate MOD Baud) DIV Baud;
         Port[Base + DLL]:=Lo(Divider);
         Port[Base + DLM]:=Hi(Divider);
         Port[Base + LCR]:=(8-5) + ((1-1) SHL 2) + 0;
         GetIntVec(8+IRQ[P], OrgHandler);
         SetIntVec(8+IRQ[P], Addr(IntCom));
         Port[$20+1]:=Port[$20+1] AND NOT (1 SHL IRQ[P]);
         Port[Base + MCR]:=$01 + $01 + $04 + $08;
         Port[Base + IER]:=$0F
      END;

      {----------------------------------}
      PROCEDURE DisableCOMInterrupt (P: Byte);
      BEGIN
         Port[Base + IER]:=0;
         SetIntVec(8+IRQ[P], OrgHandler)
      END;

   VAR
      P: ^Word;
   BEGIN
      System.Test8086:=0;
      {$IFDEF DPMI }
      System.HeapLimit:=0;
      {$ENDIF }
      Count:=0;
      InitPort(COM, 38400);
      Port[Base+TXB]:=Ord(' ');
      WHILE NOT keypressed DO
      BEGIN
         Write(^M, count);
         New(P);
         IF P = NIL THEN WriteLn('error in alloc!');
         IF p^ = 7 THEN ;  { read access }
         Dispose(P)
      END;
      DisableCOMInterrupt(COM);
      WHILE Keypressed DO IF ReadKey = ' ' THEN
   END.
{
The problem can be worked around by disabling interrupts during the first
access to the segment. This is achieved with the following changes to file
WMEM.ASM (part of unit System):
   Comparing files WMEM.ASM and C:\BP70\RTL\SYS\WMEM.ASM
   ***** WMEM.ASM
           OR      AX,AX
           JE      @@2                     ; line number 253
           STC                             ; error and return
           RET
   @@2:    PUSH    AX                      ; save return value
           MOV     AX, 0900H               ; DPMI ints off
           INT     31H                     ; leave int state in AX
           MOV     ES, DX                  ; load seg-reg to load segment
           INT     31H                     ; DPMI restore int state
           POP     AX                      ; restore return value
       ENDIF
   ***** C:\BP70\RTL\SYS\WMEM.ASM
           OR      AX,AX
           JE      @@1
           STC
       ENDIF
   *****

Please note that this fix only affects allocations of the heap. Others (such as
LoadLibrary, InitGraph, GlobalAlloc, etc.) are still affected.
}
