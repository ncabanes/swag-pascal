
Unit XMSLib;
{ XMSLIB V2.02  Copyright (c) 1994 by Andrew Eigus Fido Net: 2:5100/33 }
{ XMS Interface for Turbo Pascal version 7.0 }

(*
  XMS termines:

  XMS: eXtended Memory Specification
  XMS gives access to extended memory and noncontiguous/nonEMS
      memory above 640K
  UMB: Upper Memory Block
  HMA: High Memory Area

  Material used:

  C and ASM source of XMS Library (c) by Michael Graff,
  eXtended Memory Specification unit source (c) by Yuval Tal,
  Interrupt List V1.02 (WindowBook) (c) 1984-90 Box Company, Inc.
*)

interface

const

  { XMS function numbers }

  XGetVersion    = $00;
  XRequestHMA    = $01;
  XReleaseHMA    = $02;
  XGlobalE20     = $03;
  XGlobalD20     = $04;
  XLocalE20      = $05;
  XLocalD20      = $06;
  XQuery20       = $07;
  XGetMemSize    = $08;
  XAllocEMB      = $09;
  XFreeEMB       = $0A;
  XMoveEMB       = $0B;
  XLockEMB       = $0C;
  XUnlockEMB     = $0D;
  XGetHandleInfo = $0E;
  XReallocEMB    = $0F;
  XRequestUMB    = $10;
  XReleaseUMB    = $11;

  { XMS_GetVersion parameters }

  XMS = True;  { Get XMS version }
  XMM = False; { Get XMM version }

  { XMS functions return codes }

  xmsrOk            = $00; { Function successful }
  xmsrNotInitd      = $01; { XMS driver not initialized by XMS_Setup }
  xmsrBadFunction   = $80; { Function not implemented }
  xmsrVDiskDetected = $81; { VDisk was detected }
  xmsrA20Error      = $82; { An A20 error occurred }
  xmsrDriverError   = $8E; { A general driver error }
  xmsrUnrecError    = $8F; { Unrecoverable driver error }
  xmsrNoHMA         = $90; { HMA does not exist }
  xmsrHMAInUse      = $91; { HMA is already in use }
  xmsrHMAMinError   = $92; { HMAMIN parameter is too large }
  xmsrHMANotAlloc   = $93; { HMA is not allocated }
  xmsrA20Enabled    = $94; { A20 line still enabled }
  xmsrNoMoreMem     = $A0; { All extended memory is allocated }
  xmsrNoMoreHandles = $A1; { All available XMS handles are allocated }
  xmsrBadHandle     = $A2; { Invalid handle }
  xmsrBadSourceH    = $A3; { Source handle is invalid }
  xmsrBadSourceO    = $A4; { Source offset is invalid }
  xmsrBadDestH      = $A5; { Destination handle is invalid }
  xmsrBadDestO      = $A6; { Destination offset is invalid }
  xmsrBadLength     = $A7; { Length (size) is invalid }
  xmsrBadOverlap    = $A8; { Move has an invalid overlap }
  xmsrParityError   = $A9; { Parity error occurred }
  xmsrBlkNotLocked  = $AA; { Block is not locked }
  xmsrBlkLocked     = $AB; { Block is locked }
  xmsrBlkLCOverflow = $AC; { Block lock count overflowed }
  xmsrLockFailed    = $AD; { Lock failed }
  xmsrSmallerUMB    = $B0; { Only a smaller UMB is available }
  xmsrNoUMB         = $B1; { No UMB's are available }
  xmsrBadUMBSegment = $B2; { UMB segment number is invalid }

type
  THandle = Word; { Memory block handle type }

var
  XMSResult : byte; { Returns the status of the last XMS operation performed }


function XMS_Setup : boolean;
{ This function returns True is the extended memory manager device driver
  is installed in memory and active. True if installed, False if not
  installed. You should call this function first, before any other are
  called so it will setup memory manager for use with your program }

function XMS_GetVersion(OfWhat : boolean) : word;
{ This function returns eighter the version of the extended memory
  specifications version, or the version of the extended memory manager
  device driver version, depends on what you're using as an OfWhat
  parameter (see XMS_GetVersion parameters in const section of the unit).
  The result's low byte is the major version number, and the high byte is
  the minor version number }

function XMS_HMAAvail : boolean;
{ This function obtains the status of the high memory area (HMA).
  If the result is true, HMA exists. If the result is False no HMA exists }

function XMS_AllocHMA(Size : word) : byte;
{ This function allocates high memory area (HMA). Size contains the the
  bytes which are needed. The maximum HMA allocation is 65520 bytes.
  The base address of the HMA is FFFF:0010h. If an application fails
  to release the HMA before it terminates, the HMA becomes unavailable
  to the other programs until the system is restarted. Function returns
  zero (xmsrOk) if the call was successful, or one of the xmsr-error codes
  if the call has failed }

function XMS_FreeHMA : byte;
{ This function releases the high memory area (HMA) and returns zero if
  the call was successful, or one of the xmsr-error codes if the call has
  failed }

function XMS_GlobalEnableA20 : byte;
{ This function enables the A20 line and should only be used by programs
  that have successfully allocated the HMA. The result is zero if the
  call was successful, otherwise, the result is one of the (xmsr)
  return values }

function XMS_GlobalDisableA20 : byte;
{ This function disables the A20 line and should only be used by programs
  that do not own the HMA. The result is zero if the call was successful,
  otherwise, the result is one of the (xmsr) return values }

function XMS_LocalEnableA20 : byte;
{ This function enables the A20 line and should only be used by programs
  that have successfully allocated the HMA. The result is zero if the call
  was successful, otherwise, the result is one of the (xmsr) return values }

function XMS_LocalDisableA20 : byte;
{ This function disables the A20 line and should only be used by programs
  that do not own the HMA. The A20 line should be disabled before the program
  releases control of the system. The result is zero if the call was
  successful, otherwise, the result is one of the (xmsr) return values }

function XMS_QueryA20 : boolean;
{ This function returns the status of the A20 address line. If the result is
  True then the A20 line is enabled. If False, it is disabled }

function XMS_MemAvail : word;
{ This function returns the total free extended memory in kilo-bytes }

function XMS_MaxAvail : word;
{ This function returns the largest free extended memory block in kilo-bytes }

function XMS_AllocEMB(Size : word) : THandle;
{ This function allocates extended memory block (EMB). Size defines the size
  of the requested block in kilo-bytes. Function returns a handle number
  which is used by the other EMB commands to refer to this block. If the call
  to this function was unsuccessful, zero is returned instead of the handle
  number and (xmsr) error code is stored in XMSResult variable }

function XMS_ReallocEMB(Handle : THandle; Size : word) : byte;
{ This function reallocates EMB. Handle is a handle number which was given
  by XMS_AllocEMB. Size defines a new size of the requested block in
  kilo-bytes. Function returns zero if the call was successful, or
  a (xmsr) error code if it failed }

function XMS_FreeEMB(Handle : THandle) : byte;
{ This function releases allocated extended memory. Handle is a handle number
  which was given by XMS_AllocEMB. Note: If a program fails to release its
  extended memory before it terminates, the memory becomes unavailable to
  other programs until the system is restarted. Blocks may not be released
  while they are locked. Function returns zero if the call was successful, or
  a (xmsr) error code if the call has failed }

function XMS_MoveFromEMB(Handle : THandle; var Dest; Count : longint) : byte;
{ This function moves data from the extended memory to the conventional
  memory. Handle is a handle number given by XMS_AllocEMB. Dest is a non-typed
  variable so any kind of data can be written there. Count is the number of
  bytes which should be moved. The state of the A20 line is preserved.
  Function returns zero if the call was successful, or a (xmsr) error code
  if the call has failed }

function XMS_MoveToEMB(Handle : THandle; var Source; Count : longint) : byte;
{ This function moves data from the conventional memory to the extended
  memory. Handle is a handle number given by XMS_AllocEMB. Source is a
  non-typed variable so any kind of data can be written there. Count is
  the number of bytes which should be moved. The state of the A20 line is
  preserved. Function returns zero if the call was successful, or a
  (xmsr) error code if the call has failed }

function XMS_LockEMB(Handle : THandle) : pointer;
{ This function locks a specified EMB. This function is intended for use by
  programs which enable the A20 line and access extended memory directly.
  Handle is a handle number given by XMS_AllocEMB. The result is a 32-bit
  linear address of the locked block or NIL if lock did not succeed. The
  result value is stored in XMSResult variable }

function XMS_UnlockEMB(Handle : THandle) : byte;
{ This function unlocks previously locked blocks (by XMS_LockEMB). After
  the EMB is unlocked the 32-bit pointer returned by XMS_LockEMB becomes
  invalid and should not be used. Handle is a handle number given by
  XMS_AllocEMB. The result value is zero if the call was successful,
  otherwise it is one of the (xmsr) return codes }

function XMS_EMBHandlesAvail(Handle : THandle) : byte;
{ This function returns the number of free handles which are available to
  your program. Handle is a handle number given by XMS_AllocEMB. The result
  value is stored in XMSResult variable }

function XMS_EMBLockCount(Handle : THandle) : byte;
{ This function returns the lock count of a specified EMB. Handle is a handle
  number given by XMS_AllocEMB. If the function returns zero it means that
  the block is not locked. The result value is stored in XMSResult variable }

function XMS_EMBSize(Handle : THandle) : word;
{ This function determines the size of a specified EMB. Handle is a handle
  number given by XMS_AllocEMB. The result is the size of the block in
  kilo-bytes. The result code is stored in XMSResult variable }

function XMS_AllocUMB(Size : word) : longint;
{ This function allocates upper memory blocks (UMBs). Size is the size of
  the block in paragraphs.
  Function returns:
    - segment base of the allocated block in the low-order word
    - actual block size in paragraphs in the high-order word
      In case of an error the high-order word will be the size of the largest
      available block in paragraphs.
  The result code is stored in XMSResult variable }

function XMS_FreeUMB(Segment : word) : byte;
{ This function releases the memory that was allocated by XMS_FreeUMB.
  Segment must contain the segment base of the block which must be
  released. The result value is zero if the call was successful, or
  one of the (xmsr) error codes, otherwise }

function XMS_GetErrorMsg(ErrorCode : byte) : string;
{ This function translates the error code which is returned by all the
  XMS_ functions in the unit from a number to a string. The error code is
  written to the global variable XMSResult (byte). If XMSResult is equal
  to zero then no errors were encountered. For more information about
  the result codes, see (xmsr) constants in the unit's const section }


implementation

type
  TransferRec = record
    TransferSize : longint;
    SourceHandle : THandle;
    SourceOffset : longint;
    DestHandle : THandle;
    DestOffset : longint
  end;

var
  XMSInitd : boolean;
  XMSDriver : procedure;
  TR : TransferRec; { Internal transfer EMB structure }

Function XMS_Setup; assembler;
Asm
  MOV [XMSInitd],False
  MOV AX,4300h        { XMS Driver installation check }
  INT 2Fh
  CMP AL,80h
  JE  @@1             { XMS found }
  MOV AL,False        { else XMS manager not found }
  JMP @@2
@@1:
  MOV AX,4310h        { Get address of XMS driver }
  INT 2Fh
  MOV WORD [XMSDriver],BX    { store offset }
  MOV WORD [XMSDriver+2],ES  { store segment }
  INC [XMSInitd]             { we have init'd our code }
  MOV AL,True
@@2:
End; { XMS_Setup }

Function XMS_GetVersion; assembler;
Asm
  MOV [XMSResult],xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetVersion     { Function to get version }
  CALL [XMSDriver]       { Call the XMS driver }
  MOV [XMSResult],xmsrOk
  CMP OfWhat,XMS         { XMS or XMM version? }
  JE  @@1                { If XMS, it's already in AX }
  MOV AX,BX              { If XMM, it's in BX, so move it to AX }
@@1:
End; { XMS_GetVersion }

Function XMS_HMAAvail; assembler;
Asm
  MOV [XMSResult],xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetVersion     { Function number }
  CALL [XMSDriver]
  MOV [XMSResult],xmsrOk
  MOV AL,DL              { Store result value }
@@1:
End; { XMS_HMAAvail }

Function XMS_AllocHMA; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV DX,Size         { Ammount of HMA wanted }
  MOV AH,XRequestHMA  { Function to allocate HMA }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { No error }
@@1:
  MOV AL,BL           { Store result value }
  MOV [XMSResult],BL  { Save error code }
End; { XMS_AllocHMA }

Function XMS_FreeHMA; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XReleaseHMA  { Function to release HMA }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1             { If error then jump, else }
  XOR BL,BL           { clear error code }
@@1:
  MOV AL,BL
  MOV [XMSResult],BL  { Get return code in XMSResult }
End; { XMS_FreeHMA }

Function XMS_GlobalEnableA20; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGlobalE20   { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { Return no error }
@@1:
  MOV AL,BL
  MOV [XMSResult],BL  { Store result value }
End; { XMS_GlobalEnableA20 }

Function XMS_GlobalDisableA20; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGlobalD20   { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { Return success }
@@1:
  MOV AL,BL
  MOV [XMSResult],BL  { Store result value }
End; { XMS_GlobalDisableA20 }

Function XMS_LocalEnableA20; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XLocalE20    { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { Return no error value }
@@1:
  MOV AL,BL
  MOV [XMSResult],BL  { Store result value }
End; { XMS_LocalEnableA20 }

Function XMS_LocalDisableA20; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XLocalD20    { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { Return no error }
@@1:
  MOV AL,BL
  MOV [XMSResult],BL  { Save result }
End; { XMS_LocalDisableA20 }

Function XMS_QueryA20; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XQuery20     { Function code }
  CALL [XMSDriver]    { Call the XMS driver; result in AL }
@@1:
  MOV [XMSResult],BL  { Store error code value }
End; { XMS_QueryA20 }

Function XMS_MemAvail; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetMemSize  { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
  MOV AX,DX           { AX=Get XMS memory available in K-bytes }
@@1:
  MOV [XMSResult],BL  { Store result value }
End; { XMS_MemAvail }

Function XMS_MaxAvail; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetMemSize  { Function code }
  CALL [XMSDriver]    { Call the XMS driver }
                      { AX=Get XMS maximum memory block available in K-bytes }
@@1:
  MOV [XMSResult],BL  { Store result value }
End; { XMS_MaxAvail }

Function XMS_AllocEMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@2
  MOV AH,XAllocEMB    { Function code }
  MOV DX,Size         { Number of K-Bytes to allocate }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  MOV AX,DX           { Store handle number in AX }
  XOR BL,BL           { Set no error }
  JMP @@2
@@1:
  XOR AX,AX           { Return handle 0 if error }
@@2:
  MOV [XMSResult],BL
End; { XMS_AllocEMB }

Function XMS_ReallocEMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XReallocEMB  { Function code }
  MOV DX,Handle       { Handle number }
  MOV BX,Size         { New size wanted in K-Bytes }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { There's no error }
@@1:
  MOV AL,BL           { Return result value }
  MOV [XMSResult],BL  { Store error code }
End; { XMS_ReallocEMB }

Function XMS_FreeEMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XFreeEMB     { Function code }
  MOV DX,Handle       { Set handle number in DX }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL           { No error }
@@1:
  MOV AL,BL           { Return result value }
  MOV [XMSResult],BL  { Store error code }
End; { XMS_FreeEMB }

Function XMS_MoveFromEMB; assembler;
Asm
  PUSH DS
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV CX,WORD PTR [Count]
  MOV TR.WORD PTR [TransferSize],CX
  MOV CX,WORD PTR [Count+2]
  MOV TR.WORD PTR [TransferSize+2],CX
  MOV CX,Handle
  MOV TR.SourceHandle,CX
  MOV WORD PTR [TR.SourceOffset],0
  MOV WORD PTR [TR.SourceOffset+2],0
  MOV TR.DestHandle,0
  LES SI,Dest
  MOV WORD PTR [TR.DestOffset],SI
  MOV WORD PTR [TR.DestOffset+2],ES
  MOV AH,XMoveEMB
  MOV DX,SEG TR
  MOV DS,DX
  MOV SI,OFFSET TR
  CALL [XMSDriver]
  OR  AX,AX
  JZ  @@1
  XOR BL,BL
@@1:
  MOV AL,BL
  MOV [XMSResult],BL
  POP DS
End; { XMS_MoveFromEMB }

Function XMS_MoveToEMB; assembler;
Asm
  PUSH DS
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV CX,WORD PTR [Count]
  MOV TR.WORD PTR [TransferSize],CX
  MOV CX,WORD PTR [Count+2]
  MOV TR.WORD PTR [TransferSize+2],CX
  MOV TR.SourceHandle,0
  LES SI,Source
  MOV WORD PTR [TR.SourceOffset],SI
  MOV WORD PTR [TR.SourceOffset+2],ES
  MOV CX,Handle
  MOV TR.DestHandle,CX
  MOV WORD PTR [TR.DestOffset],0
  MOV WORD PTR [TR.DestOffset+2],0
  MOV AH,XMoveEMB
  MOV DX,SEG TR
  MOV DS,DX
  MOV SI,OFFSET TR
  CALL [XMSDriver]
  OR  AX,AX
  JZ  @@1
  XOR BL,BL
@@1:
  MOV AL,BL
  MOV [XMSResult],BL
  POP DS
End; { XMS_MoveToEMB }

Function XMS_LockEMB; assembler;
Asm
  CMP [XMSInitd],True
  JNE @@1             { if not initialized, return the NIL pointer }
  MOV AH,XLockEMB     { Function code }
  MOV DX,Handle       { Handle in DX }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX           { Was the call successful? }
  JNZ @@2             { Yep, so jump and return pointer }
@@1:
  XOR AX,AX
  XOR DX,DX           { Return NIL }
  MOV [XMSResult],xmsrLockFailed
  JMP @@3
@@2:
  MOV AX,BX           { Offset in AX, Segment in DX }
  MOV XMSResult,xmsrOk
@@3:
End; { XMS_LockEMB }

Function XMS_UnlockEMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XUnlockEMB   { Function code }
  MOV DX,Handle       { Handle in DX }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL
@@1:
  MOV AL,BL
  MOV [XMSResult],BL
End; { XMS_UnlockEMB }

Function XMS_EMBHandlesAvail; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetHandleInfo { Function code }
  MOV DX,Handle
  CALL [XMSDriver]
  OR  AX,AX
  JZ  @@1
  MOV AL,BL             { Save number of free handles }
  XOR BL,BL
@@1:
  MOV [XMSResult],BL
End; { XMS_EMBHandlesAvail }

Function XMS_EMBLockCount; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetHandleInfo
  MOV DX,Handle         { Handle in DX }
  CALL [XMSDriver]
  OR  AX,AX
  JZ  @@1
  MOV AL,BH             { Save lock count }
  XOR BL,BL
@@1:
  MOV [XMSResult],BL
End; { XMS_EMBLockCount }

Function XMS_EMBSize; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XGetHandleInfo
  MOV DX,Handle
  CALL [XMSDriver]
  OR  AX,AX
  JZ  @@1
  MOV AX,DX             { Save EMB size in K-bytes }
  XOR BL,BL
@@1:
  MOV [XMSResult],BL
End; { XMS_EMBSize }

Function XMS_AllocUMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XRequestUMB  { Function code }
  MOV DX,Size         { Number of paragraphs we want }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  MOV AX,BX           { Return segment of UMB in low-order word }
                      { Actual block size in high-order word }
  XOR BL,BL
@@1:
  MOV [XMSResult],BL
End; { XMS_AllocUMB }

Function XMS_FreeUMB; assembler;
Asm
  MOV BL,xmsrNotInitd
  CMP [XMSInitd],True
  JNE @@1
  MOV AH,XReleaseUMB  { Function code }
  MOV DX,Segment      { Segment of UMB to release }
  CALL [XMSDriver]    { Call the XMS driver }
  OR  AX,AX
  JZ  @@1
  XOR BL,BL
@@1:
  MOV AL,BL
  MOV [XMSResult],BL
End; { XMS_FreeUMB }

Function XMS_GetErrorMsg;
var S : ^String;
Begin
  New(S);
  case ErrorCode of
    xmsrNotInitd:      S^ := 'XMS driver not initialized';
    xmsrBadFunction:   S^ := 'Function not implemented';
    xmsrVDiskDetected: S^ := 'VDisk has detected';
    xmsrA20Error:      S^ := 'An A20 error occurred';
    xmsrDriverError:   S^ := 'A general driver error';
    xmsrUnrecError:    S^ := 'Unrecoverable driver error';
    xmsrNoHMA:         S^ := 'HMA does not exist';
    xmsrHMAInUse:      S^ := 'HMA is already in use';
    xmsrHMAMinError:   S^ := 'HMAMIN parameter is too large';
    xmsrHMANotAlloc:   S^ := 'HMA is not allocated';
    xmsrA20Enabled:    S^ := 'A20 line still enabled';
    xmsrNoMoreMem:     S^ := 'All extended memory is allocated';
    xmsrNoMoreHandles: S^ := 'All available XMS handles are allocated';
    xmsrBadHandle:     S^ := 'Invalid block handle';
    xmsrBadSourceH:    S^ := 'Block source handle is invalid';
    xmsrBadSourceO:    S^ := 'Block source offset is invalid';
    xmsrBadDestH:      S^ := 'Block destination handle is invalid';
    xmsrBadDestO:      S^ := 'Block destination offset is invalid';
    xmsrBadLength:     S^ := 'Block length is invalid';
    xmsrBadOverlap:    S^ := 'Move operation has an invalid overlap';
    xmsrParityError:   S^ := 'Parity error';
    xmsrBlkNotLocked:  S^ := 'Block is not locked';
    xmsrBlkLocked:     S^ := 'Block is locked';
    xmsrBlkLCOverflow: S^ := 'Block lock count overflowed';
    xmsrLockFailed:    S^ := 'Lock failed';
    xmsrSmallerUMB:    S^ := 'Too large UMB requested';
    xmsrNoUMB:         S^ := 'No UMB''s are available';
    xmsrBadUMBSegment: S^ := 'UMB segment number is invalid';
    else S^ := 'Unknown error'
  end;
  XMS_GetErrorMsg := S^;
  Dispose(S)
End; { XMS_GetErrorMsg }

Begin
  { Initialize global variables }
  XMSInitd := False;
  XMSResult := xmsrOk
End. { XMSLib }

{ ***** XMSDEMO.PAS ***** }

Program XMSLibDemo;
{ Copyright (c) 1994 by Andrew Eigus              Fido Net: 2:5100/33 }
{ XMS Interface V2.02 for Turbo Pascal version 7.0 demonstration program }

(*
  Tested on IBM 486 SX 33Mhz with 4MB RAM with the following configuration:
     1)  HIMEM.SYS  (MS-DOS 6.2 XMS memory manager)
     2)  HIMEM.SYS  (MS-DOS 6.2 XMS memory manager)
  EMM386.EXE (MS-DOS 6.2 EMS memory manager)

  If any inpredictable errors occur in your system while running this demo,
  please be so kind to inform me:

 AndRew's BBS Phone: 003-712-559777 (Riga, Latvia) 24h 2400bps
 Voice Phone:     003-712-553218
 Fido Net:     2:5100/20.12
*)

{X+}{$R-}

uses XMSLib;

type
  TMsg = array[1..14] of Char;

  TUMBAllocRec = record
    Size : word;
    SegAddr : word
  end;

const
  Message1 : TMsg = 'First message ';
  Message2 : TMsg = 'Second message';

  YesNo : array[boolean] of string[3] = ('No', 'Yes');
  A20State : array[boolean] of string[8] = ('Disabled', 'Enabled');

var
  Version, Memory, Handle, BlockLength : word;
  Locks, FreeHandles : byte;
  HMAAvailable : boolean;
  Address : pointer;
  UMB : longint;

Function Hex(Num : longint; Places : byte) : string;
const HexTab : array[0..15] of Char = '0123456789ABCDEF';
var
  HS : string[8];
  Digit : byte;
Begin
  HS[0] := Chr(Places);
  for Digit := Places downto 1 do
  begin
    HS[Digit] := HexTab[Num and $0000000F];
    Num := Num shr 4
  end;
  Hex := HS
End; { Hex }

Function Check(Result : byte; Func : string) : byte;
Begin
  if Result <> xmsrOk then
    WriteLn(Func, ' returned ',
      Hex(Result, 2), 'h (', Result, '): ', XMS_GetErrorMsg(Result));
  Check := Result
End; { Check }

Procedure ShowA20State;
var State : boolean;
Begin
  State := XMS_QueryA20;
  if Check(XMSResult, 'XMS_QueryA20') = xmsrOk then
    WriteLn('A20 state: ', A20State[State])
End; { ShowA20State }

Procedure Wait4Return;
Begin
  WriteLn;
  WriteLn('Press ENTER to continue');
  ReadLn
end; { Wait4Return }


Begin
  WriteLn('XMS Library V2.02 Demonstration program by Andrew Eigus'#10);
  if XMS_Setup then
  begin

    Version := XMS_GetVersion(XMS);
    if Check(XMSResult, 'XMS_GetVersion(XMS)') = xmsrOk then
      WriteLn('XMS version ', Hi(Version), '.', Lo(Version), ' present');
    Version := XMS_GetVersion(XMM);
    if Check(XMSResult, 'XMS_GetVersion(XMM)') = xmsrOk then
      WriteLn('XMM version ', Hi(Version), '.', Lo(Version), ' detected');
    HMAAvailable := XMS_HMAAvail;
    if Check(XMSResult, 'XMS_HMAAvail') = xmsrOk then
      WriteLn('HMA Available: ', YesNo[HMAAvailable]);

    WriteLn;
    Memory := XMS_MemAvail;
    if Check(XMSResult, 'XMS_MemAvail') = xmsrOk then
      WriteLn('Free XMS memory available: ', Memory, ' KB')
    else
      if XMSResult = xmsrNoMoreMem then Halt(xmsrNoMoreMem);
    Memory := XMS_MaxAvail;
    if Check(XMSResult, 'XMS_MaxAvail') = xmsrOk then
      WriteLn('Largest XMS memory block: ', Memory, ' KB');

    WriteLn;
    if HMAAvailable then
      if Check(XMS_AllocHMA($FFFF), 'XMS_AllocHMA') = xmsrOk then
      begin
        WriteLn('HMA: Block allocated');
        if Check(XMS_FreeHMA, 'XMS_FreeHMA') = xmsrOk then
          WriteLn('HMA: Block released')
      end;

    Wait4Return;

    WriteLn('XMS data transfer test'#10);
    WriteLn('Message1: ', Message1);
    WriteLn('Message2: ', Message2);

    Handle := XMS_AllocEMB(1);
    if Check(XMSResult, 'XMS_AllocEMB') = xmsrOk then
    begin
      WriteLn('1 KB EMB allocated. Handle number: ', Hex(Handle, 4), 'h');
      { Now copy our little Message1 to extended memory }
      if Check(XMS_MoveToEMB(Handle, Message1, SizeOf(TMsg)),
        'XMS_MoveToEMB') = xmsrOk then WriteLn('Transfer to XMS: OK');
      { Now copy it back to the second string }
      if Check(XMS_MoveFromEMB(Handle, Message2, SizeOf(TMsg)),
        'XMS_MoveFromEMB') = xmsrOk then WriteLn('Transfer from XMS: OK');
      WriteLn('Message1: ', Message1);
      WriteLn('Message2: ', Message2);
      WriteLn;
      if Check(XMS_ReallocEMB(Handle, 2),
        'XMS_ReallocEMB') = xmsrOk then
        WriteLn('EMB reallocated. New size: 2 KB');
      WriteLn;
      Address := XMS_LockEMB(Handle);
      if Check(XMSResult, 'XMS_LockEMB') = xmsrOk then
        WriteLn('EMB locked at linear memory address ',
          Hex(Longint(Address), 8), 'h');

      WriteLn;
      FreeHandles := XMS_EMBHandlesAvail(Handle);
      if Check(XMSResult, 'XMS_EMBHandlesAvail') = xmsrOk then
        WriteLn('EMB Handles available: ', FreeHandles);
      Locks := XMS_EMBLockCount(Handle);
      if Check(XMSResult, 'XMS_EMBLockCount') = xmsrOk then
        WriteLn('EMB Lock count: ', Locks);
      BlockLength := XMS_EMBSize(Handle);
      if Check(XMSResult, 'XMS_EMBSize') = xmsrOk then
        WriteLn('EMB Length: ', BlockLength, ' KB');

      WriteLn;
      if Check(XMS_UnlockEMB(Handle), 'XMS_UnlockEMB') = xmsrOk then
          WriteLn('EMB unlocked');

      WriteLn;
      if Check(XMS_FreeEMB(Handle), 'XMS_FreeEMB') = xmsrOk then
        WriteLn('EMB released');

      Wait4Return
    end;

    UMB := XMS_AllocUMB($FFFF);
    if Check(XMSResult, 'XMS_AllocUMB') = xmsrOk then
    begin
      WriteLn('UMB allocated at segment base ',
        Hex(TUMBAllocRec(UMB).SegAddr, 4), 'h');
      WriteLn('Actual size: ', TUMBAllocRec(UMB).Size, ' paragraphs'#10);
      if Check(XMS_FreeUMB(TUMBAllocRec(UMB).SegAddr),
        'XMS_FreeUMB') = xmsrOk then WriteLn('UMB released')
    end;
  end else WriteLn('XMS not present.')
End.
