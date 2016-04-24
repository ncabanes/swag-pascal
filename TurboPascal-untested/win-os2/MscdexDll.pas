(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0073.PAS
  Description: MSCDEX DLL
  Author: P. BELOW
  Date: 09-04-95  10:55
*)


{+------------------------------------------------------------
 | Unit PBCDInt
 |
 | Version: 1.0  Last modified: 02/27/95, 22:09:07
 | Author : P. Below  CIS [100113,1101]
 | Project: Common utilities
 | Description:
 |   This DLL exports a number of functions of the MSCDEX interface
 |	 for the use of other Windows programs. Was originally written
 |	 for a Visual Basic app that needed a method do detect whether
 |	 a given drive is a CD-ROM and whether it contains a CD or not.
 |
 |   Released to public domain
 +------------------------------------------------------------}
Library PBCDINT;

Uses WinTypes, WinProcs, Utils;

Const
  CD_ERROR = -1;
  CD_NOTACDDRIVE = 0;
  CD_DRIVEEMPTY = 1;
  CD_CDFOUND = 2;

(* returns TRUE if MSCDEX is loaded, False otherwise *)
FUNCTION Is_MSCDEX_loaded: BOOLEAN; assembler;
  ASM
    mov AX, $1500   (* MSCDEX installed check *)
    xor BX, BX
    int $2F
    xor ax, ax      (* set default return value to false *)
    or  BX, BX      (* returns bx <> 0 if MSCDEX installed *)
    jz  @no_mscdex
    mov al, TRUE
  @no_mscdex:
  END;

(* returns -1 ( VB True ) if drive is CD-ROM, 0 otherwise. 
   drivenum = 1 for A:, 2 for B: etc. *)
Function CDDriveIsCD( drivenum: Integer): Integer; export;
  Begin
    ASM
      mov AX, $150B (* MSCDEX check drive function *)
      mov CX, drivenum
      sub BX,BX
      int $2F
      cmp bx, $ADAD
      jne @no_cdrom
      or  AX, AX
      jz  @no_cdrom
      mov @result, $FFFF
      jmp @exit
    @no_cdrom:
      mov @result, 0
    @exit:
    END;
  End;


(* returns one of the CD_xxx constants. 
   drivenum = 1 for A:, 2 for B: etc. *)
Function CDDriveStatus( drivenum: integer ): integer; export;
  Var
    RealModeReg: TRealModeReg;
    dwGlobalDosBuffer: LongInt;
  Begin
    If CDDriveIsCD( drivenum ) = 0 Then
      CDDriveStatus := CD_NOTACDDRIVE
    Else Begin
      CDDriveStatus := CD_ERROR;
      { alloc a buffer for the MSCDEX call to put the copyright filename into.
        this has to reside in low dos memory since the function needs a real mode
        pointer in es:bx. We ignore the info put into the buffer. }
      dwGlobalDosBuffer := GlobalDosAlloc(40);
      if (dwGlobalDosBuffer <> 0) then Begin
        { initialize the real mode register structure }
        FillChar(RealModeReg, sizeof(RealModeReg), 0);
        RealModeReg.rmEAX := $1502;
        RealModeReg.rmECX := Longint(drivenum);
        RealModeReg.rmES  := HIWORD(dwGlobalDosBuffer);  { real mode segment }
        RealModeReg.rmEBX := 0;         { offset is zero }

        { simulate the real mode interrupt. we have to jump thru these hoops
          because loading a real mode segment value into a register in
          protected mode is a sure recipe for a GPF. }
        if RealInt($2F, RealModeReg) then
          If (LoWord(RealModeReg.rmCPUFlags) and 1) = 0 Then
            { carry clear, CD drive containing a readable CD }
            CDDriveStatus := CD_CDFOUND
          Else
            If LoWord( RealModeReg.rmEAX ) = $F Then
              { DOS error "invalid drive" }
              CDDriveStatus := CD_NOTACDDRIVE
            Else
              { normally DOS error 1Eh: read fault }
              CDDriveStatus := CD_DRIVEEMPTY;
        GlobalDosFree(LOWORD(dwGlobalDosBuffer));
      End;
    End;
  End;

(* returns the number of CD drives supported by MSCDEX *)
Function CDNumberOfDrives: Integer; export;
  Begin
    ASM
      mov AX, $1500   (* MSCDEX installed check *)
      xor BX, BX
      int $2F
      mov @result, bx
    END;
  End;

(* returns the number of the first drive supported by MSCDEX *)
Function CDFirstDrive: Integer; export;
  Begin
    ASM
      mov AX, $1500   (* MSCDEX installed check *)
      xor BX, BX
      int $2F
      mov @result, cx
    END;
  End;

exports
  CDDriveStatus    index 1,
  CDNumberOfDrives index 2,
  CDFirstDrive     index 3,
  CDDriveIsCD      index 4;

Begin
  (* make the fixed DLL data segment moveable *)
  GlobalPageUnlock( DSeg );
  GlobalReAlloc(DSeg, 0, GMEM_MODIFY or GMEM_MOVEABLE);
End.
