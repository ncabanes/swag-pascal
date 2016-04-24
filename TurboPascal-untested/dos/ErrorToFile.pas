(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0061.PAS
  Description: Error to file
  Author: JEFF WILSON
  Date: 08-24-94  13:35
*)

{
Here is a unit that I've played with a bit.. I have no idea who the original
author is. What it does is expand the Runtime Errors reported by TP and
optionally logs it to a file that you supply the name to.. It works fine for
me on MSDOS 3.3 and 5.0.  If you make any improvements to it I would
appreciate a copy of it..
}

{$S-}
UNIT Errors ;

INTERFACE

USES
  Dos ;

VAR
  ErrorFile  : PathStr ;                 { optional name you include in the }
                                         { main program code                }
PROCEDURE CheckRTError ;

IMPLEMENTATION

VAR
  ErrorExitProc : Pointer ;

FUNCTION HexStr(w: Word): String ;
  CONST
    HexChars : Array [0..$F] of Char = '0123456789ABCDEF' ;
  BEGIN
    HexStr := HexChars[Hi(w) shr 4]
            + HexChars[Hi(w) and $F]
            + HexChars[Lo(w) shr 4]
            + HexChars[Lo(w) and $F] ;
  END ;

FUNCTION ExtendedError: String ; { goto DOS to get the last reported error }
  VAR
    Regs : Registers ;
  BEGIN
    FillChar(Regs,Sizeof(Regs),#0) ;
    Regs.AH := $59 ;
    MSDos(Regs) ;
    CASE Regs.AX OF
      $20 : ExtendedError := 'Share Violation' ;
      $21 : ExtendedError := 'Lock Violation' ;
      $23 : ExtendedError := 'FCB Unavailable' ;
      $24 : ExtendedError := 'Sharing Buffer Overflow' ;
      ELSE  ExtendedError := 'Extended Error ' + HexStr(Regs.AX) ;
    END ; { case }
  END ;

FUNCTION ErrorMsg(Err : Integer): String ;
BEGIN
  CASE Err OF
      1 : ErrorMsg := 'Invalid Function Number';
      2 : ErrorMsg := 'File Not Found';
      3 : ErrorMsg := 'Path Not Found';
      4 : ErrorMsg := 'Too Many Open Files';
      5 : ErrorMsg := 'File Access Denied';
      6 : ErrorMsg := 'Invalid File Handle';

     12 : ErrorMsg := 'Invalid File Access Code';

     15 : ErrorMsg := 'Invalid Drive Number';
     16 : ErrorMsg := 'Cannot Remove Current Directory';
     17 : ErrorMsg := 'Cannot Rename Across Drives';
     18 : ErrorMsg := 'No More Files';

    100 : ErrorMsg := 'Disk Read Past End Of File';
    101 : ErrorMsg := 'Disk Full';
    102 : ErrorMsg := 'File Not Assigned';
    103 : ErrorMsg := 'File Not Open';
    104 : ErrorMsg := 'File Not Open For Input';
    105 : ErrorMsg := 'File Not Open For Output';
    106 : ErrorMsg := 'Invalid Numeric Format';

    150 : ErrorMsg := 'Disk is write protected';
    151 : ErrorMsg := 'Unknown Unit';
    152 : ErrorMsg := 'Drive Not Ready';
    153 : ErrorMsg := 'Unknown command';
    154 : ErrorMsg := 'CRC Error in data';
    155 : ErrorMsg := 'Bad drive request structure length';
    156 : ErrorMsg := 'Disk seek error';
    157 : ErrorMsg := 'Unknown media type';
    158 : ErrorMsg := 'Sector not found';
    159 : ErrorMsg := 'Printer out of paper';
    160 : ErrorMsg := 'Device write fault';
    161 : ErrorMsg := 'Device read fault';
    162 : ErrorMsg := 'Hardware failure';

    163 : ErrorMsg := ExtendedError ;

    200 : ErrorMsg := 'Division by zero';
    201 : ErrorMsg := 'Range check error';
    202 : ErrorMsg := 'Stack overflow error';
    203 : ErrorMsg := 'Heap overflow error';
    204 : ErrorMsg := 'Invalid pointer operation';
    205 : ErrorMsg := 'Floating point overflow';
    206 : ErrorMsg := 'Floating point underflow';
    207 : ErrorMsg := 'Invalid floating point operation';
    208 : ErrorMsg := 'Overlay manager not installed';
    209 : ErrorMsg := 'Overlay file read error';
    210 : ErrorMsg := 'Object not initialized';
    211 : ErrorMsg := 'Call to abstract method';
    212 : ErrorMsg := 'Stream registration error';
    213 : ErrorMsg := 'Collection index out of range';
    214 : ErrorMsg := 'Collection overflow error';
    215 : ErrorMsg := 'Arithmetic overflow error';
    216 : ErrorMsg := 'General protection fault';
  END ;
END ;

FUNCTION LZ(W : Word): String ;
  VAR
    s : String ;
  BEGIN
    Str(w:0,s) ;
    IF Length(s) = 1 THEN s := '0' + s ;
    LZ := s ;
  END ;

FUNCTION TodayDate : String ;
  VAR
    Year,
    Month,
    Day,
    Dummy,
    Hour,
    Minute,
    Second : Word ;
  BEGIN
    GetDate(Year, Month, Day, Dummy) ;
    GetTime(Hour, Minute, Second, Dummy) ;
    TodayDate := LZ(Month) + '/' + LZ(Day) + '/' + LZ(Year-1900)
               + '   ' + LZ(Hour) + ':' + LZ(Minute) ;
  END ;

{$F+}
PROCEDURE CheckRTError ;
  VAR
   F : Text ;
  BEGIN
    IF ErrorAddr <> Nil THEN
      BEGIN
        IF ErrorFile <> '' THEN
          BEGIN
            Assign(F,ErrorFile) ;
            {$I-} Append(F) ; {$I+}
            IF IOResult <> 0 THEN Rewrite(F) ;
            Writeln(F,'Date: ' + TodayDate) ;
            Write(F,'RunTime Error #',ExitCode,' at ') ;
            Write(F,HexStr(Seg(ErrorAddr^)) + ':') ;
            WriteLn(F,HexStr(Ofs(ErrorAddr^))) ;
            Writeln(F,ErrorMsg(ExitCode)) ;
            Writeln(F,'') ;
            Close(F) ;
          END ;
        Writeln('Date: ' + TodayDate) ;
        Write('RunTime Error #',ExitCode,' at ') ;
        Write(HexStr(Seg(ErrorAddr^)) + ':') ;
        WriteLn(HexStr(Ofs(ErrorAddr^))) ;
        Writeln(ErrorMsg(ExitCode)) ;
        Writeln ;
        ErrorAddr := Nil ;          { reset variable so TP doesn't report  }
        ExitProc := ErrorExitProc ; { the error and reset the Exit Pointer }
      END ;
  END ;
{$F-}

BEGIN
  ErrorFile := '' ;                 { don't log the error to a file }
  ErrorExitProc := ExitProc ;
  ExitProc := @CheckRTError ;
END.

{============== DEMO  ==============}

PROGRAM Test ;

USES
  Errors ;

VAR
  TestFile : Text ;

BEGIN
  ErrorFile := 'TESTERR.TXT' ;     { log errors to this file }
  RunError(3) ;                    { test whatever you want  }
END.


