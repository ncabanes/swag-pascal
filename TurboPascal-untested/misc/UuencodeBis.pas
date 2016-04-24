(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0076.PAS
  Description: UUEncode!
  Author: PETER BEEFTINK
  Date: 01-27-94  12:24
*)

{
> Yeah ! Please post your UU(EN/DE)CODE here ! I am interested, as well !

Here she goes then.
}

PROGRAM uuencode;

Uses Dos,Crt;

CONST
  Header = 'begin';
  Trailer = 'end';
  DefaultMode = '644';
  DefaultExtension = '.uue';
  OFFSET = 32;
  CHARSPERLINE = 60;
  BYTESPERHUNK = 3;
  SIXBITMASK = $3F;
TYPE
  Str80 = STRING[80];
VAR
  Infile: FILE OF Byte;
  Outfile: TEXT;
  Infilename, Outfilename, Mode: Str80;
  lineLength, numbytes, bytesInLine: INTEGER;
  Line: ARRAY [0..59] OF CHAR;
  hunk: ARRAY [0..2] OF Byte;
  chars: ARRAY [0..3] OF Byte;
  size,remaining : longint;  {v1.1 REAL;}
PROCEDURE Abort (Msg : Str80);
  BEGIN
    WRITELN(Msg);
    {$I-}                 {v1.1}
    CLOSE(Infile);
    CLOSE(Outfile);
    {$I+}                 {v1.1}
    HALT
  END; {of Abort}
PROCEDURE Init;
  PROCEDURE GetFiles;
    VAR
      i : INTEGER;
      TempS : Str80;
      Ch : CHAR;
    BEGIN
      IF ParamCount < 1 THEN Abort ('No input file specified.');
      Infilename := ParamStr(1);
      {$I-}
      ASSIGN (Infile, Infilename);
      RESET (Infile);
      {$I+}
      IF IOResult > 0 THEN Abort (CONCAT ('Can''t open file ', Infilename));
      size := FileSize(Infile);
{     IF size < 0 THEN size:=size+65536.0; }
      remaining := size;
      WRITE('Uuencoding file ', Infilename);
      i := POS('.', Infilename);
      IF i = 0
      THEN Outfilename := Infilename
      ELSE Outfilename := COPY (Infilename, 1, PRED(i));
      Mode := DefaultMode;
      { Process 2d cmdline arg (if any).
        It could be a new mode (rather than default "644")
        or it could be a forced output name (rather than
        "infile.uue")       }
      IF ParamCount > 1                         {got more args}
      THEN FOR i := 2 TO ParamCount DO BEGIN
        TempS := ParamStr(i);
        IF TempS[1] IN ['0'..'9']               {numeric : it's a mode}
        THEN Mode := TempS
        ELSE Outfilename := TempS               {it's output filename}
      END;
      IF POS ('.', Outfilename) = 0       {he didn't give us extension..}
                                          {..so make it ".uue"}
      THEN Outfilename := CONCAT(Outfilename, DefaultExtension);
      ASSIGN (Outfile, Outfilename);
      WRITELN (' to file ', Outfilename, '.');
      {$I-}
      RESET(Outfile);
      {$I+}
      IF IOResult = 0 THEN BEGIN          {output file exists!}
        WRITE ('Overwrite current ', Outfilename, '? [Y/N] ');
        REPEAT
          Ch := Upcase(ReadKey);
        UNTIL Ch IN ['Y', 'N'];
        WRITELN (Ch);
        IF Ch = 'N' THEN Abort(CONCAT (Outfilename, ' not overwritten.'))
      END;
      {$I-}
      CLOSE(Outfile);
      IF IOResult <> 0 THEN ;  {v1.1 we don't care}
      REWRITE(Outfile);
      {$I+}
      IF IOResult > 0 THEN Abort(CONCAT('Can''t open ', Outfilename));
    END; {of GetFiles}
  BEGIN {Init}
    GetFiles;
    bytesInLine := 0;
    lineLength := 0;
    numbytes := 0;
    WRITELN (Outfile, Header, ' ', Mode, ' ', Infilename);
  END; {init}
{You'll notice from here on we don't do any error-trapping on disk
 read/writes.  We just let DOS do the job.  Any errors are terminal
 anyway, right? }
PROCEDURE FlushLine;
  VAR i: INTEGER;
  PROCEDURE WriteOut(Ch: CHAR);
    BEGIN
      IF Ch = ' ' THEN WRITE(Outfile, '`')
                  ELSE WRITE(Outfile, Ch)
    END; {of WriteOut}
  BEGIN {FlushLine}
    {write ('.');}
    WRITE('bytes remaining: ',remaining:7,' (',
          remaining/size*100.0:3:0,'%)',CHR(13));
    WriteOut(CHR(bytesInLine + OFFSET));
    FOR i := 0 TO PRED(lineLength) DO
      WriteOut(Line[i]);
    WRITELN (Outfile);
    lineLength := 0;
    bytesInLine := 0
  END; {of FlushLine}
PROCEDURE FlushHunk;
  VAR i: INTEGER;
  BEGIN
    IF lineLength = CHARSPERLINE THEN FlushLine;
    chars[0] := hunk[0] ShR 2;
    chars[1] := (hunk[0] ShL 4) + (hunk[1] ShR 4);
    chars[2] := (hunk[1] ShL 2) + (hunk[2] ShR 6);
    chars[3] := hunk[2] AND SIXBITMASK;
    {debug;}
    FOR i := 0 TO 3 DO BEGIN
      Line[lineLength] := CHR((chars[i] AND SIXBITMASK) + OFFSET);
      {write(line[linelength]:2);}
      Inc(lineLength);
    END;
    {writeln;}
    Inc(bytesInLine,numbytes);
    numbytes := 0
  END; {of FlushHunk}
PROCEDURE Encode1;
  BEGIN
    IF numbytes = BYTESPERHUNK THEN FlushHunk;

    READ (Infile, hunk[numbytes]);
    Dec(remaining);
    Inc(numbytes);
  END; {of Encode1}
PROCEDURE Terminate;
  BEGIN
    IF numbytes > 0 THEN FlushHunk;
    IF lineLength > 0 THEN BEGIN
      FlushLine;
      FlushLine;
    END
    ELSE FlushLine;
    WRITELN (Outfile, Trailer);
    CLOSE (Outfile);
    CLOSE (Infile);
  END; {Terminate}
BEGIN {uuencode}
  Init;
  WHILE NOT EOF (Infile) DO Encode1;
  Terminate;
  WRITELN;
END. {uuencode}


