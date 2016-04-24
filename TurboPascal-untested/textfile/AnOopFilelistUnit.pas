(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0013.PAS
  Description: An OOP FILELIST Unit
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:43
*)

PROGRAM FileListDemo;          {FILELIST.PAS}

USES Crt, Printer;

TYPE
  Action = (Input, Output);
  TextObj = OBJECT
    fp : text;
    LineCount : integer;
    EndOfFile : boolean;
    CONSTRUCTOR OpenFile(FileName: string;
                        FileAction: Action);
    PROCEDURE ReadLine(VAR TextLine: string);
    PROCEDURE WriteLine(TextLine: string);
    PROCEDURE PrintLine(TextLine: string);
    PROCEDURE FillBlanks;
    FUNCTION Done: boolean;
    DESTRUCTOR CloseFile;
  END;

CONSTRUCTOR TextObj.OpenFile;
BEGIN
  Assign(fp, FileName);
  CASE FileAction of
    Input:
      BEGIN
        LineCount := 1;
        Reset(fp);
        IF IOResult <> 0 THEN
          BEGIN
            writeln(FileName, ' not found!');
            halt(1);
          END;
        writeln(FileName, ' opened for read...');
      END;
    Output:
      BEGIN
        Rewrite(fp);
        WriteLn(FileName, ' opened for write...');
      END;
  END; {CASE}
END;

DESTRUCTOR TextObj.CloseFile;
BEGIN
  Close(fp);
  WriteLn('File closed...');
END;

PROCEDURE TextObj.ReadLine;
BEGIN
  ReadLn(fp, TextLine);
  EndOfFile := Eof(fp);
END;

PROCEDURE TextObj.WriteLine;
BEGIN
  WriteLn(fp, TextLine);
END;

PROCEDURE TextObj.PrintLine;
BEGIN
  IF not EndOfFile THEN
  BEGIN
    IF TextLine[1] <> '}' THEN
      BEGIN
        WriteLn(lst, TextLine);
        Inc(LineCount);
      END ELSE FillBlanks;
  END;
END;

PROCEDURE TextObj.FillBlanks;
VAR
  i : integer;
BEGIN
  FOR i := LineCount TO 6 DO WriteLn(lst);
  LineCount := 1;
END;

FUNCTION TextObj.Done;
BEGIN
  Done := EndOfFile;
END;

VAR
  InFile: TextObj;
  TextLine: string;

BEGIN
  ClrScr;
  WITH InFile DO
    BEGIN
      OpenFile('DUMMY.DAT', Input);
      REPEAT
        ReadLine(TextLine);
        PrintLine(TextLine);
      UNTIL Done;
      CloseFile;
    END;
  Write('Press Enter to quit...'); ReadLn;
END.

