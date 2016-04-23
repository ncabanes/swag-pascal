{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT CritErr;

INTERFACE

USES DOS;

TYPE
    Str10 = STRING[10];
    IOErrorRec = Record
                 RoutineName : PathStr;
                 ErrorAddr   : Str10;
                 ErrorType   : Str10;
                 TurboResult : Word;  { TP Error number }
                 IOResult    : Word;  { DOS Extended number }
                 ErrMsg      : PathStr;
                 End;


{}PROCEDURE IOResultTOErrorMessage (IOCode : WORD; VAR MSG : STRING);
{}PROCEDURE GetDOSErrorMessage (VAR Msg : STRING);
{}FUNCTION  UserIOError(ErrNum : INTEGER; VAR IOErr : IOErrorRec) : BOOLEAN;
{}PROCEDURE CriticalErrorDOS;
{}PROCEDURE CriticalErrorTP;
{}PROCEDURE CriticalErrorOwn(ErrAddr: POINTER);

IMPLEMENTATION

VAR
    TurboInt24: POINTER;        { Holds address of TP's error handler }

  function Hex(v: Longint; w: Integer): String;
  var
    s               : String;
    i               : Integer;
  const
    hexc            : array [0 .. 15] of Char= '0123456789abcdef';
  begin
    s[0] := Chr(w);
    for i := w downto 1 do begin
      s[i] := hexc[v and $F];
      v := v shr 4
    end;
    Hex := s;
  end {Hex};


PROCEDURE CriticalErrorDOS;

    BEGIN
        SetIntVec($24,SaveInt24);
    END;



PROCEDURE CriticalErrorTP;

    BEGIN
        SetIntVec($24,TurboInt24);
    END;



PROCEDURE CriticalErrorOwn(ErrAddr: POINTER);

    BEGIN
        SetIntVec($24,ErrAddr);
    END;



PROCEDURE GetDOSErrorMessage (VAR Msg : STRING);

TYPE pointerwords =
  RECORD
    ofspoint, segpoint : WORD;
  END;

VAR
  breakdown : pointerwords ABSOLUTE erroraddr;

BEGIN
IOResultToErrorMessage (ExitCode, MSG);
      WITH breakdown DO
      Msg := Msg + ' $' + hex (SegPoint, 4) + ':' + hex (OfsPoint, 4);
END;                          {Exitprogram}

PROCEDURE IOResultToErrorMessage (IOCode : WORD; VAR MSG : STRING);
BEGIN
      CASE IOCode OF
      $01 : msg := 'Invalid DOS Function Number';
      $02 : msg := 'File not found ';
      $03 : msg := 'Path not found ';
      $04 : msg := 'Too many open files ';
      $05 : msg := 'File access denied ';
      $06 : msg := 'Invalid file handle ';
      $07 : msg := 'Memory Control Block Destroyed';
      $08 : msg := 'Not Enough Memory';
      $09 : msg := 'Invalid Memory Block Address';
      $0A : msg := 'Environment Scrambled';
      $0B : msg := 'Bad Program EXE File';
      $0C : msg := 'Invalid file access mode';
      $0D : msg := 'Invalid Data';
      $0E : msg := 'Unknown Unit';
      $0F : msg := 'Invalid drive number ';
      $10 : msg := 'Cannot remove current directory';
      $11 : msg := 'Cannot rename across drives';
      $12 : msg := 'Disk Read/Write Error';
      $13 : msg := 'Disk Write-Protected';
      $14 : msg := 'Unknown Unit';
      $15 : msg := 'Drive Not Ready';
      $16 : msg := 'Unknown Command';
      $17 : msg := 'Data CRC Error';
      $18 : msg := 'Bad Request Structure Length';
      $19 : msg := 'Seek Error';
      $1A : msg := 'Unknown Media Type';
      $1B : msg := 'Sector Not Found';
      $1C : msg := 'Printer Out Of Paper';
      $1D : msg := 'Disk Write Error';
      $1E : msg := 'Disk Read Error';
      $1F : msg := 'General Failure';
      $20 : msg := 'Sharing Violation';
      $21 : msg := 'Lock Violation';
      $22 : msg := 'Invalid Disk Change';
      $23 : msg := 'File Control Block Gone';
      $24 : msg := 'Sharing Buffer Exceeded';
      $32 : msg := 'Unsupported Network Request';
      $33 : msg := 'Remote Machine Not Listening';
      $34 : msg := 'Duplicate Network Name';
      $35 : msg := 'Network Name NOT Found';
      $36 : msg := 'Network BUSY';
      $37 : msg := 'Device No Longer Exists On NETWORK';
      $38 : msg := 'NetBIOS Command Limit Exceeded';
      $39 : msg := 'Adapter Hardware ERROR';
      $3A : msg := 'Incorrect Response From NETWORK';
      $3B : msg := 'Unexpected NETWORK Error';
      $3C : msg := 'Remote Adapter Incompatible';
      $3D : msg := 'Print QUEUE FULL';
      $3E : msg := 'No space For Print File';
      $3F : msg := 'Print File Cancelled';
      $40 : msg := 'Network Name Deleted';
      $41 : msg := 'Network Access Denied';
      $42 : msg := 'Incorrect Network Device Type';
      $43 : msg := 'Network Name Not Found';
      $44 : msg := 'Network Name Limit Exceeded';
      $45 : msg := 'NetBIOS session limit exceeded';
      $46 : msg := 'Filer Sharing temporarily paused';
      $47 : msg := 'Network Request Not Accepted';
      $48 : msg := 'Print or Disk File Paused';
      $50 : msg := 'File Already Exists';
      $52 : msg := 'Cannot Make Directory';
      $53 : msg := 'Fail On Critical Error';
      $54 : msg := 'Too Many Redirections';
      $55 : msg := 'Duplicate Redirection';
      $56 : msg := 'Invalid Password';
      $57 : msg := 'Invalid Parameter';
      $58 : msg := 'Network Device Fault';
      $59 : msg := 'Function Not Supported By NETWORK';
      $5A : msg := 'Required Component NOT Installed';

      (* Pascal Errors *)
       94 : msg := 'EMS Memory Swap Error';
       98 : msg := 'Disk Full';
      100 : msg := 'Disk read error ';
      101 : msg := 'Disk write error ';
      102 : msg := 'File not assigned ';
      103 : msg := 'File not open ';
      104 : msg := 'File not open for input ';
      105 : msg := 'File not open for output ';
      106 : msg := 'Invalid numeric format ';
      150 : msg := 'Disk is write_protected';
      151 : msg := 'Unknown unit';
      152 : msg := 'Drive not ready';
      153 : msg := 'Unknown command';
      154 : msg := 'CRC error in data';
      155 : msg := 'Bad drive request structure length';
      156 : msg := 'Disk seek error';
      157 : msg := 'Unknown media type';
      158 : msg := 'Sector not found';
      159 : msg := 'Printer out of paper';
      160 : msg := 'Device write fault';
      161 : msg := 'Device read fault';
      162 : msg := 'Hardware Failure';
      163 : msg := 'Sharing Confilct';
      200 : msg := 'Division by zero ';
      201 : msg := 'Range check error ';
      202 : msg := 'Stack overflow error ';
      203 : msg := 'Heap overflow error ';
      204 : msg := 'Invalid pointer operation ';
      205 : msg := 'Floating point overflow ';
      206 : msg := 'Floating point underflow ';
      207 : msg := 'Invalid floating point operation ';
      390 : msg := 'Serial Port TIMEOUT';
      399 : msg := 'Serial Port NOT Responding';

     1008 : Msg := 'EMS Memory Swap Error '
      ELSE
          GetDosErrorMessage (Msg);
      END;
END;


FUNCTION  UserIOError(ErrNum : INTEGER; VAR IOErr : IOErrorRec) : BOOLEAN;
{ RETURN ALL INFO ABOUT THE ERROR IF IT OCCURED}
CONST
      ErrTitles : ARRAY [1..5] OF STRING [10] =
                  ('System', 'Disk', 'Network', 'Serial', 'Memory');

VAR
    Msg       : STRING;
    Regs      : REGISTERS;

    BEGIN

    UserIOError := FALSE;
    FILLCHAR(IOErr,SizeOf(IOErr),#0);
    IF ErrNum <=0 THEN EXIT;

    { GET DOS Extended Error }
    WITH Regs DO
    BEGIN
      AH := $59;
      BX := $00;
      MSDOS (Regs);
    END;

    IOResultToErrorMessage (Regs.AX, Msg);

    IOErr.RoutineName  := PARAMSTR (0);
    IOErr.ErrorAddr    := Hex (SEG (ErrorAddr^), 4) + ':' + Hex (OFS (ErrorAddr^), 4);
    IOErr.ErrorType    := ErrTitles[Regs.CH];
    IOErr.TurboResult  := ErrNum;
    IOErr.IOResult     := Regs.AX;
    IOErr.ErrMsg       := Msg;

    UserIOError        := (ErrNum > 0);
    END;

BEGIN
 GetIntVec($24,TurboInt24);
 CriticalErrorDOS;
END.

{ --------------------------     DEMO  --------------------- }

{ EXAMPLE FOR CRITICAL ERROR HANDLER UNIT }
{ COMPILE AND RUN FROM DOS !!!   WILL NOT WORK PROPERLY FROM THE IDE }
{$I-}   { A MUST FOR THE CRITICAL HANDLER TO WORK !!!! }

USES
  CRT, CRITERR;

VAR
  f:  TEXT;
  i:  INTEGER;
  ErrMsg : STRING;
  IOErr  : IOErrorRec;

BEGIN
    ClrScr;
    WriteLn(' EXAMPLE PROGRAM FOR CRITICAL ERROR HANDLER ');
    WriteLn;
    WriteLn('Turbo Pascal replaces the operating system''s critical-error');
    WriteLn('handler with its own.  For this demonstration we will generate');
    WriteLn('a critical error by attempting to access a diskette that is not');
    WriteLn('present.  Please ensure that no diskette is in drive A, then');
    WriteLn('press RETURN...');
    ReadLn;
    CriticalErrorTP;
    Assign(f,'A:NOFILE.$$$');
    WriteLn;
    WriteLn('Now attempting to access drive...');
    Reset(f);
    IF UserIOError(IOResult,IOErr) THEN
       BEGIN
       WriteLn(IOErr.RoutineName);
       WriteLn(IOErr.ErrorAddr);
       WriteLn(IOErr.ErrorType);
       WriteLn(IOErr.TurboResult);
       WriteLn(IOErr.IOResult);
       WriteLn(IOErr.ErrMsg);
       END;
    WriteLn;
    Write('Press RETURN to continue...');
    ReadLn;
    WriteLn;
    CriticalErrorDOS;
    WriteLn('With the DOS error handler restored, you will be presented');
    WriteLn('with the usual "Abort, Retry, Ignore?" prompt when such an');
    WriteLn('error occurs.  (Later DOS versions allow a "Fail" option.)');
    WriteLn('Run this program several times and try different responses.');
    Write('Press RETURN to continue...');
    ReadLn;
    WriteLn('Now attempting to access drive again...');
    Reset(f);
    IF UserIOError(IOResult,IOErr) THEN
       BEGIN
       WriteLn(IOErr.RoutineName);
       WriteLn(IOErr.ErrorAddr);
       WriteLn(IOErr.ErrorType);
       WriteLn(IOErr.TurboResult);
       WriteLn(IOErr.IOResult);
       WriteLn(IOErr.ErrMsg);
       END;
    Readkey;
END.

