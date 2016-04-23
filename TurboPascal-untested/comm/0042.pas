
PROGRAM ComChk;

USES Crt;

  FUNCTION HexWord(a : Word) : String;
  CONST
    Digit          : ARRAY[$0..$F] OF Char = '0123456789ABCDEF';
  VAR
    I              : Byte;
    HexStr         : String;

  BEGIN
    HexStr := '';
    FOR I := 1 TO 4 DO
    BEGIN
      Insert(Digit[a AND $000F], HexStr, 1);
      a := a SHR 4
    END;
    HexWord := HexStr;
  END;                            {hex}


PROCEDURE UncodePort(NR : integer);
  VAR
    B, M, V1, V2, TLRC, D, MSB, LSB : integer;
    S, CO : integer;
    Baud : real;
    Answer : string[10];
    ComList : array[1..4] OF word ABSOLUTE $0000:$0400;
  BEGIN
    CO := ComList[NR];
    WriteLn;
    WriteLn ('Communications Port ', NR, ':');
    IF CO = 0 THEN
      BEGIN
        WriteLn ('  Not installed.');
        Exit;
      END;

    S := Port[CO + 3];
    TLRC := Port[CO + 3];
    Port[CO + 3] := TLRC OR $80;
    LSB := Port[CO];
    MSB := Port[CO + 1];
    D := 256 * MSB + LSB;
    Baud := 115200.0 / D;
    Port[CO + 3] := TLRC AND $7F;

    {Display port address}
    WriteLn ('  Port address: ', HexWord (ComList[NR]));

    {Display baud rate}
    WriteLn ('     Baud rate: ', Baud:5:0);

    {Display data bits}
    IF (S AND 3) = 3 THEN
      B := 8
    ELSE IF (S AND 2) = 2 THEN
      B := 7
    ELSE IF (S AND 1) = 1 THEN
      B := 6
    ELSE
      B := 5;
    WriteLn ('     Data bits: ', B:5);

    {Display stop bits}
    IF (S AND 4) = 4 THEN
      B := 2
    ELSE
      B := 1;
    WriteLn ('     Stop bits: ', B:5);

    IF (S AND 24) = 24 THEN
      Answer := 'Even'
    ELSE IF (S AND 8) = 8 THEN
      Answer := 'Odd'
    ELSE
      Answer := 'None';
    WriteLn ('        Parity: ', Answer:5);
  END; {procedure Uncode_Setup_Of_Port}

BEGIN
  ClrScr;
  WriteLn ('Communications Port Status--------------------------');
  UncodePort (1);
  UncodePort (2);
  UncodePort (3);
  UncodePort (4);
END.

