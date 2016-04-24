(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0083.PAS
  Description: DPMI unit
  Author: SWAG SUPPORT TEAM
  Date: 05-27-95  10:35
*)


Unit DMPI;

Interface

type
  TRealModeReg = RECORD
    rmEDI, rmESI, rmEBP, Reserved, rmEBX, rmEDX, rmECX, rmEAX: LongInt;
    rmCPUFlags, rmES, rmDS, rmFS, rmGS, rmIP, rmCS, rmSP, rmSS: WORD
  END;
  PRealModeReg = ^TRealModeReg;

Function RealInt ( intnum: BYTE; Var RealModeReg: TRealModeReg): Boolean;

Implementation

   (*************************************************************************
 / RealInt()
 /
 / Simulate an interrupt in real mode using DPMI function 0300h
 / When the interrupt is simulated in real mode, the registers will
 / contain the values in lpRealModeReg.  When the interrupt returns,
 / lpRealModeReg will contain the values from real mode.
 /
 /*************************************************************************)


Function RealInt ( intnum: BYTE; Var RealModeReg: TRealModeReg): Boolean; assembler;
   asm
       mov  ax, 0300h  (* Simulate Real Mode Interrupt *)
       mov  bl, intnum
       mov  bh, 0
       mov  cx, 0
       les  di, RealModeReg
       int  31h
       jc   @Error
       mov  ax, TRUE    (* All is well, return TRUE *)
       jmp  @Exit
   @Error:
       mov  ax, FALSE   (* Hmm, Mr. DPMI unhappy, return FALSE *)
   @Exit:
   End;


End.
