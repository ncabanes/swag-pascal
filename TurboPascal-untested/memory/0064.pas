{
 SM> I have a bit of a problem with pascal 7 protected mode,
 SM> I have a TSR (assembly) that does my comms work for me.
 SM> I use intr(regs) with various settings to the registers to collect
 SM> data from the TSR. However when in protected mode my TSR seems
 SM> to be unavailable.

 SM> Do I need to switch to real mode from the app.
 SM> (if so how, I can't find it in the manual).

Yes. This is not documented in the manual, though.

 SM> Do I need to modify my TSR.
 SM> I presume not because I'm sure that the mouse drivers can be got
 SM> to work.

The problem is that interrupt calls in protected mode use
protected mode interrupt handlers. RTM.EXE converts protected
mode interrupts to real mode ones, for 'known' interrupts
(ie INT $21, some functions of INT $10, INT $33 (mouse)...)

What you need is to call the DPMI function that lets you issue
a real mode interrupt. What follows should help you (let me know
if it's not clear enough;-))
}

{ DPMI tools }

{$X+,G+}

{$IfNDef DPMI}
     You don't need that.
{$EndIf}

Unit MinDPMI;

Interface

Type TRealModeRegs =
     Record
          Case Integer Of
          0: ( EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
               Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
          1: ( DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
               Case Integer of
                 0: (BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
                 1: (BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                     CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
     End;

     TLowMemoryBlock     =
     Record
          ProtectedPtr   : Pointer;
          RealSegment    : Word;
          Size           : Word;
     End;

Procedure ClearRegs(Var RealRegs : TRealModeRegs);

Function RealModeInt(    IntNo          : Byte;
                         Var RealRegs   : TRealModeRegs) : Boolean;
{ IMPORTANT notes :
     - If SS and SP in RealRegs are set to 0, the DPMI server provides
       a 30 bytes stack. If not, the specified stack is used.    }

Procedure AllocateLowMem(Var Pt : TLowMemoryBlock; Size : Word);
Procedure FreeLowMem(Var Pt : TLowMemoryBlock);

Procedure SetProtectedIntVec(No : Byte; p : Pointer);
Procedure GetProtectedIntVec(No : Byte; Var p : Pointer);

Implementation

Uses WinAPI;

Type TDouble   =
     Record
          Lo, Hi    : Word;
     End;

Procedure ClearRegs;
Begin
     FillChar(RealRegs, SizeOf(RealRegs), 0);
End;

Function RealModeInt(    IntNo          : Byte;
                         Var RealRegs   : TRealModeRegs) : Boolean;
Assembler;
Asm
     Mov  AX, $0300
     Mov  BL, IntNo
     XOr  BH, BH
     XOr  CX, CX
     LES  DI, RealRegs
     Int  $31
     Mov  AX, 0               { Not XOr }
     JNC  @Ok
     Inc  AX
@Ok:
     Or   AX, AX
End;

Procedure AllocateLowMem;
Var  Adr  : LongInt;
Begin
     Adr:=GlobalDOSAlloc(Size);
     If Adr=0 Then Size:=0;
     Pt.ProtectedPtr:=Ptr(TDouble(Adr).Lo, 0);
     Pt.RealSegment:=TDouble(Adr).Hi;
     Pt.Size:=Size;
End;

Procedure FreeLowMem;
Begin
     GlobalDOSFree(Seg(Pt.ProtectedPtr^));
     FillChar(Pt, SizeOf(Pt), 0);           { Fills with NIL }
End;

Procedure SetProtectedIntVec(No : Byte; p : Pointer); Assembler;
Asm
     Mov  AX, $0205
     Mov  BL, No
     Mov  CX, TDouble[p].Hi        { Selector }
     Mov  DX, TDouble[p].Lo        { Offset }
     Int  $31
End;

Procedure GetProtectedIntVec(No : Byte; Var p : Pointer); Assembler;
Asm
     Mov  AX, $0204
     Mov  BL, No
     Int  $31
     LES  DI, p
     { Mov  ES:[DI], DX }
     { Mov  ES:[DI+2], CX }
     Mov  TDouble[ES:DI].Lo, DX
     Mov  TDouble[ES:DI].Hi, CX
End;

End.
