(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0024.PAS
  Description: Edit Disk Serial Number
  Author: SWAG SUPPORT TEAM
  Date: 07-16-93  06:30
*)

PROGRAM Serial (Input, Output);
USES CRT;

CONST
  HexDigits : ARRAY [0..15]OF CHAR = '0123456789ABCDEF';
TYPE
  InfoBuffer = RECORD
               InfoLevel : WORD;    {should be zero}
               Serial : LONGINT;
               VolLabel : ARRAY [0..10]OF CHAR;
               FileSystem : ARRAY [0..7]OF CHAR;
             END;
  SerString = STRING [9];

VAR
  IB : InfoBuffer;
  N : WORD;
  let : CHAR;
  param : STRING [10];
  IsSet : BOOLEAN;
  NewSerial : LONGINT;
  code : INTEGER;

  FUNCTION SerialStr (L : LONGINT) : SerString;
  VAR Temp : SerString;
  BEGIN
    Temp [0] := #9;
    Temp [1] := HexDigits [L SHR 28];
    Temp [2] := HexDigits [ (L SHR 24) AND $F];
    Temp [3] := HexDigits [ (L SHR 20) AND $F];
    Temp [4] := HexDigits [ (L SHR 16) AND $F];
    Temp [5] := '-';
    Temp [6] := HexDigits [ (L SHR 12) AND $F];
    Temp [7] := HexDigits [ (L SHR 8) AND $F];
    Temp [8] := HexDigits [ (L SHR 4) AND $F];
    Temp [9] := HexDigits [L AND $F];
    SerialStr := Temp;
  END;

  FUNCTION GetSerial (DiskNum : BYTE;
                     VAR I : InfoBuffer) : WORD;assembler;
    asm
    MOV AH, 69h
    MOV AL, 00h
    MOV BL, DiskNum
    PUSH DS
    LDS DX, I
    INT 21h
    POP DS
    JC @Bad
    XOR AX, AX
    @Bad :
    END;

    FUNCTION SetSerial (DiskNum : BYTE;
                       VAR I : InfoBuffer) : WORD;assembler;
      asm
      MOV AH, 69h
      MOV AL, 00h
      MOV BL, DiskNum
      PUSH DS
      LDS DX, I
      INT 21h
      POP DS
      JC @Bad
      XOR AX, AX
      @Bad :
      END;

      PROCEDURE ErrorOut (err : BYTE);
      BEGIN
        CASE err OF
          5 : BEGIN
              WRITELN ('Either the disk in ', let, ': is write',
                      'protected or it lacks an extended BPB.');
              WRITELN ('If the disk is not write-protected, ',
                      'reformat it with DOS 4 or higher.');
            END;
          15 : WRITELN ('Not a valid drive letter.');
          255 : BEGIN
                WRITELN ('SYNTAX:   SERIAL D:########"');
                WRITELN ('  where D: is the drive letter',
                        'and ######## is the eight digit');
                WRITELN ('  hexadecimal serial number with-',
                        'out the "-".');
                WRITELN ('EXAMPLE:  SERIAL A: 1234ABCD');
              END;

        ELSE WRITELN ('DOS ERROR #', N);
        END;
        HALT (1);
      END;

    BEGIN
      CLRSCR;
      IF PARAMCOUNT < 1 THEN ErrorOut (255);
      IF PARAMCOUNT > 2 THEN ErrorOut (255);
      param := PARAMSTR (1);
      CASE LENGTH (param) OF
        1 : {OK};
        2 : IF param [2] <> ':' THEN ErrorOut (255);
      ELSE ErrorOut (255);
      END;
      let := UPCASE (param [1]);
      IF (let < 'A') OR (let > 'Z') THEN ErrorOut (15);
      IF PARAMCOUNT < 2 THEN IsSet := FALSE
      ELSE
        BEGIN
          IsSet := TRUE;
          param := '$' + PARAMSTR (2);
          VAL (param, NewSerial, code);
          IF code <> 0 THEN ErrorOut (255);
        END;
      N := GetSerial (ORD (let) - ORD ('@'), IB);
      IF N = 0 THEN
        BEGIN
          WITH IB DO
            BEGIN
              WRITELN ('Serial Number is "',
                      SerialStr (Serial), '"');
              IF IsSet THEN
                BEGIN
                  Serial :=
                  NewSerial; ;
                  N :=
                  SetSerial (ORD (let) - ORD ('@'), IB);
                  IF N = 0 THEN

                    WRITELN ('Successfully canged serial to "', SerialStr (NewSerial), '"')
                  ELSE
                    ErrorOut (N);
                END;
            END;
        END
      ELSE ErrorOut (N);

    END.


