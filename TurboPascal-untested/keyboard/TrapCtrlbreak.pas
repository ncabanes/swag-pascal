(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0019.PAS
  Description: Trap CTRL-BREAK
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{  >> What sort of code do I need to include in a pascal Program (Writen in
  >> Borland Pascal 6.0) to disable CTRL-BREAK and CTRL-C?
}
Unit CAD;

Interface

Uses Dos;

Var
  Int9Handler  : Pointer;

Procedure InterceptCtrlAltDel;
Procedure RestoreCAD;

  Implementation

Procedure InterceptCtrlAltDel; Assembler;

Const
  Ctrl         = 4;
  Alt          = 8;
  Del          = $53;
  KbdPort      = $60;                  { Keyboard port }
  KbdCtrlPort  = $61;                  { Keyboard control port }
  PIC          = $20;                  { 8259 Interrupt controller }
  EOI          = $20;                  { end-of-interrupt }

  Asm

  PUSH   AX
  PUSH   DS
  MOV    AX, SEG @Data
  MOV    DS, AX
  STI
  in     AL, KbdPort
  and    AL, 01111111b
  CMP    AL, Del
  JNE    @2

  @1 :     MOV    AH, 2               { BIOS Get keyboard flags service }
  inT    16h
  TEST   AL, Ctrl + Alt
  JNZ    @3

  @2 :     PUSHF
  CALL   [Int9Handler]
  JMP    @4

  @3 :     in     AL, KbdCtrlPort
  MOV    AH, AL
  or     AL, 10000000b
  OUT    KbdCtrlPort, AL
  XCHG   AH, AL
  OUT    KbdCtrlPort, AL
  CLI

  MOV    AL, EOI
  OUT    PIC, AL
  @4 :     POP    DS
  POP    AX
  IRET                       { make sure we return correctly }
end;  { InterceptCtrlAltDel }

Procedure RestoreCAD;

begin
  SETinTVEC (9, Int9Handler);
end;  { RestoreCAD }


begin
  GETinTVEC (9, Int9Handler);
  SETinTVEC (9, @InterceptCtrlAltDel);
end. {Unit CAD}


