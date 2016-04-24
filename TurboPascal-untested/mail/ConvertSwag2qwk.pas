(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0012.PAS
  Description: Convert SWAG2QWK
  Author: GAYLE DAVIS
  Date: 11-08-93  04:45
*)

{$V-,S-,I-}
{$M 16384,0,355360}   { leave some memory for PKZIP !!! }


{ By POPULAR Request .................
  this SIMPLE program let's you read SWAG files and CONVERT them to QWK
  format readable by many of the popular MAIL readers out there.  I
  tested it with OLX by MUSTANG.  It should would with the others as well.

  WARNING ...  Many QWK mail readers are limited in the amount of text
  that can be contained in one message.  SEVERAL of the SWAG files exceed
  what can be read !!  Therefore, you will NOT be able to read all of these.
  Your mail reader program will truncate them.  This was an interesting
  exercise anyway, and shows how QWK mail packets can be created.

  Gayle Davis
  November, 1993  }

USES
  Dos, Crt;

CONST
     ControlHdr : ARRAY [1..11] OF STRING [30] = (

 {1} 'SOURCEWARE ARCHIVAL GROUP',
 {2} 'Goshen',
 {3} '875-8133',
 {4} 'Gayle Davis',
 {5} '99999,SWAG',
 {6} '11-03-1993,04:41:37',
 {7} 'SWAG Genius',
 {8} '',     { QMAIL Menu name ???                 }
 {9} '0',    { allways ZERO ???                    }
{10} '0',    { total number of messages in package }
{11} '56');  { number of conferences-1 here        }
             { next is 0 , then first conference   }

TYPE

  BlockArray   = ARRAY [1..128] OF CHAR;
  CharArray    = ARRAY [1..6] OF CHAR;  { to read in chunks }
  ControlArray = ARRAY [1..200] OF STRING [20];
  bsingle      = array [0..4] of byte;

  MSGDATHdr = RECORD  { ALSO the format for SWAG files !!! }
    Status   : CHAR;
    MSGNum   : ARRAY [1..7] OF CHAR;
    Date     : ARRAY [1..8] OF CHAR;
    Time     : ARRAY [1..5] OF CHAR;
    UpTO     : ARRAY [1..25] OF CHAR;
    UpFROM   : ARRAY [1..25] OF CHAR;
    Subject  : ARRAY [1..25] OF CHAR;
    PassWord : ARRAY [1..12] OF CHAR;
    ReferNum : ARRAY [1..8] OF CHAR;
    NumChunk : CharArray;
    Alive    : BYTE;
    LeastSig : BYTE;
    MostSig  : BYTE;
    Reserved : ARRAY [1..3] OF CHAR;
  END;

CONST

     PKZIP   : PathStr = 'PKZIP.EXE';

VAR

  SWAGF,
  QWKF        : FILE;
  ControlF    : TEXT;

  SavePath,
  SwagPath,
  SWAGFn,
  MsgFName    : PATHSTR;

  TR          : SearchRec;

  ConfNum,
  Number      : WORD;

  MSGHdr      : MSGDatHdr;
  ch          : CHAR;
  count       : INTEGER;
  chunks      : INTEGER;
  ControlVal  : ControlArray;
  ControlIdx  : BYTE;
  WStr        : STRING;

FUNCTION TrimL (InpStr : STRING) : STRING; ASSEMBLER;
ASM
      PUSH   DS
      LDS    SI, InpStr
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      INC    DI
      JCXZ   @@2

      MOV    BL, ' '
      CLD
@@1 :  LODSB
      CMP    AL, BL
      LOOPE  @@1
      DEC    SI
      INC    CX
      REP    MOVSB

@@2 :  XCHG   AX, DI
      MOV    DI, WORD PTR @Result
      SUB    AX, DI
      DEC    AX
      STOSB
      POP    DS
END;

FUNCTION TrimR (InpStr : STRING) : STRING;

VAR i : INTEGER;

BEGIN
   i := LENGTH (InpStr);
   WHILE (i >= 1) AND (InpStr [i] = ' ') DO
      i := i - 1;
   TrimR := COPY (InpStr, 1, i)
END;

FUNCTION TrimB (InpStr : STRING) : STRING;

BEGIN
 TrimB := TrimL (TrimR (InpStr) );
END;

FUNCTION IntStr (Num : LONGINT; Width : BYTE; Zeros : BOOLEAN) : STRING;
{ Return a string value (width 'w')for the input integer ('n') }
  VAR
    Stg : STRING;
  BEGIN
    STR (Num : Width, Stg);
    IF Zeros THEN BEGIN
    FOR Num := 1 TO Width DO IF Stg [Num] = #32 THEN Stg [Num] := '0';
    END ELSE Stg := TrimL (Stg);
    IntStr := Stg;
  END;

FUNCTION NameOnly (FileName : PathStr) : PathStr;
{ Strip any path information from a file specification }
VAR
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
BEGIN
   FSplit (FileName, Dir, Name, Ext);
   NameOnly := Name;
END {NameOnly};

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

PROCEDURE FindSwagPath (VAR P : PathStr);
VAR
  S : PathStr;
BEGIN
  IF SwagPath <> '' THEN S := SwagPath + '\DRIVES.SWG' ELSE
     S := 'DRIVES.SWG';
  S := FSearch (S, GetEnv ('PATH') );
  IF S = '' THEN
     BEGIN
     WriteLn(#7,'You GOTTA have the SWAG files somewhere on your PATH to do this !!');
     WriteLn(#7,'OR, you can enter the path on the command line !!');
     HALT(1);
     END;
S := FExpand (S);
P := FExpand (COPY(S,1,POS('DRIVES',S)-1));
END;

PROCEDURE FindPKZip;
VAR
  S : PathStr;
BEGIN
  S := FSearch ('PKZIP.EXE', GetEnv ('PATH') );
  IF S = '' THEN
     BEGIN
     WriteLn(#7,'You GOTTA have PKZIP somewhere on your PATH to do this !!');
     HALT(1);
     END;
     PKZIP := FExpand (S);
END;

PROCEDURE CleanUp;
{ clean up after ourselves }
BEGIN
  FINDFIRST ('*.NDX', $21, TR);
  WHILE DosError = 0 DO
        BEGIN
        EraseFile(TR.NAME);
        FINDNEXT (TR);
        END;
  EraseFile('MESSAGES.DAT');
  EraseFile('CONTROL.DAT');
END;

PROCEDURE CreateControlDat;
VAR
    I : BYTE;
BEGIN
     ControlHdr [11] := IntStr (PRED (ConfNum), 3, FALSE);
     ASSIGN (ControlF, 'CONTROL.DAT');
     REWRITE (ControlF);
     FOR I := 1 TO 11 DO
         WRITELN (ControlF, ControlHdr [i]);
     FOR I := 1 TO ControlIdx DO
         WRITELN (ControlF, ControlVal [i]);
     CLOSE (ControlF);
END;

PROCEDURE CreateMessageDat;
VAR
    I    : BYTE;
    Buff : BlockArray;
BEGIN
  FILLCHAR (ControlVal, SIZEOF (ControlVal), #0);
  FILLCHAR (Buff, SIZEOF (Buff), #32);
  FILLCHAR (MsgHdr, SIZEOF (MsgHdr), #32);
  ConfNum    := 0;
  ControlIdx := 0;
  Number     := 0;
  ASSIGN (QWKF, 'MESSAGES.DAT');
  REWRITE (QWKF, SIZEOF (MsgHdr) );
  WStr := 'SWAG TO QWK (c) 1993 GDSOFT';
  FOR I := 1 TO LENGTH (WStr) DO Buff [i] := WSTR [i];
  BLOCKWRITE (QwkF, Buff, 1);
END;

FUNCTION ArrayTOInteger (B : CharArray; Len : BYTE) : LONGINT;

VAR I : BYTE;
    S : STRING;
    E  : INTEGER;
    T  : INTEGER;

BEGIN
    S := '';
    FOR I := 1 TO PRED (Len) DO IF B [i] <> #32 THEN S := S + B [i];
    VAL (S, T, E);
    IF E = 0 THEN ArrayToInteger := T;
END;

PROCEDURE ReadMessage (HDR : MSGDatHdr; RelNum : LONGINT; VAR Chunks : INTEGER);
VAR
  Buff : BlockArray;
  J    : INTEGER;
  I    : BYTE;
  NS   : STRING;

BEGIN

  { read the header block }
  SEEK (SwagF, RelNum - 1);
  BLOCKREAD  (SwagF, Hdr, 1);

  { Correct the record number }
  INC(Number);
  NS := IntStr(Number,7,FALSE);
  WHILE Length(NS) < 7 DO NS := NS + #32;
  MOVE (NS, Hdr.MsgNum, 7);
  Hdr.LeastSig := ConfNum;
  Hdr.MostSig  := Number;

  { write the header to our QWK file }
  BLOCKWRITE (QwkF,  Hdr, 1);

  { process the rest of the blocks }
  Chunks := ArrayToInteger (HDR.NumChunk, 6);
  FOR J := 1 TO PRED (Chunks) DO
  BEGIN
    BLOCKREAD  (SwagF, Buff, 1);
    BLOCKWRITE (QwkF,  Buff, 1);
  END;

END;

PROCEDURE ProcessSwag (FN : PathStr);
VAR
    ndxF : File;
    b    : bSingle;
    r    : REAL;
    n    : LONGINT;

    { converts TP real to Microsoft 4 bytes single .. GOOFY !!!! }
    procedure real_to_msb (preal : real; var b : bsingle);
    var
         r : array [0 .. 5] of byte absolute preal;
    begin
         b [3] := r [0];
         move (r [3], b [0], 3);
    end; { procedure real_to_msb }


BEGIN

  WriteLn('Process .. ',FN);
  { create the NDX file }
  ASSIGN  (ndxF,IntStr(ConfNum,3,TRUE)+'.NDX');
  REWRITE (ndxF,1);

  ASSIGN (SwagF, FN);
  RESET (SwagF, SIZEOF (MsgHdr) );
  Count  := 2;  { start at RECORD #2 }

  WHILE (Count < FILESIZE (SwagF) ) DO
        BEGIN

        n := SUCC(FilePos(QwkF));      { ndx wants the RELATIVE position }
        r := N;                        { make a REAL                     }
        REAL_TO_MSB(r,b);              { convert to MSB format           }
        BLOCKWRITE(ndxF,B,SizeOf(B));  { store it                        }

        ReadMessage (MSGHdr, Count, Chunks);
        INC (Count, Chunks);
        END;

  CLOSE (SwagF);
  CLOSE (NdxF);

  { update the CONTROL file array }
  INC (ControlIdx);
  ControlVal [ControlIdx] := IntStr (ConfNum, 3, TRUE);
  INC (ControlIdx);
  ControlVal [ControlIdx] := NameOnly (FN);
  INC (ConfNum);

END;


BEGIN

  ClrScr;

  IF ParamCount > 0 THEN SwagPath := FExpand(ParamStr(1));

  EraseFile('SWAG.QWK');  { make sure we don't have one yet }

  FindSwagPath (SwagPath);

  FindPkZip;

  CreateMessageDat;

  IF SwagPath [LENGTH (SwagPath) ] <> '\' THEN SwagPath := SwagPath + '\';

  FINDFIRST (SwagPath + '*.SWG', $21, TR);
  WHILE DosError = 0 DO
        BEGIN
        ProcessSwag (SwagPath + TR.Name);
        FINDNEXT (TR);
        END;

  CLOSE (QwkF);

  CreateControlDat;

  SwapVectors;
  Exec(PKZIP,' -ex SWAG.QWK *.NDX MESSAGES.DAT CONTROL.DAT');
  SwapVectors;

  CleanUp;

END.

