(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0057.PAS
  Description: Screen Writes
  Author: WILBERT VAN LEIJEN
  Date: 01-27-94  12:25
*)

{
> how do you write a string directly to the screen (the window is not always
> 80 columns)?

A "well behaved" direct screen write routine queries the number of columns on
the screen as returned in the AH register after calling INT 10h, AH=0Fh.
Multiply it by 2 times the number of the Y coordinate (zero-based) and add 2
times the number of the X coordinate (zero-based too).  This yields the
offset into the video segment.  The segment value is 0B000h if AL as returned
by aforementioned call is 7, 0B800h otherwise.  Use the SegB000 and SegB800
selectors for DPMI apps.

Example follows for DOS real mode.  Note: doesn't perform "snow checking".
}

Var
  ScreenSeg   : Word;
  ScreenWidth : Word;
  Columns     : Word;

Procedure WriteXY(x, y : Integer; attr : Byte; s : String); Assembler;

ASM
  CLD
  PUSH   DS
  MOV    ES, [ScreenSeg]         { get start address }
  MOV    AX, [y]
  DEC    AX
  IMUL   [ScreenWidth]
  MOV    DX, [x]
  DEC    DX
  SHL    DX, 1
  ADD    AX, DX
  XCHG   AX, DI

  MOV    AH, [attr]

  LDS    SI, [s]                 { load string to display }
  LODSB
  SUB    CH, CH
  MOV    CL, AL
  JCXZ   @2

 @1:
  LODSB                          { loop - move to screen }
  STOSW
  LOOP   @1
 @2:
  POP    DS
end;

{ unit's initialisation code... }

Begin  { Screen }
  ASM
    MOV    AH, 0Fh
    INT    10h
    PUSH   AX
    MOV    AL, AH
    SUB    AH, AH
    MOV    [ScreenWidth], AX
    MOV    [Columns], AX
    SHL    [ScreenWidth], 1
    POP    AX
    CMP    AL, 7
    JNE    @2

    MOV    Byte Ptr [ScreenSeg+1], 0B0h
    JMP    @4

    { deleted for brevity ... }
   @2:
   @4:
  end;
end.

