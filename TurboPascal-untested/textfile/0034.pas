
Unit TextUtil;
{ Written by Wilbert Van.Leijen and posted in the Pascal Echo }

Interface

Function TextFilePos(Var f : Text) : LongInt;
Function TextFileSize(Var f : Text) : LongInt;
Procedure TextSeek(Var f : Text; n : LongInt);

Implementation
uses Dos;

{$R-,S- }

Procedure GetFileMode; Assembler;

ASM
        CLC
        CMP    ES:[DI].TextRec.Mode, fmInput
        JE     @1
        MOV    [InOutRes], 104         { 'File not opened for reading' }
        XOR    AX, AX                  { Zero out function result }
        XOR    DX, DX
        STC
@1:
end;  { GetFileMode }

Function TextFilePos(Var f : Text) : LongInt; Assembler;

ASM
        LES    DI, f
        CALL   GetFileMode
        JC     @1

        XOR    CX, CX                  { Get position of file pointer }
        XOR    DX, DX
        MOV    BX, ES:[DI].TextRec.handle
        MOV    AX, 4201h
        INT    21h                     { offset := offset-BufEnd+BufPos }
        XOR    BX, BX
        SUB    AX, ES:[DI].TextRec.BufEnd
        SBB    DX, BX
        ADD    AX, ES:[DI].TextRec.BufPos
        ADC    DX, BX
@1:
end;  { TextFilePos }


Function TextFileSize(Var f : Text) : LongInt; Assembler;

ASM
        LES    DI, f
        CALL   GetFileMode
        JC     @1
        XOR    CX, CX                  { Get position of file pointer }
        XOR    DX, DX
        MOV    BX, ES:[DI].TextRec.handle
        MOV    AX, 4201h
        INT    21h
        PUSH   DX                      { Save current offset on the stack }
        PUSH   AX
        XOR    DX, DX                  { Move file pointer to EOF }
        MOV    AX, 4202h
        INT    21h
        POP    SI
        POP    CX
        PUSH   DX                      { Save EOF position }
        PUSH   AX
        MOV    DX, SI                  { Restore old offset }
        MOV    AX, 4200h
        INT    21h
        POP    AX                      { Return result}
        POP    DX
@1:
end;  { TextFileSize }

Procedure TextSeek(Var f : Text; n : LongInt); Assembler;

ASM
        LES    DI, f
        CALL   GetFileMode
        JC     @2

        MOV    CX, Word Ptr n+2        { Move file pointer }
        MOV    DX, Word Ptr n
        MOV    BX, ES:[DI].TextRec.Handle
        MOV    AX, 4200h
        INT    21h
        JNC    @1                      { Carry flag = reading past EOF }
        MOV    [InOutRes], AX
        JMP    @2


        { Force read next time }
@1:     MOV    AX, ES:[DI].TextRec.BufEnd
        MOV    ES:[DI].TextRec.BufPos, AX
@2:
end;  { TextSeek }
end.  { TextUtil }

