(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0113.PAS
  Description: Handling Massive Number functions
  Author: JES R. KLINKE
  Date: 05-31-96  09:17
*)

{
You may use the following unit I have made for an encryption program
of mine. It implements real binary arithmetic, no BCD. But be careful,
there is currently no range checking at all, and overflows may result
in endless loops. If you need 2048 bit integers you have to set
BigNumLength to at least 128, a little more would be safer. Also
notice that the routines cannot handle negative numbers.

I hope you find this one useful.

        Jes R Klinke
}


PROGRAM BigNum;

USES

  Crt, Dos;

CONST

  BigNumLength = 20; {Number of words in value}

TYPE

  PBigNum = ^TBigNum;
  TBigNum = object

    Value : ARRAY [0..BigNumLength - 1] OF WORD;

    PROCEDURE ASSIGN (VAR AValue : TBigNum);
    PROCEDURE AssignLong (AValue : LONGINT);
    PROCEDURE ADD (VAR AValue : TBigNum);
    PROCEDURE Subtract (VAR AValue : TBigNum);
    PROCEDURE Multiply (VAR AMultiplicator : TBigNum);
    FUNCTION Divide (VAR ADivisor : TBigNum) : BOOLEAN;
    FUNCTION Modulus (VAR ADivisor : TBigNum) : BOOLEAN;
    PROCEDURE SquareRoot;
    PROCEDURE Increment (By : WORD);
    PROCEDURE Decrement (By : WORD);
    PROCEDURE BitwiseOr (VAR AMaske : TBigNum);
    FUNCTION Compare (VAR AValue : TBigNum) : INTEGER;
    PROCEDURE Mult10;
    PROCEDURE Div10;
    PROCEDURE Mult2;
    PROCEDURE Div2;
    FUNCTION STR : STRING;
    FUNCTION Str16 : STRING;
    PROCEDURE VAL (CONST S : STRING);
    FUNCTION AsLong : LONGINT;
  END;



PROCEDURE TBigNum.ASSIGN (VAR AValue : TBigNum);
BEGIN
  MOVE (AValue.Value, Value, SIZEOF (Value) );;
END;

PROCEDURE TBigNum.AssignLong (AValue : LONGINT);
BEGIN
  MOVE (AValue, Value [0], SIZEOF (LONGINT) );;
  FILLCHAR (Value [SIZEOF (LONGINT) SHR 1], BigNumLength SHL 1 -
SIZEOF (LONGINT), 0);
END;

PROCEDURE TBigNum.ADD (VAR AValue : TBigNum); assembler;
asm

    PUSH  DS
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    LDS    SI, AValue
    ADD    SI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    CLD
    CLC
@@0 : LODSW
    ADC    [ES : DI], AX
    INC    DI
    INC    DI
    LOOP  @@0
    POP    DS
END;

PROCEDURE TBigNum.Subtract (VAR AValue : TBigNum); assembler;

asm

    PUSH  DS
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    LDS    SI, AValue
    ADD    SI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    CLD
    CLC
@@0 : LODSW
    SBB    [ES : DI], AX
    INC    DI
    INC    DI
    LOOP  @@0
    POP    DS
END;

PROCEDURE TBigNum.Multiply (VAR AMultiplicator : TBigNum); assembler;

VAR

  Res : ARRAY [0..BigNumLength] OF WORD;
asm

    PUSH  DS
    PUSH  BP
    STD
    LES    DI, AMultiplicator
    ADD    DI, OFFSET TBigNum.Value
    LDS    SI, Self
    ADD    SI, OFFSET TBigNum.Value
    PUSH  SI
    LEA    BP, Res
    XOR    SI, SI
    MOV    CX, BigNumLength
    XOR    AX, AX
@@8 : MOV    SS : [BP + SI], AX
    ADD    SI, 2
    LOOP  @@8
    POP    SI
    XOR    BX, BX
@@0 : MOV    CX, BX
    MOV    DX, CX
    SHL    DX, 1
    ADD    SI, DX
    INC    CX
@@1 : LODSW
    MOV    DX, ES : [DI]
    ADD    DI, 2
    MUL    DX
    ADD    SS : [BP], AX
    ADC    SS : [BP + 2], DX
    JC    @@3
@@2 : LOOP  @@1
    MOV    DX, BX
    INC    DX
    SHL    DX, 1
    SUB    DI, DX
    ADD    SI, 2
    ADD    BP, 2
    INC    BX
    CMP    BX, BigNumLength
    JNE    @@0
    CLD
    POP    BP
    LEA    SI, Res
    PUSH  SS
    POP    DS
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    REP    MOVSW
    POP    DS
    JMP    @@9
@@3 : PUSH  SI
    MOV    DX, 1
    MOV    SI, 4
@@4 : ADD    [BP + SI], DX
    INC   SI
    INC    SI
    JC    @@4
    POP    SI
    JMP    @@2
@@9 :
END;

FUNCTION TBigNum.Divide (VAR ADivisor : TBigNum) : BOOLEAN;

VAR
  Bit, Res, Divisor : TBigNum;
  WholeResult : BOOLEAN;
BEGIN

  Divisor.ASSIGN (ADivisor);
  WholeResult := FALSE;
  Bit.AssignLong (1);
  Res.AssignLong (0);
  WHILE Compare (Divisor) >= 0 DO
  BEGIN
    Bit.Mult2;
    Divisor.Mult2;
  END;
  WHILE (Bit.Value [0] AND 1 = 0) AND NOT WholeResult DO
  BEGIN
    Bit.Div2;
    Divisor.Div2;
    CASE Compare (Divisor) OF
      1 :
      BEGIN
        Res.BitwiseOr (Bit);
        Subtract (Divisor);
      END;

      0 :
      BEGIN
        WholeResult := TRUE;
        Res.BitwiseOr (Bit);
        Subtract (Divisor);
      END;
    END;

  END;

  ASSIGN (Res);
  Divide := WholeResult;

END;

FUNCTION TBigNum.Modulus (VAR ADivisor : TBigNum) : BOOLEAN;

VAR

  Bit, Res, Divisor : TBigNum;
  WholeResult : BOOLEAN;

BEGIN

  Divisor.ASSIGN (ADivisor);
  WholeResult := FALSE;
  Bit.AssignLong (1);
  Res.AssignLong (0);

  WHILE Compare (Divisor) >= 0 DO
  BEGIN

    Bit.Mult2;
    Divisor.Mult2;

  END;

  WHILE (Bit.Value [0] AND 1 = 0) AND NOT WholeResult DO
  BEGIN
    Bit.Div2;
    Divisor.Div2;

    CASE Compare (Divisor) OF
      1 :
      BEGIN
        Res.BitwiseOr (Bit);
        Subtract (Divisor);
      END;

      0 :
      BEGIN
        WholeResult := TRUE;
        Res.BitwiseOr (Bit);
        Subtract (Divisor);
      END;

    END;

  END;

  Modulus := WholeResult;

END;

PROCEDURE TBigNum.SquareRoot;

VAR

  Guess, NewGuess : TBigNum;

BEGIN

  NewGuess.ASSIGN (Self);
  NewGuess.Div2;

  REPEAT

    Guess.ASSIGN (NewGuess);
    NewGuess.ASSIGN (Self);
    NewGuess.Divide (Guess);
    NewGuess.ADD (Guess);
    NewGuess.Div2;

  UNTIL NewGuess.Compare (Guess) = 0;

  ASSIGN (NewGuess);

END;

PROCEDURE TBigNum.Increment (By : WORD); assembler;

asm

    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    CLD
    MOV    AX, ES : [DI]
    ADD    AX, By
    STOSW
    MOV    CX, BigNumLength - 1
@@0 : MOV    AX, ES : [DI]
    ADC    AX, 0
    STOSW
    LOOP  @@0
END;


PROCEDURE TBigNum.Decrement (By : WORD); assembler;

asm

    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    CLD
    MOV    AX, ES : [DI]
    SUB    AX, By
    STOSW
    MOV    CX, BigNumLength - 1
@@0 : MOV    AX, ES : [DI]
    SBB    AX, 0
    STOSW
    LOOP  @@0
END;

PROCEDURE TBigNum.BitwiseOr (VAR AMaske : TBigNum); assembler;

asm

    PUSH  DS
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    LDS    SI, AMaske
    ADD    SI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    CLD
@@0 : LODSW
    OR    AX, ES : [DI]
    STOSW
    LOOP  @@0
    POP    DS
END;

FUNCTION TBigNum.Compare (VAR AValue : TBigNum) : INTEGER; assembler;

asm
    PUSH  DS
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    LDS    SI, AValue
    ADD    SI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    MOV    DX, CX
    DEC    DX
    SHL    DX, 1
    ADD    DI, DX
    ADD    SI, DX
    STD
    REPZ  CMPSW
    MOV    AX, 0FFFFh
    JA    @@1
    MOV    AX, 0000h
    JE    @@1
    MOV    AX, 0001h
@@1 : POP    DS
END;

PROCEDURE TBigNum.Mult10; assembler;

asm

    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    XOR    BX, BX
    MOV    CX, BigNumLength
@@0 : MOV    AX, [ES : DI]
    MOV    DX, 10
    MUL    DX
    ADD    AX, BX
    ADC    DX, 0
    MOV    [ES : DI], AX
    INC    DI
    INC    DI
    MOV    BX, DX
    LOOP  @@0
END;

PROCEDURE TBigNum.Div10; assembler;

asm
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    MOV    DX, CX
    DEC    DX
    SHL    DX, 1
    ADD    DI, DX
    XOR    DX, DX
@@0 : MOV    AX, [ES : DI]
    MOV    BX, 10
    DIV    BX
    MOV    [ES : DI], AX
    DEC    DI
    DEC    DI
    LOOP  @@0
END;

PROCEDURE TBigNum.Mult2; assembler;

asm
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    XOR    BX, BX
    MOV    CX, BigNumLength
    CLC
    CLD
@@0 : MOV    AX, [ES : DI]
    RCL    AX, 1
    STOSW
    LOOP  @@0
END;

PROCEDURE TBigNum.Div2; assembler;

asm
    LES    DI, Self
    ADD    DI, OFFSET TBigNum.Value
    MOV    CX, BigNumLength
    MOV    DX, CX
    DEC    DX
    SHL    DX, 1
    ADD    DI, DX
    XOR    DX, DX
    CLC
    STD
@@0 : MOV    AX, [ES : DI]
    RCR    AX, 1
    STOSW
    LOOP  @@0
END;

FUNCTION TBigNum.STR : STRING;

VAR

  M, T : TBigNum;
  Res : STRING;
  I, Ciffer : INTEGER;

BEGIN

  M.ASSIGN (Self);
  T.AssignLong (1);
  I := 0;
  WHILE M.Compare (T) >= 0 DO
  BEGIN
    T.Mult10;
    INC (I);
  END;
  IF I <= 1 THEN
  BEGIN
    STR := CHAR (BYTE ('0') + M.Value [0]);
  END
  ELSE
  BEGIN
    Res := '';
    T.Div10;
    WHILE I > 0 DO
    BEGIN
      Ciffer := 0;
      WHILE (M.Compare (T) >= 0) DO
      BEGIN
        M.Subtract (T);
        INC (Ciffer);
      END;
      Res := Res + CHAR (BYTE ('0') + Ciffer);
      DEC (I);
      T.Div10;
    END;
    STR := Res;
  END;
END;

FUNCTION TBigNum.Str16 : STRING;

CONST
  HexCif : ARRAY [0..15] OF CHAR = '0123456789ABCDEF';
VAR
  Res : STRING;
  I : INTEGER;
  ErMed : BOOLEAN;
BEGIN
  ErMed := FALSE;
  Res := '';
  FOR I := BigNumLength - 1 DOWNTO 0 DO
  BEGIN
    IF ErMed OR (Value [I] <> 0) THEN
    BEGIN
      IF ErMed OR (Value [I] SHR 12 AND $F <> 0) THEN
      BEGIN
        Res := Res + HexCif [Value [I] SHR 12 AND $F];
        ErMed := TRUE;
      END;
      IF ErMed OR (Value [I] SHR 8 AND $F <> 0) THEN
      BEGIN
        Res := Res + HexCif [Value [I] SHR 8 AND $F];
        ErMed := TRUE;
      END;
      IF ErMed OR (Value [I] SHR 4 AND $F <> 0) THEN
      BEGIN
        Res := Res + HexCif [Value [I] SHR 4 AND $F];
        ErMed := TRUE;
      END;
      Res := Res + HexCif [Value [I] AND $F];
      ErMed := TRUE;
    END;
  END;
  Str16 := Res;
END;

PROCEDURE TBigNum.VAL (CONST S : STRING);
VAR
  I : INTEGER;
BEGIN
  AssignLong (0);
  I := 1;
  WHILE I <= LENGTH (S) DO
  BEGIN
    Mult10;
    Increment (BYTE (S [I]) - BYTE ('0') );
    INC (I);
  END;
END;

FUNCTION TBigNum.AsLong : LONGINT;
VAR
 Res : ^LONGINT;

BEGIN
  Res := @Value [0];
  AsLong := Res^;
END;

VAR
  ABigNum : TBigNum;
  I : INTEGER;


BEGIN
  ABigNum.AssignLong (1);
  FOR I := 1 TO 260 DO
  BEGIN
    WRITELN (ABigNum.STR : 79);
    ABigNum.Mult2;
  END;
  FOR I := 1 TO 260 DO
  BEGIN
    WRITELN (ABigNum.STR : 79);
    ABigNum.Div2;
  END;
  WRITELN (ABigNum.STR : 79);
  WRITE ('Press enter to exit.');
  READLN;
END.



