(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0030.PAS
  Description: Reading a Text File
  Author: DON BURGESS
  Date: 02-03-94  07:07
*)

{
After much trial and error, and finding some helpful code from the SWAG
support team (thanks!) this is what I came up with.  It can handle text
files up to 750,000 bytes and does basically what I'm looking for, but
the scrolling isn't as smooth as it should be.  Also, the lines of
text are limited to 79 characters...  (The source code can probably be
streamlined a lot too, like I said, I'm fairly new at this...)
}

 Program Reader;

 uses Crt, Dos;

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
@1:  MOV    AX, ES:[DI].TextRec.Bufend
                       MOV    ES:[DI].TextRec.BufPos, AX
@2:
end;  { TextSeek }
    {end TextUtil }


  Procedure HideCursor;  assembler;
  asm
    mov      ah,$01  { Function number }
    mov      ch,$20
    mov      cl,$00
    Int      $10     { Call BIOS }
  end;  { HideCursor }


  Procedure RestoreCursor;  assembler;
  asm
    mov      ah,$01  { Function number }
    mov      ch,$06  { Starting scan line }
    mov      cl,$07  { Ending scan line }
    int      $10     { Call BIOS }
  end; { RestoreCursor }


 Var
     TxtFile : text;
     s : string[79];
     Cee : CHAR;

 Label RWLoop, Final, FileSizeError, WrongKey, NoParamError;

 Var
    Size : Longint;
    YY, GG, Counter : LongInt;
    LineNumArray : Array[0..15000] Of LongInt;
    MyText : Array[0..23] Of String[79];
    InstructStr : String[79];
    OrigColor, ColorSwitch : Integer;
    LineNo : String[5];
 Begin
   OrigColor := TextAttr;
   TextColor(11);
   TextBackground(1);
   InstructStr := 'Scroll (^) up - (v) down - (Page up/down) - (Home) - (End) - (ESC) Quit';
   If ParamStr(1) = '' Then GoTo NoParamError;
   Assign(TxtFile, ParamStr(1)); {'TEXTFILE.DOC';}
   Reset(TxtFile);
   Counter := -1;
   ClrScr;
   HideCursor;
   If (TextFileSize(TxtFile)) >= 750000 Then GoTo FileSizeError;
   While Not EOF(TxtFile) Do
     Begin
       Inc(Counter,1);
       LineNumArray[Counter] := TextFilePos(TxtFile);
       ReadLn(TxtFile);
     End;
   Inc(Counter,1);
   YY:=0;


   RWLoop:
     For GG:=0+YY TO 23+YY DO
       Begin
         TextSeek(TxtFile,LineNumArray[GG]);
         ReadLn(TxtFile,S);
         MyText[GG-YY]:=S;
       End;
     GoToXY(1,1);
     ColorSwitch := TextAttr;
     Str(yy+23:5,LineNo);

     Repeat Until Port[$3DA] And 8 = 8; { Wait For Vertical retrace }

     For GG:=0 TO 23 DO
       Begin
         ClrEOL;
         WriteLn(MyText[GG]);
       End;
     GoToXY(2,25);
     TextColor(14);
     Write(LineNo);
     GoToXY(8,25);
     TextColor(15);
     Write(InstructStr);
     TextAttr:=ColorSwitch;

     Delay(1);
   WrongKey:
     Repeat
     Until KeyPressed;
     Cee := ReadKey;

     If Cee=Chr(27) Then GoTo Final
     Else If Cee=Chr(72) Then   {UP ARROW}
       Begin
         If YY>0 Then Dec(YY,1);
         GoTo RWLoop;
       End
     Else If Cee=Chr(80) Then  {DOWN ARROW}
       Begin
         Inc(YY,1);
         If YY>=Counter-23 Then YY:= Counter-24;
         GoTo RWLoop;
       End
     Else If Cee=Chr(73) Then {PAGE UP}
       Begin
         YY:=YY-24;
         If YY<1 Then YY:=0;
         GoTo RWLoop;
       End
     Else If Cee=Chr(81) Then {PAGEDOWN}
       Begin
         YY:= YY+24;
         If YY>=Counter-23 Then YY:= Counter-24;
         GoTo RWLoop;
       End
     Else If Cee=Chr(71) Then  {HOME}
       Begin
         YY:=0;
         GoTo RWLoop;
       End
     Else If Cee=Chr(79) Then  {End}
       Begin
         YY:= Counter-24;
         GoTo RWLoop;
       End;

   GoTo WrongKey;

  FileSizeError:
    WriteLn;
    WriteLn('ERROR...');
    WriteLn;
    WriteLn('File Size Larger Than 750,000');
    GoTo Final;

  NoParamError:
    WriteLn;
    WriteLn('ERROR...');
    WriteLn;
    WriteLn('Command line syntax is Reader C:\TextFile.txt');
    GoTo Final;

  Final:
    Close(TxtFile);
    TextAttr := OrigColor;
    RestoreCursor;
    ClrScr;
 End.

