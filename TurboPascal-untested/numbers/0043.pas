
{  You've probably seen a lot of code to convert a number to HEX.
   Here is one that will take a hex String and covert it back to a number

   The conversion is back to type LONGINT, so you can covert to WORDS or
   BYTES by simply declaring your whatever varible you want }

{$V-}
USES CRT;

VAR
    A   : LONGINT;
    B   : WORD;
    C   : BYTE;
    D   : WORD;

{ ---------------------------------------------------------------------- }

FUNCTION HexToLong(S : STRING) : LONGINT;

    FUNCTION ANumBin (B : STRING) : LONGINT; Assembler;
    ASM
      LES DI, B
      XOR CH, CH
      MOV CL, ES : [DI]
      ADD DI, CX
      MOV AX, 0
      MOV DX, 0
      MOV BX, 1
      MOV SI, 0
      @LOOP :
        CMP BYTE PTR ES : [DI], '1'
        JNE @NotOne
          ADD AX, BX   {add power to accum}
          ADC DX, SI
        @NotOne :
        SHL SI, 1      {double power}
        SHL BX, 1
        ADC SI, 0
        DEC DI
      LOOP @LOOP
    END;

CONST
  HexDigits : ARRAY [0..15] OF CHAR = '0123456789ABCDEF';
  Legal     : SET OF Char = ['$','0'..'9','A'..'F'];
  BinNibbles : ARRAY [0..15] OF ARRAY [0..3] OF CHAR = (
    '0000', '0001', '0010', '0011',
    '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011',
    '1100', '1101', '1110', '1111');

VAR I : BYTE;
    O : STRING;

BEGIN
O := '';
HexToLong := 0;       { Returns zero if illegal characters found }
IF S = '' THEN EXIT;
FOR I := 1 TO LENGTH(S) DO
    BEGIN
    IF NOT (S[i] in LEGAL) THEN EXIT;
    O := O + binNibbles[PRED(POS(S[i],Hexdigits))];
    END;
HexToLong := ANumBin(O)
END;

{ ---------------------------------------------------------------------- }

BEGIN
ClrScr;
A   := HexToLong('$02F8');
B   := HexToLong('$0DFF');
C   := HexToLong('$00FF');   { The biggest byte there is !! }
D   := HexToLong('');   { this is ILLEGAL !! .. D will be ZERO }
WriteLn(A,' ',B,' ',C,' ',D);
END.