(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0022.PAS
  Description: Execute PKZIP
  Author: GAYLE DAVIS
  Date: 05-26-94  08:32
*)

UNIT PKZExec;

INTERFACE

USES DOS;

{ Purpose :  Execute PKZIP/PKUNZIP on archive files                         }
{ Uses specialized EXEC procedure so main program can use ALL of the memory }
{ Also shows how to take over INT29 to NOT display anything on the CRT      }

CONST
    PKZIP             : PathStr = 'PKZIP.EXE';
    PKUNZIP           : PathStr = 'PKUNZIP.EXE';

VAR ZIPError          : INTEGER;

PROCEDURE CleanUpDir (WorkDir, FileMask : STRING);
                   {Erases files based on a mask }

PROCEDURE DisplayZIPError;
                   { PKZip interface }

PROCEDURE DefaultCleanup (WorkDir : STRING);
                   {Erases files *.BAK, *.MAP, temp*.*}

PROCEDURE ShowEraseStats;
                   {shows count & bytes recovered}

FUNCTION  UnZIPFile (ZIPOpts, ZIPName, DPath, fspec : STRING; qt : BOOLEAN) : BOOLEAN;
                   {Uses PKUnZip to de-archive files }

FUNCTION  ZIPFile (ZIPOpts, ZIPName, fspec  : STRING; qt : BOOLEAN) : BOOLEAN;
                   {Uses PKZip to archive files }

IMPLEMENTATION

VAR  ZIPDefaultZIPOpts : STRING [16];
VAR  ZIPFileName       : STRING [50];
VAR  ZIPDPath          : STRING [50];

VAR  EraseCount        : WORD;        { files erased }
     EraseSizeK        : LONGINT;     { kilobytes released by erasing files }
     ShowOnWrite       : BOOLEAN;
     I29H              : POINTER;

{ EXECUTE STUFF - SHRINK HEAP AND EXECUTE LIKE EXECDOS }

{$F+}
PROCEDURE Int29Handler (AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD); INTERRUPT;
VAR
  Dummy : BYTE;
BEGIN
  Asm
    Sti
  END;
  IF ShowOnWrite THEN WRITE (CHAR (LO (Ax) ) );
  Asm
    Cli
  END;
END;

PROCEDURE ReallocateMemory (P : POINTER); ASSEMBLER;
ASM
  MOV  AX, PrefixSeg
  MOV  ES, AX
  MOV  BX, WORD PTR P + 2
  CMP  WORD PTR P, 0
  JE   @OK
  INC  BX

 @OK :
  SUB  BX, AX
  MOV  AH, 4Ah
  INT  21h
  JC   @X
  LES  DI, P
  MOV  WORD PTR HeapEnd, DI
  MOV  WORD PTR HeapEnd + 2, ES
 @X :
END;

{ ZAP this DEFINE if NOT 386,486}
{..$DEFINE CPU386}

FUNCTION EXECUTE (Name : PathStr ; Tail : STRING) : WORD; ASSEMBLER;
ASM
  {$IFDEF CPU386}
  DB      66h
  PUSH    WORD PTR HeapEnd
  DB      66h
  PUSH    WORD PTR Name
  DB      66h
  PUSH    WORD PTR Tail
  DB      66h
  PUSH    WORD PTR HeapPtr
  {$ELSE}
  PUSH    WORD PTR HeapEnd + 2
  PUSH    WORD PTR HeapEnd
  PUSH    WORD PTR Name + 2
  PUSH    WORD PTR Name
  PUSH    WORD PTR Tail + 2
  PUSH    WORD PTR Tail
  PUSH    WORD PTR HeapPtr + 2
  PUSH    WORD PTR HeapPtr
  {$ENDIF}

  CALL ReallocateMemory
  CALL SwapVectors
  CALL DOS.EXEC
  CALL SwapVectors
  CALL ReallocateMemory
  MOV  AX, DosError
  OR   AX, AX
  JNZ  @OUT
  MOV  AH, 4Dh
  INT  21h
 @OUT :
END;
{$F-}

FUNCTION ExecuteCommand(p,s : STRING; quiet : BOOLEAN) : INTEGER;
BEGIN
ShowOnWrite := NOT quiet;  { turn off INT 29 }
GETINTVEC ($29, I29H);
SETINTVEC ($29, @Int29Handler);         { Install interrupt handler }
Execute(p,s);
SETINTVEC ($29, I29h);
IF DosError = 0 THEN ExecuteCommand := DosExitCode   ELSE ExecuteCommand := DosError;
END;

FUNCTION AddBackSlash (dName : STRING) : STRING;
BEGIN
  IF dName [LENGTH (dName) ] IN ['\', ':', #0] THEN
    AddBackSlash := dName
  ELSE
    AddBackSlash := dName + '\';
END;

FUNCTION EraseFile ( S : PathStr ) : BOOLEAN ;

VAR F : FILE;

BEGIN

EraseFile := FALSE;

ASSIGN (F, S);
RESET (F);

IF IORESULT <> 0 THEN EXIT;

  CLOSE (F);
  ERASE (F);
  EraseFile := (IORESULT = 0);

END;

FUNCTION FileExists ( S : PathStr ) : BOOLEAN ;

VAR F : FILE;

BEGIN

FileExists := FALSE;

ASSIGN (F, S);
RESET (F);

IF IORESULT <> 0 THEN EXIT;

  CLOSE (F);
  FileExists := (IORESULT = 0);

END;

PROCEDURE CleanUpFile (WorkDir : STRING; SR : searchRec);
VAR l    : LONGINT;
    BEGIN
    WITH SR DO
        BEGIN
        l := size DIV 512;
        IF (attr AND 31) = 0 THEN
            BEGIN
            IF l = 0 THEN l := 1;
            EraseSizeK := EraseSizeK + l;
            WRITELN ('         Removing: ', (AddBackSlash (WorkDir) + name),
                    '   ', l DIV 2, 'k');
            EraseFile (AddBackSlash (WorkDir) + name);
            INC (EraseCount);
            END
        ELSE WRITELN (' ??  ', (AddBackSlash (WorkDir) + name), '   ', l DIV 2, 'k',
                     '  attr: ', attr);
        END;
    END;


PROCEDURE CleanUpDir (WorkDir, FileMask : STRING);
VAR Frec : SearchRec;
    s    : STRING [64];
    BEGIN
    s := '';
    FINDFIRST (AddBackSlash (WorkDir) + FileMask, anyfile, Frec);
    WHILE doserror = 0 DO
        BEGIN
        CleanUpFile (WorkDir, Frec);
        FINDNEXT (Frec);
        END;
    END;


PROCEDURE DefaultCleanup (WorkDir : STRING);
    BEGIN
    CleanUpDir (WorkDir, '*.BAK');
    CleanUpDir (WorkDir, '*.MAP');
    CleanUpDir (WorkDir, 'TEMP*.*');
    END;


PROCEDURE DisplayZIPError;
    BEGIN
    CASE ziperror OF
        0       : WRITELN ('no error');
        2,3     : WRITELN (ziperror : 3, ' Error in ZIP file ');
        4..8    : WRITELN (ziperror : 3, ' Insufficient Memory');
        11,12   : WRITELN (ziperror : 3, ' No MORE files ');
        9,13    : WRITELN (ziperror : 3, ' File NOT found ');
        14,50   : WRITELN (ziperror : 3, ' Disk FULL !! ');
        51      : WRITELN (ziperror : 3, ' Unexpected EOF in ZIP file ');
        15      : WRITELN (ziperror : 3, ' Zip file is Read ONLY! ');
        10,16   : WRITELN (ziperror : 3, ' Bad or illegal parameters ');
        17      : WRITELN (ziperror : 3, ' Too many files ');
        18      : WRITELN (ziperror : 3, ' Could NOT open file ');
        1..90   : WRITELN (ziperror : 3, ' Exec DOS error ');
        98      : WRITELN (ziperror : 3, ' requested file not produced ');
        99      : WRITELN (ziperror : 3, ' archive file not found');
        END;
    END;


PROCEDURE PKZIPInit;
     BEGIN
     PKZIP   := FSearch('PKZIP.EXE',GetEnv('PATH'));
     PKUNZIP := FSearch('PKUNZIP.EXE',GetEnv('PATH'));
     ZIPError          := 0;
     ZIPDefaultZIPOpts := '-n';
     ZIPFileName       := '';
     ZIPDPath          := '';
     EraseCount        := 0;
     EraseSizeK        := 0;
     END;


PROCEDURE ShowEraseStats;
    {-Show statistics at the end of run}
    BEGIN
    WRITELN ('Files Erased: ', EraseCount,
            '  bytes used: ', EraseSizeK DIV 2, 'k');
    END;


FUNCTION  UnZIPFile ( ZIPOpts, ZIPName, DPath, fspec : STRING; qt : BOOLEAN) : BOOLEAN;
VAR s, zname     : STRING;
    i, j         : INTEGER;
    BEGIN
    ZIPError       := 0;
    UnZIPFile := TRUE;
    s := '';
    IF ZIPOpts <> '' THEN  s := s + ZIPOpts
    ELSE                   s := s + ZIPDefaultZIPOpts;

    IF ZIPName <> '' THEN  zname := ZIPName
    ELSE                   zname := ZIPFileName;
    IF NOT FileExists (zname) THEN
        BEGIN
        WRITELN ('zname: [', zname, ']');
        UnZIPFile := FALSE;
        ZIPError := 99;
        EXIT;
        END;

    s := s + ' ' + zname;

    IF DPath <> '' THEN s := s + ' ' + DPath
    ELSE                   s := s + ' ' + ZIPDPath;
    s := s + ' ' + fspec;
    ZIPError := ExecuteCommand (PKUNZIP,s,qt);
    IF ZIPError > 0 THEN
         BEGIN
         WRITELN ('PKUNZIP start failed ', ZIPError, ' [', s, ']');
         UnZIPFile := FALSE;
         END
    ELSE BEGIN
         i := POS ('*', fspec);
         j := POS ('?', fspec);
         IF (i = 0) AND (j = 0) THEN
             BEGIN
             IF NOT FileExists (DPath + fspec) THEN
                  BEGIN
                  UnZIPFile := FALSE;
                  ZIPError := 98;
                  END;
             END;
         END;
    END;

FUNCTION  ZIPFile ( ZIPOpts, ZIPName, fspec  : STRING; qt : BOOLEAN) : BOOLEAN;
VAR s, zname     : STRING;
    i, j         : INTEGER;
    BEGIN
    ZIPError       := 0;
    ZIPFile := TRUE;
    s  := '';
    IF ZIPOpts <> '' THEN  s := s + ZIPOpts
    ELSE                   s := s + ZIPDefaultZIPOpts;

    IF ZIPName <> '' THEN  zname := ZIPName
    ELSE                   zname := ZIPFileName;
    s := s + ' ' + zname;
    s := s + ' ' + fspec;
    ZIPError := ExecuteCommand (PKZIP,s,qt);
    IF ZIPError > 0 THEN
         BEGIN
         WRITELN ('PKZIP start failed ', ZIPError, ' [', s, ']');
         ZIPFile := FALSE;
         END
    ELSE BEGIN
         IF NOT FileExists (ZIPname + '.ZIP') THEN
              BEGIN
              ZIPFile := FALSE;
              ZIPError := 98;
              END;
         END;
    END;


     BEGIN
     PKZIPInit;
     END.

