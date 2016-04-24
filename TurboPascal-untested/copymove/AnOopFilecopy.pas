(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0017.PAS
  Description: An OOP FILECOPY
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:42
*)

PROGRAM FileCopyDemo;         { FILECOPY.PAS }

USES Crt;

TYPE
   Action  = (Input, Output);
   DataBlk = array[1..512] of byte;
   FileObj = OBJECT
     fp : FILE;
     CONSTRUCTOR OpenFile(FileName: string;
                           FileAction: Action);
     PROCEDURE ReadBlock(VAR fb: DataBlk;
                            VAR Size: integer);
     PROCEDURE WriteBlock(fb: DataBlk;
                                size: integer);
     DESTRUCTOR CloseFile;
   END;

CONSTRUCTOR FileObj.OpenFile;
BEGIN
  Assign(fp, FileName);
  CASE FileAction of
    Input: BEGIN
      Reset(fp, 1);
      IF IOResult <> 0 THEN
        BEGIN
          WriteLn(FileName, ' not found!');
          Halt(1);
        END;
        WriteLn(FileName,' opened for read ... ');
      END;
    Output: BEGIN
      Rewrite(fp, 1);
      WriteLn(FileName,' opened for write ... ');
      END;
   END; {CASE}
END;

DESTRUCTOR FileObj.CloseFile;
BEGIN
   Close(fp);
   WriteLn('File closed ...');
END;

PROCEDURE FileObj.ReadBlock;
BEGIN
   BlockRead(fp, fb, SizeOf(fb), Size);
   WriteLn('Reading ', Size, ' bytes ... ');
END;

PROCEDURE FileObj.WriteBlock;
BEGIN
   BlockWrite(fp, fb, Size);
   WriteLn('Writing ', Size, ' bytes ... ');
END;

VAR
   InFile, OutFile : FileObj;
   Data: DataBlk;
   Size: integer;

BEGIN
   ClrScr;
   InFile.OpenFile('FILECOPY.PAS', Input);
   OutFile.OpenFile('FILECOPY.CPY', Output);
   REPEAT
      InFile.ReadBlock(Data, Size);
      OutFile.WriteBlock(Data, Size);
   UNTIL Size <> SizeOf(DataBlk);
   InFile.CloseFile;
   OutFile.CloseFile;
   Write('Press Enter to quit ... ');
   ReadLn;
END.

