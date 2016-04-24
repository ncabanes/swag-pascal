(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0035.PAS
  Description: Convert USENET to QWK format
  Author: GAYLE DAVIS
  Date: 05-31-96  09:16
*)

{NEWSQWK.PAS}

{
  Converts USENET files to QWK format ..

  You'll need PKZIP to use this.

  I use NXpress for my Newsgroup reader, in it saves it files with an
  extension of .MBX.  If you newsreader saves in someother format, then
  change the extension default at the front of the program.

  Perhaps you newsreader has a SAVEAS feature that allows you to download
  all of the material and save it as a text file.  If so, you could use it.
  Just save the files as SOMEFILE.MBX in the same DIR as this program,
  and it'll create the QWK file for you.

  Gayle Davis 05/28/96

}

{$V-,S-,I-}
{$M 16384,0,655360}   { no need to leave memory for PKZIP !!!
                        see the EXECUTE procedure below and find out how !!}

USES
  Dos, Crt, Upper, RLine;
       { NOTE : Upper is in STRINGS.SWG
                RLINE is in TEXTFILE.SWG }

CONST
     ControlHdr : ARRAY [1..11] OF STRING [30] = (

 {1} 'SOURCEWARE ARCHIVAL GROUP',  { change this to whatever you want ! }
 {2} 'Goshen',                     { ditto }
 {3} '875-8133',                   { ditto }
 {4} 'Gayle Davis',                { ditto }
 {5} '99999,SWAG',                 { ditto }
 {6} '11-03-1993,04:41:37',        { this will get updated automatically }
 {7} 'SWAG Genius',                { whatever pleases you ! }
 {8} '',     { QMAIL Menu name ???                 }
 {9} '0',    { allways ZERO ???                    }
{10} '0',    { total number of messages in package }
{11} '0');   { number of conferences-1 here        }
             { next is 0 , then first conference   }

TYPE

  BlockArray   = ARRAY [1..128] OF CHAR;
  CharArray    = ARRAY [1..6] OF CHAR;  { to read in chunks }
  ControlArray = ARRAY [1..100] OF STRING [40]; { set to 100 conferences !!}
  bsingle      = array [0..4] of byte;

  MSGDATHdr = RECORD
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

  MBXHeader = RECORD
   Xref     : STRING[70];
   Path     : STRING;
   From     : STRING[70];
   Subject  : STRING[70];
   Date     : STRING[40];
   Lines    : WORD;
   Status   : CHAR;
   END;

CONST

     PKZIP   : PathStr = 'PKZIP.EXE';
     QWKFile : PathStr = 'NEWS.QWK';

VAR

  MBXF        : TEXT;
  QWKF        : FILE;
  ControlF    : TEXT;

  FOL         : FileOfLinesPtr;
  FOLPos      : LONGINT;

  SavePath,
  SwagPath,
  MBXFn,
  MsgFName    : PATHSTR;

  TR          : SearchRec;

  ConfNum,
  Number      : WORD;  { message number, conference number }

  MSGHdr      : MSGDatHdr;
  ch          : CHAR;
  count       : INTEGER;
  chunks      : INTEGER;
  ControlVal  : ControlArray;
  ControlIdx  : BYTE;
  ConfName,
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

FUNCTION PadR (InpStr : STRING; FieldLen : BYTE) : STRING;
  {-Return a string right-padded to length len with ch}
VAR
  o    : STRING;
  SLen : BYTE ABSOLUTE InpStr;
BEGIN
  IF LENGTH (InpStr) >= FieldLen THEN
    PadR := COPY (InpStr, 1, FieldLen)
  ELSE BEGIN
    o [0] := CHR (FieldLen);
    MOVE (InpStr [1], o [1], SLen);
    IF SLen < 255 THEN
      FILLCHAR (o [SUCC (SLen) ], FieldLen - SLen, #32);
    PadR := o;
  END;
END;


FUNCTION GoodNumber (S : STRING) : BOOLEAN;
VAR
   Num  : LONGINT;
   Code : WORD;

BEGIN
Num := 0;
VAL (S, Num, Code);
GoodNumber := ( (Code = 0) AND (Num > 0) AND (S > '') );
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

 FUNCTION GetStr (VAR InpStr : STRING; Delim : CHAR) : STRING;

VAR i : INTEGER;
BEGIN
   i := POS (Delim, InpStr);
   IF i = 0 THEN
   BEGIN
      GetStr := InpStr;
      InpStr := ''
      END ELSE
          BEGIN
          GetStr := COPY (InpStr, 1, i - 1);
          DELETE (InpStr, 1, i)
          END
END;

FUNCTION Str2LongInt (S : STRING; VAR I : LONGINT) : BOOLEAN;
    {-Convert a string to an integer, returning true if successful}
  VAR
    code : WORD;
  BEGIN
    VAL (S, I, code);
    IF code <> 0 THEN BEGIN
      i := 0;
      Str2LongInt := FALSE;
    END ELSE
      Str2LongInt := TRUE;
  END;

FUNCTION GetNumber (VAR InpStr : STRING; Delim : CHAR) : LONGINT;

VAR S, S1 : STRING;
    I    : LONGINT;
BEGIN
   I  := 0;
   S1 := InpStr;
   S  := GetStr (InpStr, Delim);
   IF NOT GoodNumber (S) THEN InpStr := S1 ELSE
   Str2LongInt (S, I);
   GetNumber := I;
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

FUNCTION SlashDate(AddCentury : BOOLEAN) : STRING; {10/08/88}

VAR
  MonthName, dayname, yearname, dayofweekname : WORD;

BEGIN

  GETDATE (yearname, MonthName, dayname, dayofweekname);

  IF AddCentury THEN
  SlashDate := IntStr (MonthName, 2, TRUE) + '/' +
  IntStr (dayname, 2, TRUE) + '/' +
  IntStr (yearname, 4, TRUE) ELSE

  SlashDate := IntStr (MonthName, 2, TRUE) + '/' +
  IntStr (dayname, 2, TRUE) + '/' +
  COPY (IntStr (yearname, 4, TRUE), 3, 2);

END;

FUNCTION PlainTime : STRING; {09:10:01}

VAR
  Hr, Min, Sec, sec100 : WORD;

BEGIN
  GETTIME (Hr, Min, Sec, sec100);
  PlainTime := IntStr (Hr, 2, TRUE) + ':' +
  IntStr (Min, 2, TRUE) + ':' +
  IntStr (Sec, 2, TRUE);

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

PROCEDURE ReallocateMemory(P : POINTER); ASSEMBLER;
ASM
  MOV  AX, PrefixSeg
  MOV  ES, AX
  MOV  BX, WORD PTR P+2
  CMP  WORD PTR P,0
  JE   @OK
  INC  BX

 @OK:
  SUB  BX, AX
  MOV  AH, 4Ah
  INT  21h
  JC   @X
  LES  DI, P
  MOV  WORD PTR HeapEnd,DI
  MOV  WORD PTR HeapEnd+2,ES

 @X:
END;

FUNCTION EXECUTE(Name : PathStr ; Tail : STRING) : WORD; ASSEMBLER;
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
  PUSH    WORD PTR HeapEnd+2
  PUSH    WORD PTR HeapEnd
  PUSH    WORD PTR Name+2
  PUSH    WORD PTR Name
  PUSH    WORD PTR Tail+2
  PUSH    WORD PTR Tail
  PUSH    WORD PTR HeapPtr+2
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

 @OUT:
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

     ControlHdr [ 6] := SlashDate(TRUE)+','+PlainTime;
     ControlHdr [10] := IntStr (Count, 5, FALSE);
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
  WStr := 'NEWS TO QWK (c) 1996 GDSOFT';
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

PROCEDURE GetNewsGroupHeader(VAR NGH : MBXHeader);

VAR
   Junk : STRING;

BEGIN
     WHILE POS('STATUS:',UpCaseStr(FOL^.LastLine)) = 0 DO
         BEGIN
         FOL^.SeekLine(FOLPos);
         INC(FOLPos);
         IF POS('XREF:',UpCaseStr(FOL^.LastLine)) > 0 THEN
            NGH.XRef := TrimB(COPY(FOL^.LastLine,6,$FF));
         IF POS('PATH:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            NGH.Path := TrimB(COPY(FOL^.LastLine,6,$FF));
         IF POS('FROM:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            NGH.From := TrimB(COPY(FOL^.LastLine,6,$FF));
         IF POS('SUBJECT:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            NGH.Subject := Trimb(COPY(FOL^.LastLine,9,$FF));
         IF POS('DATE:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            NGH.Date := Trimb(COPY(FOL^.LastLine,6,$FF));
         IF POS('LINES:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            BEGIN
            Junk := GetStr(FOL^.LastLine,#32);
            NGH.Lines := GetNumber(FOL^.LastLine,#32);
            END;
         IF POS('STATUS:',UpCaseStr(FOL^.Lastline)) > 0 THEN
            NGH.STATUS := 'S';
         END;
END;

PROCEDURE ReadMessage(HdrPos : LONGINT);
VAR

  HDR    : MsgDatHdr;
  Block  : BlockArray;
  EndPos : LONGINT;
  Chunks : LONGINT;
  J,K    : INTEGER;
  I,SFOL : LONGINT;
  NS     : STRING;
  NGH    : MBXHeader;

  PROCEDURE MoveDataToBlock (Start, Len : BYTE; S : STRING; VAR Block : BlockArray);
  VAR I, K : BYTE;

  BEGIN
      K := 0;
      FOR I := Start TO PRED (Start + Len) DO
          BEGIN
          INC (k);
          Block [i] := S [k];
          END;
  END;


  PROCEDURE WriteHeader;
  BEGIN
  { write the header out }
  Seek(QwkF,HdrPos);
  FillChar(Block,SizeOf(Block),#32);
  MoveDataToBlock(  2, 7,PadR(IntStr(Number,7,FALSE),7),Block); { number }
  MoveDataToBlock(  9, 8,SlashDate(FALSE),Block);               { date }
  MoveDataToBlock( 17, 5,PlainTime,Block);                      { Time }
  MoveDataToBlock( 22,25,PadR(ControlHdr[4],25),Block);               { To   }
  MoveDataToBlock( 47,25,PadR(NGH.FROM,25),Block);              { From }
  MoveDataToBlock( 72,25,PadR(NGH.Subject,25),Block);           { Subj }
  MoveDataToBlock( 97,20,PadR('IMPORT',20),Block);              { Confname }
  MoveDataToBlock(117, 6,PadR(IntStr(Chunks,6,FALSE),6),Block); { Numpacs }
  MoveDataToBlock(124, 1,Chr(64),Block);
  BlockWrite(QwkF,Block,1);
  END;

  PROCEDURE WriteBlock;
  BEGIN
       BLOCKWRITE (QwkF, Block, 1);
       FILLCHAR (Block, SIZEOF (Block), #32);
       INC (chunks);  { increment block count }
       k := 0;
  END;

  PROCEDURE ProcessLine;
  VAR
     c : BYTE;
  BEGIN
       FOR c := 1 TO LENGTH(FOL^.LastLine) DO
           BEGIN
           INC (k);
           {
           IF FOL^.LastLine [c] = #13 THEN
              BEGIN
              Block [k] := #227;
              INC (c);
              END ELSE Block [k] := FOL^.LastLine [c];
           }
           Block[k] := FOL^.Lastline[c];
           IF k = 128 THEN WriteBlock;

           END; { for }

      { write end of line }
      INC(k);
      Block[k] := #227;
      IF k=128 THEN WriteBlock;
  END;

BEGIN

  SFOL := SUCC(FOLPos);

  { read the header block }
  GetNewsGroupHeader(NGH);

  { fill QWK Header with info }

  FILLCHAR (Block, SIZEOF (Block), #32);
  FILLCHAR(Hdr,SizeOF(Hdr),#0);

  { write the header out }
  chunks := 1;  { number packs }
  INC(Number);  { update message number }

   { write the header to our QWK file }
   WriteHeader;

   { write the blocks out }
   K := 0;
   FILLCHAR (Block, SIZEOF (Block), #32);

   FOR I := FOLPos TO FOLPos + NGH.Lines DO
       BEGIN
       FOL^.SeekLine(i);
       ProcessLine;
       END;

  J := I; { save the FOLPos for later }

  { write the original header out }
  FOL^.LastLine := ' ';
  ProcessLine;
  FOL^.LastLine := 'Original Header:';
  ProcessLine;
  FOL^.LastLine := ' ';
  ProcessLine;

  FOR I := SFOL TO FOLPos DO
      BEGIN
      FOL^.Seekline(i);
      ProcessLine;
      END;

  IF k > 0 THEN WriteBlock;
  FOLPos := j; { update the position in the file }

  EndPos := FilePos(QwkF);

  { update the header }
  WriteHeader;
  SEEK(QwkF, EndPos);

END;

PROCEDURE ProcessUseNetFile (FN : PathStr);
{ this is the heart !!  Read messages from MBX file and save in QWK file }
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

  WHILE (FOLPos < FOL^.Totallines) DO
        BEGIN

        n := SUCC(FilePos(QwkF));      { ndx wants the RELATIVE position }
        r := N;                        { make a REAL                     }
        REAL_TO_MSB(r,b);              { convert to MSB format           }
        BLOCKWRITE(ndxF,B,SizeOf(B));  { store it                        }

        WriteLn('Process message .. ',IntStr(Number+1,5,FALSE));
        ReadMessage(PRED(n));
        INC(Count);
        END;

  CLOSE (NdxF);

  { update the CONTROL file array }
  INC (ControlIdx);
  ControlVal [ControlIdx] := IntStr (ConfNum, 3, TRUE);
  INC (ControlIdx);
  ControlVal [ControlIdx] := ConfName;
  INC (ConfNum);

END;

PROCEDURE GetConferenceName;

VAR
   Junk : STRING;

BEGIN
     WHILE POS('NEWSGROUPS:',UpCaseStr(FOL^.LastLine)) = 0 DO
         BEGIN
         FOL^.SeekLine(FOLPos);
         INC(FOLPos);
         END;
Junk     := GetStr(FOL^.LastLine,' ');
ConfName := TrimB(FOL^.Lastline);
FOLPos   := 1;
END;

BEGIN

  ClrScr;

  IF ParamCount > 0 THEN MBXfn := FExpand(ParamStr(1)) ELSE MBXfn := '*.MBX';

  EraseFile(QWKFile);  { make sure we don't have one yet }

  FindPkZip;

  CreateMessageDat;

  Count := 0;  { total messages in package }

  { process all the files that we find with the extension }
  FINDFIRST (MBXFn, $21, TR);
  WHILE DosError = 0 DO
        BEGIN
        NEW(FOL, Init(TR.Name, 1024));
        FOLPos := 1;  { current position in RLINE array }
        GetConferenceName;
        ProcessUseNetFile (TR.Name);
        DISPOSE (FOL, Done);
        FindNext(TR);
        END;

  CLOSE (QwkF);

  CreateControlDat;

  Execute(PKZIP,' -ex '+QWKFile+' *.NDX MESSAGES.DAT CONTROL.DAT');

  CleanUp;


END.

