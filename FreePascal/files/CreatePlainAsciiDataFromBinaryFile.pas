(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0095.PAS
  Description: Create plain ASCII data from binary file
  Author: DIRK SCHWARZMANN
  Date: 11-29-96  08:17
*)


PROGRAM BinToInclude; (* Version 1.0, 12.10.96 *)

(*

   Author: Dirk "Rob!" Schwarzmann, (w) September 1996, Germany

   E-Mail: rob@rbg.informatik.th-darmstadt.de

   WWW   : http://www.student.informatik.th-darmstadt.de/~rob/


   About this small piece of code:

   This program reads any type of file and writes it back as a include
   file  (text type for TurboPascal) where every byte read is written as
   its value. So, if a .com file is read and byte #x is an @, BinToInclude
   will write the number 64 for it.

   In addition, it creates a header so that you can use the new data
   file directly as an include file in your own programs. The binary file
   is stored as an array of byte and you can write it back to disc by using
   the small procedure shown below.

   What's it all good for?

   You can hold binary files of _any_ type in your own program and do not
   have to take care that an external data (or program) file is truly there.
   If it does not exist, you simple write it! No panic, if a user has
   accidently deleted a file or a file is corrupted!

   Using this program:

   You have to specify at least one command line parameter giving the file
   you like to read. If no second parameter (the target file name) is given,
   BinToInclude will create an .INC file with the path and name similar to
   the source file. Otherwise the given name is used.
   Note that BinToInclude does very little error checking! It does not
   assure that the source file exists nor does it prevent you from over-
   writing existing include files! But because this program is only a small
   quick-hacked utility for programmers, I guess this not very important.
   If you include a file in your program, keep in mind that you may get
   problems if you include files bigger than 64k!

   There a some constants you can only change in this source code;

    - COMPRESSED is a boolean flag and toggles the writing of data between
      the well-to-read format:
        001, 020, 234, 089, ...
      and the space-saving format:
        1, 20, 234, 89, ...
      If you want to save even the blanks between comma and numbers, get
      your editor, mark the whole area and do a search + replace. It's
      that simple! It would have taken much more effort to do this here.

    - ArrayFormat
      Specify the number of rows the array definition should use. 65 - 70
      rows are a good choice to keep a good readability.

    - Ext2_Str
      Here you can change the default data file suffix - but I think there
      is no need to do so.

   To write the data back in a file, you only need this small routine:

     PROCEDURE WriteArrayToFile(TargetName:FILE OF BYTE);

     VAR
       i : LONGINT;

     BEGIN
       Assign(TargetFile,TargetName);
       Rewrite(TargetFile);
       FOR i := 1 TO BinFileSize DO
         Write(TargetFile,BinFile[i]);
       Close(TargetFile);
     END;

   That's all!

   For any suggestions, please feel free to email me!

 *)

USES DOS;

CONST
  Compressed : BOOLEAN = FALSE; (* False: 010, 009, 255, ...
                                   True: 10, 9, 255,...
                                   If you want to have 10,9,255 you can
                                   remove the blanks with search +
replace
                                   in your editor! *)

  ArrayFormat : BYTE = 65; (* The width of the array definition area
                              (number of rows) *)

  Ext2_Str : ExtStr = '.INC'; (* The default suffix for the file to write *)

  (* These lines are the header of the written include-file. After the
     variable "BinFileSize =" the program will insert the file length
     (=array length) and after the last header line the data will  follow. *)

  IncHeader1 : STRING = 'CONST';
  IncHeader2 : STRING = '  BinFileSize = ';
  IncHeader3 : STRING = '  BinFile : ARRAY[1..BinFileSize] OF BYTE = (';

VAR (* main.BinToInclude *)
  SourceFile : FILE OF BYTE;
  TargetFile : TEXT;
  SourceName : STRING[128];
  TargetName : STRING[128];
  SourceByte : BYTE;
  TgtByteStr : STRING[5];
  TargetStr : STRING[80];
  Dir_Str : DirStr;
  Name_Str : NameStr;
  Ext_Str : ExtStr;

BEGIN (* main.BinToInclude *)
  (* The case statement is only to parse the command line: *)
  CASE ParamCount OF
    1: BEGIN
      FSplit(FExpand(ParamStr(1)),Dir_Str,Name_Str,Ext_Str);
      SourceName := Dir_Str + Name_Str + Ext_Str;
      TargetName := Dir_Str + Name_Str + Ext2_Str;
    END; (* case ParamCount of 1 *)
    2: BEGIN
      FSplit(FExpand(ParamStr(1)),Dir_Str,Name_Str,Ext_Str);
      SourceName := Dir_Str + Name_Str + Ext_Str;
      FSplit(FExpand(ParamStr(2)),Dir_Str,Name_Str,Ext_Str);
      TargetName := Dir_Str + Name_Str + Ext_Str;
    END; (* case ParamCount of 2 *)
  ELSE (* case ParamCount *)
    WriteLn('Please specify at least one Parameter as the source file.');
    Write('If the optional second one is not given, <Source file>.INC is');
    WriteLn(' assumed.');
    Halt(1);
  END; (* case ParamCount *)

  Assign(SourceFile,SourceName);
  Reset(SourceFile);
  Assign(TargetFile,TargetName);
  Rewrite(TargetFile);
  WriteLn(TargetFile,IncHeader1);
  WriteLn(TargetFile,IncHeader2,FileSize(SourceFile),';');
  WriteLn(TargetFile,IncHeader3);
  TargetStr := '    '; (* Set the left margin *)
  Inc(ArrayFormat,2); (* This needs an explanation: because of the 4 blanks
                         on the left margin, we should add 4 to ArrayFormat.
                         But as every number will be followed by a comma
                         and a blank, we have to decrease it by 2. -> add 2 *)
  WHILE NOT EoF(SourceFile) DO BEGIN
    Read(SourceFile,SourceByte);
    Str(Ord(SourceByte),TgtByteStr);
    IF NOT Compressed THEN
      TgtByteStr := Copy('00',1,3-Length(TgtByteStr)) + TgtByteStr;
    IF (Length(TargetStr) + Length(TgtByteStr) > ArrayFormat) THEN BEGIN
      WriteLn(TargetFile,TargetStr); (* Flush the string *)
      TargetStr := '    ';
    END;
    TargetStr := TargetStr + TgtByteStr + ', ';
  END; (* while not EoF(SourceFile) *)
  (* Flush the buffer string but don't write the last comma: *)
  Write(TargetFile,Copy(TargetStr,1,Length(TargetStr)-2));
  WriteLn(TargetFile,');'); (* Close the array definition with the ")"
  *)
  Close(TargetFile);
  Close(SourceFile);
END. (* main.BinToInclude *)

