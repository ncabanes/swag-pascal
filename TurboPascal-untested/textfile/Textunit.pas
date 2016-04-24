(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0010.PAS
  Description: TEXTUNIT.PAS
  Author: WILBERT VAN LEIJEN
  Date: 05-28-93  13:58
*)

Unit TextUtil;
{        Written by Wilbert Van.Leijen and posted in the Pascal Echo }

Interface

Function TextFilePos(Var f : Text) : LongInt;
Function TextFileSize(Var f : Text) : LongInt;
Procedure TextSeek(Var f : Text; n : LongInt);

Implementation
Uses Dos;

{$R-,S- }

Procedure GetFileMode; Assembler;

Asm
                                CLC
                                CMP    ES:[DI].TextRec.Mode, fmInput
                                JE     @1
                                MOV    [InOutRes], 104         { 'File not opened For reading' }
                                xor    AX, AX                  { Zero out Function result }
                                xor    DX, DX
                                STC
@1:
end;  { GetFileMode }

Function TextFilePos(Var f : Text) : LongInt; Assembler;

Asm
        LES    DI, f
        CALL   GetFileMode
        JC     @1

        xor    CX, CX                  { Get position of File Pointer }
        xor    DX, DX
        MOV    BX, ES:[DI].TextRec.handle
        MOV    AX, 4201h
        inT    21h                     { offset := offset-Bufend+BufPos }
                                xor    BX, BX
        SUB    AX, ES:[DI].TextRec.Bufend
        SBB    DX, BX
        ADD    AX, ES:[DI].TextRec.BufPos
        ADC    DX, BX
@1:
end;  { TextFilePos }


Function TextFileSize(Var f : Text) : LongInt; Assembler;

Asm
                                LES    DI, f
                                CALL   GetFileMode
                                JC     @1

                                xor    CX, CX                  { Get position of File Pointer }
        xor    DX, DX
        MOV    BX, ES:[DI].TextRec.handle
        MOV    AX, 4201h
                                inT    21h
        PUSH   DX                      { Save current offset on the stack }
                                PUSH   AX
        xor    DX, DX                  { Move File Pointer to Eof }
        MOV    AX, 4202h
        inT    21h
        POP    SI
        POP    CX
                                PUSH   DX                      { Save Eof position }
        PUSH   AX
        MOV    DX, SI                  { Restore old offset }
        MOV    AX, 4200h
        inT    21h
        POP    AX                      { Return result}
        POP    DX
@1:
end;  { TextFileSize }

Procedure TextSeek(Var f : Text; n : LongInt); Assembler;

Asm
        LES    DI, f
                                CALL   GetFileMode
        JC     @2

        MOV    CX, Word Ptr n+2        { Move File Pointer }
        MOV    DX, Word Ptr n
        MOV    BX, ES:[DI].TextRec.Handle
                                MOV    AX, 4200h
                                inT    21h
                                JNC    @1                      { Carry flag = reading past Eof }
                                MOV    [InOutRes], AX
                                JMP    @2
                                                                                                                                                         { Force read next time }
@1:     MOV    AX, ES:[DI].TextRec.Bufend
                                MOV    ES:[DI].TextRec.BufPos, AX
@2:
end;  { TextSeek }
end.  { TextUtil }

{    With the aid of that Unit you could save the position of each line
in the Text File to an Array of LongInt as you read them. You can also
open a temporary File, a File of LongInt, where each Record would simply
represent the offset of that line in the Text File. if you need to go
back in the Text, simply read the offset of the line where you which to
restart reading. Suppose you are on line 391 and you decide to go back
say, 100 lines, simply do a Seek(MyIndex, CurrentLine-100). then use the
TextSeek Procedure to seek to that position in the Text File and start
reading again, taking into acount that you allready read those lines so
you either re-Write the offsets to your index File, which won't hurt
since you will just be overwriting the Records With the same values
again or simply skip writing the offsets Until you reach a point where
NEW lines that haven't yet been read are reached. Save any new offset as
you read Forward.

    With this method you can go back-wards as well as Forwards. In fact
if you first read the File, saving all offsets Until the end, you can
offer the user to seek to any line number.

    When you read new lines or seek backwards, simply flush any lines
from memory. or maybe you could decide to keep a predetermined number of
lines in memory say 300. When ever the user asks to read Forward or
backwards, simply flush the 100 first or Last line, depending on the
direction the user wants to go, and read 100 new lines from the Text
File.

    Maybe the best approach to be sure of sufficient memory is to
determine how many lines will fit. Suppose you limit line lengths to 255
caracters. Determine how many will fit in a worse Case scenario. Create
as many 255 caracter Strings as will fit. divide that number of lines by
4. Say you managed to create 1000 Strings of 255 caracters. divided by 4
is 250. So set a limit to 750 Strings to be safe and make any disk
accesses in bundles of 250 Lines.

    You can also keep the line offsets in memory in Arrays but you will
be limited to 65520 / 8 = 16380 lines. Make that two Arrays stored on
the heap and you've got yourself enough space to store 32760 line
offsets which at 255 caracters by line would be an 8.3 Meg File.
 }
