(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0129.PAS
  Description: Example of how to read Verison 3.x SWAG
  Author: GAYLE DAVIS
  Date: 02-28-95  10:10
*)

program ReadSwag;
{+$X}
uses Dos,Crt;

type
  SwagHeader =
    RECORD
      HeadSize : BYTE;                  {size of header}
      HeadChk  : BYTE;                  {checksum for header}
      HeadID   : ARRAY [1..5] OF CHAR;  {compression type tag}
      NewSize  : LONGINT;               {compressed size}
      OrigSize : LONGINT;               {original size}
      Time     : WORD;                  {packed time}
      Date     : WORD;                  {packed date}
      Attr     : WORD;                  {file attributes and flags}
      BufCRC   : LONGINT;               {32-CRC of the Buffer }
      Swag     : STRING[12];            {stored SWAG filename}
      Subject  : STRING[40];            {snipet subject}
      Contrib  : STRING[35];            {contributor}
      Keys     : STRING[70];            {search keys, comma deliminated}
      FName    : PathStr;               {filename (variable length)}
      CRC      : WORD;                  {16-bit CRC (immediately follows FName)}
    END;

PROCEDURE SWAGView (LzhFile : PathStr);

VAR

  Swaghead   : Swagheader;
  HeadA      : ARRAY [1..SIZEOF (Swagheader) ] OF BYTE ABSOLUTE Swaghead;
  inFile     : FILE; { File to be processed }
  J, LZHpos  : LONGINT;
  numread, i  : WORD;

FUNCTION Mksum : BYTE;  {calculate check sum For File header }
VAR
  i : INTEGER;
  b : BYTE;
BEGIN
  b := 0;
  FOR i := 3 TO Swaghead.headsize + 2 DO b := b + HeadA [i];
  mksum := b;
END;

PROCEDURE ShowView;
BEGIN
    with Swaghead do
      begin
        writeln('==================================================');
        writeln('Header size = ', HeadSize);
        writeln('compressed size = ', NewSize);
        writeln('stored SWAG filename = ', Swag);
        writeln('snipet subject = ', Subject);
        writeln('Contributor = ', Contrib);
        writeln('Search keys = ', Keys);
        writeln('File name = ', Fname);
      end;
END;

BEGIN

  Assign(infile,LzhFile);
  Reset(infile, 1);

  {Goto start of File}
  LZHPos := 0;

  REPEAT

    { Move to the correct position }
    SEEK (inFile, LZHpos);
    {Read Fileheader}
    BLOCKREAD (inFile, HeadA, SIZEOF (Swagheader), numread);
    { get the position of the next header }
    LZHpos := LZHpos + Swaghead.headsize + 2 + Swaghead.Newsize;
    { check the checksum }
    i := Mksum;

    IF Swaghead.headsize <> 0 THEN
    BEGIN
      IF i <> Swaghead.headchk THEN
      BEGIN
        { ERROR : FORMAT ERROR !! }
        CLOSE (infile);
        EXIT;
      END;
    ShowView;
    END;

  UNTIL   (Swaghead.headsize = 0);

  CLOSE (infile);

END;

BEGIN
    SwagView('d:\swag\files\oop.swg');
END.
