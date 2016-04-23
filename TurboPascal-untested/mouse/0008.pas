
UNIT AMOUSE; (* mouse/keyboard Routines *)

INTERFACE

CONST
          MouseInstalled : Boolean = FALSE;

FUNCTION  InitMouse : WORD;
PROCEDURE ShowMouseCursor;
PROCEDURE HideMouseCursor;
PROCEDURE SetMouseWindow (X1, Y1, X2, Y2 : WORD);
PROCEDURE GetMousePos (VAR X, Y, button : WORD);
PROCEDURE SetMousePos (X, Y : WORD);
PROCEDURE GetButtonPressInfo (VAR X, Y, Button, NumberOfPresses : WORD);
PROCEDURE GetButtonRelInfo (VAR X, Y, Button, NumberOfReleases : WORD);
PROCEDURE KeyOrButton (VAR Code, X, Y, Button : WORD; VAR Ch : CHAR);
FUNCTION  KEYPRESSED : BOOLEAN;
FUNCTION  MousePRESSED : BOOLEAN;
FUNCTION  MouseORKeyPRESSED : BOOLEAN;

IMPLEMENTATION

USES DOS;

CONST

  MIO    = $33;  (* Mouse Services       *)
  KBIO   = $16;  (* BIOS Keyboard        *)

VAR
   X, Y : WORD;
   reg  : REGISTERS;


FUNCTION KEYPRESSED : BOOLEAN; Assembler;
ASM
  PUSH DS
  MOV AX, 40h
  MOV DS, AX
  CLI
  MOV AX, [1Ah]
  CMP AX, [1Ch]
  STI
  MOV AX, 0
  JZ @NoPress
  INC AX
  @NoPress :
  POP DS
END;


FUNCTION PollKey (VAR Status : WORD) : WORD;
VAR s : WORD;
BEGIN
  asm
    MOV AH, 01
    INT KBIO
    MOV @Result, AX
    LAHF
    AND AX, 64
    MOV S, AX
  END;
  Status := s;
END;

FUNCTION MousePressed : BOOLEAN;
VAR B : WORD;
  BEGIN
  Asm
    MOV AX, $0003
    INT $33
    MOV B,  BX
  END;
  MousePressed := (B <> 0);
  END;

FUNCTION MouseORKeyPressed : BOOLEAN;
VAR B : WORD;
  BEGIN
  Asm
    MOV AX, $0003
    INT $33
    MOV B,  BX
  END;
  MouseORKeyPressed := (B <> 0) OR KeyPressed;
  END;

PROCEDURE KeyOrButton (VAR Code, X, Y, Button : WORD; VAR Ch : CHAR);
 (* wait for key or mouse click and returns data *)
VAR Status : WORD;
BEGIN
  REPEAT
    Code := PollKey (Status);
    GetMousePos (X, Y, Button);
  UNTIL (Button <> 0) OR (Status = 0);

  IF (LO (Status) = 0) AND (HI (Status) <> 0) THEN
        Ch := CHR ( HI (Status) + 128 )
      ELSE
        Ch := CHR (LO (Status) );
END;

FUNCTION InitMouse : WORD;
BEGIN
  Asm
    MOV AX, $0000
    INT MIO
    MOV @Result, AX
  END;
END;

PROCEDURE ShowMouseCursor; Assembler;
Asm
  MOV AX, $0001
  INT MIO
END;

PROCEDURE HideMouseCursor; Assembler;
Asm
  MOV AX, $0002
  INT MIO
END;

PROCEDURE GetMousePos (VAR X, Y, Button : WORD);
VAR X1, Y1, b : WORD;
BEGIN
  Asm
    MOV AX, $0003
    INT MIO
    MOV b,  BX
    MOV X1, CX
    MOV Y1, DX
  END;
  X := X1;
  Y := Y1;
  Button := b;
END;

PROCEDURE SetMousePos (X, Y : WORD); Assembler;
Asm
  MOV AX, $0004
  MOV CX, X
  MOV DX, Y
  INT MIO
END;

PROCEDURE GetButtonPressInfo (VAR X, Y, Button, NumberOfPresses : WORD);
BEGIN
  reg. AX := $0005;
  reg. BX := Button;
  INTR (MIO, reg);
  Button := reg. AX;
  X := reg. CX;
  Y := reg. DX;
  NumberOfPresses := reg. BX
END;

PROCEDURE GetButtonRelInfo (VAR X, Y, Button, NumberOfReleases : WORD);
BEGIN
  reg. AX := $0006;
  reg. BX := Button;
  INTR (MIO, reg);
  Button := reg. AX;
  X := reg. CX;
  Y := reg. DX;
  NumberOfReleases := reg. BX
END;

PROCEDURE SetMouseWindow (X1, Y1, X2, Y2 : WORD);
BEGIN
  reg. AX := $0007;
  reg. CX := X1;
  reg. DX := X2;
  INTR ($33, reg);
  INC (reg. AX, 1);
  reg. CX := Y1;
  reg. DX := Y2;
  INTR (MIO, reg)
END;

BEGIN
  MouseInstalled := (InitMouse <> 0);
END.