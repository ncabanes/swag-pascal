(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0065.PAS
  Description: HEXWRITE Strings
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:35
*)

{$R-}
UNIT HexWrite;
(**) INTERFACE (**)
TYPE HexString = String[9];
  BinString = String[32];

  FUNCTION HexByte(B : Byte) : HexString;
  FUNCTION HexShortInt(S : ShortInt) : HexString;
  FUNCTION HexWord(W : Word) : HexString;
  FUNCTION HexInteger(I : Integer) : HexString;
  FUNCTION HexLongInt(L : LongInt) : HexString;
  FUNCTION HexPointer(VAR P) : HexString;

  FUNCTION BinByte(B : Byte) : BinString;
  FUNCTION BinShortInt(S : ShortInt) : BinString;
  FUNCTION BinWord(W : Word) : BinString;
  FUNCTION BinInteger(I : Integer) : BinString;
  FUNCTION BinLongInt(L : LongInt) : BinString;

  FUNCTION NumBin(B : BinString) : LongInt;
  FUNCTION ANumBin(B : BinString) : LongInt;
(**) IMPLEMENTATION (**)
CONST
  HexDigits : ARRAY[0..15] OF Char = '0123456789ABCDEF';
  BinNibbles : ARRAY[0..15] OF ARRAY[0..3] OF Char = (
    '0000', '0001', '0010', '0011',
    '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011',
    '1100', '1101', '1110', '1111');

  FUNCTION HexByte(B : Byte) : HexString;
  VAR Temp : HexString;
  BEGIN
    Temp[0] := #2;
    Temp[1] := HexDigits[B SHR 4];
    Temp[2] := HexDigits[B AND $F];
    HexByte := Temp;
  END;

  FUNCTION HexShortInt(S : ShortInt) : HexString;
  BEGIN HexShortInt := HexByte(Byte(S)); END;

  FUNCTION HexWord(W : Word) : HexString;
  VAR Temp : HexString;
  BEGIN
    Temp[0] := #4;
    Temp[1] := HexDigits[W SHR 12];
    Temp[2] := HexDigits[(W SHR 8) AND $F];
    Temp[3] := HexDigits[(W SHR 4) AND $F];
    Temp[4] := HexDigits[W AND $F];
    HexWord := Temp;
  END;

  FUNCTION HexInteger(I : Integer) : HexString;
  BEGIN HexInteger := HexWord(Word(I)); END;

  FUNCTION HexLongInt(L : LongInt) : HexString;
  VAR Temp : HexString;
  BEGIN
    Temp[0] := #8;
    Temp[1] := HexDigits[L SHR 28];
    Temp[2] := HexDigits[(L SHR 24) AND $F];
    Temp[3] := HexDigits[(L SHR 20) AND $F];
    Temp[4] := HexDigits[(L SHR 16) AND $F];
    Temp[5] := HexDigits[(L SHR 12) AND $F];
    Temp[6] := HexDigits[(L SHR 8) AND $F];
    Temp[7] := HexDigits[(L SHR 4) AND $F];
    Temp[8] := HexDigits[L AND $F];
    HexLongInt := Temp;
  END;

  FUNCTION HexPointer(VAR P) : HexString;
  VAR
    Temp : HexString;
    L    : LongInt ABSOLUTE P;
  BEGIN
    Temp := HexLongInt(L);
    Move(Temp[5], Temp[6], 4);
    Temp[5] := ':';
    Inc(Temp[0]);
    HexPointer := Temp;
  END;

  FUNCTION BinByte(B : Byte) : BinString;
  VAR Temp : BinString;
  BEGIN
    Temp[0] := #8;
    Move(BinNibbles[B SHR 4], Temp[1], 4);
    Move(BinNibbles[B AND $F], Temp[5], 4);
    BinByte := Temp;
  END;

  FUNCTION BinShortInt(S : ShortInt) : BinString;
  BEGIN BinShortInt := BinByte(Byte(S)); END;

  FUNCTION BinWord(W : Word) : BinString;
  VAR Temp : BinString;
  BEGIN
    Temp[0] := #16;
    Move(BinNibbles[W SHR 12], Temp[1], 4);
    Move(BinNibbles[(W SHR 8) AND $F], Temp[5], 4);
    Move(BinNibbles[(W SHR 4) AND $F], Temp[9], 4);
    Move(BinNibbles[W AND $F], Temp[13], 4);
    BinWord := Temp;
  END;

  FUNCTION BinInteger(I : Integer) : BinString;
  BEGIN BinInteger := BinWord(Word(I)); END;

  FUNCTION BinLongInt(L : LongInt) : BinString;
  VAR Temp : BinString;
  BEGIN
    Temp[0] := #32;
    Move(BinNibbles[L SHR 28], Temp[1], 4);
    Move(BinNibbles[(L SHR 24) AND $F], Temp[5], 4);
    Move(BinNibbles[(L SHR 20) AND $F], Temp[9], 4);
    Move(BinNibbles[(L SHR 16) AND $F], Temp[13], 4);
    Move(BinNibbles[(L SHR 12) AND $F], Temp[17], 4);
    Move(BinNibbles[(L SHR 8) AND $F], Temp[21], 4);
    Move(BinNibbles[(L SHR 4) AND $F], Temp[25], 4);
    Move(BinNibbles[L AND $F], Temp[29], 4);
    BinLongInt := Temp;
  END;

  FUNCTION NumBin(B : BinString) : LongInt;
  VAR Accum, Power : LongInt;
    P : Byte;
  BEGIN
    Power := 1; Accum := 0;
    FOR P := length(B) DOWNTO 1 DO
      BEGIN
        IF B[P] = '1' THEN Inc(Accum, Power);
        Power := PoweR SHL 1;
      END;
    NumBin := Accum;
  END;

  FUNCTION ANumBin(B : BinString) : LongInt; Assembler;
  ASM
    LES DI, B
    XOR CH, CH
    MOV CL, ES:[DI]
    ADD DI, CX
    MOV AX, 0
    MOV DX, 0
    MOV BX, 1
    MOV SI, 0
    @LOOP:
      CMP BYTE PTR ES:[DI],'1'
      JNE @NotOne
        ADD AX, BX   {add power to accum}
        ADC DX, SI
      @NotOne:
      SHL SI, 1      {double power}
      SHL BX, 1
      ADC SI, 0
      DEC DI
    LOOP @LOOP
  END;

END.

