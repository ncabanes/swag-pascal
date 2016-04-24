(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0040.PAS
  Description: Deleting Chars from Files
  Author: TOM CARROLL
  Date: 01-27-94  11:57
*)

{
> A friend of mine has a small problem with Binkley connecting, and whenever
> this happens, Binkley writes a bunch of Line noise characters in his log f
> Some of these characters are EOF and EOL markers. I am trying to write a s
> program that will read it, and write the contents to a new file, without a
> the garbage in it. Of course, when I get to the first EOF, my program thin
> it's done.
}

Program KillChar;

{ Written by Tom Carroll and released to the public domain
  on 12/11/93.

 This program will read any file and delete any characters passed on
  the command line.

  For example:  KillChar InFile OutFile ASCII Value (of character)

         i.e.:  KILLCHAR MYFILE.TXT NEWFILE.TXT 12

  This will remove all form feeds from a text file.

  No error control is included.

}

VAR
   Buffer    : ARRAY[0..255] OF Char;
   TmpString,
   StringVar : STRING;
   FileLoc,
   NumBytes  : LongInt;
   InFile,
   OutFile   : FILE;
   NumRead   : Integer;
   StringPos : Integer;

BEGIN
   Val(ParamStr(3), NumRead, StringPos);
   TmpString := Chr(NumRead); {#26;}
   Assign(InFile, ParamStr(1));
   Reset(InFile, 1);
   Assign(OutFile, ParamStr(2));
   Rewrite(OutFile, 1);
   NumBytes := FileSize(InFIle);
   WHILE FilePos(InFile) < NumBytes DO
      BEGIN
         FileLoc := FilePos(InFile);
         IF FileLoc < (NumBytes - 255) THEN
            BlockRead(InFile, Buffer, 255, NumRead)
         ELSE
            BlockRead(InFile, Buffer, FileSize(InFile) - FileLoc,
                      NumRead);
         Move(Buffer[0], StringVar[1], NumRead);
         StringVar[0] := Chr(NumRead);
         StringPos := Pos(TmpString, StringVar);
         WHILE StringPos > 0 DO
            BEGIN
               StringPos := Pos(TmpString, StringVar);
               Delete(StringVar, StringPos, 1);
            END;
         StringPos := Length(StringVar);
         Move(StringVar[1], Buffer, Length(StringVar));
         BlockWrite(OutFile, Buffer, Length(StringVar));
      END;
   Close(InFile);
   Close(OutFIle);
END.

