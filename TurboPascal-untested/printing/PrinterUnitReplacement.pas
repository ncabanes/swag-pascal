(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0028.PAS
  Description: PRINTER Unit Replacement
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  17:38
*)

{ Can be used as a TOTAL replacement for the PRINTER UNIT }
{ You'll need to replace the PRINTER unit in the TURBO.TPL to use this }
{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
{$F+,O-,X+,A-}
{$ENDIF}

{$DEFINE AssignLstDevice}
{$DEFINE DoErrorChecking}   { undefine this to eliminate error checking }

UNIT Printer;

INTERFACE

{$IFDEF DoErrorChecking}
USES CRT;
{$ENDIF}

CONST

  fmClosed = $D7B0;               { magic numbers for Turbo }
  fmInput = $D7B1;
  fmOutput = $D782;
  fmInOut = $D7B3;

  IO_Invalid = $FC;               { invalid operation eg. attempt to write }
  { to a file opened in fmInput mode       }

  LPTNames : ARRAY [0..2] OF STRING [4] = ('LPT1', 'LPT2', 'LPT3');

  LPTPort : BYTE = 0;

VAR
  Lst : TEXT;                     { for source compatability with TP3 }

FUNCTION GetROMPrinterStatus (LPTNo : WORD) : BYTE;
  { status of LPTNo via ROM BIOS int 17h func 2h }
  INLINE (
    $5A /                         {  pop     DX    ; get printer number}
    $B4 / $02 /                   {  mov     AH,02 ; set AH for BIOS int 17h function 0}
    $CD / $17 /                   {  int     $17   ; do an int 17h}
    $86 / $E0);                   {  xchg    AL,AH ; put byte result in AL}

FUNCTION DoInt17 (Ch : CHAR; LPTNo : WORD) : BYTE;
  { send a character to LPTNo via ROM BIOS int 17h func 0h }
  INLINE (
    $5A /                         {  pop     DX    ; get printer number}
    $58 /                         {  pop     AX    ; get char}
    $B4 / $00 /                   {  mov     AH,00 ; set AH for BIOS int 17h function 0}
    $CD / $17 /                   {  int     $17   ; do an int 17h}
    $86 / $E0);                   {  xchg    AL,AH ; put byte result in AL}

PROCEDURE AssignLst (VAR F : TEXT; LPTNumber : WORD);
  { like Turbo's assign, except associates Text variable with one of the LPTs }

PROCEDURE OutputToFile (FName : STRING);
  {redirect printer output to file }

FUNCTION  PrinterStatus (LPTNum : BYTE) : BYTE;

FUNCTION  Printer_OK : BOOLEAN;

PROCEDURE SelectPrinter (LPTNum : BYTE);

PROCEDURE ResetPrinter;           { only resets printer 0 }

IMPLEMENTATION

TYPE
  TextBuffer = ARRAY [0..127] OF CHAR;

  TextRec = RECORD
              Handle   : WORD;
              Mode     : WORD;
              BufSize  : WORD;
              Private  : WORD;
              BufPos   : WORD;
              BufEnd   : WORD;
              BufPtr   : ^TextBuffer;
              OpenFunc : POINTER;
              InOutFunc : POINTER;
              FlushFunc : POINTER;
              CloseFunc : POINTER;
              { 16 byte user data area, I use 4 bytes }
              PrintMode : WORD;   { not currently used}
              LPTNo : WORD;       { LPT number in [0..2] }
              UserData : ARRAY [1..12] OF CHAR;
              Name : ARRAY [0..79] OF CHAR;
              Buffer : TextBuffer;
            END;
CONST
  LPTFileopen : BOOLEAN = FALSE;

VAR
  LPTExitSave : POINTER;

  PROCEDURE Out_Char (Ch : CHAR; LPTNo : WORD; VAR ErrorCode : INTEGER);
    { call macro to send char to LPTNo.  If bit 4, the Printer Selected bit }
    { is not set upon return, it is assumed that an error has occurred.     }

  BEGIN
    ErrorCode := DoInt17 (Ch, LPTNo);
    IF (ErrorCode AND $10) = $10 THEN { if bit 4 is set }
      ErrorCode := 0              { no error }
      { if bit 4 is not set, error is passed untouched and placed in IOResult }
  END;

  FUNCTION LstIgnore (VAR F : TextRec) : INTEGER;
    { A do nothing, no error routine }
  BEGIN
    LstIgnore := 0                { return 0 for IOResult }
  END;

  FUNCTION LstOutput (VAR F : TextRec) : INTEGER;
    { Send whatever has accumulated in the Buffer to int 17h   }
    { If error occurs, return in IOResult.  See Inside Turbo   }
    { Pascal chapter of TP4 manual for more info on TFDD       }
  VAR
    I : WORD;
    ErrorCode : INTEGER;

  BEGIN
    LstOutput := 0;

    {$IFDEF DOERRORCHECKING}
    WHILE NOT Printer_OK DO
    BEGIN
    GotoXY(1,23);ClrEol;
    Write('Please check Printer, and press any key when ready...');
    Readkey;
    END;
    {$ENDIF}

    WITH F DO BEGIN
      FOR I := 0 TO PRED (BufPos) DO
      BEGIN
        Out_Char (BufPtr^ [I], LPTNo, ErrorCode); { send each char to printer }
        IF ErrorCode <> 0 THEN BEGIN { if error }
          LstOutput := ErrorCode; { return errorcode in IOResult }
          EXIT                    { return from function }
        END
      END;
      BufPos := 0
    END;
  END;

  PROCEDURE AssignLst (VAR F : TEXT; LPTNumber : WORD);
    { like Turbo's assign, except associates Text variable with one of the LPTs }

  BEGIN
    WITH TextRec (F) DO
      BEGIN
        Mode := fmClosed;
        BufSize := SIZEOF (Buffer);
        BufPtr := @Buffer;
        OpenFunc := @LstIgnore;   { you don't open the BIOS printer functions }
        CloseFunc := @LstIgnore;  { nor do you close them }
        InOutFunc := @LstOutput;  { but you can Write to them }
        FlushFunc := @LstOutput;  { and you can WriteLn to them }
        LPTNo := LPTNumber;       { user selected printer num (in [0..2]) }
        MOVE (LPTNames [LPTNumber], Name, 4); { set name of device }
        BufPos := 0;              { reset BufPos }
      END;
  END;

  PROCEDURE OutputToFile (FName : STRING);
  BEGIN
    ASSIGN (Lst, FName);
    REWRITE (Lst);
    LPTFileopen := TRUE;
  END;

  FUNCTION PrinterStatus (LPTNum : BYTE) : BYTE;
  VAR
    Status : BYTE;
  BEGIN
    Status := GetROMPrinterStatus (LPTNum);
    IF (Status AND $B8) = $90 THEN
      PrinterStatus := 0          {all's well}
    ELSE IF (Status AND $20) = $20 THEN
      PrinterStatus := 1          {no Paper}
    ELSE IF (Status AND $10) = $00 THEN
      PrinterStatus := 2          {off line}
    ELSE IF (Status AND $80) = $00 THEN
      PrinterStatus := 3          {busy}
    ELSE IF (Status AND $08) = $08 THEN
      PrinterStatus := 4;         {undetermined error}
  END;

  FUNCTION Printer_OK : BOOLEAN;
  VAR
    Retry : BYTE;
  BEGIN
    Retry := 0;
    WHILE (PrinterStatus (LPTPort) <> 0) AND (Retry < 255) DO INC (Retry);
    Printer_OK := (PrinterStatus (LPTPort) = 0);
  END;                            {PrinterReady}

  PROCEDURE SelectPrinter (LPTNum : BYTE);
  BEGIN
    IF (LPTNum >= 0) AND (LPTNum <= 3) THEN
      LPTPort := LPTNum;
    AssignLst (Lst, LPTPort);      { set up turbo 3 compatable Lst device }
    REWRITE (Lst);
  END;

  PROCEDURE ResetPrinter;
  VAR
    address : INTEGER ABSOLUTE $0040 : $0008;
    portno, DELAY : INTEGER;
  BEGIN
    portno := address + 2;
    Port [portno] := 232;
    FOR DELAY := 1 TO 2000 DO {nothing} ;
    Port [portno] := 236;
  END;                            {ResetPrinter}

  PROCEDURE LptExitHandler; FAR;
  BEGIN
    IF LPTFileopen THEN CLOSE (Lst);
    ExitProc := LPTExitSave;
  END;

BEGIN

  LPTExitSave := ExitProc;
  ExitProc := @LptExitHandler;

  {$IFDEF AssignLstDevice}

  LPTPort := 0;
  AssignLst (Lst, LPTPort);        { set up turbo 3 compatable Lst device }
  REWRITE (Lst);

  {$ENDIF}

  {$IFDEF DOERRORCHECKING}
  WHILE NOT Printer_OK DO
  BEGIN
  GotoXY(1,23);ClrEol;
  Write('Please check Printer, and press any key when ready...');
  Readkey;
  END;
  {$ENDIF}

END.

