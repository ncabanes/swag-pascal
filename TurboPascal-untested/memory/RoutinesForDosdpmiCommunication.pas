(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0089.PAS
  Description: Routines for DOS/DPMI communication
  Author: PETER LOUWEN
  Date: 02-21-96  21:03
*)

{
 XDR> I'm currently developing an application that I would gladly spread in
 XDR> protected mode... But could someone explain to me what can I NOT do in
 XDR> DPMI pascal

This is actually explained quite clearly in Ch. 17 of the BP7 Language Guide.

The main difference is that memory is no longer yours to do with as you
please; you can only "touch" memory that has been allocated to your program.
This is where the "protected" in "protected mode" stems from.

The following is a rather simplified view of things, but it does illustrate
the general priciple:

In pmode a pointer such as ptr($B800, 0) does NOT point to memory location
$B800:0000. The segment part (called the "selector" in pmode), $B800,
is treated as an index into a system maintained table, which *does* contain
the actual physical memory location (called the "base"), and the number of
bytes allocated to that base (called the "limit"). This table is unavailable
to your program.
At the start of your program, all entries in this table are marked "not in
use" and therefore illegal.
During program execution, whenever you attempt to read or write Mem[S:O],
the CPU checks (in that table) to see if S is a legal index (i.e., if S is
a valid base), and if so, whether O is within the limit of that base.
If at least one of these checks fail, the memory access is invalid, and you
will be presented with run time error 216 a.k.a. the dreaded General
Protection Failure (GPF) a.k.a. Exception $0D.

 XDR> Ag: I can no more acces the screen at an Obsolute $b800:000 but at
 XDR> absolute Segb800:000, why?

Btw: ABSOLUTE SegB800:0 won't compile.
Use "mem[SegB800:0]" instead, or use a pointer, like so:

VAR VidMemStart: pointer;
BEGIN VidMemStart:=ptr(SegB800, 0) END;

and manipulate video memory using VidMemStart^.

The reason should now be clear: $B800 is almost certainly *not* a valid
selector. Since no one has asked the DPMI server to associate selector $B800
with a physical memory location, it is illegal.
You *can* use SegB800, as your program startup code asks the DPMI server to
associate SegB800 with video memory.

You should not pass pmode pointers to real mode routines nor the other way
around (they are invalid in the "receiving" mode).
It can be done, but you'll need the cooperation of the DPMI server.
Find a DPMI unit (I can't post mine, as it is commercial). Below you'll
find such a unit - I've never used it, so no guarantees.

Notes: - if you attempt to write to code segments, or read from invalid
         pointers, a GPF will result.
       - if you attempt to read an invalid stack element, you will receive
         an Exception $0C (Stack Fault), which BP will convert to run time
         error 202.
       - Exception 6 (Invalid Opcode) is not related to memory accesses.
         It means the CPU has received a couple of bytes which it cannot
         interpret as a valid instruction.
       - prior to distribution, be sure to read file DPMIUSER.DOC.
         You can find that file in archive DOC.ZIP on your BP7 distribution
         disks.

The above three exceptions are likely the only ones you'll see.

Happy programming,

Peter. }

===== Start of includefile FDEFINE.DEF =====

{ Include file FDEFINE.DEF - general include file for the unit systems
                             conditional defines }

 (***************************************************************************

            RELEASE 1.04 - as contained in the file PRUS100.LZH
                by Orazio Czerwenka, 2:2450/540.55, GERMANY

               --------------------------------------------
                organized for Fido's PASCAL related echoes
               --------------------------------------------

     06/21/1994 to --/--/---- by Orazio Czerwenka, 2:2450/540.55, GERMANY

 ***************************************************************************)

{ ==========================================================================
  WHICH VERSION OF TURBO PASCAL DO YOU COMPILE WITH ?
  THE DEFAULT IS TURBO PASCAL 6.0x !
  ========================================================================== }

  { The following conditional defines do not yet have any effect, ... }

  {.$define ver30}       { Turbo Pascal 3.0x }
  {.$define ver40}       { Turbo Pascal 4.0x }
  {.$define ver50}       { Turbo Pascal 5.0x }
  {.$define ver55}       { Turbo Pascal 5.5x }
  {$define ver60}       { Turbo Pascal 6.0x }
  {.$define ver70}       { Turbo/Borland Pascal 7.0x }

  { ... these commenting lines will be deleted once that should be changed. }


{ ==========================================================================
  WHAT LANGUAGE DO YOU WANT YOUR PROGRAMS TO DISPLAY MESSAGES IN BY DEFAULT?
  ========================================================================== }

  {$define English}
  {.$define German}


{ ==========================================================================
  ACTIVATE THE FOLLOWING DISABLED COMPILER DIRECTIVE IF YOU WANT TO BE ABLE
  TO USE THE UNIT SYSTEM FROM WITHIN OVERLAYS !
  ========================================================================== }

  {.$O+}   { This tells your compiler - if activated - to produce a unit
             that will be allowed to be used from within overlays. }

  {$IFOPT O+}
    {$DEFINE Overlays}                                    { easier to read }
  {$ENDIF}

{ ==========================================================================
  WHAT KIND OF PROCESSOR ARE YOU COMPILING FOR ? SOME CPU DEPENDEND DEFINES.
  ========================================================================== }

  (* Some of the units use inline assembler designed to work on machines
     with at least 80286 processor, so generally you can tell your compiler
     to produce 80286 code anyway.
  *)

  {$G+}   { This tells - if activated - your compiler to produce 80286
            code. }

  (* In addition you might want to specify one of the following higher
     processors, if you want your programmes ONLY to run on THESE and
     higher machines.
  *)

  { The following conditional defines do not yet have any effect, ... }

  {.$define cpu386}           { Use specific code for 80386 machines }
  {.$define cpu486}           { Use specific code for 80486 machines }

  { ... these commenting lines will be deleted once that should be changed. }

{ -------------------------------------------------------------------------- }

  (* Define one of the following CRT replacements (or CRT) for use by the
     units FTMODE and FSPEAKER, depending on what you've got.
     If you don't have a replacement, take the CRT, it is a bit slower but
     it should work as well.
     -----------------------------------------------------------------------
     NOTICE THAT THE UNIT FCRT SHOULD ALSO BE INCLUDED IN THIS FILE PACKAGE!
     -----------------------------------------------------------------------
     Note that at least one of those units shoul be defined to be used !
     By default this should be the unit FCRT.

     In case you should also want to use TP CRT's screen handling related
     functions in addition to the routines provided by FCONDRV and FCRT
     you probably will have to define the usage of TP's CRT here.
     By default the usage of TP's CRT is *NOT* defined in order to avoid
     smaller drawbacks in speed and unnecessarilly 'blown up' code.
  *)

  {$define FCRT}
  {.$define CRT}
  {.$define CRT2}



{ -------------------------------------------------------------------------- }

  (* The following conditional define will specify wether the unit(s) FTMODE
     will use the BIOS for the 80x25 mode or try programming it by hand. You
     should leave it inactivated, since who would want to force the user to
     use 80x25 ? I (MM) implemented it, since on my system, mode 3 corresponds
     to 90x28 through a TSR, and a small program would have helped here :-)
     Note that forcing will only take place if FTMODE's SetVideoMode(3) does
     not result in an 80 column mode.
  *)

{.$define UseBIOS}



{ -------------------------------------------------------------------------- }

===== End   of includefile FDEFINE.DEF =====

===== Start of unit FDPMI =====

Unit FDPMI; { routines for DOS/DPMI communication }
 (***************************************************************************

           RELEASE 1.00 - as contained in the file PRUS100.LZH
                 by Max Maischein, 2:244/1106.17, GERMANY

               --------------------------------------------
                organized for Fido's PASCAL related echoes
               --------------------------------------------

     06/15/1994 to --/--/---- by Max Maischein, 2:244/1106.17, GERMANY

           As far as third party copyrights are not violated this
           source code is hereby placed to the public domain. Use
           it whatever way you want, but use AT YOUR OWN RISK.

           In case you should modify the source rather send your
           modifications to the unit's current organizer (see above for
           NM address) than to spread it on your own. This will help to
           keep the unit updated and grant a certain standard to all
           other users as well.

           The unit is currently still under work. So it might greatly
           benefit of your participation.

           Those who contributed to the following piece of source,
           listed in alphabethical order:
        ================================================================
           Jochen Magnus (SEGDEMO.PAS), Max Maischein (collecting,
           documenting, testing etc.), Raphael Vanney (program CHARSET
           .PAS)
        ================================================================
           YOUR NAME WILL APPEAR HERE IF YOU CONTRIBUTE USEFUL SOURCE.

 ***************************************************************************)

{$I FDEFINE.DEF}

Interface

Type TRealModeRegs  =
     Record
          Case Integer Of
          0: ( EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
               Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word) ;
          1: ( DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
               Case Integer of
                 0: (BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
                 1: (BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                     CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
     End;
(* Use these and RealModeInt() instead of Registers and Intr() under DPMI *)

Type TLongRec = Record
       Case Byte of
         0 : ( L : LongInt );
         1 : ( wLo : Word;
               wHi : Word; );
         2 : ( iLo : Integer;
               iHi : Integer );
     End;

Function RealModeInt( IntNo : Byte; Var RealRegs : TRealModeRegs) : Boolean;
(* Replacement for Intr(), returns False on error *)

Function NewSelector( Base, Limit : Longint) : Word;
(* Returns a new selector for the range [Base - (Base+Limit)]        *)
(* Base is the linear address of the memory location you want to use *)
(* You must free this selector after use with FreeSelector()         *)

Function AllocateLowMem( Size : Word; var PMPointer : Pointer ) : Word;
(* Allocates some memory in the first MB *)
(* Returns a pointer to it and a segment to pass to the real mode routine *)

Procedure FreeLowMem(Var PMPointer : Pointer );
(* Frees memory allocated with AllocateLowMem() *)

Implementation
Uses WinAPI;

Function RealModeInt( IntNo : Byte; Var RealRegs : TRealModeRegs) : Boolean;
Assembler;
{ This function switches to real mode and issues the specified interrupt,
  after filling the registers with values stored in RealRegs.
  If SS/SP as specified in RealRegs are Nil, the DPMI server provides a
  small stack. For more discution of this, see Ralf Brown's INTERxx.ZIP }
Asm
                        mov     ax, 0300h       { DPMI function "simulate real
mode int" }
                        mov     bl, [IntNo]
                        xor     bh, bh          { 0 as requested by DPMI v1.0
}                        xor     cx, cx          { bytes to copy onto "remote"
stack }
                        les     di, [RealRegs]
                        int     31h             { Returns CF set on error }
                        mov     ax, 1           { assume everything went OK }
                        sbb     ax, 0           { if carry set, decrement ax }
                                                { to signal an error }
End;

Function NewSelector(Base,Limit:longint) : Word;
Var Sel : Word;
Begin
  Sel := AllocSelector(0);
  If (sel<>0) and (setSelectorBase(sel,base)=sel) and (setSelectorLimit(sel,
limit)=0)
    then newSelector:=sel
    else newSelector:=0;
End;

Function AllocateLowMem( Size : Word; var PMPointer : Pointer ) : Word;
{ This procedure allocates memory in the first megabyte, and returns two
  ways of accessing it : a pointer valid in protected mode, and the
  segment part of a pointer valid in real mode ; offset part is always 0 }

Var  Adr  : LongInt ;
Begin
  Adr:=GlobalDOSAlloc(Size) ;
  If Adr=0 then RunError( 0 );
  PMPointer := Ptr( TLongRec(Adr).wLo, 0);
  AllocateLowMem := TLongRec(Adr).wHi;
End ;

Procedure FreeLowMem(Var PMPointer : Pointer ) ;
{ Frees memory allocated with AllocateLowMem }
Begin
  GlobalDOSFree(Seg( PMPointer^ ));
  PMPointer := nil;
End ;
{$IFnDEF DPMI}
{$IFnDEF Windows}
  You are compiling WHAT ??
{$ENDIF}
{$ENDIF}
End.

===== End   of unit FDPMI =====

