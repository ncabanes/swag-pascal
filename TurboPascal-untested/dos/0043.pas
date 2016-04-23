{$I- $F+}
UNIT Errtrp;
INTERFACE

USES
crt,
dos;

CONST
ScrSeg : WORD = $B800;
FGNorm = lightgray;
BGNorm = blue;
FGErr = white;
BGErr = red;

VAR
SaveInt24 : POINTER;
ErrorRetry : BOOLEAN;
IOCode    : INTEGER;
version   : INTEGER;

PROCEDURE DisplayError (ErrNo : INTEGER);
PROCEDURE RuntimeError;
PROCEDURE DisableErrorHandler;
PROCEDURE ErrTrap (ErrNo : INTEGER);


IMPLEMENTATION


VAR
  ExitSave : POINTER;
  regs : REGISTERS;


(**************************************************************************)

CONST
 INT59ERROR  : INTEGER  = 0;
 ERRORACTION : BYTE = 0;
 ERRORTYPE   : BYTE = 0;
 ERRORAREA   : BYTE = 0;
 ERRORRESP   : BYTE = 0;
 ERRORRESULT : INTEGER = 0;

TYPE
errmsg         = ARRAY [0..89] OF STRING;
ermsgPtr       = ^errmsg;

VAR
Errs : ermsgPTR;

PROCEDURE HideCursor; Assembler;
Asm
  MOV   ax, $0100
  MOV   cx, $2607
  INT   $10
END;

PROCEDURE ShowCursor; Assembler;
Asm
  MOV   ax, $0100
  MOV   cx, $0506
  INT   $10
END;


PROCEDURE box;
VAR
 i : INTEGER;
BEGIN
  TEXTCOLOR (FGErr);
  TEXTBACKGROUND (BGErr);
  GOTOXY (1, 1);
  WRITELN ('┌───────────────  Critical Error  ───────────────┐');
    FOR i := 1 TO 5 DO
  WRITELN ('│                                                │');
  WRITE  ('└────────────────────────────────────────────────┘');
END;{box}

FUNCTION DosVer : INTEGER;
VAR
 Maj : shortint;
 Min : shortint;
 regs : REGISTERS;

BEGIN
 regs.ah := $30;
 MSDOS (Regs);
 Maj := regs.al;
 Min := regs.ah;
 DosVer := Maj;
END;

PROCEDURE InitErrs;
BEGIN
NEW (Errs);
Errs^ [0] :=   '             No error occured           ';
Errs^ [1] :=    '          Invalid function number       ';
Errs^ [2] :=    '              File not found            ';
Errs^ [3] :=    '              Path not found            ';
Errs^ [4] :=    '            No handle available         ';
Errs^ [5] :=    '              Access denied             ';
Errs^ [6] :=    '             Invalid handle             ';
Errs^ [7] :=    '     Memory control blocks destroyed    ';
Errs^ [8] :=    '           Insufficient memory          ';
Errs^ [9] :=    '      Invalid memory block address      ';
Errs^ [10] :=    '       Invalid SET command string       ';
Errs^ [11] :=    '             Invalid format             ';
Errs^ [12] :=    '          Invalid access code           ';
Errs^ [13] :=    '              Invalid data              ';
Errs^ [14] :=    '                Reserved                ';
Errs^ [15] :=    '       Invalid drive specification      ';
Errs^ [16] :=    '   Attempt to remove current directory  ';
Errs^ [17] :=    '             Not same device            ';
Errs^ [18] :=    '        No more files to be found       ';
Errs^ [19] :=    '          Disk write protected          ';
Errs^ [20] :=    '            Unknown unit ID             ';
Errs^ [21] :=    '          Disk drive not ready          ';
Errs^ [22] :=    '          Command not defined           ';
Errs^ [23] :=    '            Disk data error             ';
Errs^ [24] :=    '      Bad request structure length      ';
Errs^ [25] :=    '             Disk seek error            ';
Errs^ [26] :=    '         Unknown disk media type        ';
Errs^ [27] :=    '          Disk sector not found         ';
Errs^ [28] :=    '          Printer out of paper          ';
Errs^ [29] :=    '      Write error - Printer Error?      ';
Errs^ [30] :=    '               Read error               ';
Errs^ [31] :=    '            General failure             ';
Errs^ [32] :=    '         File sharing violation         ';
Errs^ [33] :=    '         File locking violation         ';
Errs^ [34] :=    '          Improper disk change          ';
Errs^ [35] :=    '             No FCB available           ';
Errs^ [36] :=    '         Sharing buffer overflow        ';
Errs^ [37] :=    '                Reserved                ';
Errs^ [38] :=    '                Reserved                ';
Errs^ [39] :=    '                Reserved                ';
Errs^ [40] :=    '                Reserved                ';
Errs^ [41] :=    '                Reserved                ';
Errs^ [42] :=    '                Reserved                ';
Errs^ [43] :=    '                Reserved                ';
Errs^ [44] :=    '                Reserved                ';
Errs^ [45] :=    '                Reserved                ';
Errs^ [46] :=    '                Reserved                ';
Errs^ [47] :=    '                Reserved                ';
Errs^ [48] :=    '                Reserved                ';
Errs^ [49] :=    '                Reserved                ';
Errs^ [50] :=    '      Network request not supported     ';
Errs^ [51] :=    '      Remote computer not listening     ';
Errs^ [52] :=    '        Duplicate name on network       ';
Errs^ [53] :=    '         Network name not found         ';
Errs^ [54] :=    '             Network busy               ';
Errs^ [55] :=    '      Network device no longer exists   ';
Errs^ [56] :=    '      NetBIOS command limit exceeded    ';
Errs^ [57] :=    '      Network adapter hardware error    ';
Errs^ [58] :=    '      Incorrect response from network   ';
Errs^ [59] :=    '        Unexpected network error        ';
Errs^ [60] :=    '      Incompatible remote adapter       ';
Errs^ [61] :=    '            Print queue full            ';
Errs^ [62] :=    '      Not enough space for print file   ';
Errs^ [63] :=    '         Print file was deleted         ';
Errs^ [64] :=    '        Network name was deleted        ';
Errs^ [65] :=    '             Access denied              ';
Errs^ [66] :=    '       Network device type incorrect    ';
Errs^ [67] :=    '          Network name not found        ';
Errs^ [68] :=    '        Network name limit exceeded     ';
Errs^ [69] :=    '      NetBIOS session limit exceeded    ';
Errs^ [70] :=    '           Temporarily paused           ';
Errs^ [71] :=    '       Network request not accepted     ';
Errs^ [72] :=    '  Print or disk re-direction is paused  ';
Errs^ [73] :=    '                Reserved                ';
Errs^ [74] :=    '                Reserved                ';
Errs^ [75] :=    '                Reserved                ';
Errs^ [76] :=    '                Reserved                ';
Errs^ [77] :=    '                Reserved                ';
Errs^ [78] :=    '                Reserved                ';
Errs^ [79] :=    '                Reserved                ';
Errs^ [80] :=    '           File already exists          ';
Errs^ [81] :=    '                Reserved                ';
Errs^ [82] :=    '              Cannot make               ';
Errs^ [83] :=    '     Critical-error interrupt failure   ';
Errs^ [84] :=    '          Too many redirections         ';
Errs^ [85] :=    '          Duplicate redirection         ';
Errs^ [86] :=    '           Duplicate password           ';
Errs^ [87] :=    '            Invalid parameter           ';
Errs^ [88] :=    '            Network data fault          ';
Errs^ [89] :=    '             Undefined Error            ';
END;

PROCEDURE CritError (Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD);
 INTERRUPT;
TYPE
ScrPtr         = ^ScrBuff;
ScrBuff        = ARRAY [1..4096] OF BYTE;

VAR
  Display,
  SaveScr    : ScrPtr;

  c         : CHAR;
  ErrorPrompt,
  msg        : STRING;
  ErrNum     : BYTE;

  drive,
  area,
  al, ah      : BYTE;

  deviceattr : ^WORD;
  devicename : ^CHAR;
  ch,
  i          : shortint;
  actmsg,
  tmsg,
  amsg,
  dname      : STRING;
BEGIN
    ah := HI (ax);
    al := LO (ax);                            { in case DOS version < 3     }
    ErrNum := LO (DI) + 19;                     { save the error and add      }
    msg := Errs^ [ErrNum];                    { add 19 to convert to        }
                                           { standard DOS error          }
    tmsg := '';
    actmsg := '';                            { we can't suggest a response }

 IF (ah AND $80) = 0 THEN                    { if a disk error then        }
   BEGIN                                   { get the drive and area      }
     amsg := ' drive ' + CHR (al + 65) + ':';
     area := (ah AND 6) SHR 1;
     CASE area OF
     0 : amsg := amsg + ' dos communications area ';
     1 : amsg := amsg + ' disk directory area ';
     2 : amsg := amsg + ' files area ';
     END;
   END
ELSE                                       { else if a device error }
   BEGIN                                   { get type of device     }
     deviceattr := PTR (bp, si + 4);
     i := 0;
     IF (deviceattr^ AND $8000) <> 0 THEN     { if a character device }
       BEGIN                                { like a printer        }
         amsg := 'character device';
         ch := 0;
         REPEAT
         i := i + 1;
         devicename := PTR (bp, si + $0a + ch);      { get the device name  }
         dname [i] := devicename^;
         dname [0] := CHR (i);
         INC (ch);
         UNTIL (devicename^ = CHR (0) ) OR (ch > 7);
       END
    ELSE                                     { else }
      BEGIN                                  { just inform of the error }
        dname := 'disk in ' + CHR (al) + ':';
        msg := ' general failure ' ;
        END;
     amsg := amsg + ' ' + dname;
     END;

 INLINE ($FA);                           { Enable interrupts       }
 Display := PTR (ScrSeg, $0000);            { save the current screen }
 NEW (SaveScr);
 SaveScr^ := Display^;
 WINDOW (15, 10, 65, 16);                   { make a box to display the}
 TEXTCOLOR (FGErr);                      { error message            }
 TEXTBACKGROUND (BGErr);
 CLRSCR;
 box;

  IF Version >= 3 THEN                     { check the DOS version   }
  BEGIN                                  { major component         }
  regs.ah := $59;                          { and use DosExtErr since }
  regs.bx := $00;                          { it is available         }
  MSDOS (Regs);
  INT59ERROR := regs.ax;
  ERRORTYPE := regs.bh;
  ERRORACTION := regs.bl;
  ERRORAREA := regs.ch;
  msg := Errs^ [INT59ERROR];                { get the error information}
(*
  case ERRORAREA of
  1: amsg:='Unknown';
  2: amsg:='Block Device';               { usually disk access error}
  3: amsg:='Network Problem';
  4: amsg:='Serial Device';              { printer or COM problem   }
  5: amsg:='Memory';                     { corrupted memory         }
  end;
*)
  CASE ERRORTYPE OF
  1 : tmsg := 'Out of Resource';            { no channels, space       }
  2 : tmsg := 'Temporary situation';        { file locked for instance;}
                                          { not an error and will    }
                                          { clear eventually         }
  3 : tmsg := 'Authorization Violation';     { permission problem e.g.  }
                                          { write to read only file  }
  4 : tmsg := 'Internal Software Error';     { system software bug      }
  5 : tmsg := 'Hardware Error';              { serious trouble -- fix   }
                                          { the machine              }
  6 : tmsg := 'System Error';                { serious trouble software }
                                          { at fault -- e.g. missing }
                                          { CONFIG file              }
  7 : tmsg := 'Program Error';               { inconsistent request     }
                                          { from your program        }
  8 : tmsg := 'Not found';                   { as stated                }
  9 : tmsg := 'Bad Format';                  { as stated                }
  10 : tmsg := 'Locked';                      { interlock situation      }
  11 : tmsg := 'Media Error';                 { CRC error, wrong disk in }
                                          { drive, bad disk cluster  }
  12 : tmsg := 'Exists';                      { collision with existing  }
                                          { item, e.g. duplicate     }
                                          { device name              }
  13 : tmsg := 'Unknown Error';
  END;

  CASE ERRORACTION OF
  1 : actmsg := 'Retry';                     { retry a few times then   }
                                          { give user abort option   }
                                          { if not fixed             }
  2 : actmsg := 'Delay Retry';               { pause, retry, then give  }
                                          { user abort option        }
  3 : actmsg := 'User Action';               { ask user to reenter item }
                                          { e.g. bad drive letter or }
                                          { filename used            }
  4 : actmsg := 'Abort';                      { invoke an orderly shut   }
                                          { down -- close files, etc }
  5 : actmsg := 'Immediate Exit';             { don't clean up, you may  }
                                          { really screw something up}
  6 : actmsg := 'Ignore';
  7 : actmsg := 'Retry';                     { after user intervention: }
  END;                                    { let the user fix it first}

  END;
amsg := tmsg + amsg;
actmsg := 'Suggested Action: ' + actmsg;

GOTOXY ( (54 - LENGTH (msg) ) DIV 2, 3);
WRITE (msg);

GOTOXY ( (54 - LENGTH (amsg) ) DIV 2, 4);
WRITE (amsg);

GOTOXY ( (54 - LENGTH (actmsg) ) DIV 2, 6);
WRITE (actmsg);
                                          { display it              }

ErrorPrompt := ' I)gnore R)etry A)bort F)ail ? ';
GOTOXY ( (54 - LENGTH (ErrorPrompt) ) DIV 2, 5);
WRITE (ErrorPrompt);
REPEAT                                     { get the user response  }
c := READKEY;
c := UPCASE (c);
UNTIL c IN ['A', 'R', 'I', 'F'];
WINDOW (1, 1, 80, 25);                         { restore the screen     }
TEXTCOLOR (FGNorm);
TEXTBACKGROUND (BGNorm);
Display^ := SaveScr^;
DISPOSE (SaveScr);
CASE c OF
  'I' : BEGIN
        AX := 0;
        ERRORRETRY := FALSE;
      END;
  'R' : BEGIN
        AX := 1;
        ERRORRETRY := TRUE;
      END;
  'A' : BEGIN
        Ax := 2;
        ERRORRETRY := FALSE;
        Showcursor;
      END;
  'F' : BEGIN
        Ax := 3;
        ERRORRETRY := FALSE;
        Showcursor;
      END;
END;

END;{procedure CritError}

(**************************************************************************)
PROCEDURE DisplayError (ErrNo : INTEGER);
VAR
msg,
exitmsg : STRING;
BEGIN
    CASE ErrNo OF
    2 : exitmsg := 'File not found';
    3 : exitmsg := 'Path not found';
    4 : exitmsg := 'Too many open files';
    5 : exitmsg := 'Access denied';
    6 : exitmsg := 'Invalid file handle';
    12 : exitmsg := 'Invalid file access code';
    15 : exitmsg := 'Invalid drive';
    16 : exitmsg := 'Cannot remove current directory';
    17 : exitmsg := 'Cannot rename across drives';
    100 : exitmsg := 'Disk read error';
    101 : exitmsg := 'Disk write error - Disk Full ?';
    102 : exitmsg := 'File not assigned';
    103 : exitmsg := 'File not opened';
    104 : exitmsg := 'File not open for input';
    105 : exitmsg := 'File not open for output';
    106 : exitmsg := 'Invalid numeric format';
    150 : exitmsg := 'Disk is write protected';
    151 : exitmsg := 'Unknown unit';
    152 : exitmsg := 'Drive not ready';
    153 : exitmsg := 'Unkown command';
    154 : exitmsg := 'CRC error in data';
    155 : exitmsg := 'Bad drive request structure length';
    156 : exitmsg := 'Disk seek error';
    157 : exitmsg := 'Unknown media type';
    158 : exitmsg := 'Sector not found';
    159 : exitmsg := 'Printer out of paper';
    160 : exitmsg := 'Device write fault';
    161 : exitmsg := 'Device read fault';
    162 : exitmsg := 'Hardware failure';
    200 : exitmsg := 'Division by zero';
    201 : exitmsg := 'Range check error';
    202 : exitmsg := 'Stack overflow';
    203 : exitmsg := 'Heap overflow';
    204 : exitmsg := 'Invalid pointer operation';
    205 : exitmsg := 'Floating point overflow';
    206 : exitmsg := 'Floating point underflow';
    207 : exitmsg := 'Invalid floating point operation'
    ELSE exitmsg := 'Unknown Error # ';
    END;

  msg := exitmsg;

  TEXTCOLOR (FGErr);
  TEXTBACKGROUND (BGErr);
  GOTOXY ( (50 - LENGTH (msg) ) DIV 2, 3);
  WRITE (msg);

END;

PROCEDURE ErrTrap (ErrNo : INTEGER);
TYPE
ScrPtr         = ^ScrBuff;
ScrBuff        = ARRAY [1..4096] OF BYTE;

VAR
  Display,
  SaveScr    : ScrPtr;

  c         : CHAR;
  ErrorPrompt,
  msg : STRING;

BEGIN

 Display := PTR (ScrSeg, $0000);            { save the current screen }
 NEW (SaveScr);
 SaveScr^ := Display^;
 WINDOW (15, 10, 65, 16);                   { make a box to display the}
 TEXTCOLOR (FGErr);                      { error message            }
 TEXTBACKGROUND (BGErr);
 CLRSCR;
 box;

  ErrorRetry := TRUE;
  DisplayError (ErrNo);

                                          { display it              }

ErrorPrompt := ' I)gnore R)etry A)bort F)ail ? ';
GOTOXY ( (54 - LENGTH (ErrorPrompt) ) DIV 2, 5);
WRITE (ErrorPrompt);
REPEAT                                     { get the user response  }
c := READKEY;
c := UPCASE (c);
UNTIL c IN ['A', 'R', 'I', 'F'];
CASE c OF
  'I' : ErrorRetry := FALSE;
  'R' : ErrorRetry := TRUE;
  'A' : BEGIN
        ErrorRetry := FALSE;
        Showcursor;
      END;
  'F' : BEGIN
        ErrorRetry := FALSE;
        Showcursor;
      END;
  END;
  IF ErrorRetry = FALSE THEN
    BEGIN
      GOTOXY (4, 4);
      WRITE ('If you are unable to correct the error');
      GOTOXY (4, 5);
      WRITE ('please report the error ', #40, Errno, #41, ' and      ');
      GOTOXY (4, 6);
      WRITE ('exact circumstances when it occurred to us.');
      WINDOW (1, 1, 80, 25);                         { restore the screen     }
      TEXTCOLOR (FGNorm);
      TEXTBACKGROUND (BGNorm);
      Display^ := SaveScr^;
      DISPOSE (SaveScr);

      ErrorAddr := NIL;
      GOTOXY (1, 1);
      Showcursor;
      HALT;
    END;
WINDOW (1, 1, 80, 25);                         { restore the screen     }
TEXTCOLOR (FGNorm);
TEXTBACKGROUND (BGNorm);
Display^ := SaveScr^;
DISPOSE (SaveScr);
END;

PROCEDURE RuntimeError;

TYPE
ScrPtr         = ^ScrBuff;
ScrBuff        = ARRAY [1..4096] OF BYTE;

VAR
  Display,
  SaveScr    : ScrPtr;

  c         : CHAR;
  ErrorPrompt,
  msg : STRING;

BEGIN
  IF ErrorAddr <> NIL THEN
    BEGIN
      Display := PTR (ScrSeg, $0000);            { save the current screen }
      NEW (SaveScr);
      SaveScr^ := Display^;
      WINDOW (15, 10, 65, 16);                   { make a box to display the}
      TEXTCOLOR (FGErr);                      { error message            }
      TEXTBACKGROUND (BGErr);
      CLRSCR;
      box;
      GOTOXY (15, 1);
      WRITE ('   Fatal  Error   ');
      DisplayError (ExitCode);
      GOTOXY (20, 2);
      WRITE ('Run time error ', ExitCode);
      GOTOXY (4, 4);
      WRITE ('If you are unable to correct the error');
      GOTOXY (4, 5);
      WRITE ('Please report the error and exact');
      GOTOXY (4, 6);
      WRITE ('circumstances when it occurred to us.');
      GOTOXY (4, 7);
      WRITE ( ' Press a key to continue ');
      ErrorAddr := NIL;

      ExitProc := ExitSave;
      c := READKEY;
    END;
  WINDOW (1, 1, 80, 25);                         { restore the screen     }
  TEXTCOLOR (FGNorm);
  TEXTBACKGROUND (BGNorm);
  Display^ := SaveScr^;
  DISPOSE (SaveScr);

  ShowCursor;
  TEXTCOLOR (lightgray);
  TEXTBACKGROUND (black);

  SETINTVEC ($24, SaveInt24);
END;

PROCEDURE DisableErrorHandler;
BEGIN
  SETINTVEC ($24, SaveInt24);
  ExitProc := ExitSave;
END;

(**************************************************************************)
BEGIN
  InitErrs;
  Version := DosVer;
  Hidecursor;
  IF mem [$0000 : $0449] <> 7 THEN ScrSeg := $B800 ELSE ScrSeg := $B000;
  GETINTVEC ($24, SaveInt24);
  SETINTVEC ($24, @CritError);
  ExitSave := ExitProc;
  ExitProc := @RuntimeError;
END.

{ ---------------------   DEMO PROGRAM -------------------------- }

{$I-}  { THIS MUST BE HERE FOR THE ERROR TRAP TO WORK !! }
PROGRAM testerr;
USES dos, crt, printer, errtrp;
VAR
regs : REGISTERS;
fil : FILE;
Pchar : STRING;
BEGIN
CLRSCR;
(*COMMENT OUT THE FUNCTIONS NOT BEING TESTED*)
(*       USING THE CRITICAL ERROR HANDLER PROCEDURE CRITERR  *)

(* remove disc from A: drive to test this *)
(******************************************)

WRITE ('trying to write to drive a: ');

  ASSIGN (fil, 'A:filename.ext');
  REWRITE (fil);

DisableErrorHandler;

(*  USING THE ERRTRAP PROCEDURE *)

WRITE ('trying to write to drive a: using ERRTRAP');
REPEAT
ASSIGN (fil, 'A:filename.ext');
REWRITE (fil);
iocode := IORESULT;
IF IOCode <> 0 THEN ErrTrap (IOCode);
UNTIL ERRORRETRY = FALSE;

END.
