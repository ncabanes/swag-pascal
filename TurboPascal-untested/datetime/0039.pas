{ COUNTRY.PAS -- Going native with Dos.  Do not use under DOS 2.xx.
  Written by Wilbert van Leijen and released into the Public Domain }

Unit Country;

Interface
uses Dos;

Type
  DelimType    = Record
                   thousands,
                   decimal,
                   date,
                   time        : Array[0..1] of Char;
                 end;
  CurrType     = (leads,               { symbol precedes value }
                  trails,              { value precedes symbol }
                  leads_,              { symbol, space, value }
                  _trails,             { value, space, symbol }
                  replace);            { replaced }
  CountryType  = Record
                   DateFormat  : Word;       { 0: USA, 1: Europe, 2: Japan }
                   CurrSymbol  : Array[0..4] of Char;
                   Delimiter   : DelimType;  { Separators }
                   CurrFormat  : CurrType;   { Way currency is formatted }
                   CurrDigits  : Byte;       { Digits in currency }
                   Clock24hrs  : Boolean;    { True if 24-hour clock }
                   CaseMapCall : Procedure;  { Lookup table for ASCII ≥ $80 }
                   DataListSep : Array[0..1] of Char;
                   CountryCode : Word;
                 end;
  UpCaseType   = Function(c : Char) : Char;
  UpCaseStrType = Procedure(Var s : String);

Var
  UpCase       : UpCaseType;       { To be determined at runtime }
  UpCaseStr    : UpCaseStrType;
  CountryOk    : Boolean;          { Could determine country code flag }
  CountryRec   : CountryType;

Procedure GetSysTime(Var Today : DateTime);
Procedure SetSysTime(Today : DateTime);

Function DateString(FileStamp : DateTime) : String;
Function TimeString(FileStamp : DateTime) : String;

Implementation

{$R-,S-,V- }

{ Country dependent character capitalisation for DOS 3 }

Function UpCase3(c : Char) : Char; Far; Assembler;

ASM
        MOV    AL, c
        CMP    AL, 'a'
        JB     @2
        CMP    AL, 'z'
        JA     @1
        AND    AL, 11011111b
        JMP    @2
@1:     CMP    AL, 80h
        JB     @2
        CALL   [CountryRec.CaseMapCall]
@2:
end;  { UpCase3 }

{ Country dependent string capitalisation for DOS 3 }

Procedure UpCaseStr3(Var s : String); Far; Assembler;

ASM
        CLD
        LES    DI, s
        XOR    AX, AX
        MOV    AL, ES:[DI]
        STOSB
        XCHG   AX, CX
        JCXZ   @4

@1:     MOV    AL, ES:[DI]
        CMP    AL, 'a'
        JB     @3
        CMP    AL, 'z'
        JA     @2
        AND    AL, 11011111b
        JMP    @3
@2:     CMP    AL, 80h
        JB     @3
        CALL   [CountryRec.CaseMapCall]
@3:     STOSB
        LOOP   @1
@4:
end;  { UpCaseStr3 }

{ Country dependent character capitalisation for DOS 4+ }

Function UpCase4(c : Char) : Char; Far; Assembler;

ASM
        MOV    DL, c
        MOV    AX, 6520h
        INT    21h
        MOV    AL, DL
end;  { UpCase4 }

{ Country dependent string capitalisation for DOS 4+ }

Procedure UpCaseStr4(Var s : String); Far; Assembler;

ASM
        PUSH   DS
        CLD
        XOR    AX, AX
        LDS    SI, s
        LODSB
        XCHG   AX, CX
        JCXZ   @1

        MOV    DX, SI
        MOV    AX, 6521h
        INT    21h
@1:     POP    DS
end;  { UpCaseStr4 }

{ Return system time in Today }

Procedure GetSysTime(Var Today : DateTime); Assembler;

ASM
        LES    DI, Today
        CLD

        MOV    AH, 2Ah
        INT    21h
        XCHG   AX, CX          { year }
        STOSW
        XOR    AH, AH
        MOV    AL, DH          { month }
        STOSW
        MOV    AL, DL          { day }
        STOSW

        MOV    AH, 2Ch
        INT    21h
        XOR    AH, AH
        MOV    AL, CH          { hours }
        STOSW
        MOV    AL, CL          { min }
        STOSW
        MOV    AL, DH          { seconds }
        STOSW
end;  { GetSysTime }

{ Set system time }

Procedure SetSysTime(Today : DateTime); Assembler;

ASM
        PUSH   DS
        CLD
        LDS    SI, Today
        LODSW
        MOV    CX, AX          { year }
        LODSW
        MOV    DH, AL          { month }
        LODSW
        MOV    DL, AL          { day }
        MOV    AH, 2Bh
        INT    21h

        LODSW                  
        MOV    CH, AL          { hour }
        LODSW
        MOV    CL, AL          { minutes }
        LODSW
        MOV    DH, AL          { seconds }
        XOR    DL, DL
        MOV    AH, 2Dh
        INT    21h
        POP    DS
end;  { SetSysTime }

{ Convert a binary number to an unpacked decimal
  On entry:  AL <-- number ≤ 99
  On exit:   AX --> ASCII representation }

Procedure UnpackNumber; Assembler;

ASM
        AAM
        XCHG    AH, AL
        ADD     AX, '00'
end;  { UnpackNumber }

Function DateString(FileStamp : DateTime) : String; Assembler;

ASM
        PUSH   DS
        CLD

  { Set string length }

        LES    DI, @Result
        MOV    AL, 8
        STOSB

  { Store year, month and day in registers }

        LDS    SI, FileStamp
        LODSW
        SUB    AX, 1900
        CALL   UnpackNumber
        XCHG   AX, BX              { yy -> BX }
        LODSW
        CALL   UnpackNumber
        XCHG   AX, CX              { mm -> CX }
        LODSW
        CALL   UnpackNumber
        XCHG   AX, DX              { dd -> DX }

  {  Case date format of
       0 : USA standard       mm:dd:yy
       1 : Europe standard    dd:mm:yy
       2 : Japan standard     yy:mm:dd }

        POP    DS
        MOV    AL, Byte Ptr [CountryRec.DateFormat]
        OR     AL, AL
        JZ     @1
        DEC    AL
        JZ     @2

  { Japan }

        PUSH   DX
        PUSH   CX
        PUSH   BX
        JMP    @3

  { USA }

@1:     PUSH   BX
        PUSH   DX
        PUSH   CX
        JMP    @3

  { Europe }

@2:     PUSH   BX
        PUSH   CX
        PUSH   DX

  { Remove leading zero }

@3:     POP    AX
        CMP    AL, '0'
        JNE    @4
        MOV    AL, ' '

@4:     MOV    CL, Byte Ptr [CountryRec.Delimiter.date]
        STOSW
        MOV    AL, CL
        STOSB
        POP    AX
        STOSW
        MOV    AL, CL
        STOSB
        POP    AX
        STOSW
end;  { DateString }

Function TimeString(FileStamp : DateTime) : String; Assembler;

ASM
        PUSH   DS
        CLD

        MOV    BL, [CountryRec.Clock24Hrs]
        MOV    DX, [CountryRec.Delimiter.time]
        LDS    SI, FileStamp
        LES    DI, @Result

  { Set string length }

        MOV    AL, 5
        STOSB

  { Advance string index of FileStamp to hour field }

        ADD    SI, 6
        LODSW

  { Query time format }

        OR     BL, BL
        JNZ    @2

  { a.m. / p.m. clock format, set string length to 6 }

        INC    Byte Ptr ES:[DI-1]
        MOV    BL, 'a'
        CMP    AL, 12
        JBE    @1
        SUB    AL, 12
        MOV    BL, 'p'
@1:     MOV    Byte Ptr ES:[DI+5], BL

  { Convert to ASCII and remove leading zero }

@2:     CALL   UnpackNumber
        CMP    AL, '0'
        JNE    @3
        MOV    AL, ' '
@3:     STOSW

  { Write time separator }

        XCHG   AX, DX
        STOSB

  { Store minutes in string }

        LODSW
        CALL   UnpackNumber
        STOSW

        POP    DS
end;  { TimeString }

Begin  { Country }
ASM

   { Exit if Dos version < 3.0 }

        MOV    AH, 30h
        INT    21h
        CMP    AL, 3
        JB     @3
        JA     @1

   { Initialise pointers to DOS 3 capitalisation routines }

        MOV    Word Ptr [UpCase], Offset UpCase3
        MOV    Word Ptr [UpCaseStr], Offset UpCaseStr3
        JMP    @2

   { Initialise pointers to DOS 4 (or later) capitalisation routines }

@1:     MOV    Word Ptr [UpCase], Offset UpCase4
        MOV    Word Ptr [UpCaseStr], Offset UpCaseStr4

@2:     MOV    Word Ptr [UpCase+2], CS
        MOV    Word Ptr [UpCaseStr+2], CS

   { Call Dos 'Get country dependent information' function }

        MOV    AX, 3800h
        MOV    DX, Offset [CountryRec]
        INT    21h
        JC     @3

   { Add country code to the structure }

        MOV    [CountryRec.CountryCode], BX
        MOV    [CountryOk], True
        JMP    @4
@3:     MOV    [CountryOk], False
@4:
end;
end.  { Country }