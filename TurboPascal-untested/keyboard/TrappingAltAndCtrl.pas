(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0037.PAS
  Description: Trapping ALT and CTRL
  Author: WILBERT VAN LEIJEN
  Date: 08-27-93  21:29
*)

{
WILBERT VAN LEIJEN

> HEy, I have been using some routines to check if certain keys are pressed,
> but I can't figure out how to test For ALT and CTRL key combinations.
}

{$G+}

Uses
  Dos, Crt;

Var
  KeyHandlerProc : Procedure;
  Int15Vector    : Pointer;

Const
  AltStatus  : Array [Boolean] of String[5] = ('     ', ' ALT ');
  CtrlStatus : Array [Boolean] of String[6] = ('      ', ' CTRL ');

Procedure KeyHandler; Far;
Var
  AltKey  : Boolean;
  CtrlKey : Boolean;
  WhereXY : Record
    x, y : Byte;
  end;

begin
  AltKey  := False;
  CtrlKey := False;

  Asm
    MOV AH, 2
    INT 16h
    CMP AL, 8
    JNE @1
    INC [AltKey]
   @1:
    CMP AL, 4
    JNE @2
    INC [CtrlKey]
   @2:
  end;

  WhereXY.x := WhereX;
  WhereXY.y := WhereY;
  GotoXY(66, 25);
  Write(AltStatus[AltKey], ' ', CtrlStatus[CtrlKey]);
  GotoXY(WhereXY.x, WhereXY.y);
end;  { KeyHandler }

{ This INT 15h handler is called every time a key is pressed -
  provided you're not running this Program on an XT-class machine }

Procedure TrapKeyboard; Assembler;
Asm
  PUSH   BX
  PUSH   DS
  PUSHF
  MOV    BX, SEG @Data
  MOV    DS, BX
  CMP    AH, 4Fh
  JNE    @ChainInt15
  PUSH   ES
  PUSHA
  CALL   [KeyHandlerProc]
  POPA
  POP    ES

 @ChainInt15:
  PUSHF
  CALL   [Int15Vector]
  POPF
  POP    DS
  POP    BX
  IRET
end;  { TrapKeyboard }

begin
  GetIntVec($15, Int15Vector);
  KeyHandlerProc := KeyHandler;
  SetIntVec($15, @TrapKeyboard);
  ReadLn;
  SetIntVec($15, Int15Vector);
end.

