{
   Fast driver for backwards reading...  Aha!
   This is the way to do it.

   Below you will find the source of a "tail" program.
   I wrote it because I needed to check the status of some log files,
   and I didn't want to go through the entire file every time, as the
   files could grow quite large.

   It is currently limited to 255 chars per line, but that
   can easily be fixed (see the Limit const).

   Although it's not an exact solution to your problem, it will show you
   how to do "backwards" reading.
}

PROGRAM Tail;
{
  Shows the tailing lines of a text file.

  Syntax: TAIL [d:\path]filespec.ext [-<lines>]
          Default number of lines is 10.

          "TAIL filename -20" will show the 20 last lines

  Written by Lars Fosdal, 1993 
  Released to the Public Domain by Lars Fosdal, 1993
}

USES
  DOS, Objects, Strings;

CONST
  MaxBufSize = 32000;
TYPE
  pBuffer = ^TBuffer;
  TBuffer = ARRAY[0..MaxBufSize-1] OF Char;

  pRawStrCollection = ^TRawStrCollection;
  TRawStrCollection = OBJECT(TCollection)
    PROCEDURE FreeItem(Item:Pointer); VIRTUAL;
  END;
  
PROCEDURE TRawStrCollection.FreeItem(Item:Pointer);
BEGIN
  IF Item<>nil
  THEN StrDispose(pChar(Item));
END; {PROC TRawStrCollection.FreeItem}

FUNCTION ShowTail(FileName:String; n:Integer):Integer;
  PROCEDURE DumpLine(p:pChar); FAR;
  BEGIN
    IF p^=#255
    THEN Writeln
    ELSE Writeln(p);
  END;
CONST
  Limit = 255;  
VAR
  lines   : pRawStrCollection;
  fm      : Byte;
  f       : File;
  fs,fp   : LongInt;
  MaxRead : Word;
  Buf     : pBuffer;
  lc,ix,ex : Integer;
  sp      : ARRAY[0..Limit] OF Char;
BEGIN
  lines:=nil;
  fm:=FileMode;
  FileMode:=$40; {Read-only, deny none}
  Assign(f, FileName);
  Reset(f, 1);
  lc:=IOResult;
  IF lc=0
  THEN BEGIN
    New(Buf);
   
    fs:=FileSize(f); {First, let's find out how much to read}
    fp:=fs-MaxBufSize;
    IF fp<0
    THEN fp:=0;
    
    Seek(f,fp); {Then, read it}
    BlockRead(f, Buf^, MaxBufSize, MaxRead);
    Close(f);
    
    IF MaxRead>0
    THEN BEGIN
      New(Lines, Init(n,10));
      ix:=MaxRead-1;

      IF Buf^[ix]=^J THEN Dec(ix);
      IF (ix>0) and (Buf^[ix]=^M) THEN Dec(ix); {Skip trailing line break}

      WHILE (lc<n) and (ix>0)
      DO BEGIN
        ex:=ix;
        FillChar(sp, SizeOf(sp), 0);
        
        WHILE (ix>0) and not (Buf^[ix] =^J)
        DO Dec(ix);
        
        IF ex-ix<=Limit {If no break was found within limit, it's no txt file}
        THEN BEGIN
          IF ix=ex
          THEN sp[0]:=#255 {Pad empty lines to avoid zero-length pchar}
          ELSE StrLCopy(sp, @Buf^[ix+1], ex-ix);
          Inc(lc);

          Lines^.AtInsert(0, StrNew(sp));

          Dec(ix);
          WHILE (ix>0) and (Buf^[ix] =^M)
          DO Dec(ix);
        END
        ELSE BEGIN
          Writeln('"',FileName,'" doesn''t seem to be a text file');
          ix:=-1;
        END;

      END; {lc<n and ix>0}
    END {Maxread>0}
    ELSE Lines:=nil;
    Dispose(Buf);
  END
  ELSE lc:=-lc;

  IF Lines<>nil
  THEN BEGIN
    Lines^.ForEach(@DumpLine);
    Dispose(Lines, Done);
  END;

  ShowTail:=lc;
  FileMode:=fm;
END; {FUNC ShowTail}

TYPE
  CharSet = Set of Char;

FUNCTION StripAll(CONST Exclude:CharSet; S:String):String;
VAR
  ix : Integer;
BEGIN
  ix:=Length(S);
  WHILE ix>0
  DO BEGIN
    IF S[ix] in Exclude
    THEN Delete(S, ix, 1);
    Dec(ix);
  END;
  StripAll:=S;
END; {FUNC StripAll}  
  
VAR
  r : Integer;
  l : Integer;
  e : Integer;
BEGIN
  IF (ParamCount<1) or (ParamCount>2)
  THEN BEGIN
    Writeln('TAIL v.1.0 - PD 1993 Lars Fosdal');
    Writeln('  TAIL [d:\path]filename.ext [-n]');
    Writeln('  Default is 10 lines');
  END
  ELSE BEGIN
    IF ParamCount=2
    THEN BEGIN
      Val(StripAll(['/','-'], ParamStr(2)), l, e);
      IF e<>0
      THEN l:=10
    END
    ELSE l:=10;

    r:=ShowTail(ParamStr(1), l);
    IF r<0
    THEN BEGIN
      Writeln('Couldn''t open "',ParamStr(1),'"!  (Error ', -r,')');
      Halt(Word(-r));
    END;
  END;
END.
