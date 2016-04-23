{
> One part of the program I am writing must call an interrupt (6A I believe
> - it is a networking interrupt).  The interrupt expects ds:dx to point to a
> structure I have to create.  I know my procedures work because I have
> tested them in real mode.  The problem comes when Is witch into protected
> mode.  The interrupt can no longer find the record that I create. How can I
> do this without too much trouble?  I was thinking of using a known segment,
> such as SegB000 (which I am not using right now), and using memcpy to
> copy the record I create to that segment.  Then I could just point ds:
> SegB000 and dx: 0 and do my interrupt.

Here's the unit I use to solve such problems. What you need to do :
- allocate memory in the first megabyte, using AllocateLowMem,
- properly set-up your structure in this memory area, using ProtectedPtr,
- set-up a TRealModeRegs, DS being initialized with the RealSegment of
  the previously allocated memory block,
- call your interrupt with RealModeInt.

From: zlika@chaos2.frmug.fr.net (Raphael Vanney)
}

{ Outils DPMI }
{$x+,g+}

{$IfNDef DPMI}
     You don't need that unit.
{$EndIf}

Unit MinDPMI ;

Interface

Type TRealModeRegs =
     Record
          Case Integer Of
          0: ( EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
               Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word) ;
          1: ( DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
               Case Integer of
                 0: (BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
                 1: (BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                     CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
     End ;

     TLowMemoryBlock     =
     { TLowMemoryBlock is used to point to a memory area within the
       first megabyte, which can thus be accessed both in protected
       and real mode. }
     Record
          ProtectedPtr   : Pointer ;    { pointer valid in protected mode }
          RealSegment    : Word ;       { segment valid in real mode (ofs=0) }
          Size           : Word ;       { size of allocated memory area }
     End ;

Procedure ClearRegs(Var RealRegs : TRealModeRegs) ;

Function RealModeInt(    IntNo          : Byte ;
                         Var RealRegs   : TRealModeRegs) : Boolean ;
{ Important notes :
  . If SS and SP are set to 0, the DPMI server will provide a 30 bytes stack.
  . Calling ClearRegs before initializing registers used for a RealModeInt
    sets SS ans SP to 0.
  }

Procedure AllocateLowMem(Var Pt : TLowMemoryBlock ; Size : Word) ;
Procedure FreeLowMem(Var Pt : TLowMemoryBlock) ;

Procedure SetProtectedIntVec(No : Byte ; p : Pointer) ;
Procedure GetProtectedIntVec(No : Byte ; Var p : Pointer) ;

Implementation

Uses WinAPI ;

Type TDouble   =
     Record
          Lo, Hi    : Word ;
     End ;

Procedure ClearRegs ;
Begin
     FillChar(RealRegs, SizeOf(RealRegs), 0) ;
End ;

Function RealModeInt(    IntNo          : Byte ;
                         Var RealRegs   : TRealModeRegs) : Boolean ;
Assembler ;
Asm
     Mov  AX, $0300
     Mov  BL, IntNo
     XOr  BH, BH
     XOr  CX, CX
     LES  DI, RealRegs
     Int  $31
     Mov  AX, 0               { don't use XOr }
     JNC  @Ok
     Inc  AX
@Ok:
     Or   AX, AX
End ;

Procedure AllocateLowMem ;
Var  Adr  : LongInt ;
Begin
     Adr:=GlobalDOSAlloc(Size) ;
     If Adr=0 Then Size:=0 ;
     Pt.ProtectedPtr:=Ptr(TDouble(Adr).Lo, 0) ;
     Pt.RealSegment:=TDouble(Adr).Hi ;
     Pt.Size:=Size ;
End ;

Procedure FreeLowMem ;
Begin
     GlobalDOSFree(Seg(Pt.ProtectedPtr^)) ;
     FillChar(Pt, SizeOf(Pt), 0) ;           { Fills with NIL }
End ;

Procedure SetProtectedIntVec(No : Byte ; p : Pointer) ; Assembler ;
Asm
     Mov  AX, $0205
     Mov  BL, No
     Mov  CX, TDouble[p].Hi        { Selector }
     Mov  DX, TDouble[p].Lo        { Offset }
     Int  $31
End ;

Procedure GetProtectedIntVec(No : Byte ; Var p : Pointer) ; Assembler ;
Asm
     Mov  AX, $0204
     Mov  BL, No
     Int  $31
     LES  DI, p
     { Mov  ES:[DI], DX }
     { Mov  ES:[DI+2], CX }
     Mov  TDouble[ES:DI].Lo, DX
     Mov  TDouble[ES:DI].Hi, CX
End ;

Function  HugeAdr(Slct : Word ; Ofst : LongInt) : Pointer ;
Assembler ;
Asm
     Mov  AX, SelectorInc
     Mul  TDouble[Ofst].Hi
     Add  AX, Slct                 { First selector of bloc }
     Mov  DX, AX                   { New selector }
     Mov  AX, TDouble[Ofst].Lo     { Low word of offset is the same }
End ;

End.
